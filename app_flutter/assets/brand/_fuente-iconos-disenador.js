
const P = (d, extra) => ({ d, ...extra });

const ICONS = {
  // acciones rápidas
  nuevoTurno: ['M3 6.5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2V19a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z','M8 2.5v4','M16 2.5v4','M3 10h18','M12 13v5','M9.5 15.5h5'],
  nuevaClienta: ['M9 11.5a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z','M2 21v-1.2A5.8 5.8 0 0 1 7.8 14h2.4a5.8 5.8 0 0 1 5.3 3.4','M19 14v6','M16 17h6'],
  registrarPago: ['M2.5 6.5a2 2 0 0 1 2-2h15a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-15a2 2 0 0 1-2-2z','M12 14a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z','M6 8.5v0','M18 13.5v0','M6 20.5h12'],
  estadisticas: ['M3.5 20.5h17','M7 20.5v-6','M12 20.5V8','M17 20.5v-9'],
  // estados vacíos
  sinTurnos: ['M3 6.5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2V19a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z','M8 2.5v4','M16 2.5v4','M3 10h18','M9 15h6'],
  sinClientas: ['M12 11.5a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z','M4.5 21v-1.2A5.8 5.8 0 0 1 10.3 14h3.4a5.8 5.8 0 0 1 5.8 5.8V21','M3 3l18 18'],
  sinProductos: ['M20.5 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 2.5 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 20.5 16Z','M9 12h6'],
  sinMovimientos: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z','M8.5 12h7'],
  // stock
  adhesivos: ['M9.5 2.5h5v3h-5z','M8 5.5h8l1 3.5v9.5a3 3 0 0 1-3 3h-4a3 3 0 0 1-3-3V9z','M12 12.5c-1.2 1.4-2 2.4-2 3.4a2 2 0 0 0 4 0c0-1-.8-2-2-3.4Z'],
  pestanas: ['M2.5 13.5c2.6-3.9 5.9-5.8 9.5-5.8s6.9 1.9 9.5 5.8','M12 17.2a3.4 3.4 0 1 0 0-6.8 3.4 3.4 0 0 0 0 6.8Z','M4.5 8.5 3 5.5','M12 6.6V3.4','M19.5 8.5 21 5.5','M8 7.2 6.9 4.4','M16 7.2 17.1 4.4'],
  removedores: ['M8.5 2.5h7','M10 2.5v3.6L7.4 11a4.5 4.5 0 0 0-.4 1.9v5.6a3 3 0 0 0 3 3h4a3 3 0 0 0 3-3v-5.6a4.5 4.5 0 0 0-.4-1.9L14 6.1V2.5','M7 14.5h10'],
  primers: ['M13.5 2.5 8 8a5.5 5.5 0 0 0 7.8 7.8l5.5-5.5','M11 5l5.5 5.5','M6 21.5a2.2 2.2 0 0 0 2.2-2.2c0-1.2-2.2-3.6-2.2-3.6s-2.2 2.4-2.2 3.6A2.2 2.2 0 0 0 6 21.5Z'],
  herramientas: ['M7 2.5 11.4 13','M17 2.5 12.6 13','M12 13v4.5','M12 21.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z','M5.5 5.5 8.5 4.2','M18.5 5.5 15.5 4.2'],
  limpieza: ['M9.5 2.5h4v3.5h-4z','M8 6h7a3 3 0 0 1 3 3v9.5a3 3 0 0 1-3 3H9a3 3 0 0 1-3-3V9a3 3 0 0 1 2-2.8','M18 9h3.5','M21.5 5.5v7','M9 11h5'],
  otrosStock: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z','M8 12v0','M12 12v0','M16 12v0'],
  // caja
  servicio: ['M12 2.5 13.9 8 19.5 10 13.9 12 12 17.5 10.1 12 4.5 10 10.1 8Z','M18.5 15.5 19.4 18l2.6.9-2.6.9-.9 2.6-.9-2.6-2.6-.9 2.6-.9Z','M5 16v3','M3.5 17.5h3'],
  productos: ['M5 8h14l1 12.5a1 1 0 0 1-1 1.1H5a1 1 0 0 1-1-1.1Z','M8.5 10.5V7a3.5 3.5 0 1 1 7 0v3.5'],
  insumos: ['M2.5 8.5 12 5l9.5 3.5-9.5 3.5Z','M2.5 8.5v8L12 20l9.5-3.5v-8','M12 12v8'],
  alquiler: ['M3.5 10.5 12 3.5l8.5 7','M5.5 12v8.5h13V12','M9.5 20.5v-5.5h5v5.5'],
  sueldos: ['M3 8.5a2 2 0 0 1 2-2h13a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2Z','M3 10.5h17','M16.5 15h1.5','M6 4.5h10'],
  marketing: ['M4 10.5v3a1.5 1.5 0 0 0 1.5 1.5H8l7 4.5V6L8 10.5H5.5A1.5 1.5 0 0 0 4 12','M18.5 9a4.5 4.5 0 0 1 0 6','M7.5 15v4a1.5 1.5 0 0 0 3 0v-2.5'],
  impuestos: ['M6 2.5h8.5L19 7v14.5H6z','M14 2.5V7h5','M9.5 11.5v0','M14.5 16.5v0','M15 11 9 17'],
  mantenimiento: ['M15.5 3.2a5 5 0 0 0-5.9 6.6L3 16.4a2 2 0 0 0 2.8 2.8l6.6-6.6a5 5 0 0 0 6.6-5.9l-3 3-2.8-.7-.7-2.8Z'],
  otrosCaja: ['M4 6.5h16','M4 12h16','M4 17.5h9'],
  // estados de turno
  confirmado: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z','m8 12 2.8 2.8L16 9.6'],
  pendiente: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z','M12 7v5.2l3.2 2'],
  completado: ['m2.5 12.6 3 3','m8 12.6 3 3 8-8.4','m13 7.2 1.6-1.7'],
  cancelado: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z','m9.2 9.2 5.6 5.6','m14.8 9.2-5.6 5.6'],
  // pagos
  efectivo: ['M2.5 7.5a2 2 0 0 1 2-2h15a2 2 0 0 1 2 2v7a2 2 0 0 1-2 2h-15a2 2 0 0 1-2-2Z','M12 13.5a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5Z','M5.5 20h13'],
  transferencia: ['M3.5 8.5h14','m14 5-3.5 3.5L14 12','M20.5 15.5h-14','m10 12 3.5 3.5L10 19'],
  tarjeta: ['M2.5 7.5a2 2 0 0 1 2-2h15a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-15a2 2 0 0 1-2-2Z','M2.5 10.5h19','M6 15h3.5'],
  // ajustes
  cerrarSesion: ['M9.5 3.5H6a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2h3.5','m15.5 8 4 4-4 4','M19.5 12H9'],
  nombreEstudio: ['M4 9.5V20a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V9.5','M3 9.5 4.8 4a1 1 0 0 1 .95-.7h12.5a1 1 0 0 1 .95.7L21 9.5a3 3 0 0 1-5.7 1.3 3 3 0 0 1-5.7 0A3 3 0 0 1 3 9.5Z','M9.5 21v-5.5h5V21'],
  profesionales: ['M9 11a3.6 3.6 0 1 0 0-7.2A3.6 3.6 0 0 0 9 11Z','M2 20.5v-1a5.5 5.5 0 0 1 5.5-5.5h3A5.5 5.5 0 0 1 16 19.5v1','M16 4.2a3.6 3.6 0 0 1 0 6.9','M18 14.3a5.5 5.5 0 0 1 4 5.2v1'],
  servicios: ['M9 6.5h12','M9 12h12','M9 17.5h8','M4 6.5v0','M4 12v0','M4 17.5v0'],
  exportar: ['M12 15.5V3.5','m8 7.5 4-4 4 4','M4 14.5v4a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-4'],
  importar: ['M12 3.5v12','m8 11.5 4 4 4-4','M4 14.5v4a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-4'],
  autoBackup: ['M7 18.5a4.5 4.5 0 0 1-.6-8.96A5.5 5.5 0 0 1 17.2 9.6 4 4 0 0 1 17 18.5Z','M12 20.5v-7','m9.5 15.5 2.5-2.5 2.5 2.5'],
  instalarApp: ['M6 4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2Z','M10 19h4','M12 6.5v6','m9.8 10.3 2.2 2.2 2.2-2.2'],
  version: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z','M12 8v0','M12 11.5V16'],
  // varios
  recordatorio: ['M18 8.5a6 6 0 1 0-12 0c0 6.5-2.5 8.5-2.5 8.5h17S18 15 18 8.5','M13.7 20.5a2 2 0 0 1-3.4 0','M19.5 2.5l.7 2 2 .7-2 .7-.7 2-.7-2-2-.7 2-.7Z'],
  sincronizacion: ['M20.5 12a8.5 8.5 0 0 1-14.4 6.1','M3.5 12A8.5 8.5 0 0 1 18 5.9','M18 2.5v3.5h-3.5','M6 21.5V18h3.5'],
  alerta: ['M10.3 3.6 2.6 17a2 2 0 0 0 1.7 3h15.4a2 2 0 0 0 1.7-3L13.7 3.6a2 2 0 0 0-3.4 0Z','M12 9.5v4','M12 17v0'],
  exito: ['M12 20.5a8.5 8.5 0 1 0 0-17 8.5 8.5 0 0 0 0 17Z','m8.3 12.2 2.6 2.6 4.8-5.2','M20 3.5l.55 1.6 1.6.55-1.6.55L20 7.8l-.55-1.6-1.6-.55 1.6-.55Z'],
  error: ['M8.4 2.6h7.2l5.8 5.8v7.2l-5.8 5.8H8.4l-5.8-5.8V8.4Z','m9.4 9.4 5.2 5.2','m14.6 9.4-5.2 5.2'],
  informacion: ['M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z','M12 16v-4.5','M12 8v0']
};

const GROUPS = [
  { title: 'Acciones rápidas', keys: [['nuevoTurno','Nuevo turno'],['nuevaClienta','Nueva clienta'],['registrarPago','Registrar pago'],['estadisticas','Estadísticas']] },
  { title: 'Estados vacíos', keys: [['sinTurnos','Sin turnos'],['sinClientas','Sin clientas'],['sinProductos','Sin productos'],['sinMovimientos','Sin movimientos']] },
  { title: 'Categorías de stock', keys: [['adhesivos','Adhesivos'],['pestanas','Pestañas'],['removedores','Removedores'],['primers','Primers'],['herramientas','Herramientas'],['limpieza','Limpieza'],['otrosStock','Otros']] },
  { title: 'Categorías de caja', keys: [['servicio','Servicio'],['productos','Productos'],['insumos','Insumos'],['alquiler','Alquiler'],['sueldos','Sueldos'],['marketing','Marketing'],['impuestos','Impuestos'],['mantenimiento','Mantenimiento'],['otrosCaja','Otros']] },
  { title: 'Estados de turno', keys: [['confirmado','Confirmado'],['pendiente','Pendiente'],['completado','Completado'],['cancelado','Cancelado']] },
  { title: 'Métodos de pago', keys: [['efectivo','Efectivo'],['transferencia','Transferencia'],['tarjeta','Tarjeta']] },
  { title: 'Ajustes', keys: [['cerrarSesion','Cerrar sesión'],['nombreEstudio','Nombre del estudio'],['profesionales','Profesionales'],['servicios','Servicios'],['exportar','Exportar'],['importar','Importar'],['autoBackup','Auto-backup'],['instalarApp','Instalar app'],['version','Versión']] },
  { title: 'Varios', keys: [['recordatorio','Recordatorio de retoque'],['sincronizacion','Sincronización'],['alerta','Alerta'],['exito','Éxito'],['error','Error'],['informacion','Información']] }
];

class Component extends DCLogic {
  icon(key, size, color, sw) {
    const paths = ICONS[key] || [];
    return React.createElement('svg', {
      width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
      stroke: color || 'currentColor', strokeWidth: sw || this.sw(),
      strokeLinecap: 'round', strokeLinejoin: 'round'
    }, paths.map((d, i) => React.createElement('path', { key: i, d })));
  }
  sw() { return this.props.strokeWidth ?? 1.8; }

  emptyIll(kind) {
    const lav = '#c4b8f8', deep = '#8b77ec', nude = '#e4a898', soft = '#f0c4b8';
    const base = { fill: 'none', strokeWidth: 1.6, strokeLinecap: 'round', strokeLinejoin: 'round' };
    const el = (t, p) => React.createElement(t, p);
    const wrap = (kids) => React.createElement('svg', { width: 120, height: 120, viewBox: '0 0 120 120', fill: 'none' },
      el('circle', { cx: 60, cy: 60, r: 46, fill: 'url(#g' + kind + ')' }),
      React.createElement('defs', null, React.createElement('linearGradient', { id: 'g' + kind, x1: 0, y1: 0, x2: 1, y2: 1 },
        React.createElement('stop', { offset: '0%', stopColor: '#f5f3ff' }),
        React.createElement('stop', { offset: '100%', stopColor: '#fdf0ec' }))),
      kids);
    const K = {
      agenda: [
        el('rect', { key: 1, x: 36, y: 40, width: 48, height: 44, rx: 8, stroke: deep, ...base }),
        el('path', { key: 2, d: 'M36 54h48', stroke: deep, ...base }),
        el('path', { key: 3, d: 'M48 34v10M72 34v10', stroke: deep, ...base }),
        el('path', { key: 4, d: 'M46 66h12M46 74h20', stroke: soft, ...base, strokeWidth: 2.4 }),
        el('path', { key: 5, d: 'M92 32l1.6 4.6 4.6 1.6-4.6 1.6L92 44.4l-1.6-4.6-4.6-1.6 4.6-1.6Z', stroke: nude, ...base })
      ],
      clientas: [
        el('circle', { key: 1, cx: 60, cy: 50, r: 12, stroke: deep, ...base }),
        el('path', { key: 2, d: 'M38 84v-4a16 16 0 0 1 16-16h12a16 16 0 0 1 16 16v4', stroke: deep, ...base }),
        el('path', { key: 3, d: 'M30 44a8 8 0 0 1 8-8M90 44a8 8 0 0 0-8-8', stroke: soft, ...base, strokeWidth: 2.2 }),
        el('path', { key: 4, d: 'M60 26c-2 3-3 4.6-3 6a3 3 0 0 0 6 0c0-1.4-1-3-3-6Z', stroke: nude, ...base })
      ],
      productos: [
        el('path', { key: 1, d: 'M60 32 88 42 60 52 32 42Z', stroke: deep, ...base }),
        el('path', { key: 2, d: 'M32 42v24l28 10 28-10V42', stroke: deep, ...base }),
        el('path', { key: 3, d: 'M60 52v24', stroke: deep, ...base }),
        el('path', { key: 4, d: 'M44 70v8M76 70v8', stroke: soft, ...base, strokeWidth: 2.2 }),
        el('circle', { key: 5, cx: 92, cy: 32, r: 4, stroke: nude, ...base })
      ],
      movimientos: [
        el('path', { key: 1, d: 'M34 78h52', stroke: deep, ...base }),
        el('path', { key: 2, d: 'M42 78V62M58 78V54M74 78V68', stroke: deep, ...base, strokeWidth: 3.2 }),
        el('path', { key: 3, d: 'M36 44h20m-6-6 6 6-6 6', stroke: nude, ...base }),
        el('path', { key: 4, d: 'M84 34H64m6-6-6 6 6 6', stroke: soft, ...base, strokeWidth: 2.2 })
      ]
    };
    return wrap(K[kind]);
  }

  renderVals() {
    const color = this.props.iconColor ?? '#7459d9';
    const groups = GROUPS.map(g => ({
      title: g.title,
      count: g.keys.length + ' íconos',
      icons: g.keys.map(([k, label]) => ({ key: k, label, node: this.icon(k, 24, color) }))
    }));
    const empties = [
      { title: 'Agenda vacía', sub: 'Todavía no hay turnos para este día.', node: this.emptyIll('agenda') },
      { title: 'Sin clientas', sub: 'Cargá tu primera clienta para empezar.', node: this.emptyIll('clientas') },
      { title: 'Sin productos', sub: 'Tu stock está vacío por ahora.', node: this.emptyIll('productos') },
      { title: 'Sin movimientos', sub: 'No hay ingresos ni gastos este mes.', node: this.emptyIll('movimientos') }
    ];
    return {
      groups, empties,
      specimenBig: [16, 24, 32, 48].map((s, i) =>
        React.createElement('span', { key: i, style: { color: '#5f45be', display: 'flex' } }, this.icon('pestanas', s, undefined, 1.8))),
      specimenColors: ['#1a1612', '#8b77ec', '#d4897a', '#c4bdb5'].map((c, i) =>
        React.createElement('span', { key: i, style: { display: 'flex' } }, this.icon('confirmado', 26, c)))
    };
  }
}
