/// Lecturas y escrituras del módulo de ropa.
///
/// Mismas reglas que `business_repository.dart`: la UI lee de Drift y nunca
/// espera a la red; toda escritura va a Drift **y** al `outbox` en la misma
/// transacción, para que un cierre de app entre las dos no deje un cambio
/// local que nunca sube.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Con prefijo: Drift genera clases con los MISMOS nombres (`Producto`,
// `Deposito`) a partir de las tablas. Sin el prefijo, cada tipo taparia al
// otro segun el orden de los imports.
import '../../domain/entities/ropa.dart' as dom;
import '../../domain/rules/consignacion.dart';
import '../../domain/rules/period.dart';
import '../local/database.dart';
import '../sync/sync_engine.dart';
import 'business_repository.dart'
    show BusinessRepository, businessRepoProvider, nuevoId;

class RopaRepository {
  const RopaRepository(this._db, this._sync, this._tenantId, this._negocio);

  final MirameDb _db;
  final SyncEngine _sync;
  final String _tenantId;

  /// Se usa para que una venta impacte en la caja SIN que la pantalla tenga
  /// que acordarse de cargarla. Si eso dependiera de la UI, el dia que se
  /// agregue una segunda forma de vender (el vendedor desde su telefono) la
  /// mitad de las ventas no llegaria a la caja.
  final BusinessRepository _negocio;

  String get tenantId => _tenantId;

  // ── Lecturas ────────────────────────────────────────────────────────────

  Stream<List<Proveedore>> verProveedores() => (_db.select(_db.proveedores)
        ..where((p) => p.tenantId.equals(_tenantId) & p.deletedAt.isNull())
        ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
      .watch();

  Stream<List<Deposito>> verDepositos() => (_db.select(_db.depositos)
        ..where((d) => d.tenantId.equals(_tenantId) & d.deletedAt.isNull())
        ..orderBy([
          // El principal primero: es donde está casi todo y donde se carga
          // por defecto.
          (d) => OrderingTerm.desc(d.esPrincipal),
          (d) => OrderingTerm.asc(d.nombre),
        ]))
      .watch();

  Stream<List<Producto>> verProductos() => (_db.select(_db.productos)
        ..where((p) => p.tenantId.equals(_tenantId) & p.deletedAt.isNull())
        ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
      .watch();

  Stream<List<ProductoVariante>> verVariantes() =>
      (_db.select(_db.productoVariantes)
            ..where((v) => v.tenantId.equals(_tenantId) & v.deletedAt.isNull()))
          .watch();

  /// Variantes agrupadas por producto, que es como las consume la ficha.
  Stream<Map<String, List<ProductoVariante>>> verVariantesPorProducto() =>
      verVariantes().map((filas) {
        final out = <String, List<ProductoVariante>>{};
        for (final v in filas) {
          (out[v.productoId] ??= []).add(v);
        }
        return out;
      });

  Stream<List<StockVariante>> verStock() => (_db.select(_db.stockVariantes)
        ..where((s) => s.tenantId.equals(_tenantId) & s.deletedAt.isNull()))
      .watch();

  /// Cuánto hay de cada variante, sumando todos los depósitos.
  Stream<Map<String, int>> verStockPorVariante() => verStock().map((filas) {
        final out = <String, int>{};
        for (final s in filas) {
          out[s.varianteId] = (out[s.varianteId] ?? 0) + s.cantidad;
        }
        return out;
      });

  Stream<List<ProductoFoto>> verFotos() => (_db.select(_db.productoFotos)
        ..where((f) => f.tenantId.equals(_tenantId) & f.deletedAt.isNull())
        ..orderBy([(f) => OrderingTerm.asc(f.orden)]))
      .watch();

  /// La primera foto de cada producto — la que va en la grilla del catálogo.
  Stream<Map<String, ProductoFoto>> verPortadas() => verFotos().map((filas) {
        final out = <String, ProductoFoto>{};
        for (final f in filas) {
          out.putIfAbsent(f.productoId, () => f);
        }
        return out;
      });

  Stream<List<Venta>> verVentas({int ultimosDias = 90}) {
    final desde = claveFecha(
        DateTime.now().subtract(Duration(days: ultimosDias)));
    return (_db.select(_db.ventas)
          ..where((v) =>
              v.tenantId.equals(_tenantId) &
              v.deletedAt.isNull() &
              v.fecha.isBiggerOrEqualValue(desde))
          ..orderBy([(v) => OrderingTerm.desc(v.fecha)]))
        .watch();
  }

  /// Ítems todavía sin liquidar. Es lo que alimenta el comprobante.
  Future<List<VentaItem>> itemsSinLiquidar({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final ventas = await (_db.select(_db.ventas)
          ..where((v) =>
              v.tenantId.equals(_tenantId) &
              v.deletedAt.isNull() &
              // Una venta anulada no se le paga a nadie.
              v.estado.equals('completada') &
              v.fecha.isBetweenValues(claveFecha(desde), claveFecha(hasta))))
        .get();
    if (ventas.isEmpty) return const [];

    final ids = ventas.map((v) => v.id).toList();
    return (_db.select(_db.ventaItems)
          ..where((i) =>
              i.tenantId.equals(_tenantId) &
              i.deletedAt.isNull() &
              i.liquidacionId.isNull() &
              i.ventaId.isIn(ids)))
        .get();
  }

  /// Última venta de cada producto. Alimenta el aviso de prendas estancadas.
  Future<Map<String, DateTime>> ultimaVentaPorProducto() async {
    final filas = await _db.customSelect(
      'select v.producto_id as pid, max(ve.fecha) as f '
      'from venta_items i '
      'join ventas ve on ve.id = i.venta_id '
      'join producto_variantes v on v.id = i.variante_id '
      'where i.tenant_id = ? and i.deleted_at is null '
      "  and ve.estado = 'completada' and ve.deleted_at is null "
      'group by v.producto_id',
      variables: [Variable.withString(_tenantId)],
    ).get();

    return {
      for (final f in filas)
        if (f.data['pid'] != null && f.data['f'] != null)
          f.data['pid'] as String: fechaDesdeTextoSql('${f.data['f']}'),
    };
  }

  // ── Escrituras ──────────────────────────────────────────────────────────

  Future<String> guardarProveedor({
    String? id,
    required String nombre,
    String? telefono,
    String? email,
    num pctSalon = 30,
    bool descuentoLoAbsorbeSalon = true,
    String? notas,
    bool activo = true,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.proveedores).insertOnConflictUpdate(
            ProveedoresCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              nombre: nombre,
              telefono: Value(telefono),
              email: Value(email),
              pctSalon: Value(pctSalon.toDouble()),
              descuentoLoAbsorbeSalon: Value(descuentoLoAbsorbeSalon),
              notas: Value(notas),
              activo: Value(activo),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'proveedores',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'nombre': nombre,
          'telefono': telefono,
          'email': email,
          'pct_salon': pctSalon,
          'descuento_lo_absorbe_salon': descuentoLoAbsorbeSalon,
          'notas': notas,
          'activo': activo,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );
    });
    return filaId;
  }

  Future<String> guardarDeposito({
    String? id,
    required String nombre,
    String? direccion,
    bool esPrincipal = false,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    await _db.transaction(() async {
      // Solo puede haber un principal: si no, el formulario de venta no
      // sabría cuál elegir por defecto y elegiría uno al azar.
      if (esPrincipal) {
        await _db.customStatement(
          'update depositos set es_principal = 0, updated_at = ? '
          'where tenant_id = ? and id <> ?',
          [aEpochSegundos(ahora), _tenantId, filaId],
        );
      }
      await _db.into(_db.depositos).insertOnConflictUpdate(
            DepositosCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              nombre: nombre,
              direccion: Value(direccion),
              esPrincipal: Value(esPrincipal),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'depositos',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'nombre': nombre,
          'direccion': direccion,
          'es_principal': esPrincipal,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );
    });
    return filaId;
  }

  /// Guarda un producto **con sus variantes**.
  ///
  /// Las variantes van acá y no en un método aparte porque un producto sin
  /// talles no se puede vender: separarlos permitiría dejar a medias un
  /// producto que la vitrina ya está mostrando.
  Future<String> guardarProducto({
    String? id,
    required String nombre,
    String? proveedorId,
    String? descripcion,
    String? categoria,
    String? codigo,
    num precio = 0,
    num? pctSalon,
    String rubro = 'ropa',
    bool publicado = false,
    bool destacado = false,
    List<VarianteParaGuardar>? variantes,
    String? depositoId,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.productos).insertOnConflictUpdate(
            ProductosCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              nombre: nombre,
              proveedorId: Value(proveedorId),
              descripcion: Value(descripcion),
              categoria: Value(categoria),
              codigo: Value(codigo),
              precio: Value(precio.toDouble()),
              pctSalon: Value(pctSalon?.toDouble()),
              rubro: Value(rubro),
              publicado: Value(publicado),
              destacado: Value(destacado),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'productos',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'proveedor_id': proveedorId,
          'nombre': nombre,
          'descripcion': descripcion,
          'categoria': categoria,
          'codigo': codigo,
          'precio': precio,
          'pct_salon': pctSalon,
          'rubro': rubro,
          'publicado': publicado,
          'destacado': destacado,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );

      if (variantes == null) return;

      // Las variantes que YA NO están se marcan borradas, no se eliminan: una
      // venta vieja apunta a ellas y tiene que seguir siendo legible.
      final vivas = variantes
          .map((v) => v.id)
          .whereType<String>()
          .toSet();
      final actuales = await (_db.select(_db.productoVariantes)
            ..where((v) =>
                v.productoId.equals(filaId) & v.deletedAt.isNull()))
          .get();
      for (final a in actuales) {
        if (!vivas.contains(a.id)) {
          await borrar('producto_variantes', a.id);
        }
      }

      for (final v in variantes) {
        final vid = v.id ?? nuevoId();
        await _db.into(_db.productoVariantes).insertOnConflictUpdate(
              ProductoVariantesCompanion.insert(
                id: vid,
                tenantId: _tenantId,
                productoId: filaId,
                talle: Value(v.talle),
                color: Value(v.color),
                updatedAt: Value(ahora),
              ),
            );
        await _sync.encolar(
          tenantId: _tenantId,
          tabla: 'producto_variantes',
          filaId: vid,
          operacion: 'upsert',
          payload: {
            'id': vid,
            'tenant_id': _tenantId,
            'producto_id': filaId,
            'talle': v.talle,
            'color': v.color,
            'updated_at': ahora.toUtc().toIso8601String(),
          },
        );

        // El stock va por DELTA aunque el formulario muestre un absoluto: si
        // se escribiera el valor tal cual, editar una prenda desde el teléfono
        // pisaría las ventas que el otro dispositivo cargó mientras tanto.
        if (v.stock != null && depositoId != null) {
          final actual = await (_db.select(_db.stockVariantes)
                ..where((x) =>
                    x.varianteId.equals(vid) &
                    x.depositoId.equals(depositoId)))
              .getSingleOrNull();
          final diferencia = v.stock! - (actual?.cantidad ?? 0);
          if (diferencia != 0) {
            await ajustarStock(
              varianteId: vid,
              depositoId: depositoId,
              delta: diferencia,
              motivo: dom.MotivoStock.ingreso,
            );
          }
        }
      }
    });
    return filaId;
  }

  /// Mueve stock **por diferencia**, nunca por valor absoluto.
  ///
  /// Es la misma razón que en el inventario del salón: dos ventas offline de
  /// la misma prenda resueltas por last-write-wins descuentan una sola.
  Future<void> ajustarStock({
    required String varianteId,
    required String depositoId,
    required int delta,
    dom.MotivoStock motivo = dom.MotivoStock.ajuste,
    String? referenciaId,
  }) async {
    if (delta == 0) return;
    final ahora = DateTime.now();

    await _db.transaction(() async {
      final actual = await (_db.select(_db.stockVariantes)
            ..where((s) =>
                s.varianteId.equals(varianteId) &
                s.depositoId.equals(depositoId)))
          .getSingleOrNull();

      if (actual == null) {
        await _db.into(_db.stockVariantes).insert(
              StockVariantesCompanion.insert(
                id: nuevoId(),
                tenantId: _tenantId,
                varianteId: varianteId,
                depositoId: depositoId,
                cantidad: Value(delta < 0 ? 0 : delta),
                updatedAt: Value(ahora),
              ),
            );
      } else {
        await _db.customStatement(
          'update stock_variantes set cantidad = max(0, cantidad + ?), '
          'updated_at = ? where id = ?',
          [delta, aEpochSegundos(ahora), actual.id],
        );
      }

      final movId = nuevoId();
      await _db.into(_db.movimientosStock).insert(
            MovimientosStockCompanion.insert(
              id: movId,
              tenantId: _tenantId,
              varianteId: varianteId,
              depositoId: depositoId,
              delta: delta,
              motivo: motivo.sql,
              referenciaId: Value(referenciaId),
              updatedAt: Value(ahora),
            ),
          );

      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'stock_variantes',
        filaId: varianteId,
        operacion: 'delta_variante',
        payload: {
          'variante_id': varianteId,
          'deposito_id': depositoId,
          'delta': delta,
          'motivo': motivo.sql,
          'referencia_id': referenciaId,
        },
      );
    });
  }

  /// Registra una venta con su reparto ya calculado y descuenta el stock.
  Future<String> registrarVenta({
    required String depositoId,
    required List<ItemParaVender> items,
    String? clientId,
    String? vendedorId,
    num descuento = 0,
    String metodo = 'efectivo',
    String? notas,
    DateTime? fecha,
  }) async {
    final ventaId = nuevoId();
    final ahora = DateTime.now();
    final dia = fecha ?? ahora;

    // El reparto se calcula ACÁ y se guarda con la venta: los porcentajes
    // quedan congelados y una liquidación es una suma, no una reconstrucción.
    final repartos = items
        .map((i) => repartirItem(
              precioUnitario: i.precioUnit,
              cantidad: i.cantidad,
              // El descuento se reparte entre los ítems en proporción a lo que
              // pesa cada uno: cargarlo entero al primero deformaría su
              // liquidación y dejaría bien la de los demás.
              descuento: _porcion(descuento, i, items),
              pctSalon: i.pctSalon,
              pctVendedor: i.pctVendedor,
              descuentoLoAbsorbeSalon: i.descuentoLoAbsorbeSalon,
            ))
        .toList();
    final total = repartirVenta(repartos).neto;

    await _db.transaction(() async {
      await _db.into(_db.ventas).insert(
            VentasCompanion.insert(
              id: ventaId,
              tenantId: _tenantId,
              fecha: claveFecha(dia),
              depositoId: Value(depositoId),
              vendedorId: Value(vendedorId),
              clientId: Value(clientId),
              total: Value(total.toDouble()),
              descuento: Value(descuento.toDouble()),
              metodo: Value(metodo),
              notas: Value(notas),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'ventas',
        filaId: ventaId,
        operacion: 'upsert',
        payload: {
          'id': ventaId,
          'tenant_id': _tenantId,
          'deposito_id': depositoId,
          'vendedor_id': vendedorId,
          'client_id': clientId,
          'fecha': claveFecha(dia),
          'total': total,
          'descuento': descuento,
          'metodo': metodo,
          'estado': 'completada',
          'notas': notas,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );

      for (var k = 0; k < items.length; k++) {
        final i = items[k];
        final r = repartos[k];
        final itemId = nuevoId();

        await _db.into(_db.ventaItems).insert(
              VentaItemsCompanion.insert(
                id: itemId,
                tenantId: _tenantId,
                ventaId: ventaId,
                varianteId: Value(i.varianteId),
                descripcion: Value(i.descripcion),
                cantidad: Value(i.cantidad),
                precioUnit: Value(i.precioUnit.toDouble()),
                pctSalon: Value(i.pctSalon.toDouble()),
                pctVendedor: Value(i.pctVendedor.toDouble()),
                montoProveedor: Value(r.proveedor.toDouble()),
                montoSalon: Value(r.salon.toDouble()),
                montoVendedor: Value(r.vendedor.toDouble()),
                updatedAt: Value(ahora),
              ),
            );
        await _sync.encolar(
          tenantId: _tenantId,
          tabla: 'venta_items',
          filaId: itemId,
          operacion: 'upsert',
          payload: {
            'id': itemId,
            'tenant_id': _tenantId,
            'venta_id': ventaId,
            'variante_id': i.varianteId,
            'descripcion': i.descripcion,
            'cantidad': i.cantidad,
            'precio_unit': i.precioUnit,
            'pct_salon': i.pctSalon,
            'pct_vendedor': i.pctVendedor,
            'monto_proveedor': r.proveedor,
            'monto_salon': r.salon,
            'monto_vendedor': r.vendedor,
            'updated_at': ahora.toUtc().toIso8601String(),
          },
        );

        if (i.varianteId != null) {
          await ajustarStock(
            varianteId: i.varianteId!,
            depositoId: depositoId,
            delta: -i.cantidad,
            motivo: dom.MotivoStock.venta,
            referenciaId: ventaId,
          );
        }
      }

      // La venta impacta en la caja por el TOTAL, no por la parte del salon.
      //
      // Es lo que refleja la plata de verdad: ella cobra todo y despues le
      // paga al proveedor, y ese pago se registra como egreso al liquidar.
      // Anotar solo su parte haria que la caja no cuadre con el efectivo que
      // tiene en la mano al cerrar el dia.
      if (total > 0) {
        await _negocio.guardarMovimiento(
          tipo: 'income',
          monto: total.toDouble(),
          fecha: dia,
          descripcion: notas ?? 'Venta de ropa',
          categoria: 'ropa',
          metodo: metodo,
          clientId: clientId,
        );
      }
    });
    return ventaId;
  }



  /// Arma el comprobante de un proveedor o de un vendedor para un período.
  ///
  /// Solo entran ítems **sin liquidar**: el `liquidacion_id` es lo que evita
  /// pagar dos veces la misma prenda, que es el error más caro que puede
  /// cometer este módulo y el que nadie nota hasta que faltan los números.
  Future<DetalleLiquidacion> armarLiquidacion({
    required String destinatarioId,
    required String destinatarioNombre,
    required dom.LiquidacionTipo tipo,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final items = await itemsSinLiquidar(desde: desde, hasta: hasta);
    if (items.isEmpty) {
      return armarDetalle(
        destinatario: destinatarioNombre,
        tipo: tipo,
        desde: desde,
        hasta: hasta,
        filas: const [],
      );
    }

    // Se resuelve a qué producto pertenece cada ítem para poder filtrar por
    // proveedor y para escribir en el comprobante el código y el talle: sin
    // eso, el papel dice "prenda" y no sirve para auditar nada.
    final variantes = {
      for (final v in await _db.select(_db.productoVariantes).get()) v.id: v
    };
    final productos = {
      for (final p in await _db.select(_db.productos).get()) p.id: p
    };
    final ventas = {
      for (final v in await _db.select(_db.ventas).get()) v.id: v
    };

    final filas = <FilaLiquidacion>[];
    for (final i in items) {
      final variante = i.varianteId == null ? null : variantes[i.varianteId];
      final producto =
          variante == null ? null : productos[variante.productoId];

      final esDeEste = switch (tipo) {
        dom.LiquidacionTipo.proveedor =>
          producto?.proveedorId == destinatarioId,
        dom.LiquidacionTipo.vendedor =>
          ventas[i.ventaId]?.vendedorId == destinatarioId,
      };
      if (!esDeEste) continue;

      final monto = tipo == dom.LiquidacionTipo.proveedor
          ? i.montoProveedor
          : i.montoVendedor;
      if (monto == 0) continue;

      filas.add(FilaLiquidacion(
        itemId: i.id,
        fecha: fechaDesdeTextoSql(ventas[i.ventaId]?.fecha ?? ''),
        prenda: producto?.nombre ?? i.descripcion ?? 'Prenda',
        codigo: producto?.codigo,
        variante: variante == null
            ? null
            : [variante.talle, variante.color]
                .where((x) => x != null && x.isNotEmpty)
                .join(' · '),
        cantidad: i.cantidad,
        precioUnit: i.precioUnit,
        // El porcentaje que se le aplicó, no el que tiene hoy: es lo que
        // permite explicar el número sin discutir.
        pct: tipo == dom.LiquidacionTipo.proveedor
            ? 100 - i.pctSalon
            : i.pctVendedor,
        monto: monto,
      ));
    }

    return armarDetalle(
      destinatario: destinatarioNombre,
      tipo: tipo,
      desde: desde,
      hasta: hasta,
      filas: filas,
    );
  }

  /// Cierra la liquidación: la guarda y marca sus ítems como pagados.
  ///
  /// Va en UNA transacción. Si se guardara la liquidación y fallara el marcado
  /// de los ítems, esas prendas volverían a aparecer como pendientes en el
  /// próximo período y se pagarían dos veces.
  Future<String> cerrarLiquidacion({
    required DetalleLiquidacion detalle,
    required String destinatarioId,
  }) async {
    final filaId = nuevoId();
    final ahora = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.liquidaciones).insert(
            LiquidacionesCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              tipo: detalle.tipo.name,
              destinatarioId: destinatarioId,
              periodoDesde: claveFecha(detalle.desde),
              periodoHasta: claveFecha(detalle.hasta),
              total: Value(detalle.total.toDouble()),
              estado: const Value('pagada'),
              pagadaAt: Value(ahora),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'liquidaciones',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'tipo': detalle.tipo.name,
          'destinatario_id': destinatarioId,
          'periodo_desde': claveFecha(detalle.desde),
          'periodo_hasta': claveFecha(detalle.hasta),
          'total': detalle.total,
          'estado': 'pagada',
          'pagada_at': ahora.toUtc().toIso8601String(),
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );

      for (final f in detalle.filas) {
        await (_db.update(_db.ventaItems)..where((i) => i.id.equals(f.itemId)))
            .write(VentaItemsCompanion(
          liquidacionId: Value(filaId),
          updatedAt: Value(ahora),
        ));
        await _sync.encolar(
          tenantId: _tenantId,
          tabla: 'venta_items',
          filaId: f.itemId,
          operacion: 'upsert',
          payload: {
            'id': f.itemId,
            'liquidacion_id': filaId,
            'updated_at': ahora.toUtc().toIso8601String(),
          },
        );
      }

      // Pagarle al proveedor es plata que SALE. Se registra como egreso para
      // que la caja cuadre: al vender entró el total, acá sale su parte.
      if (detalle.total > 0 &&
          detalle.tipo == dom.LiquidacionTipo.proveedor) {
        await _negocio.guardarMovimiento(
          tipo: 'expense',
          monto: detalle.total.toDouble(),
          fecha: ahora,
          descripcion: 'Liquidación · ${detalle.destinatario}',
          categoria: 'ropa-proveedor',
        );
      }
    });
    return filaId;
  }

  Stream<List<Liquidacione>> verLiquidaciones() =>
      (_db.select(_db.liquidaciones)
            ..where((l) => l.tenantId.equals(_tenantId) & l.deletedAt.isNull())
            ..orderBy([(l) => OrderingTerm.desc(l.createdAt)]))
          .watch();

  /// Guarda una foto. Si `path` viene vacio, queda pendiente de subir.
  ///
  /// Las fotos son lo unico del modulo que NO funciona offline de punta a
  /// punta: los datos de la prenda se encolan como cualquier fila, pero una
  /// imagen no se encola razonablemente. Se guarda la ruta local, se marca
  /// pendiente, y la ficha lo dice en vez de mostrar un rectangulo roto.
  Future<String> guardarFoto({
    String? id,
    required String productoId,
    String? varianteId,
    String path = '',
    String? rutaLocal,
    int orden = 0,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    final pendiente = path.isEmpty;

    await _db.transaction(() async {
      await _db.into(_db.productoFotos).insertOnConflictUpdate(
            ProductoFotosCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              productoId: productoId,
              varianteId: Value(varianteId),
              path: path,
              orden: Value(orden),
              pendienteDeSubir: Value(pendiente),
              rutaLocal: Value(rutaLocal),
              updatedAt: Value(ahora),
            ),
          );
      // Una foto pendiente NO se encola: el servidor guardaria una fila con
      // path vacio y la vitrina mostraria un hueco. Se encola recien cuando
      // la imagen ya esta arriba.
      if (!pendiente) {
        await _sync.encolar(
          tenantId: _tenantId,
          tabla: 'producto_fotos',
          filaId: filaId,
          operacion: 'upsert',
          payload: {
            'id': filaId,
            'tenant_id': _tenantId,
            'producto_id': productoId,
            'variante_id': varianteId,
            'path': path,
            'orden': orden,
            'updated_at': ahora.toUtc().toIso8601String(),
          },
        );
      }
    });
    return filaId;
  }

  /// Las fotos que quedaron sin subir, para reintentarlas cuando haya senal.
  Future<List<ProductoFoto>> fotosPendientes() =>
      (_db.select(_db.productoFotos)
            ..where((f) =>
                f.tenantId.equals(_tenantId) &
                f.deletedAt.isNull() &
                f.pendienteDeSubir.equals(true)))
          .get();

  /// Borrado logico, igual que el resto del sistema.
  Future<void> borrar(String tabla, String filaId) async {
    final ahora = DateTime.now();
    await _db.transaction(() async {
      await _db.customStatement(
        'update $tabla set deleted_at = ?, updated_at = ? '
        'where id = ? and tenant_id = ?',
        [aEpochSegundos(ahora), aEpochSegundos(ahora), filaId, _tenantId],
      );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: tabla,
        filaId: filaId,
        operacion: 'delete',
        payload: const {},
      );
    });
  }
}

/// Una variante al guardarla.
///
/// Es una clase y no un record a propósito: un record es estructural, así que
/// agregarle un campo rompe TODOS los llamadores a la vez aunque ese campo sea
/// opcional. Pasó al sumar el stock.
class VarianteParaGuardar {
  const VarianteParaGuardar({this.id, this.talle, this.color, this.stock});

  /// `null` = variante nueva.
  final String? id;
  final String? talle;
  final String? color;

  /// Cuántas unidades tienen que QUEDAR, no un delta: el formulario muestra un
  /// número y la usuaria lo corrige. La diferencia se calcula en el
  /// repositorio y se aplica como delta, que es lo que el motor de sync sabe
  /// resolver cuando dos dispositivos tocan lo mismo.
  ///
  /// `null` = no tocar el stock.
  final int? stock;
}

/// Lo que se está por vender, antes de calcular el reparto.
class ItemParaVender {
  const ItemParaVender({
    required this.precioUnit,
    required this.pctSalon,
    this.varianteId,
    this.descripcion,
    this.cantidad = 1,
    this.pctVendedor = 0,
    this.descuentoLoAbsorbeSalon = true,
  });

  final String? varianteId;
  final String? descripcion;
  final int cantidad;
  final num precioUnit;
  final num pctSalon;
  final num pctVendedor;
  final bool descuentoLoAbsorbeSalon;

  num get bruto => precioUnit * cantidad;
}

/// Qué parte del descuento total le toca a este ítem.
num _porcion(num descuento, ItemParaVender item, List<ItemParaVender> todos) {
  if (descuento == 0) return 0;
  final total = todos.fold<num>(0, (a, i) => a + i.bruto);
  if (total == 0) return 0;
  return descuento * (item.bruto / total);
}

/// Drift guarda los `DateTime` como epoch en segundos. Escribir un ISO con SQL
/// crudo deja la columna ilegible y la próxima lectura lanza `FormatException`
/// — lo encontró un test, después de que un borrado dejara una lista sin poder
/// abrirse.
int aEpochSegundos(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

/// `'YYYY-MM-DD'` de una consulta cruda a `DateTime` local.
DateTime fechaDesdeTextoSql(String s) {
  final p = s.split('-');
  if (p.length != 3) return DateTime.now();
  return DateTime(int.tryParse(p[0]) ?? 1970, int.tryParse(p[1]) ?? 1,
      int.tryParse(p[2]) ?? 1);
}

final ropaRepoProvider = Provider<RopaRepository?>((ref) {
  // Se apoya en el repositorio de negocio para no duplicar la resolución del
  // salón activo: si esa lógica viviera en dos lugares, un día discreparían.
  final base = ref.watch(businessRepoProvider);
  if (base == null) return null;
  return RopaRepository(ref.watch(dbProvider), ref.watch(syncEngineProvider),
      base.tenantId, base);
});
