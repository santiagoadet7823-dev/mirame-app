// Fan-out de notificaciones push contra la API HTTP v1 de FCM.
//
// Vive en el servidor porque necesita la service account de Firebase, que NO
// puede estar en el cliente: con ella se le puede mandar una notificación a
// cualquier dispositivo de la plataforma.
//
// Secrets requeridos (Supabase > Edge Functions > Secrets):
//   FIREBASE_SERVICE_ACCOUNT  el JSON completo de la service account
//   SUPABASE_SERVICE_ROLE_KEY para leer device_tokens salteando RLS
//
// Body:
//   { tenant_id?: uuid, user_ids?: uuid[], titulo, cuerpo, ir_a? }
// Uno de `tenant_id` o `user_ids` es obligatorio. `ir_a` es la sección que
// abre la app al tocar la notificación ('agenda' | 'caja' | 'stock' | …).

import { createClient } from 'jsr:@supabase/supabase-js@2'

const FCM = 'https://fcm.googleapis.com/v1/projects'

/// Token OAuth2 de la service account, firmando un JWT a mano. Se pide uno por
/// invocación: dura una hora y una Edge Function no sobrevive tanto, así que
/// cachearlo entre llamadas no ahorraría nada.
async function accessToken(sa: Record<string, string>): Promise<string> {
  const ahora = Math.floor(Date.now() / 1000)
  const claim = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: ahora,
    exp: ahora + 3600,
  }

  const b64 = (o: unknown) =>
    btoa(JSON.stringify(o)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
  const cabeza = b64({ alg: 'RS256', typ: 'JWT' })
  const cuerpo = b64(claim)

  const pem = sa.private_key
    .replace(/-----[A-Z ]+-----/g, '')
    .replace(/\s/g, '')
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0))
  const clave = await crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  )
  const firma = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    clave,
    new TextEncoder().encode(`${cabeza}.${cuerpo}`),
  )
  const jwt = `${cabeza}.${cuerpo}.${
    btoa(String.fromCharCode(...new Uint8Array(firma)))
      .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
  }`

  const r = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })
  const j = await r.json()
  if (!j.access_token) throw new Error(`OAuth de FCM falló: ${JSON.stringify(j)}`)
  return j.access_token
}

Deno.serve(async (req) => {
  try {
    const { tenant_id, user_ids, titulo, cuerpo, ir_a } = await req.json()
    if (!titulo || (!tenant_id && !user_ids?.length)) {
      return new Response('falta tenant_id/user_ids o titulo', { status: 400 })
    }

    const db = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )
    let q = db.from('device_tokens').select('token')
    q = tenant_id ? q.eq('tenant_id', tenant_id) : q.in('user_id', user_ids)
    const { data: filas, error } = await q
    if (error) throw error

    const sa = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!)
    const bearer = await accessToken(sa)
    const url = `${FCM}/${sa.project_id}/messages:send`

    const invalidos: string[] = []
    let enviados = 0

    for (const { token } of filas ?? []) {
      const r = await fetch(url, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${bearer}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title: titulo, body: cuerpo ?? '' },
            data: ir_a ? { ir_a } : {},
            android: { priority: 'high' },
          },
        }),
      })
      if (r.ok) enviados++
      // 404 = el token murió (app desinstalada, datos borrados). Si no se
      // limpian, la tabla se llena de tokens muertos y cada envío se hace más
      // lento para siempre.
      else if (r.status === 404) invalidos.push(token)
    }

    if (invalidos.length) {
      await db.from('device_tokens').delete().in('token', invalidos)
    }

    return Response.json({ enviados, limpiados: invalidos.length })
  } catch (e) {
    return new Response(`${e}`, { status: 500 })
  }
})
