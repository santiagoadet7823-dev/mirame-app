// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfessionalsTable extends Professionals
    with TableInfo<$ProfessionalsTable, Professional> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfessionalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tenantId, createdAt, updatedAt, deletedAt, nombre, telefono];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'professionals';
  @override
  VerificationContext validateIntegrity(Insertable<Professional> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Professional map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Professional(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
    );
  }

  @override
  $ProfessionalsTable createAlias(String alias) {
    return $ProfessionalsTable(attachedDatabase, alias);
  }
}

class Professional extends DataClass implements Insertable<Professional> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String nombre;
  final String? telefono;
  const Professional(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.nombre,
      this.telefono});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    return map;
  }

  ProfessionalsCompanion toCompanion(bool nullToAbsent) {
    return ProfessionalsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
    );
  }

  factory Professional.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Professional(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
    };
  }

  Professional copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? nombre,
          Value<String?> telefono = const Value.absent()}) =>
      Professional(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        nombre: nombre ?? this.nombre,
        telefono: telefono.present ? telefono.value : this.telefono,
      );
  Professional copyWithCompanion(ProfessionalsCompanion data) {
    return Professional(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Professional(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, tenantId, createdAt, updatedAt, deletedAt, nombre, telefono);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Professional &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono);
}

class ProfessionalsCompanion extends UpdateCompanion<Professional> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<int> rowid;
  const ProfessionalsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfessionalsCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String nombre,
    this.telefono = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        nombre = Value(nombre);
  static Insertable<Professional> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfessionalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? nombre,
      Value<String?>? telefono,
      Value<int>? rowid}) {
    return ProfessionalsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfessionalsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServicesTable extends Services with TableInfo<$ServicesTable, Service> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<double> precio = GeneratedColumn<double>(
      'precio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _duracionMinMeta =
      const VerificationMeta('duracionMin');
  @override
  late final GeneratedColumn<int> duracionMin = GeneratedColumn<int>(
      'duracion_min', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(60));
  static const VerificationMeta _retoqueDiasMeta =
      const VerificationMeta('retoqueDias');
  @override
  late final GeneratedColumn<int> retoqueDias = GeneratedColumn<int>(
      'retoque_dias', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _mantenimientoDiasMeta =
      const VerificationMeta('mantenimientoDias');
  @override
  late final GeneratedColumn<int> mantenimientoDias = GeneratedColumn<int>(
      'mantenimiento_dias', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        nombre,
        precio,
        duracionMin,
        retoqueDias,
        mantenimientoDias,
        notas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'services';
  @override
  VerificationContext validateIntegrity(Insertable<Service> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('precio')) {
      context.handle(_precioMeta,
          precio.isAcceptableOrUnknown(data['precio']!, _precioMeta));
    }
    if (data.containsKey('duracion_min')) {
      context.handle(
          _duracionMinMeta,
          duracionMin.isAcceptableOrUnknown(
              data['duracion_min']!, _duracionMinMeta));
    }
    if (data.containsKey('retoque_dias')) {
      context.handle(
          _retoqueDiasMeta,
          retoqueDias.isAcceptableOrUnknown(
              data['retoque_dias']!, _retoqueDiasMeta));
    }
    if (data.containsKey('mantenimiento_dias')) {
      context.handle(
          _mantenimientoDiasMeta,
          mantenimientoDias.isAcceptableOrUnknown(
              data['mantenimiento_dias']!, _mantenimientoDiasMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Service map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Service(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      precio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio'])!,
      duracionMin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duracion_min'])!,
      retoqueDias: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retoque_dias']),
      mantenimientoDias: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mantenimiento_dias']),
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
    );
  }

  @override
  $ServicesTable createAlias(String alias) {
    return $ServicesTable(attachedDatabase, alias);
  }
}

class Service extends DataClass implements Insertable<Service> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String nombre;
  final double precio;
  final int duracionMin;
  final int? retoqueDias;
  final int? mantenimientoDias;
  final String? notas;
  const Service(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.nombre,
      required this.precio,
      required this.duracionMin,
      this.retoqueDias,
      this.mantenimientoDias,
      this.notas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['nombre'] = Variable<String>(nombre);
    map['precio'] = Variable<double>(precio);
    map['duracion_min'] = Variable<int>(duracionMin);
    if (!nullToAbsent || retoqueDias != null) {
      map['retoque_dias'] = Variable<int>(retoqueDias);
    }
    if (!nullToAbsent || mantenimientoDias != null) {
      map['mantenimiento_dias'] = Variable<int>(mantenimientoDias);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  ServicesCompanion toCompanion(bool nullToAbsent) {
    return ServicesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      nombre: Value(nombre),
      precio: Value(precio),
      duracionMin: Value(duracionMin),
      retoqueDias: retoqueDias == null && nullToAbsent
          ? const Value.absent()
          : Value(retoqueDias),
      mantenimientoDias: mantenimientoDias == null && nullToAbsent
          ? const Value.absent()
          : Value(mantenimientoDias),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
    );
  }

  factory Service.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Service(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      precio: serializer.fromJson<double>(json['precio']),
      duracionMin: serializer.fromJson<int>(json['duracionMin']),
      retoqueDias: serializer.fromJson<int?>(json['retoqueDias']),
      mantenimientoDias: serializer.fromJson<int?>(json['mantenimientoDias']),
      notas: serializer.fromJson<String?>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'nombre': serializer.toJson<String>(nombre),
      'precio': serializer.toJson<double>(precio),
      'duracionMin': serializer.toJson<int>(duracionMin),
      'retoqueDias': serializer.toJson<int?>(retoqueDias),
      'mantenimientoDias': serializer.toJson<int?>(mantenimientoDias),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Service copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? nombre,
          double? precio,
          int? duracionMin,
          Value<int?> retoqueDias = const Value.absent(),
          Value<int?> mantenimientoDias = const Value.absent(),
          Value<String?> notas = const Value.absent()}) =>
      Service(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        nombre: nombre ?? this.nombre,
        precio: precio ?? this.precio,
        duracionMin: duracionMin ?? this.duracionMin,
        retoqueDias: retoqueDias.present ? retoqueDias.value : this.retoqueDias,
        mantenimientoDias: mantenimientoDias.present
            ? mantenimientoDias.value
            : this.mantenimientoDias,
        notas: notas.present ? notas.value : this.notas,
      );
  Service copyWithCompanion(ServicesCompanion data) {
    return Service(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      precio: data.precio.present ? data.precio.value : this.precio,
      duracionMin:
          data.duracionMin.present ? data.duracionMin.value : this.duracionMin,
      retoqueDias:
          data.retoqueDias.present ? data.retoqueDias.value : this.retoqueDias,
      mantenimientoDias: data.mantenimientoDias.present
          ? data.mantenimientoDias.value
          : this.mantenimientoDias,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Service(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('precio: $precio, ')
          ..write('duracionMin: $duracionMin, ')
          ..write('retoqueDias: $retoqueDias, ')
          ..write('mantenimientoDias: $mantenimientoDias, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      nombre, precio, duracionMin, retoqueDias, mantenimientoDias, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Service &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nombre == this.nombre &&
          other.precio == this.precio &&
          other.duracionMin == this.duracionMin &&
          other.retoqueDias == this.retoqueDias &&
          other.mantenimientoDias == this.mantenimientoDias &&
          other.notas == this.notas);
}

class ServicesCompanion extends UpdateCompanion<Service> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nombre;
  final Value<double> precio;
  final Value<int> duracionMin;
  final Value<int?> retoqueDias;
  final Value<int?> mantenimientoDias;
  final Value<String?> notas;
  final Value<int> rowid;
  const ServicesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.precio = const Value.absent(),
    this.duracionMin = const Value.absent(),
    this.retoqueDias = const Value.absent(),
    this.mantenimientoDias = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServicesCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String nombre,
    this.precio = const Value.absent(),
    this.duracionMin = const Value.absent(),
    this.retoqueDias = const Value.absent(),
    this.mantenimientoDias = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        nombre = Value(nombre);
  static Insertable<Service> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nombre,
    Expression<double>? precio,
    Expression<int>? duracionMin,
    Expression<int>? retoqueDias,
    Expression<int>? mantenimientoDias,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (nombre != null) 'nombre': nombre,
      if (precio != null) 'precio': precio,
      if (duracionMin != null) 'duracion_min': duracionMin,
      if (retoqueDias != null) 'retoque_dias': retoqueDias,
      if (mantenimientoDias != null) 'mantenimiento_dias': mantenimientoDias,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? nombre,
      Value<double>? precio,
      Value<int>? duracionMin,
      Value<int?>? retoqueDias,
      Value<int?>? mantenimientoDias,
      Value<String?>? notas,
      Value<int>? rowid}) {
    return ServicesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      duracionMin: duracionMin ?? this.duracionMin,
      retoqueDias: retoqueDias ?? this.retoqueDias,
      mantenimientoDias: mantenimientoDias ?? this.mantenimientoDias,
      notas: notas ?? this.notas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (precio.present) {
      map['precio'] = Variable<double>(precio.value);
    }
    if (duracionMin.present) {
      map['duracion_min'] = Variable<int>(duracionMin.value);
    }
    if (retoqueDias.present) {
      map['retoque_dias'] = Variable<int>(retoqueDias.value);
    }
    if (mantenimientoDias.present) {
      map['mantenimiento_dias'] = Variable<int>(mantenimientoDias.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('precio: $precio, ')
          ..write('duracionMin: $duracionMin, ')
          ..write('retoqueDias: $retoqueDias, ')
          ..write('mantenimientoDias: $mantenimientoDias, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cumpleMeta = const VerificationMeta('cumple');
  @override
  late final GeneratedColumn<DateTime> cumple = GeneratedColumn<DateTime>(
      'cumple', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _vipMeta = const VerificationMeta('vip');
  @override
  late final GeneratedColumn<bool> vip = GeneratedColumn<bool>(
      'vip', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("vip" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        nombre,
        telefono,
        email,
        cumple,
        vip,
        notas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(Insertable<Client> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('cumple')) {
      context.handle(_cumpleMeta,
          cumple.isAcceptableOrUnknown(data['cumple']!, _cumpleMeta));
    }
    if (data.containsKey('vip')) {
      context.handle(
          _vipMeta, vip.isAcceptableOrUnknown(data['vip']!, _vipMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      cumple: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cumple']),
      vip: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}vip'])!,
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String nombre;
  final String? telefono;
  final String? email;
  final DateTime? cumple;
  final bool vip;
  final String? notas;
  const Client(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.nombre,
      this.telefono,
      this.email,
      this.cumple,
      required this.vip,
      this.notas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || cumple != null) {
      map['cumple'] = Variable<DateTime>(cumple);
    }
    map['vip'] = Variable<bool>(vip);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      cumple:
          cumple == null && nullToAbsent ? const Value.absent() : Value(cumple),
      vip: Value(vip),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
    );
  }

  factory Client.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      cumple: serializer.fromJson<DateTime?>(json['cumple']),
      vip: serializer.fromJson<bool>(json['vip']),
      notas: serializer.fromJson<String?>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
      'email': serializer.toJson<String?>(email),
      'cumple': serializer.toJson<DateTime?>(cumple),
      'vip': serializer.toJson<bool>(vip),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Client copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? nombre,
          Value<String?> telefono = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<DateTime?> cumple = const Value.absent(),
          bool? vip,
          Value<String?> notas = const Value.absent()}) =>
      Client(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        nombre: nombre ?? this.nombre,
        telefono: telefono.present ? telefono.value : this.telefono,
        email: email.present ? email.value : this.email,
        cumple: cumple.present ? cumple.value : this.cumple,
        vip: vip ?? this.vip,
        notas: notas.present ? notas.value : this.notas,
      );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      email: data.email.present ? data.email.value : this.email,
      cumple: data.cumple.present ? data.cumple.value : this.cumple,
      vip: data.vip.present ? data.vip.value : this.vip,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('cumple: $cumple, ')
          ..write('vip: $vip, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      nombre, telefono, email, cumple, vip, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.cumple == this.cumple &&
          other.vip == this.vip &&
          other.notas == this.notas);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<String?> email;
  final Value<DateTime?> cumple;
  final Value<bool> vip;
  final Value<String?> notas;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.cumple = const Value.absent(),
    this.vip = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String nombre,
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.cumple = const Value.absent(),
    this.vip = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        nombre = Value(nombre);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<DateTime>? cumple,
    Expression<bool>? vip,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (cumple != null) 'cumple': cumple,
      if (vip != null) 'vip': vip,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? nombre,
      Value<String?>? telefono,
      Value<String?>? email,
      Value<DateTime?>? cumple,
      Value<bool>? vip,
      Value<String?>? notas,
      Value<int>? rowid}) {
    return ClientsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      cumple: cumple ?? this.cumple,
      vip: vip ?? this.vip,
      notas: notas ?? this.notas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (cumple.present) {
      map['cumple'] = Variable<DateTime>(cumple.value);
    }
    if (vip.present) {
      map['vip'] = Variable<bool>(vip.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('cumple: $cumple, ')
          ..write('vip: $vip, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _professionalIdMeta =
      const VerificationMeta('professionalId');
  @override
  late final GeneratedColumn<String> professionalId = GeneratedColumn<String>(
      'professional_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
      'fecha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _horaMeta = const VerificationMeta('hora');
  @override
  late final GeneratedColumn<String> hora = GeneratedColumn<String>(
      'hora', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<double> precio = GeneratedColumn<double>(
      'precio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendiente'));
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        clientId,
        professionalId,
        fecha,
        hora,
        precio,
        estado,
        notas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(Insertable<Appointment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('professional_id')) {
      context.handle(
          _professionalIdMeta,
          professionalId.isAcceptableOrUnknown(
              data['professional_id']!, _professionalIdMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('hora')) {
      context.handle(
          _horaMeta, hora.isAcceptableOrUnknown(data['hora']!, _horaMeta));
    } else if (isInserting) {
      context.missing(_horaMeta);
    }
    if (data.containsKey('precio')) {
      context.handle(_precioMeta,
          precio.isAcceptableOrUnknown(data['precio']!, _precioMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      professionalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}professional_id']),
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha'])!,
      hora: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hora'])!,
      precio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? clientId;
  final String? professionalId;

  /// Fecha local `YYYY-MM-DD`. Se guarda como texto y NO como DateTime a
  /// propósito: el legacy usaba `toISOString()` y después de las 21:00 (UTC-3)
  /// el turno saltaba al día siguiente.
  final String fecha;

  /// Hora local `HH:MM`.
  final String hora;
  final double precio;
  final String estado;
  final String? notas;
  const Appointment(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.clientId,
      this.professionalId,
      required this.fecha,
      required this.hora,
      required this.precio,
      required this.estado,
      this.notas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    if (!nullToAbsent || professionalId != null) {
      map['professional_id'] = Variable<String>(professionalId);
    }
    map['fecha'] = Variable<String>(fecha);
    map['hora'] = Variable<String>(hora);
    map['precio'] = Variable<double>(precio);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      professionalId: professionalId == null && nullToAbsent
          ? const Value.absent()
          : Value(professionalId),
      fecha: Value(fecha),
      hora: Value(hora),
      precio: Value(precio),
      estado: Value(estado),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      professionalId: serializer.fromJson<String?>(json['professionalId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      hora: serializer.fromJson<String>(json['hora']),
      precio: serializer.fromJson<double>(json['precio']),
      estado: serializer.fromJson<String>(json['estado']),
      notas: serializer.fromJson<String?>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'clientId': serializer.toJson<String?>(clientId),
      'professionalId': serializer.toJson<String?>(professionalId),
      'fecha': serializer.toJson<String>(fecha),
      'hora': serializer.toJson<String>(hora),
      'precio': serializer.toJson<double>(precio),
      'estado': serializer.toJson<String>(estado),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Appointment copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          Value<String?> professionalId = const Value.absent(),
          String? fecha,
          String? hora,
          double? precio,
          String? estado,
          Value<String?> notas = const Value.absent()}) =>
      Appointment(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        clientId: clientId.present ? clientId.value : this.clientId,
        professionalId:
            professionalId.present ? professionalId.value : this.professionalId,
        fecha: fecha ?? this.fecha,
        hora: hora ?? this.hora,
        precio: precio ?? this.precio,
        estado: estado ?? this.estado,
        notas: notas.present ? notas.value : this.notas,
      );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      professionalId: data.professionalId.present
          ? data.professionalId.value
          : this.professionalId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      hora: data.hora.present ? data.hora.value : this.hora,
      precio: data.precio.present ? data.precio.value : this.precio,
      estado: data.estado.present ? data.estado.value : this.estado,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('clientId: $clientId, ')
          ..write('professionalId: $professionalId, ')
          ..write('fecha: $fecha, ')
          ..write('hora: $hora, ')
          ..write('precio: $precio, ')
          ..write('estado: $estado, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      clientId, professionalId, fecha, hora, precio, estado, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.clientId == this.clientId &&
          other.professionalId == this.professionalId &&
          other.fecha == this.fecha &&
          other.hora == this.hora &&
          other.precio == this.precio &&
          other.estado == this.estado &&
          other.notas == this.notas);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> clientId;
  final Value<String?> professionalId;
  final Value<String> fecha;
  final Value<String> hora;
  final Value<double> precio;
  final Value<String> estado;
  final Value<String?> notas;
  final Value<int> rowid;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.clientId = const Value.absent(),
    this.professionalId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.hora = const Value.absent(),
    this.precio = const Value.absent(),
    this.estado = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.clientId = const Value.absent(),
    this.professionalId = const Value.absent(),
    required String fecha,
    required String hora,
    this.precio = const Value.absent(),
    this.estado = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        fecha = Value(fecha),
        hora = Value(hora);
  static Insertable<Appointment> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? clientId,
    Expression<String>? professionalId,
    Expression<String>? fecha,
    Expression<String>? hora,
    Expression<double>? precio,
    Expression<String>? estado,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (clientId != null) 'client_id': clientId,
      if (professionalId != null) 'professional_id': professionalId,
      if (fecha != null) 'fecha': fecha,
      if (hora != null) 'hora': hora,
      if (precio != null) 'precio': precio,
      if (estado != null) 'estado': estado,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? clientId,
      Value<String?>? professionalId,
      Value<String>? fecha,
      Value<String>? hora,
      Value<double>? precio,
      Value<String>? estado,
      Value<String?>? notas,
      Value<int>? rowid}) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      clientId: clientId ?? this.clientId,
      professionalId: professionalId ?? this.professionalId,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      precio: precio ?? this.precio,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (professionalId.present) {
      map['professional_id'] = Variable<String>(professionalId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (hora.present) {
      map['hora'] = Variable<String>(hora.value);
    }
    if (precio.present) {
      map['precio'] = Variable<double>(precio.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('clientId: $clientId, ')
          ..write('professionalId: $professionalId, ')
          ..write('fecha: $fecha, ')
          ..write('hora: $hora, ')
          ..write('precio: $precio, ')
          ..write('estado: $estado, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppointmentServicesTable extends AppointmentServices
    with TableInfo<$AppointmentServicesTable, AppointmentService> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _appointmentIdMeta =
      const VerificationMeta('appointmentId');
  @override
  late final GeneratedColumn<String> appointmentId = GeneratedColumn<String>(
      'appointment_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<double> precio = GeneratedColumn<double>(
      'precio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        appointmentId,
        serviceId,
        precio
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointment_services';
  @override
  VerificationContext validateIntegrity(Insertable<AppointmentService> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('appointment_id')) {
      context.handle(
          _appointmentIdMeta,
          appointmentId.isAcceptableOrUnknown(
              data['appointment_id']!, _appointmentIdMeta));
    } else if (isInserting) {
      context.missing(_appointmentIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('precio')) {
      context.handle(_precioMeta,
          precio.isAcceptableOrUnknown(data['precio']!, _precioMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppointmentService map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppointmentService(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      appointmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}appointment_id'])!,
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_id'])!,
      precio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio'])!,
    );
  }

  @override
  $AppointmentServicesTable createAlias(String alias) {
    return $AppointmentServicesTable(attachedDatabase, alias);
  }
}

class AppointmentService extends DataClass
    implements Insertable<AppointmentService> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String appointmentId;
  final String serviceId;
  final double precio;
  const AppointmentService(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.appointmentId,
      required this.serviceId,
      required this.precio});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['appointment_id'] = Variable<String>(appointmentId);
    map['service_id'] = Variable<String>(serviceId);
    map['precio'] = Variable<double>(precio);
    return map;
  }

  AppointmentServicesCompanion toCompanion(bool nullToAbsent) {
    return AppointmentServicesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      appointmentId: Value(appointmentId),
      serviceId: Value(serviceId),
      precio: Value(precio),
    );
  }

  factory AppointmentService.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppointmentService(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      appointmentId: serializer.fromJson<String>(json['appointmentId']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      precio: serializer.fromJson<double>(json['precio']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'appointmentId': serializer.toJson<String>(appointmentId),
      'serviceId': serializer.toJson<String>(serviceId),
      'precio': serializer.toJson<double>(precio),
    };
  }

  AppointmentService copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? appointmentId,
          String? serviceId,
          double? precio}) =>
      AppointmentService(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        appointmentId: appointmentId ?? this.appointmentId,
        serviceId: serviceId ?? this.serviceId,
        precio: precio ?? this.precio,
      );
  AppointmentService copyWithCompanion(AppointmentServicesCompanion data) {
    return AppointmentService(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      appointmentId: data.appointmentId.present
          ? data.appointmentId.value
          : this.appointmentId,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      precio: data.precio.present ? data.precio.value : this.precio,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentService(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('serviceId: $serviceId, ')
          ..write('precio: $precio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      appointmentId, serviceId, precio);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppointmentService &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.appointmentId == this.appointmentId &&
          other.serviceId == this.serviceId &&
          other.precio == this.precio);
}

class AppointmentServicesCompanion extends UpdateCompanion<AppointmentService> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> appointmentId;
  final Value<String> serviceId;
  final Value<double> precio;
  final Value<int> rowid;
  const AppointmentServicesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.precio = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentServicesCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String appointmentId,
    required String serviceId,
    this.precio = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        appointmentId = Value(appointmentId),
        serviceId = Value(serviceId);
  static Insertable<AppointmentService> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? appointmentId,
    Expression<String>? serviceId,
    Expression<double>? precio,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (serviceId != null) 'service_id': serviceId,
      if (precio != null) 'precio': precio,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentServicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? appointmentId,
      Value<String>? serviceId,
      Value<double>? precio,
      Value<int>? rowid}) {
    return AppointmentServicesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      appointmentId: appointmentId ?? this.appointmentId,
      serviceId: serviceId ?? this.serviceId,
      precio: precio ?? this.precio,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (appointmentId.present) {
      map['appointment_id'] = Variable<String>(appointmentId.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (precio.present) {
      map['precio'] = Variable<double>(precio.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentServicesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('serviceId: $serviceId, ')
          ..write('precio: $precio, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
      'monto', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
      'fecha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metodoMeta = const VerificationMeta('metodo');
  @override
  late final GeneratedColumn<String> metodo = GeneratedColumn<String>(
      'metodo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _appointmentIdMeta =
      const VerificationMeta('appointmentId');
  @override
  late final GeneratedColumn<String> appointmentId = GeneratedColumn<String>(
      'appointment_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        tipo,
        monto,
        descripcion,
        categoria,
        fecha,
        metodo,
        clientId,
        appointmentId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
          _montoMeta, monto.isAcceptableOrUnknown(data['monto']!, _montoMeta));
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('metodo')) {
      context.handle(_metodoMeta,
          metodo.isAcceptableOrUnknown(data['metodo']!, _metodoMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('appointment_id')) {
      context.handle(
          _appointmentIdMeta,
          appointmentId.isAcceptableOrUnknown(
              data['appointment_id']!, _appointmentIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      monto: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria']),
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha'])!,
      metodo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metodo']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      appointmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}appointment_id']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String tipo;
  final double monto;
  final String? descripcion;
  final String? categoria;
  final String fecha;
  final String? metodo;

  /// En el legacy el CRM leía este campo pero nadie lo escribía, así que el
  /// total gastado por clienta salía siempre $0.
  final String? clientId;
  final String? appointmentId;
  const Transaction(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.tipo,
      required this.monto,
      this.descripcion,
      this.categoria,
      required this.fecha,
      this.metodo,
      this.clientId,
      this.appointmentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['tipo'] = Variable<String>(tipo);
    map['monto'] = Variable<double>(monto);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    map['fecha'] = Variable<String>(fecha);
    if (!nullToAbsent || metodo != null) {
      map['metodo'] = Variable<String>(metodo);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    if (!nullToAbsent || appointmentId != null) {
      map['appointment_id'] = Variable<String>(appointmentId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      tipo: Value(tipo),
      monto: Value(monto),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
      fecha: Value(fecha),
      metodo:
          metodo == null && nullToAbsent ? const Value.absent() : Value(metodo),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      appointmentId: appointmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(appointmentId),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      tipo: serializer.fromJson<String>(json['tipo']),
      monto: serializer.fromJson<double>(json['monto']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      categoria: serializer.fromJson<String?>(json['categoria']),
      fecha: serializer.fromJson<String>(json['fecha']),
      metodo: serializer.fromJson<String?>(json['metodo']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      appointmentId: serializer.fromJson<String?>(json['appointmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'tipo': serializer.toJson<String>(tipo),
      'monto': serializer.toJson<double>(monto),
      'descripcion': serializer.toJson<String?>(descripcion),
      'categoria': serializer.toJson<String?>(categoria),
      'fecha': serializer.toJson<String>(fecha),
      'metodo': serializer.toJson<String?>(metodo),
      'clientId': serializer.toJson<String?>(clientId),
      'appointmentId': serializer.toJson<String?>(appointmentId),
    };
  }

  Transaction copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? tipo,
          double? monto,
          Value<String?> descripcion = const Value.absent(),
          Value<String?> categoria = const Value.absent(),
          String? fecha,
          Value<String?> metodo = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          Value<String?> appointmentId = const Value.absent()}) =>
      Transaction(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        tipo: tipo ?? this.tipo,
        monto: monto ?? this.monto,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        categoria: categoria.present ? categoria.value : this.categoria,
        fecha: fecha ?? this.fecha,
        metodo: metodo.present ? metodo.value : this.metodo,
        clientId: clientId.present ? clientId.value : this.clientId,
        appointmentId:
            appointmentId.present ? appointmentId.value : this.appointmentId,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      monto: data.monto.present ? data.monto.value : this.monto,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      metodo: data.metodo.present ? data.metodo.value : this.metodo,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      appointmentId: data.appointmentId.present
          ? data.appointmentId.value
          : this.appointmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tipo: $tipo, ')
          ..write('monto: $monto, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoria: $categoria, ')
          ..write('fecha: $fecha, ')
          ..write('metodo: $metodo, ')
          ..write('clientId: $clientId, ')
          ..write('appointmentId: $appointmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      createdAt,
      updatedAt,
      deletedAt,
      tipo,
      monto,
      descripcion,
      categoria,
      fecha,
      metodo,
      clientId,
      appointmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.tipo == this.tipo &&
          other.monto == this.monto &&
          other.descripcion == this.descripcion &&
          other.categoria == this.categoria &&
          other.fecha == this.fecha &&
          other.metodo == this.metodo &&
          other.clientId == this.clientId &&
          other.appointmentId == this.appointmentId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> tipo;
  final Value<double> monto;
  final Value<String?> descripcion;
  final Value<String?> categoria;
  final Value<String> fecha;
  final Value<String?> metodo;
  final Value<String?> clientId;
  final Value<String?> appointmentId;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.tipo = const Value.absent(),
    this.monto = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.categoria = const Value.absent(),
    this.fecha = const Value.absent(),
    this.metodo = const Value.absent(),
    this.clientId = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String tipo,
    this.monto = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.categoria = const Value.absent(),
    required String fecha,
    this.metodo = const Value.absent(),
    this.clientId = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        tipo = Value(tipo),
        fecha = Value(fecha);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? tipo,
    Expression<double>? monto,
    Expression<String>? descripcion,
    Expression<String>? categoria,
    Expression<String>? fecha,
    Expression<String>? metodo,
    Expression<String>? clientId,
    Expression<String>? appointmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (tipo != null) 'tipo': tipo,
      if (monto != null) 'monto': monto,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoria != null) 'categoria': categoria,
      if (fecha != null) 'fecha': fecha,
      if (metodo != null) 'metodo': metodo,
      if (clientId != null) 'client_id': clientId,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? tipo,
      Value<double>? monto,
      Value<String?>? descripcion,
      Value<String?>? categoria,
      Value<String>? fecha,
      Value<String?>? metodo,
      Value<String?>? clientId,
      Value<String?>? appointmentId,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tipo: tipo ?? this.tipo,
      monto: monto ?? this.monto,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      fecha: fecha ?? this.fecha,
      metodo: metodo ?? this.metodo,
      clientId: clientId ?? this.clientId,
      appointmentId: appointmentId ?? this.appointmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (metodo.present) {
      map['metodo'] = Variable<String>(metodo.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (appointmentId.present) {
      map['appointment_id'] = Variable<String>(appointmentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tipo: $tipo, ')
          ..write('monto: $monto, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoria: $categoria, ')
          ..write('fecha: $fecha, ')
          ..write('metodo: $metodo, ')
          ..write('clientId: $clientId, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockItemsTable extends StockItems
    with TableInfo<$StockItemsTable, StockItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minimoMeta = const VerificationMeta('minimo');
  @override
  late final GeneratedColumn<int> minimo = GeneratedColumn<int>(
      'minimo', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unidadMeta = const VerificationMeta('unidad');
  @override
  late final GeneratedColumn<String> unidad = GeneratedColumn<String>(
      'unidad', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        nombre,
        categoria,
        cantidad,
        minimo,
        unidad
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_items';
  @override
  VerificationContext validateIntegrity(Insertable<StockItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    }
    if (data.containsKey('minimo')) {
      context.handle(_minimoMeta,
          minimo.isAcceptableOrUnknown(data['minimo']!, _minimoMeta));
    }
    if (data.containsKey('unidad')) {
      context.handle(_unidadMeta,
          unidad.isAcceptableOrUnknown(data['unidad']!, _unidadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria']),
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cantidad'])!,
      minimo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minimo'])!,
      unidad: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unidad']),
    );
  }

  @override
  $StockItemsTable createAlias(String alias) {
    return $StockItemsTable(attachedDatabase, alias);
  }
}

class StockItem extends DataClass implements Insertable<StockItem> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String nombre;
  final String? categoria;
  final int cantidad;
  final int minimo;
  final String? unidad;
  const StockItem(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.nombre,
      this.categoria,
      required this.cantidad,
      required this.minimo,
      this.unidad});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    map['cantidad'] = Variable<int>(cantidad);
    map['minimo'] = Variable<int>(minimo);
    if (!nullToAbsent || unidad != null) {
      map['unidad'] = Variable<String>(unidad);
    }
    return map;
  }

  StockItemsCompanion toCompanion(bool nullToAbsent) {
    return StockItemsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      nombre: Value(nombre),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
      cantidad: Value(cantidad),
      minimo: Value(minimo),
      unidad:
          unidad == null && nullToAbsent ? const Value.absent() : Value(unidad),
    );
  }

  factory StockItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockItem(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      categoria: serializer.fromJson<String?>(json['categoria']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      minimo: serializer.fromJson<int>(json['minimo']),
      unidad: serializer.fromJson<String?>(json['unidad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'nombre': serializer.toJson<String>(nombre),
      'categoria': serializer.toJson<String?>(categoria),
      'cantidad': serializer.toJson<int>(cantidad),
      'minimo': serializer.toJson<int>(minimo),
      'unidad': serializer.toJson<String?>(unidad),
    };
  }

  StockItem copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? nombre,
          Value<String?> categoria = const Value.absent(),
          int? cantidad,
          int? minimo,
          Value<String?> unidad = const Value.absent()}) =>
      StockItem(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        nombre: nombre ?? this.nombre,
        categoria: categoria.present ? categoria.value : this.categoria,
        cantidad: cantidad ?? this.cantidad,
        minimo: minimo ?? this.minimo,
        unidad: unidad.present ? unidad.value : this.unidad,
      );
  StockItem copyWithCompanion(StockItemsCompanion data) {
    return StockItem(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      minimo: data.minimo.present ? data.minimo.value : this.minimo,
      unidad: data.unidad.present ? data.unidad.value : this.unidad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockItem(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('cantidad: $cantidad, ')
          ..write('minimo: $minimo, ')
          ..write('unidad: $unidad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      nombre, categoria, cantidad, minimo, unidad);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockItem &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nombre == this.nombre &&
          other.categoria == this.categoria &&
          other.cantidad == this.cantidad &&
          other.minimo == this.minimo &&
          other.unidad == this.unidad);
}

class StockItemsCompanion extends UpdateCompanion<StockItem> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nombre;
  final Value<String?> categoria;
  final Value<int> cantidad;
  final Value<int> minimo;
  final Value<String?> unidad;
  final Value<int> rowid;
  const StockItemsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.categoria = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.minimo = const Value.absent(),
    this.unidad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockItemsCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String nombre,
    this.categoria = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.minimo = const Value.absent(),
    this.unidad = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        nombre = Value(nombre);
  static Insertable<StockItem> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nombre,
    Expression<String>? categoria,
    Expression<int>? cantidad,
    Expression<int>? minimo,
    Expression<String>? unidad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (nombre != null) 'nombre': nombre,
      if (categoria != null) 'categoria': categoria,
      if (cantidad != null) 'cantidad': cantidad,
      if (minimo != null) 'minimo': minimo,
      if (unidad != null) 'unidad': unidad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? nombre,
      Value<String?>? categoria,
      Value<int>? cantidad,
      Value<int>? minimo,
      Value<String?>? unidad,
      Value<int>? rowid}) {
    return StockItemsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      cantidad: cantidad ?? this.cantidad,
      minimo: minimo ?? this.minimo,
      unidad: unidad ?? this.unidad,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (minimo.present) {
      map['minimo'] = Variable<int>(minimo.value);
    }
    if (unidad.present) {
      map['unidad'] = Variable<String>(unidad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockItemsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('cantidad: $cantidad, ')
          ..write('minimo: $minimo, ')
          ..write('unidad: $unidad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
      'clave', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
      'valor', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [tenantId, clave, valor, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('clave')) {
      context.handle(
          _claveMeta, clave.isAcceptableOrUnknown(data['clave']!, _claveMeta));
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
          _valorMeta, valor.isAcceptableOrUnknown(data['valor']!, _valorMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId, clave};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      clave: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}clave'])!,
      valor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}valor']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String tenantId;
  final String clave;
  final String? valor;
  final DateTime updatedAt;
  const Setting(
      {required this.tenantId,
      required this.clave,
      this.valor,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tenant_id'] = Variable<String>(tenantId);
    map['clave'] = Variable<String>(clave);
    if (!nullToAbsent || valor != null) {
      map['valor'] = Variable<String>(valor);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      tenantId: Value(tenantId),
      clave: Value(clave),
      valor:
          valor == null && nullToAbsent ? const Value.absent() : Value(valor),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      tenantId: serializer.fromJson<String>(json['tenantId']),
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String?>(json['valor']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tenantId': serializer.toJson<String>(tenantId),
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String?>(valor),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith(
          {String? tenantId,
          String? clave,
          Value<String?> valor = const Value.absent(),
          DateTime? updatedAt}) =>
      Setting(
        tenantId: tenantId ?? this.tenantId,
        clave: clave ?? this.clave,
        valor: valor.present ? valor.value : this.valor,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('tenantId: $tenantId, ')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tenantId, clave, valor, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.tenantId == this.tenantId &&
          other.clave == this.clave &&
          other.valor == this.valor &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> tenantId;
  final Value<String> clave;
  final Value<String?> valor;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.tenantId = const Value.absent(),
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String tenantId,
    required String clave,
    this.valor = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tenantId = Value(tenantId),
        clave = Value(clave);
  static Insertable<Setting> custom({
    Expression<String>? tenantId,
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tenantId != null) 'tenant_id': tenantId,
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? tenantId,
      Value<String>? clave,
      Value<String?>? valor,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SettingsCompanion(
      tenantId: tenantId ?? this.tenantId,
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('tenantId: $tenantId, ')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tablaMeta = const VerificationMeta('tabla');
  @override
  late final GeneratedColumn<String> tabla = GeneratedColumn<String>(
      'tabla', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filaIdMeta = const VerificationMeta('filaId');
  @override
  late final GeneratedColumn<String> filaId = GeneratedColumn<String>(
      'fila_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operacionMeta =
      const VerificationMeta('operacion');
  @override
  late final GeneratedColumn<String> operacion = GeneratedColumn<String>(
      'operacion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intentosMeta =
      const VerificationMeta('intentos');
  @override
  late final GeneratedColumn<int> intentos = GeneratedColumn<int>(
      'intentos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _ultimoErrorMeta =
      const VerificationMeta('ultimoError');
  @override
  late final GeneratedColumn<String> ultimoError = GeneratedColumn<String>(
      'ultimo_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creadoAtMeta =
      const VerificationMeta('creadoAt');
  @override
  late final GeneratedColumn<DateTime> creadoAt = GeneratedColumn<DateTime>(
      'creado_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _reintentarAtMeta =
      const VerificationMeta('reintentarAt');
  @override
  late final GeneratedColumn<DateTime> reintentarAt = GeneratedColumn<DateTime>(
      'reintentar_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        tabla,
        filaId,
        operacion,
        payload,
        intentos,
        ultimoError,
        creadoAt,
        reintentarAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('tabla')) {
      context.handle(
          _tablaMeta, tabla.isAcceptableOrUnknown(data['tabla']!, _tablaMeta));
    } else if (isInserting) {
      context.missing(_tablaMeta);
    }
    if (data.containsKey('fila_id')) {
      context.handle(_filaIdMeta,
          filaId.isAcceptableOrUnknown(data['fila_id']!, _filaIdMeta));
    } else if (isInserting) {
      context.missing(_filaIdMeta);
    }
    if (data.containsKey('operacion')) {
      context.handle(_operacionMeta,
          operacion.isAcceptableOrUnknown(data['operacion']!, _operacionMeta));
    } else if (isInserting) {
      context.missing(_operacionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('intentos')) {
      context.handle(_intentosMeta,
          intentos.isAcceptableOrUnknown(data['intentos']!, _intentosMeta));
    }
    if (data.containsKey('ultimo_error')) {
      context.handle(
          _ultimoErrorMeta,
          ultimoError.isAcceptableOrUnknown(
              data['ultimo_error']!, _ultimoErrorMeta));
    }
    if (data.containsKey('creado_at')) {
      context.handle(_creadoAtMeta,
          creadoAt.isAcceptableOrUnknown(data['creado_at']!, _creadoAtMeta));
    }
    if (data.containsKey('reintentar_at')) {
      context.handle(
          _reintentarAtMeta,
          reintentarAt.isAcceptableOrUnknown(
              data['reintentar_at']!, _reintentarAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      tabla: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tabla'])!,
      filaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fila_id'])!,
      operacion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operacion'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      intentos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intentos'])!,
      ultimoError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ultimo_error']),
      creadoAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}creado_at'])!,
      reintentarAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reintentar_at']),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int id;
  final String tenantId;
  final String tabla;
  final String filaId;

  /// `upsert` | `delete` | `delta`
  final String operacion;

  /// JSON con los campos a mandar.
  final String payload;
  final int intentos;
  final String? ultimoError;
  final DateTime creadoAt;

  /// Cuándo volver a intentar. Alimenta el backoff exponencial.
  final DateTime? reintentarAt;
  const OutboxData(
      {required this.id,
      required this.tenantId,
      required this.tabla,
      required this.filaId,
      required this.operacion,
      required this.payload,
      required this.intentos,
      this.ultimoError,
      required this.creadoAt,
      this.reintentarAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['tabla'] = Variable<String>(tabla);
    map['fila_id'] = Variable<String>(filaId);
    map['operacion'] = Variable<String>(operacion);
    map['payload'] = Variable<String>(payload);
    map['intentos'] = Variable<int>(intentos);
    if (!nullToAbsent || ultimoError != null) {
      map['ultimo_error'] = Variable<String>(ultimoError);
    }
    map['creado_at'] = Variable<DateTime>(creadoAt);
    if (!nullToAbsent || reintentarAt != null) {
      map['reintentar_at'] = Variable<DateTime>(reintentarAt);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      tabla: Value(tabla),
      filaId: Value(filaId),
      operacion: Value(operacion),
      payload: Value(payload),
      intentos: Value(intentos),
      ultimoError: ultimoError == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoError),
      creadoAt: Value(creadoAt),
      reintentarAt: reintentarAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reintentarAt),
    );
  }

  factory OutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<int>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      tabla: serializer.fromJson<String>(json['tabla']),
      filaId: serializer.fromJson<String>(json['filaId']),
      operacion: serializer.fromJson<String>(json['operacion']),
      payload: serializer.fromJson<String>(json['payload']),
      intentos: serializer.fromJson<int>(json['intentos']),
      ultimoError: serializer.fromJson<String?>(json['ultimoError']),
      creadoAt: serializer.fromJson<DateTime>(json['creadoAt']),
      reintentarAt: serializer.fromJson<DateTime?>(json['reintentarAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'tabla': serializer.toJson<String>(tabla),
      'filaId': serializer.toJson<String>(filaId),
      'operacion': serializer.toJson<String>(operacion),
      'payload': serializer.toJson<String>(payload),
      'intentos': serializer.toJson<int>(intentos),
      'ultimoError': serializer.toJson<String?>(ultimoError),
      'creadoAt': serializer.toJson<DateTime>(creadoAt),
      'reintentarAt': serializer.toJson<DateTime?>(reintentarAt),
    };
  }

  OutboxData copyWith(
          {int? id,
          String? tenantId,
          String? tabla,
          String? filaId,
          String? operacion,
          String? payload,
          int? intentos,
          Value<String?> ultimoError = const Value.absent(),
          DateTime? creadoAt,
          Value<DateTime?> reintentarAt = const Value.absent()}) =>
      OutboxData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        tabla: tabla ?? this.tabla,
        filaId: filaId ?? this.filaId,
        operacion: operacion ?? this.operacion,
        payload: payload ?? this.payload,
        intentos: intentos ?? this.intentos,
        ultimoError: ultimoError.present ? ultimoError.value : this.ultimoError,
        creadoAt: creadoAt ?? this.creadoAt,
        reintentarAt:
            reintentarAt.present ? reintentarAt.value : this.reintentarAt,
      );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      tabla: data.tabla.present ? data.tabla.value : this.tabla,
      filaId: data.filaId.present ? data.filaId.value : this.filaId,
      operacion: data.operacion.present ? data.operacion.value : this.operacion,
      payload: data.payload.present ? data.payload.value : this.payload,
      intentos: data.intentos.present ? data.intentos.value : this.intentos,
      ultimoError:
          data.ultimoError.present ? data.ultimoError.value : this.ultimoError,
      creadoAt: data.creadoAt.present ? data.creadoAt.value : this.creadoAt,
      reintentarAt: data.reintentarAt.present
          ? data.reintentarAt.value
          : this.reintentarAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('tabla: $tabla, ')
          ..write('filaId: $filaId, ')
          ..write('operacion: $operacion, ')
          ..write('payload: $payload, ')
          ..write('intentos: $intentos, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('creadoAt: $creadoAt, ')
          ..write('reintentarAt: $reintentarAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, tabla, filaId, operacion,
      payload, intentos, ultimoError, creadoAt, reintentarAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.tabla == this.tabla &&
          other.filaId == this.filaId &&
          other.operacion == this.operacion &&
          other.payload == this.payload &&
          other.intentos == this.intentos &&
          other.ultimoError == this.ultimoError &&
          other.creadoAt == this.creadoAt &&
          other.reintentarAt == this.reintentarAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> id;
  final Value<String> tenantId;
  final Value<String> tabla;
  final Value<String> filaId;
  final Value<String> operacion;
  final Value<String> payload;
  final Value<int> intentos;
  final Value<String?> ultimoError;
  final Value<DateTime> creadoAt;
  final Value<DateTime?> reintentarAt;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.tabla = const Value.absent(),
    this.filaId = const Value.absent(),
    this.operacion = const Value.absent(),
    this.payload = const Value.absent(),
    this.intentos = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.creadoAt = const Value.absent(),
    this.reintentarAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String tenantId,
    required String tabla,
    required String filaId,
    required String operacion,
    required String payload,
    this.intentos = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.creadoAt = const Value.absent(),
    this.reintentarAt = const Value.absent(),
  })  : tenantId = Value(tenantId),
        tabla = Value(tabla),
        filaId = Value(filaId),
        operacion = Value(operacion),
        payload = Value(payload);
  static Insertable<OutboxData> custom({
    Expression<int>? id,
    Expression<String>? tenantId,
    Expression<String>? tabla,
    Expression<String>? filaId,
    Expression<String>? operacion,
    Expression<String>? payload,
    Expression<int>? intentos,
    Expression<String>? ultimoError,
    Expression<DateTime>? creadoAt,
    Expression<DateTime>? reintentarAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (tabla != null) 'tabla': tabla,
      if (filaId != null) 'fila_id': filaId,
      if (operacion != null) 'operacion': operacion,
      if (payload != null) 'payload': payload,
      if (intentos != null) 'intentos': intentos,
      if (ultimoError != null) 'ultimo_error': ultimoError,
      if (creadoAt != null) 'creado_at': creadoAt,
      if (reintentarAt != null) 'reintentar_at': reintentarAt,
    });
  }

  OutboxCompanion copyWith(
      {Value<int>? id,
      Value<String>? tenantId,
      Value<String>? tabla,
      Value<String>? filaId,
      Value<String>? operacion,
      Value<String>? payload,
      Value<int>? intentos,
      Value<String?>? ultimoError,
      Value<DateTime>? creadoAt,
      Value<DateTime?>? reintentarAt}) {
    return OutboxCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      tabla: tabla ?? this.tabla,
      filaId: filaId ?? this.filaId,
      operacion: operacion ?? this.operacion,
      payload: payload ?? this.payload,
      intentos: intentos ?? this.intentos,
      ultimoError: ultimoError ?? this.ultimoError,
      creadoAt: creadoAt ?? this.creadoAt,
      reintentarAt: reintentarAt ?? this.reintentarAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (tabla.present) {
      map['tabla'] = Variable<String>(tabla.value);
    }
    if (filaId.present) {
      map['fila_id'] = Variable<String>(filaId.value);
    }
    if (operacion.present) {
      map['operacion'] = Variable<String>(operacion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (intentos.present) {
      map['intentos'] = Variable<int>(intentos.value);
    }
    if (ultimoError.present) {
      map['ultimo_error'] = Variable<String>(ultimoError.value);
    }
    if (creadoAt.present) {
      map['creado_at'] = Variable<DateTime>(creadoAt.value);
    }
    if (reintentarAt.present) {
      map['reintentar_at'] = Variable<DateTime>(reintentarAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('tabla: $tabla, ')
          ..write('filaId: $filaId, ')
          ..write('operacion: $operacion, ')
          ..write('payload: $payload, ')
          ..write('intentos: $intentos, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('creadoAt: $creadoAt, ')
          ..write('reintentarAt: $reintentarAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tablaMeta = const VerificationMeta('tabla');
  @override
  late final GeneratedColumn<String> tabla = GeneratedColumn<String>(
      'tabla', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<DateTime> cursor = GeneratedColumn<DateTime>(
      'cursor', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _ultimoPullMeta =
      const VerificationMeta('ultimoPull');
  @override
  late final GeneratedColumn<DateTime> ultimoPull = GeneratedColumn<DateTime>(
      'ultimo_pull', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [tenantId, tabla, cursor, ultimoPull];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('tabla')) {
      context.handle(
          _tablaMeta, tabla.isAcceptableOrUnknown(data['tabla']!, _tablaMeta));
    } else if (isInserting) {
      context.missing(_tablaMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta,
          cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    }
    if (data.containsKey('ultimo_pull')) {
      context.handle(
          _ultimoPullMeta,
          ultimoPull.isAcceptableOrUnknown(
              data['ultimo_pull']!, _ultimoPullMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId, tabla};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      tabla: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tabla'])!,
      cursor: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cursor']),
      ultimoPull: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ultimo_pull']),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String tenantId;
  final String tabla;
  final DateTime? cursor;
  final DateTime? ultimoPull;
  const SyncStateData(
      {required this.tenantId,
      required this.tabla,
      this.cursor,
      this.ultimoPull});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tenant_id'] = Variable<String>(tenantId);
    map['tabla'] = Variable<String>(tabla);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<DateTime>(cursor);
    }
    if (!nullToAbsent || ultimoPull != null) {
      map['ultimo_pull'] = Variable<DateTime>(ultimoPull);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      tenantId: Value(tenantId),
      tabla: Value(tabla),
      cursor:
          cursor == null && nullToAbsent ? const Value.absent() : Value(cursor),
      ultimoPull: ultimoPull == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoPull),
    );
  }

  factory SyncStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      tenantId: serializer.fromJson<String>(json['tenantId']),
      tabla: serializer.fromJson<String>(json['tabla']),
      cursor: serializer.fromJson<DateTime?>(json['cursor']),
      ultimoPull: serializer.fromJson<DateTime?>(json['ultimoPull']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tenantId': serializer.toJson<String>(tenantId),
      'tabla': serializer.toJson<String>(tabla),
      'cursor': serializer.toJson<DateTime?>(cursor),
      'ultimoPull': serializer.toJson<DateTime?>(ultimoPull),
    };
  }

  SyncStateData copyWith(
          {String? tenantId,
          String? tabla,
          Value<DateTime?> cursor = const Value.absent(),
          Value<DateTime?> ultimoPull = const Value.absent()}) =>
      SyncStateData(
        tenantId: tenantId ?? this.tenantId,
        tabla: tabla ?? this.tabla,
        cursor: cursor.present ? cursor.value : this.cursor,
        ultimoPull: ultimoPull.present ? ultimoPull.value : this.ultimoPull,
      );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      tabla: data.tabla.present ? data.tabla.value : this.tabla,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      ultimoPull:
          data.ultimoPull.present ? data.ultimoPull.value : this.ultimoPull,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('tenantId: $tenantId, ')
          ..write('tabla: $tabla, ')
          ..write('cursor: $cursor, ')
          ..write('ultimoPull: $ultimoPull')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tenantId, tabla, cursor, ultimoPull);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.tenantId == this.tenantId &&
          other.tabla == this.tabla &&
          other.cursor == this.cursor &&
          other.ultimoPull == this.ultimoPull);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> tenantId;
  final Value<String> tabla;
  final Value<DateTime?> cursor;
  final Value<DateTime?> ultimoPull;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.tenantId = const Value.absent(),
    this.tabla = const Value.absent(),
    this.cursor = const Value.absent(),
    this.ultimoPull = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String tenantId,
    required String tabla,
    this.cursor = const Value.absent(),
    this.ultimoPull = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tenantId = Value(tenantId),
        tabla = Value(tabla);
  static Insertable<SyncStateData> custom({
    Expression<String>? tenantId,
    Expression<String>? tabla,
    Expression<DateTime>? cursor,
    Expression<DateTime>? ultimoPull,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tenantId != null) 'tenant_id': tenantId,
      if (tabla != null) 'tabla': tabla,
      if (cursor != null) 'cursor': cursor,
      if (ultimoPull != null) 'ultimo_pull': ultimoPull,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith(
      {Value<String>? tenantId,
      Value<String>? tabla,
      Value<DateTime?>? cursor,
      Value<DateTime?>? ultimoPull,
      Value<int>? rowid}) {
    return SyncStateCompanion(
      tenantId: tenantId ?? this.tenantId,
      tabla: tabla ?? this.tabla,
      cursor: cursor ?? this.cursor,
      ultimoPull: ultimoPull ?? this.ultimoPull,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (tabla.present) {
      map['tabla'] = Variable<String>(tabla.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<DateTime>(cursor.value);
    }
    if (ultimoPull.present) {
      map['ultimo_pull'] = Variable<DateTime>(ultimoPull.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('tenantId: $tenantId, ')
          ..write('tabla: $tabla, ')
          ..write('cursor: $cursor, ')
          ..write('ultimoPull: $ultimoPull, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccessCacheTable extends AccessCache
    with TableInfo<$AccessCacheTable, AccessCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccessCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
      'clave', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
      'json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guardadoAtMeta =
      const VerificationMeta('guardadoAt');
  @override
  late final GeneratedColumn<DateTime> guardadoAt = GeneratedColumn<DateTime>(
      'guardado_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [clave, json, guardadoAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'access_cache';
  @override
  VerificationContext validateIntegrity(Insertable<AccessCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clave')) {
      context.handle(
          _claveMeta, clave.isAcceptableOrUnknown(data['clave']!, _claveMeta));
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
          _jsonMeta, json.isAcceptableOrUnknown(data['json']!, _jsonMeta));
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('guardado_at')) {
      context.handle(
          _guardadoAtMeta,
          guardadoAt.isAcceptableOrUnknown(
              data['guardado_at']!, _guardadoAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clave};
  @override
  AccessCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccessCacheData(
      clave: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}clave'])!,
      json: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json'])!,
      guardadoAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}guardado_at'])!,
    );
  }

  @override
  $AccessCacheTable createAlias(String alias) {
    return $AccessCacheTable(attachedDatabase, alias);
  }
}

class AccessCacheData extends DataClass implements Insertable<AccessCacheData> {
  final String clave;
  final String json;
  final DateTime guardadoAt;
  const AccessCacheData(
      {required this.clave, required this.json, required this.guardadoAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clave'] = Variable<String>(clave);
    map['json'] = Variable<String>(json);
    map['guardado_at'] = Variable<DateTime>(guardadoAt);
    return map;
  }

  AccessCacheCompanion toCompanion(bool nullToAbsent) {
    return AccessCacheCompanion(
      clave: Value(clave),
      json: Value(json),
      guardadoAt: Value(guardadoAt),
    );
  }

  factory AccessCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccessCacheData(
      clave: serializer.fromJson<String>(json['clave']),
      json: serializer.fromJson<String>(json['json']),
      guardadoAt: serializer.fromJson<DateTime>(json['guardadoAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clave': serializer.toJson<String>(clave),
      'json': serializer.toJson<String>(json),
      'guardadoAt': serializer.toJson<DateTime>(guardadoAt),
    };
  }

  AccessCacheData copyWith(
          {String? clave, String? json, DateTime? guardadoAt}) =>
      AccessCacheData(
        clave: clave ?? this.clave,
        json: json ?? this.json,
        guardadoAt: guardadoAt ?? this.guardadoAt,
      );
  AccessCacheData copyWithCompanion(AccessCacheCompanion data) {
    return AccessCacheData(
      clave: data.clave.present ? data.clave.value : this.clave,
      json: data.json.present ? data.json.value : this.json,
      guardadoAt:
          data.guardadoAt.present ? data.guardadoAt.value : this.guardadoAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccessCacheData(')
          ..write('clave: $clave, ')
          ..write('json: $json, ')
          ..write('guardadoAt: $guardadoAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clave, json, guardadoAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccessCacheData &&
          other.clave == this.clave &&
          other.json == this.json &&
          other.guardadoAt == this.guardadoAt);
}

class AccessCacheCompanion extends UpdateCompanion<AccessCacheData> {
  final Value<String> clave;
  final Value<String> json;
  final Value<DateTime> guardadoAt;
  final Value<int> rowid;
  const AccessCacheCompanion({
    this.clave = const Value.absent(),
    this.json = const Value.absent(),
    this.guardadoAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccessCacheCompanion.insert({
    required String clave,
    required String json,
    this.guardadoAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : clave = Value(clave),
        json = Value(json);
  static Insertable<AccessCacheData> custom({
    Expression<String>? clave,
    Expression<String>? json,
    Expression<DateTime>? guardadoAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clave != null) 'clave': clave,
      if (json != null) 'json': json,
      if (guardadoAt != null) 'guardado_at': guardadoAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccessCacheCompanion copyWith(
      {Value<String>? clave,
      Value<String>? json,
      Value<DateTime>? guardadoAt,
      Value<int>? rowid}) {
    return AccessCacheCompanion(
      clave: clave ?? this.clave,
      json: json ?? this.json,
      guardadoAt: guardadoAt ?? this.guardadoAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (guardadoAt.present) {
      map['guardado_at'] = Variable<DateTime>(guardadoAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccessCacheCompanion(')
          ..write('clave: $clave, ')
          ..write('json: $json, ')
          ..write('guardadoAt: $guardadoAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MirameDb extends GeneratedDatabase {
  _$MirameDb(QueryExecutor e) : super(e);
  $MirameDbManager get managers => $MirameDbManager(this);
  late final $ProfessionalsTable professionals = $ProfessionalsTable(this);
  late final $ServicesTable services = $ServicesTable(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $AppointmentServicesTable appointmentServices =
      $AppointmentServicesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $StockItemsTable stockItems = $StockItemsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $AccessCacheTable accessCache = $AccessCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        professionals,
        services,
        clients,
        appointments,
        appointmentServices,
        transactions,
        stockItems,
        settings,
        outbox,
        syncState,
        accessCache
      ];
}

typedef $$ProfessionalsTableCreateCompanionBuilder = ProfessionalsCompanion
    Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String nombre,
  Value<String?> telefono,
  Value<int> rowid,
});
typedef $$ProfessionalsTableUpdateCompanionBuilder = ProfessionalsCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> nombre,
  Value<String?> telefono,
  Value<int> rowid,
});

class $$ProfessionalsTableFilterComposer
    extends Composer<_$MirameDb, $ProfessionalsTable> {
  $$ProfessionalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));
}

class $$ProfessionalsTableOrderingComposer
    extends Composer<_$MirameDb, $ProfessionalsTable> {
  $$ProfessionalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));
}

class $$ProfessionalsTableAnnotationComposer
    extends Composer<_$MirameDb, $ProfessionalsTable> {
  $$ProfessionalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);
}

class $$ProfessionalsTableTableManager extends RootTableManager<
    _$MirameDb,
    $ProfessionalsTable,
    Professional,
    $$ProfessionalsTableFilterComposer,
    $$ProfessionalsTableOrderingComposer,
    $$ProfessionalsTableAnnotationComposer,
    $$ProfessionalsTableCreateCompanionBuilder,
    $$ProfessionalsTableUpdateCompanionBuilder,
    (
      Professional,
      BaseReferences<_$MirameDb, $ProfessionalsTable, Professional>
    ),
    Professional,
    PrefetchHooks Function()> {
  $$ProfessionalsTableTableManager(_$MirameDb db, $ProfessionalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfessionalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfessionalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfessionalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfessionalsCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            telefono: telefono,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String nombre,
            Value<String?> telefono = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfessionalsCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            telefono: telefono,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProfessionalsTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ProfessionalsTable,
    Professional,
    $$ProfessionalsTableFilterComposer,
    $$ProfessionalsTableOrderingComposer,
    $$ProfessionalsTableAnnotationComposer,
    $$ProfessionalsTableCreateCompanionBuilder,
    $$ProfessionalsTableUpdateCompanionBuilder,
    (
      Professional,
      BaseReferences<_$MirameDb, $ProfessionalsTable, Professional>
    ),
    Professional,
    PrefetchHooks Function()>;
typedef $$ServicesTableCreateCompanionBuilder = ServicesCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String nombre,
  Value<double> precio,
  Value<int> duracionMin,
  Value<int?> retoqueDias,
  Value<int?> mantenimientoDias,
  Value<String?> notas,
  Value<int> rowid,
});
typedef $$ServicesTableUpdateCompanionBuilder = ServicesCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> nombre,
  Value<double> precio,
  Value<int> duracionMin,
  Value<int?> retoqueDias,
  Value<int?> mantenimientoDias,
  Value<String?> notas,
  Value<int> rowid,
});

class $$ServicesTableFilterComposer
    extends Composer<_$MirameDb, $ServicesTable> {
  $$ServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duracionMin => $composableBuilder(
      column: $table.duracionMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retoqueDias => $composableBuilder(
      column: $table.retoqueDias, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mantenimientoDias => $composableBuilder(
      column: $table.mantenimientoDias,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));
}

class $$ServicesTableOrderingComposer
    extends Composer<_$MirameDb, $ServicesTable> {
  $$ServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duracionMin => $composableBuilder(
      column: $table.duracionMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retoqueDias => $composableBuilder(
      column: $table.retoqueDias, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mantenimientoDias => $composableBuilder(
      column: $table.mantenimientoDias,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));
}

class $$ServicesTableAnnotationComposer
    extends Composer<_$MirameDb, $ServicesTable> {
  $$ServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<int> get duracionMin => $composableBuilder(
      column: $table.duracionMin, builder: (column) => column);

  GeneratedColumn<int> get retoqueDias => $composableBuilder(
      column: $table.retoqueDias, builder: (column) => column);

  GeneratedColumn<int> get mantenimientoDias => $composableBuilder(
      column: $table.mantenimientoDias, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$ServicesTableTableManager extends RootTableManager<
    _$MirameDb,
    $ServicesTable,
    Service,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (Service, BaseReferences<_$MirameDb, $ServicesTable, Service>),
    Service,
    PrefetchHooks Function()> {
  $$ServicesTableTableManager(_$MirameDb db, $ServicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<double> precio = const Value.absent(),
            Value<int> duracionMin = const Value.absent(),
            Value<int?> retoqueDias = const Value.absent(),
            Value<int?> mantenimientoDias = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServicesCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            precio: precio,
            duracionMin: duracionMin,
            retoqueDias: retoqueDias,
            mantenimientoDias: mantenimientoDias,
            notas: notas,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String nombre,
            Value<double> precio = const Value.absent(),
            Value<int> duracionMin = const Value.absent(),
            Value<int?> retoqueDias = const Value.absent(),
            Value<int?> mantenimientoDias = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServicesCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            precio: precio,
            duracionMin: duracionMin,
            retoqueDias: retoqueDias,
            mantenimientoDias: mantenimientoDias,
            notas: notas,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServicesTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ServicesTable,
    Service,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (Service, BaseReferences<_$MirameDb, $ServicesTable, Service>),
    Service,
    PrefetchHooks Function()>;
typedef $$ClientsTableCreateCompanionBuilder = ClientsCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String nombre,
  Value<String?> telefono,
  Value<String?> email,
  Value<DateTime?> cumple,
  Value<bool> vip,
  Value<String?> notas,
  Value<int> rowid,
});
typedef $$ClientsTableUpdateCompanionBuilder = ClientsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> nombre,
  Value<String?> telefono,
  Value<String?> email,
  Value<DateTime?> cumple,
  Value<bool> vip,
  Value<String?> notas,
  Value<int> rowid,
});

class $$ClientsTableFilterComposer extends Composer<_$MirameDb, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cumple => $composableBuilder(
      column: $table.cumple, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get vip => $composableBuilder(
      column: $table.vip, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));
}

class $$ClientsTableOrderingComposer
    extends Composer<_$MirameDb, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cumple => $composableBuilder(
      column: $table.cumple, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get vip => $composableBuilder(
      column: $table.vip, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$MirameDb, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get cumple =>
      $composableBuilder(column: $table.cumple, builder: (column) => column);

  GeneratedColumn<bool> get vip =>
      $composableBuilder(column: $table.vip, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$ClientsTableTableManager extends RootTableManager<
    _$MirameDb,
    $ClientsTable,
    Client,
    $$ClientsTableFilterComposer,
    $$ClientsTableOrderingComposer,
    $$ClientsTableAnnotationComposer,
    $$ClientsTableCreateCompanionBuilder,
    $$ClientsTableUpdateCompanionBuilder,
    (Client, BaseReferences<_$MirameDb, $ClientsTable, Client>),
    Client,
    PrefetchHooks Function()> {
  $$ClientsTableTableManager(_$MirameDb db, $ClientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<DateTime?> cumple = const Value.absent(),
            Value<bool> vip = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientsCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            telefono: telefono,
            email: email,
            cumple: cumple,
            vip: vip,
            notas: notas,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String nombre,
            Value<String?> telefono = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<DateTime?> cumple = const Value.absent(),
            Value<bool> vip = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientsCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            telefono: telefono,
            email: email,
            cumple: cumple,
            vip: vip,
            notas: notas,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClientsTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ClientsTable,
    Client,
    $$ClientsTableFilterComposer,
    $$ClientsTableOrderingComposer,
    $$ClientsTableAnnotationComposer,
    $$ClientsTableCreateCompanionBuilder,
    $$ClientsTableUpdateCompanionBuilder,
    (Client, BaseReferences<_$MirameDb, $ClientsTable, Client>),
    Client,
    PrefetchHooks Function()>;
typedef $$AppointmentsTableCreateCompanionBuilder = AppointmentsCompanion
    Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> clientId,
  Value<String?> professionalId,
  required String fecha,
  required String hora,
  Value<double> precio,
  Value<String> estado,
  Value<String?> notas,
  Value<int> rowid,
});
typedef $$AppointmentsTableUpdateCompanionBuilder = AppointmentsCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> clientId,
  Value<String?> professionalId,
  Value<String> fecha,
  Value<String> hora,
  Value<double> precio,
  Value<String> estado,
  Value<String?> notas,
  Value<int> rowid,
});

class $$AppointmentsTableFilterComposer
    extends Composer<_$MirameDb, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get professionalId => $composableBuilder(
      column: $table.professionalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hora => $composableBuilder(
      column: $table.hora, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$MirameDb, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get professionalId => $composableBuilder(
      column: $table.professionalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hora => $composableBuilder(
      column: $table.hora, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$MirameDb, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get professionalId => $composableBuilder(
      column: $table.professionalId, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get hora =>
      $composableBuilder(column: $table.hora, builder: (column) => column);

  GeneratedColumn<double> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$AppointmentsTableTableManager extends RootTableManager<
    _$MirameDb,
    $AppointmentsTable,
    Appointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (Appointment, BaseReferences<_$MirameDb, $AppointmentsTable, Appointment>),
    Appointment,
    PrefetchHooks Function()> {
  $$AppointmentsTableTableManager(_$MirameDb db, $AppointmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String?> professionalId = const Value.absent(),
            Value<String> fecha = const Value.absent(),
            Value<String> hora = const Value.absent(),
            Value<double> precio = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentsCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            clientId: clientId,
            professionalId: professionalId,
            fecha: fecha,
            hora: hora,
            precio: precio,
            estado: estado,
            notas: notas,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String?> professionalId = const Value.absent(),
            required String fecha,
            required String hora,
            Value<double> precio = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentsCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            clientId: clientId,
            professionalId: professionalId,
            fecha: fecha,
            hora: hora,
            precio: precio,
            estado: estado,
            notas: notas,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppointmentsTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $AppointmentsTable,
    Appointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (Appointment, BaseReferences<_$MirameDb, $AppointmentsTable, Appointment>),
    Appointment,
    PrefetchHooks Function()>;
typedef $$AppointmentServicesTableCreateCompanionBuilder
    = AppointmentServicesCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String appointmentId,
  required String serviceId,
  Value<double> precio,
  Value<int> rowid,
});
typedef $$AppointmentServicesTableUpdateCompanionBuilder
    = AppointmentServicesCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> appointmentId,
  Value<String> serviceId,
  Value<double> precio,
  Value<int> rowid,
});

class $$AppointmentServicesTableFilterComposer
    extends Composer<_$MirameDb, $AppointmentServicesTable> {
  $$AppointmentServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appointmentId => $composableBuilder(
      column: $table.appointmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnFilters(column));
}

class $$AppointmentServicesTableOrderingComposer
    extends Composer<_$MirameDb, $AppointmentServicesTable> {
  $$AppointmentServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appointmentId => $composableBuilder(
      column: $table.appointmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnOrderings(column));
}

class $$AppointmentServicesTableAnnotationComposer
    extends Composer<_$MirameDb, $AppointmentServicesTable> {
  $$AppointmentServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get appointmentId => $composableBuilder(
      column: $table.appointmentId, builder: (column) => column);

  GeneratedColumn<String> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<double> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);
}

class $$AppointmentServicesTableTableManager extends RootTableManager<
    _$MirameDb,
    $AppointmentServicesTable,
    AppointmentService,
    $$AppointmentServicesTableFilterComposer,
    $$AppointmentServicesTableOrderingComposer,
    $$AppointmentServicesTableAnnotationComposer,
    $$AppointmentServicesTableCreateCompanionBuilder,
    $$AppointmentServicesTableUpdateCompanionBuilder,
    (
      AppointmentService,
      BaseReferences<_$MirameDb, $AppointmentServicesTable, AppointmentService>
    ),
    AppointmentService,
    PrefetchHooks Function()> {
  $$AppointmentServicesTableTableManager(
      _$MirameDb db, $AppointmentServicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentServicesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentServicesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> appointmentId = const Value.absent(),
            Value<String> serviceId = const Value.absent(),
            Value<double> precio = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentServicesCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            appointmentId: appointmentId,
            serviceId: serviceId,
            precio: precio,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String appointmentId,
            required String serviceId,
            Value<double> precio = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentServicesCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            appointmentId: appointmentId,
            serviceId: serviceId,
            precio: precio,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppointmentServicesTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $AppointmentServicesTable,
    AppointmentService,
    $$AppointmentServicesTableFilterComposer,
    $$AppointmentServicesTableOrderingComposer,
    $$AppointmentServicesTableAnnotationComposer,
    $$AppointmentServicesTableCreateCompanionBuilder,
    $$AppointmentServicesTableUpdateCompanionBuilder,
    (
      AppointmentService,
      BaseReferences<_$MirameDb, $AppointmentServicesTable, AppointmentService>
    ),
    AppointmentService,
    PrefetchHooks Function()>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String tipo,
  Value<double> monto,
  Value<String?> descripcion,
  Value<String?> categoria,
  required String fecha,
  Value<String?> metodo,
  Value<String?> clientId,
  Value<String?> appointmentId,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> tipo,
  Value<double> monto,
  Value<String?> descripcion,
  Value<String?> categoria,
  Value<String> fecha,
  Value<String?> metodo,
  Value<String?> clientId,
  Value<String?> appointmentId,
  Value<int> rowid,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$MirameDb, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metodo => $composableBuilder(
      column: $table.metodo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appointmentId => $composableBuilder(
      column: $table.appointmentId, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$MirameDb, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metodo => $composableBuilder(
      column: $table.metodo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appointmentId => $composableBuilder(
      column: $table.appointmentId,
      builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$MirameDb, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get metodo =>
      $composableBuilder(column: $table.metodo, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get appointmentId => $composableBuilder(
      column: $table.appointmentId, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$MirameDb,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, BaseReferences<_$MirameDb, $TransactionsTable, Transaction>),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$MirameDb db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<double> monto = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String?> categoria = const Value.absent(),
            Value<String> fecha = const Value.absent(),
            Value<String?> metodo = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String?> appointmentId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            tipo: tipo,
            monto: monto,
            descripcion: descripcion,
            categoria: categoria,
            fecha: fecha,
            metodo: metodo,
            clientId: clientId,
            appointmentId: appointmentId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String tipo,
            Value<double> monto = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String?> categoria = const Value.absent(),
            required String fecha,
            Value<String?> metodo = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String?> appointmentId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            tipo: tipo,
            monto: monto,
            descripcion: descripcion,
            categoria: categoria,
            fecha: fecha,
            metodo: metodo,
            clientId: clientId,
            appointmentId: appointmentId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, BaseReferences<_$MirameDb, $TransactionsTable, Transaction>),
    Transaction,
    PrefetchHooks Function()>;
typedef $$StockItemsTableCreateCompanionBuilder = StockItemsCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String nombre,
  Value<String?> categoria,
  Value<int> cantidad,
  Value<int> minimo,
  Value<String?> unidad,
  Value<int> rowid,
});
typedef $$StockItemsTableUpdateCompanionBuilder = StockItemsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> nombre,
  Value<String?> categoria,
  Value<int> cantidad,
  Value<int> minimo,
  Value<String?> unidad,
  Value<int> rowid,
});

class $$StockItemsTableFilterComposer
    extends Composer<_$MirameDb, $StockItemsTable> {
  $$StockItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minimo => $composableBuilder(
      column: $table.minimo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unidad => $composableBuilder(
      column: $table.unidad, builder: (column) => ColumnFilters(column));
}

class $$StockItemsTableOrderingComposer
    extends Composer<_$MirameDb, $StockItemsTable> {
  $$StockItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minimo => $composableBuilder(
      column: $table.minimo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unidad => $composableBuilder(
      column: $table.unidad, builder: (column) => ColumnOrderings(column));
}

class $$StockItemsTableAnnotationComposer
    extends Composer<_$MirameDb, $StockItemsTable> {
  $$StockItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get minimo =>
      $composableBuilder(column: $table.minimo, builder: (column) => column);

  GeneratedColumn<String> get unidad =>
      $composableBuilder(column: $table.unidad, builder: (column) => column);
}

class $$StockItemsTableTableManager extends RootTableManager<
    _$MirameDb,
    $StockItemsTable,
    StockItem,
    $$StockItemsTableFilterComposer,
    $$StockItemsTableOrderingComposer,
    $$StockItemsTableAnnotationComposer,
    $$StockItemsTableCreateCompanionBuilder,
    $$StockItemsTableUpdateCompanionBuilder,
    (StockItem, BaseReferences<_$MirameDb, $StockItemsTable, StockItem>),
    StockItem,
    PrefetchHooks Function()> {
  $$StockItemsTableTableManager(_$MirameDb db, $StockItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> categoria = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<int> minimo = const Value.absent(),
            Value<String?> unidad = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockItemsCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            categoria: categoria,
            cantidad: cantidad,
            minimo: minimo,
            unidad: unidad,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String nombre,
            Value<String?> categoria = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<int> minimo = const Value.absent(),
            Value<String?> unidad = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockItemsCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            categoria: categoria,
            cantidad: cantidad,
            minimo: minimo,
            unidad: unidad,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockItemsTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $StockItemsTable,
    StockItem,
    $$StockItemsTableFilterComposer,
    $$StockItemsTableOrderingComposer,
    $$StockItemsTableAnnotationComposer,
    $$StockItemsTableCreateCompanionBuilder,
    $$StockItemsTableUpdateCompanionBuilder,
    (StockItem, BaseReferences<_$MirameDb, $StockItemsTable, StockItem>),
    StockItem,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String tenantId,
  required String clave,
  Value<String?> valor,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> tenantId,
  Value<String> clave,
  Value<String?> valor,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$MirameDb, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clave => $composableBuilder(
      column: $table.clave, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$MirameDb, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clave => $composableBuilder(
      column: $table.clave, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$MirameDb, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$MirameDb,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$MirameDb, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$MirameDb db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> tenantId = const Value.absent(),
            Value<String> clave = const Value.absent(),
            Value<String?> valor = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            tenantId: tenantId,
            clave: clave,
            valor: valor,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String tenantId,
            required String clave,
            Value<String?> valor = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            tenantId: tenantId,
            clave: clave,
            valor: valor,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$MirameDb, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  required String tenantId,
  required String tabla,
  required String filaId,
  required String operacion,
  required String payload,
  Value<int> intentos,
  Value<String?> ultimoError,
  Value<DateTime> creadoAt,
  Value<DateTime?> reintentarAt,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  Value<String> tenantId,
  Value<String> tabla,
  Value<String> filaId,
  Value<String> operacion,
  Value<String> payload,
  Value<int> intentos,
  Value<String?> ultimoError,
  Value<DateTime> creadoAt,
  Value<DateTime?> reintentarAt,
});

class $$OutboxTableFilterComposer extends Composer<_$MirameDb, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tabla => $composableBuilder(
      column: $table.tabla, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filaId => $composableBuilder(
      column: $table.filaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operacion => $composableBuilder(
      column: $table.operacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intentos => $composableBuilder(
      column: $table.intentos, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ultimoError => $composableBuilder(
      column: $table.ultimoError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get creadoAt => $composableBuilder(
      column: $table.creadoAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reintentarAt => $composableBuilder(
      column: $table.reintentarAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer extends Composer<_$MirameDb, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tabla => $composableBuilder(
      column: $table.tabla, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filaId => $composableBuilder(
      column: $table.filaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operacion => $composableBuilder(
      column: $table.operacion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intentos => $composableBuilder(
      column: $table.intentos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ultimoError => $composableBuilder(
      column: $table.ultimoError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get creadoAt => $composableBuilder(
      column: $table.creadoAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reintentarAt => $composableBuilder(
      column: $table.reintentarAt,
      builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$MirameDb, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get tabla =>
      $composableBuilder(column: $table.tabla, builder: (column) => column);

  GeneratedColumn<String> get filaId =>
      $composableBuilder(column: $table.filaId, builder: (column) => column);

  GeneratedColumn<String> get operacion =>
      $composableBuilder(column: $table.operacion, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get intentos =>
      $composableBuilder(column: $table.intentos, builder: (column) => column);

  GeneratedColumn<String> get ultimoError => $composableBuilder(
      column: $table.ultimoError, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoAt =>
      $composableBuilder(column: $table.creadoAt, builder: (column) => column);

  GeneratedColumn<DateTime> get reintentarAt => $composableBuilder(
      column: $table.reintentarAt, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$MirameDb,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$MirameDb, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$MirameDb db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> tabla = const Value.absent(),
            Value<String> filaId = const Value.absent(),
            Value<String> operacion = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> intentos = const Value.absent(),
            Value<String?> ultimoError = const Value.absent(),
            Value<DateTime> creadoAt = const Value.absent(),
            Value<DateTime?> reintentarAt = const Value.absent(),
          }) =>
              OutboxCompanion(
            id: id,
            tenantId: tenantId,
            tabla: tabla,
            filaId: filaId,
            operacion: operacion,
            payload: payload,
            intentos: intentos,
            ultimoError: ultimoError,
            creadoAt: creadoAt,
            reintentarAt: reintentarAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String tenantId,
            required String tabla,
            required String filaId,
            required String operacion,
            required String payload,
            Value<int> intentos = const Value.absent(),
            Value<String?> ultimoError = const Value.absent(),
            Value<DateTime> creadoAt = const Value.absent(),
            Value<DateTime?> reintentarAt = const Value.absent(),
          }) =>
              OutboxCompanion.insert(
            id: id,
            tenantId: tenantId,
            tabla: tabla,
            filaId: filaId,
            operacion: operacion,
            payload: payload,
            intentos: intentos,
            ultimoError: ultimoError,
            creadoAt: creadoAt,
            reintentarAt: reintentarAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$MirameDb, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()>;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String tenantId,
  required String tabla,
  Value<DateTime?> cursor,
  Value<DateTime?> ultimoPull,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> tenantId,
  Value<String> tabla,
  Value<DateTime?> cursor,
  Value<DateTime?> ultimoPull,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$MirameDb, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tabla => $composableBuilder(
      column: $table.tabla, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get ultimoPull => $composableBuilder(
      column: $table.ultimoPull, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$MirameDb, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tabla => $composableBuilder(
      column: $table.tabla, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get ultimoPull => $composableBuilder(
      column: $table.ultimoPull, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$MirameDb, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get tabla =>
      $composableBuilder(column: $table.tabla, builder: (column) => column);

  GeneratedColumn<DateTime> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get ultimoPull => $composableBuilder(
      column: $table.ultimoPull, builder: (column) => column);
}

class $$SyncStateTableTableManager extends RootTableManager<
    _$MirameDb,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (SyncStateData, BaseReferences<_$MirameDb, $SyncStateTable, SyncStateData>),
    SyncStateData,
    PrefetchHooks Function()> {
  $$SyncStateTableTableManager(_$MirameDb db, $SyncStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> tenantId = const Value.absent(),
            Value<String> tabla = const Value.absent(),
            Value<DateTime?> cursor = const Value.absent(),
            Value<DateTime?> ultimoPull = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion(
            tenantId: tenantId,
            tabla: tabla,
            cursor: cursor,
            ultimoPull: ultimoPull,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String tenantId,
            required String tabla,
            Value<DateTime?> cursor = const Value.absent(),
            Value<DateTime?> ultimoPull = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion.insert(
            tenantId: tenantId,
            tabla: tabla,
            cursor: cursor,
            ultimoPull: ultimoPull,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (SyncStateData, BaseReferences<_$MirameDb, $SyncStateTable, SyncStateData>),
    SyncStateData,
    PrefetchHooks Function()>;
typedef $$AccessCacheTableCreateCompanionBuilder = AccessCacheCompanion
    Function({
  required String clave,
  required String json,
  Value<DateTime> guardadoAt,
  Value<int> rowid,
});
typedef $$AccessCacheTableUpdateCompanionBuilder = AccessCacheCompanion
    Function({
  Value<String> clave,
  Value<String> json,
  Value<DateTime> guardadoAt,
  Value<int> rowid,
});

class $$AccessCacheTableFilterComposer
    extends Composer<_$MirameDb, $AccessCacheTable> {
  $$AccessCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clave => $composableBuilder(
      column: $table.clave, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get json => $composableBuilder(
      column: $table.json, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get guardadoAt => $composableBuilder(
      column: $table.guardadoAt, builder: (column) => ColumnFilters(column));
}

class $$AccessCacheTableOrderingComposer
    extends Composer<_$MirameDb, $AccessCacheTable> {
  $$AccessCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clave => $composableBuilder(
      column: $table.clave, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get json => $composableBuilder(
      column: $table.json, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get guardadoAt => $composableBuilder(
      column: $table.guardadoAt, builder: (column) => ColumnOrderings(column));
}

class $$AccessCacheTableAnnotationComposer
    extends Composer<_$MirameDb, $AccessCacheTable> {
  $$AccessCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get guardadoAt => $composableBuilder(
      column: $table.guardadoAt, builder: (column) => column);
}

class $$AccessCacheTableTableManager extends RootTableManager<
    _$MirameDb,
    $AccessCacheTable,
    AccessCacheData,
    $$AccessCacheTableFilterComposer,
    $$AccessCacheTableOrderingComposer,
    $$AccessCacheTableAnnotationComposer,
    $$AccessCacheTableCreateCompanionBuilder,
    $$AccessCacheTableUpdateCompanionBuilder,
    (
      AccessCacheData,
      BaseReferences<_$MirameDb, $AccessCacheTable, AccessCacheData>
    ),
    AccessCacheData,
    PrefetchHooks Function()> {
  $$AccessCacheTableTableManager(_$MirameDb db, $AccessCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccessCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccessCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccessCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> clave = const Value.absent(),
            Value<String> json = const Value.absent(),
            Value<DateTime> guardadoAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccessCacheCompanion(
            clave: clave,
            json: json,
            guardadoAt: guardadoAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String clave,
            required String json,
            Value<DateTime> guardadoAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccessCacheCompanion.insert(
            clave: clave,
            json: json,
            guardadoAt: guardadoAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccessCacheTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $AccessCacheTable,
    AccessCacheData,
    $$AccessCacheTableFilterComposer,
    $$AccessCacheTableOrderingComposer,
    $$AccessCacheTableAnnotationComposer,
    $$AccessCacheTableCreateCompanionBuilder,
    $$AccessCacheTableUpdateCompanionBuilder,
    (
      AccessCacheData,
      BaseReferences<_$MirameDb, $AccessCacheTable, AccessCacheData>
    ),
    AccessCacheData,
    PrefetchHooks Function()>;

class $MirameDbManager {
  final _$MirameDb _db;
  $MirameDbManager(this._db);
  $$ProfessionalsTableTableManager get professionals =>
      $$ProfessionalsTableTableManager(_db, _db.professionals);
  $$ServicesTableTableManager get services =>
      $$ServicesTableTableManager(_db, _db.services);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$AppointmentServicesTableTableManager get appointmentServices =>
      $$AppointmentServicesTableTableManager(_db, _db.appointmentServices);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$StockItemsTableTableManager get stockItems =>
      $$StockItemsTableTableManager(_db, _db.stockItems);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$AccessCacheTableTableManager get accessCache =>
      $$AccessCacheTableTableManager(_db, _db.accessCache);
}
