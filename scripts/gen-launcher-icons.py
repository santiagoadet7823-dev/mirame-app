#!/usr/bin/env python3
"""Genera los iconos de launcher Android a partir de assets/brand/logo-mirame.jpg.

PROVISIONAL. El brief (11-BRIEF-DISENADOR.md, punto 1) pide arte final del
diseniador: adaptive icon con foreground disenado para la zona segura y un
monochrome para Android 13+. Lo que hay hoy es un boceto sin PNG exportados,
asi que esto deriva un icono aceptable del logo para poder compilar y probar
el APK. Cuando llegue el arte final, se reemplaza y se borra este script.

Uso:  python android/scripts/gen-launcher-icons.py
"""
from pathlib import Path
from PIL import Image

RAIZ = Path(__file__).resolve().parents[1] / 'app_flutter'
LOGO = RAIZ / 'assets/brand/logo-mirame.jpg'
RES = RAIZ / 'android/app/src/main/res'

CREMA = (250, 248, 245, 255)          # --bg del design system
EMBLEMA = (305, 72, 1146, 965)        # bbox del contenido en el JPG original

# densidad -> (px del icono legacy, px del foreground adaptativo 108dp)
DENSIDADES = {
    'mdpi': (48, 108), 'hdpi': (72, 162), 'xhdpi': (96, 216),
    'xxhdpi': (144, 324), 'xxxhdpi': (192, 432),
}


def emblema_cuadrado() -> Image.Image:
    em = Image.open(LOGO).convert('RGBA').crop(EMBLEMA)
    w, h = em.size
    lado = max(w, h)
    lienzo = Image.new('RGBA', (lado, lado), (0, 0, 0, 0))
    lienzo.paste(em, ((lado - w) // 2, (lado - h) // 2))
    return lienzo


def sobre_crema(em: Image.Image, px: int, ocupacion: float) -> Image.Image:
    """Emblema centrado sobre el fondo crema, ocupando `ocupacion` del lado."""
    fondo = Image.new('RGBA', (px, px), CREMA)
    lado = max(1, int(px * ocupacion))
    escalado = em.resize((lado, lado), Image.LANCZOS)
    fondo.paste(escalado, ((px - lado) // 2, (px - lado) // 2), escalado)
    return fondo


def transparente(em: Image.Image, px: int, ocupacion: float) -> Image.Image:
    lienzo = Image.new('RGBA', (px, px), (0, 0, 0, 0))
    lado = max(1, int(px * ocupacion))
    escalado = em.resize((lado, lado), Image.LANCZOS)
    lienzo.paste(escalado, ((px - lado) // 2, (px - lado) // 2), escalado)
    return lienzo


def main() -> None:
    em = emblema_cuadrado()
    for densidad, (px_icono, px_fg) in DENSIDADES.items():
        destino = RES / f'mipmap-{densidad}'
        destino.mkdir(parents=True, exist_ok=True)
        # Legacy: 88% deja un margen para que el recorte del launcher no coma
        # las hojas del emblema.
        sobre_crema(em, px_icono, 0.88).save(destino / 'ic_launcher.png')
        sobre_crema(em, px_icono, 0.88).save(destino / 'ic_launcher_round.png')
        # Adaptativo: el launcher recorta hasta el 66% central del lienzo de
        # 108dp. Si el emblema ocupa mas, pierde las hojas y el borde del
        # circulo en los launchers que usan mascara circular.
        transparente(em, px_fg, 0.62).save(destino / 'ic_launcher_foreground.png')
        print(f'{densidad}: {px_icono}px legacy + {px_fg}px foreground')


if __name__ == '__main__':
    main()


def iconos_web() -> None:
    """Iconos de la PWA. Sin esto el manifest usa los de plantilla de Flutter,
    y al instalar aparece una app llamada 'mirame' con el logo de Flutter."""
    em = emblema_cuadrado()
    web = RAIZ / 'web'
    (web / 'icons').mkdir(parents=True, exist_ok=True)
    for px in (192, 512):
        # Normal: con margen, como se ve en un listado.
        sobre_crema(em, px, 0.88).convert('RGB').save(
            web / f'icons/Icon-{px}.png')
        # Maskable: el sistema recorta hasta el 80% central, asi que el
        # emblema tiene que ocupar menos o pierde las hojas.
        sobre_crema(em, px, 0.62).convert('RGB').save(
            web / f'icons/Icon-maskable-{px}.png')
    sobre_crema(em, 32, 0.9).convert('RGB').save(web / 'favicon.png')
    print('iconos web: 192, 512, maskable y favicon')
