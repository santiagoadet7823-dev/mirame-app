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
      defaultValue: const Constant('confirmed'));
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

  /// `confirmed` | `pending` | `done` | `cancelled` — enum `turno_estado`
  /// del servidor. El default del original tambien es 'confirmed'.
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
  List<GeneratedColumn> get $columns => [appointmentId, serviceId, precio];
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
  Set<GeneratedColumn> get $primaryKey => {appointmentId, serviceId};
  @override
  AppointmentService map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppointmentService(
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
  final String appointmentId;
  final String serviceId;
  final double precio;
  const AppointmentService(
      {required this.appointmentId,
      required this.serviceId,
      required this.precio});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['appointment_id'] = Variable<String>(appointmentId);
    map['service_id'] = Variable<String>(serviceId);
    map['precio'] = Variable<double>(precio);
    return map;
  }

  AppointmentServicesCompanion toCompanion(bool nullToAbsent) {
    return AppointmentServicesCompanion(
      appointmentId: Value(appointmentId),
      serviceId: Value(serviceId),
      precio: Value(precio),
    );
  }

  factory AppointmentService.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppointmentService(
      appointmentId: serializer.fromJson<String>(json['appointmentId']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      precio: serializer.fromJson<double>(json['precio']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'appointmentId': serializer.toJson<String>(appointmentId),
      'serviceId': serializer.toJson<String>(serviceId),
      'precio': serializer.toJson<double>(precio),
    };
  }

  AppointmentService copyWith(
          {String? appointmentId, String? serviceId, double? precio}) =>
      AppointmentService(
        appointmentId: appointmentId ?? this.appointmentId,
        serviceId: serviceId ?? this.serviceId,
        precio: precio ?? this.precio,
      );
  AppointmentService copyWithCompanion(AppointmentServicesCompanion data) {
    return AppointmentService(
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
          ..write('appointmentId: $appointmentId, ')
          ..write('serviceId: $serviceId, ')
          ..write('precio: $precio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(appointmentId, serviceId, precio);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppointmentService &&
          other.appointmentId == this.appointmentId &&
          other.serviceId == this.serviceId &&
          other.precio == this.precio);
}

class AppointmentServicesCompanion extends UpdateCompanion<AppointmentService> {
  final Value<String> appointmentId;
  final Value<String> serviceId;
  final Value<double> precio;
  final Value<int> rowid;
  const AppointmentServicesCompanion({
    this.appointmentId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.precio = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentServicesCompanion.insert({
    required String appointmentId,
    required String serviceId,
    this.precio = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : appointmentId = Value(appointmentId),
        serviceId = Value(serviceId);
  static Insertable<AppointmentService> custom({
    Expression<String>? appointmentId,
    Expression<String>? serviceId,
    Expression<double>? precio,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (serviceId != null) 'service_id': serviceId,
      if (precio != null) 'precio': precio,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentServicesCompanion copyWith(
      {Value<String>? appointmentId,
      Value<String>? serviceId,
      Value<double>? precio,
      Value<int>? rowid}) {
    return AppointmentServicesCompanion(
      appointmentId: appointmentId ?? this.appointmentId,
      serviceId: serviceId ?? this.serviceId,
      precio: precio ?? this.precio,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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

  /// `income` | `expense` — los valores EXACTOS del enum `tx_tipo` de
  /// Postgres. No 'ingreso'/'gasto': el servidor rechaza cualquier otra cosa
  /// y la fila se queda dando vueltas en el outbox hasta agotar reintentos,
  /// sin que nadie se entere.
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

class $ProveedoresTable extends Proveedores
    with TableInfo<$ProveedoresTable, Proveedore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProveedoresTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pctSalonMeta =
      const VerificationMeta('pctSalon');
  @override
  late final GeneratedColumn<double> pctSalon = GeneratedColumn<double>(
      'pct_salon', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _descuentoLoAbsorbeSalonMeta =
      const VerificationMeta('descuentoLoAbsorbeSalon');
  @override
  late final GeneratedColumn<bool> descuentoLoAbsorbeSalon =
      GeneratedColumn<bool>('descuento_lo_absorbe_salon', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("descuento_lo_absorbe_salon" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
      'notas', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
      'activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activo" IN (0, 1))'),
      defaultValue: const Constant(true));
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
        pctSalon,
        descuentoLoAbsorbeSalon,
        notas,
        activo
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proveedores';
  @override
  VerificationContext validateIntegrity(Insertable<Proveedore> instance,
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
    if (data.containsKey('pct_salon')) {
      context.handle(_pctSalonMeta,
          pctSalon.isAcceptableOrUnknown(data['pct_salon']!, _pctSalonMeta));
    }
    if (data.containsKey('descuento_lo_absorbe_salon')) {
      context.handle(
          _descuentoLoAbsorbeSalonMeta,
          descuentoLoAbsorbeSalon.isAcceptableOrUnknown(
              data['descuento_lo_absorbe_salon']!,
              _descuentoLoAbsorbeSalonMeta));
    }
    if (data.containsKey('notas')) {
      context.handle(
          _notasMeta, notas.isAcceptableOrUnknown(data['notas']!, _notasMeta));
    }
    if (data.containsKey('activo')) {
      context.handle(_activoMeta,
          activo.isAcceptableOrUnknown(data['activo']!, _activoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Proveedore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Proveedore(
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
      pctSalon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pct_salon'])!,
      descuentoLoAbsorbeSalon: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}descuento_lo_absorbe_salon'])!,
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
      activo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activo'])!,
    );
  }

  @override
  $ProveedoresTable createAlias(String alias) {
    return $ProveedoresTable(attachedDatabase, alias);
  }
}

class Proveedore extends DataClass implements Insertable<Proveedore> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String nombre;
  final String? telefono;
  final String? email;

  /// Porcentaje que se queda EL SALÓN. Es el default de sus productos.
  final double pctSalon;

  /// Si el salón hace un descuento, ¿lo absorbe solo o lo comparte el
  /// proveedor? Lo habitual en consignación es que lo absorba el salón.
  final bool descuentoLoAbsorbeSalon;
  final String? notas;
  final bool activo;
  const Proveedore(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.nombre,
      this.telefono,
      this.email,
      required this.pctSalon,
      required this.descuentoLoAbsorbeSalon,
      this.notas,
      required this.activo});
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
    map['pct_salon'] = Variable<double>(pctSalon);
    map['descuento_lo_absorbe_salon'] = Variable<bool>(descuentoLoAbsorbeSalon);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  ProveedoresCompanion toCompanion(bool nullToAbsent) {
    return ProveedoresCompanion(
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
      pctSalon: Value(pctSalon),
      descuentoLoAbsorbeSalon: Value(descuentoLoAbsorbeSalon),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
      activo: Value(activo),
    );
  }

  factory Proveedore.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Proveedore(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      pctSalon: serializer.fromJson<double>(json['pctSalon']),
      descuentoLoAbsorbeSalon:
          serializer.fromJson<bool>(json['descuentoLoAbsorbeSalon']),
      notas: serializer.fromJson<String?>(json['notas']),
      activo: serializer.fromJson<bool>(json['activo']),
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
      'pctSalon': serializer.toJson<double>(pctSalon),
      'descuentoLoAbsorbeSalon':
          serializer.toJson<bool>(descuentoLoAbsorbeSalon),
      'notas': serializer.toJson<String?>(notas),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  Proveedore copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? nombre,
          Value<String?> telefono = const Value.absent(),
          Value<String?> email = const Value.absent(),
          double? pctSalon,
          bool? descuentoLoAbsorbeSalon,
          Value<String?> notas = const Value.absent(),
          bool? activo}) =>
      Proveedore(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        nombre: nombre ?? this.nombre,
        telefono: telefono.present ? telefono.value : this.telefono,
        email: email.present ? email.value : this.email,
        pctSalon: pctSalon ?? this.pctSalon,
        descuentoLoAbsorbeSalon:
            descuentoLoAbsorbeSalon ?? this.descuentoLoAbsorbeSalon,
        notas: notas.present ? notas.value : this.notas,
        activo: activo ?? this.activo,
      );
  Proveedore copyWithCompanion(ProveedoresCompanion data) {
    return Proveedore(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      email: data.email.present ? data.email.value : this.email,
      pctSalon: data.pctSalon.present ? data.pctSalon.value : this.pctSalon,
      descuentoLoAbsorbeSalon: data.descuentoLoAbsorbeSalon.present
          ? data.descuentoLoAbsorbeSalon.value
          : this.descuentoLoAbsorbeSalon,
      notas: data.notas.present ? data.notas.value : this.notas,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Proveedore(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('pctSalon: $pctSalon, ')
          ..write('descuentoLoAbsorbeSalon: $descuentoLoAbsorbeSalon, ')
          ..write('notas: $notas, ')
          ..write('activo: $activo')
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
      nombre,
      telefono,
      email,
      pctSalon,
      descuentoLoAbsorbeSalon,
      notas,
      activo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Proveedore &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.pctSalon == this.pctSalon &&
          other.descuentoLoAbsorbeSalon == this.descuentoLoAbsorbeSalon &&
          other.notas == this.notas &&
          other.activo == this.activo);
}

class ProveedoresCompanion extends UpdateCompanion<Proveedore> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<String?> email;
  final Value<double> pctSalon;
  final Value<bool> descuentoLoAbsorbeSalon;
  final Value<String?> notas;
  final Value<bool> activo;
  final Value<int> rowid;
  const ProveedoresCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.pctSalon = const Value.absent(),
    this.descuentoLoAbsorbeSalon = const Value.absent(),
    this.notas = const Value.absent(),
    this.activo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProveedoresCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String nombre,
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.pctSalon = const Value.absent(),
    this.descuentoLoAbsorbeSalon = const Value.absent(),
    this.notas = const Value.absent(),
    this.activo = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        nombre = Value(nombre);
  static Insertable<Proveedore> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<double>? pctSalon,
    Expression<bool>? descuentoLoAbsorbeSalon,
    Expression<String>? notas,
    Expression<bool>? activo,
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
      if (pctSalon != null) 'pct_salon': pctSalon,
      if (descuentoLoAbsorbeSalon != null)
        'descuento_lo_absorbe_salon': descuentoLoAbsorbeSalon,
      if (notas != null) 'notas': notas,
      if (activo != null) 'activo': activo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProveedoresCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? nombre,
      Value<String?>? telefono,
      Value<String?>? email,
      Value<double>? pctSalon,
      Value<bool>? descuentoLoAbsorbeSalon,
      Value<String?>? notas,
      Value<bool>? activo,
      Value<int>? rowid}) {
    return ProveedoresCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      pctSalon: pctSalon ?? this.pctSalon,
      descuentoLoAbsorbeSalon:
          descuentoLoAbsorbeSalon ?? this.descuentoLoAbsorbeSalon,
      notas: notas ?? this.notas,
      activo: activo ?? this.activo,
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
    if (pctSalon.present) {
      map['pct_salon'] = Variable<double>(pctSalon.value);
    }
    if (descuentoLoAbsorbeSalon.present) {
      map['descuento_lo_absorbe_salon'] =
          Variable<bool>(descuentoLoAbsorbeSalon.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProveedoresCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('pctSalon: $pctSalon, ')
          ..write('descuentoLoAbsorbeSalon: $descuentoLoAbsorbeSalon, ')
          ..write('notas: $notas, ')
          ..write('activo: $activo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DepositosTable extends Depositos
    with TableInfo<$DepositosTable, Deposito> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepositosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _esPrincipalMeta =
      const VerificationMeta('esPrincipal');
  @override
  late final GeneratedColumn<bool> esPrincipal = GeneratedColumn<bool>(
      'es_principal', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("es_principal" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        nombre,
        direccion,
        esPrincipal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'depositos';
  @override
  VerificationContext validateIntegrity(Insertable<Deposito> instance,
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
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    }
    if (data.containsKey('es_principal')) {
      context.handle(
          _esPrincipalMeta,
          esPrincipal.isAcceptableOrUnknown(
              data['es_principal']!, _esPrincipalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deposito map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deposito(
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
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion']),
      esPrincipal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_principal'])!,
    );
  }

  @override
  $DepositosTable createAlias(String alias) {
    return $DepositosTable(attachedDatabase, alias);
  }
}

class Deposito extends DataClass implements Insertable<Deposito> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String nombre;
  final String? direccion;
  final bool esPrincipal;
  const Deposito(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.nombre,
      this.direccion,
      required this.esPrincipal});
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
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    map['es_principal'] = Variable<bool>(esPrincipal);
    return map;
  }

  DepositosCompanion toCompanion(bool nullToAbsent) {
    return DepositosCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      nombre: Value(nombre),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      esPrincipal: Value(esPrincipal),
    );
  }

  factory Deposito.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deposito(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      esPrincipal: serializer.fromJson<bool>(json['esPrincipal']),
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
      'direccion': serializer.toJson<String?>(direccion),
      'esPrincipal': serializer.toJson<bool>(esPrincipal),
    };
  }

  Deposito copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? nombre,
          Value<String?> direccion = const Value.absent(),
          bool? esPrincipal}) =>
      Deposito(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        nombre: nombre ?? this.nombre,
        direccion: direccion.present ? direccion.value : this.direccion,
        esPrincipal: esPrincipal ?? this.esPrincipal,
      );
  Deposito copyWithCompanion(DepositosCompanion data) {
    return Deposito(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      esPrincipal:
          data.esPrincipal.present ? data.esPrincipal.value : this.esPrincipal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deposito(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('direccion: $direccion, ')
          ..write('esPrincipal: $esPrincipal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      nombre, direccion, esPrincipal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deposito &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nombre == this.nombre &&
          other.direccion == this.direccion &&
          other.esPrincipal == this.esPrincipal);
}

class DepositosCompanion extends UpdateCompanion<Deposito> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nombre;
  final Value<String?> direccion;
  final Value<bool> esPrincipal;
  final Value<int> rowid;
  const DepositosCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.direccion = const Value.absent(),
    this.esPrincipal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DepositosCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String nombre,
    this.direccion = const Value.absent(),
    this.esPrincipal = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        nombre = Value(nombre);
  static Insertable<Deposito> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nombre,
    Expression<String>? direccion,
    Expression<bool>? esPrincipal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (nombre != null) 'nombre': nombre,
      if (direccion != null) 'direccion': direccion,
      if (esPrincipal != null) 'es_principal': esPrincipal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DepositosCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? nombre,
      Value<String?>? direccion,
      Value<bool>? esPrincipal,
      Value<int>? rowid}) {
    return DepositosCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      esPrincipal: esPrincipal ?? this.esPrincipal,
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
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (esPrincipal.present) {
      map['es_principal'] = Variable<bool>(esPrincipal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepositosCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nombre: $nombre, ')
          ..write('direccion: $direccion, ')
          ..write('esPrincipal: $esPrincipal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _proveedorIdMeta =
      const VerificationMeta('proveedorId');
  @override
  late final GeneratedColumn<String> proveedorId = GeneratedColumn<String>(
      'proveedor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
      'codigo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<double> precio = GeneratedColumn<double>(
      'precio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pctSalonMeta =
      const VerificationMeta('pctSalon');
  @override
  late final GeneratedColumn<double> pctSalon = GeneratedColumn<double>(
      'pct_salon', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _publicadoMeta =
      const VerificationMeta('publicado');
  @override
  late final GeneratedColumn<bool> publicado = GeneratedColumn<bool>(
      'publicado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("publicado" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _destacadoMeta =
      const VerificationMeta('destacado');
  @override
  late final GeneratedColumn<bool> destacado = GeneratedColumn<bool>(
      'destacado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("destacado" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        proveedorId,
        nombre,
        descripcion,
        categoria,
        codigo,
        precio,
        pctSalon,
        publicado,
        destacado
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(Insertable<Producto> instance,
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
    if (data.containsKey('proveedor_id')) {
      context.handle(
          _proveedorIdMeta,
          proveedorId.isAcceptableOrUnknown(
              data['proveedor_id']!, _proveedorIdMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
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
    if (data.containsKey('codigo')) {
      context.handle(_codigoMeta,
          codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta));
    }
    if (data.containsKey('precio')) {
      context.handle(_precioMeta,
          precio.isAcceptableOrUnknown(data['precio']!, _precioMeta));
    }
    if (data.containsKey('pct_salon')) {
      context.handle(_pctSalonMeta,
          pctSalon.isAcceptableOrUnknown(data['pct_salon']!, _pctSalonMeta));
    }
    if (data.containsKey('publicado')) {
      context.handle(_publicadoMeta,
          publicado.isAcceptableOrUnknown(data['publicado']!, _publicadoMeta));
    }
    if (data.containsKey('destacado')) {
      context.handle(_destacadoMeta,
          destacado.isAcceptableOrUnknown(data['destacado']!, _destacadoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
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
      proveedorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}proveedor_id']),
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria']),
      codigo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codigo']),
      precio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio'])!,
      pctSalon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pct_salon']),
      publicado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}publicado'])!,
      destacado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}destacado'])!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? proveedorId;
  final String nombre;
  final String? descripcion;
  final String? categoria;

  /// Código corto tipo `MIR-042`, para buscarla al instante y para que la
  /// clienta la nombre por WhatsApp sin describirla.
  final String? codigo;
  final double precio;

  /// Pisa el del proveedor cuando este producto tiene otro acuerdo.
  final double? pctSalon;
  final bool publicado;
  final bool destacado;
  const Producto(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.proveedorId,
      required this.nombre,
      this.descripcion,
      this.categoria,
      this.codigo,
      required this.precio,
      this.pctSalon,
      required this.publicado,
      required this.destacado});
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
    if (!nullToAbsent || proveedorId != null) {
      map['proveedor_id'] = Variable<String>(proveedorId);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    if (!nullToAbsent || codigo != null) {
      map['codigo'] = Variable<String>(codigo);
    }
    map['precio'] = Variable<double>(precio);
    if (!nullToAbsent || pctSalon != null) {
      map['pct_salon'] = Variable<double>(pctSalon);
    }
    map['publicado'] = Variable<bool>(publicado);
    map['destacado'] = Variable<bool>(destacado);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      proveedorId: proveedorId == null && nullToAbsent
          ? const Value.absent()
          : Value(proveedorId),
      nombre: Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
      codigo:
          codigo == null && nullToAbsent ? const Value.absent() : Value(codigo),
      precio: Value(precio),
      pctSalon: pctSalon == null && nullToAbsent
          ? const Value.absent()
          : Value(pctSalon),
      publicado: Value(publicado),
      destacado: Value(destacado),
    );
  }

  factory Producto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      proveedorId: serializer.fromJson<String?>(json['proveedorId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      categoria: serializer.fromJson<String?>(json['categoria']),
      codigo: serializer.fromJson<String?>(json['codigo']),
      precio: serializer.fromJson<double>(json['precio']),
      pctSalon: serializer.fromJson<double?>(json['pctSalon']),
      publicado: serializer.fromJson<bool>(json['publicado']),
      destacado: serializer.fromJson<bool>(json['destacado']),
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
      'proveedorId': serializer.toJson<String?>(proveedorId),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'categoria': serializer.toJson<String?>(categoria),
      'codigo': serializer.toJson<String?>(codigo),
      'precio': serializer.toJson<double>(precio),
      'pctSalon': serializer.toJson<double?>(pctSalon),
      'publicado': serializer.toJson<bool>(publicado),
      'destacado': serializer.toJson<bool>(destacado),
    };
  }

  Producto copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> proveedorId = const Value.absent(),
          String? nombre,
          Value<String?> descripcion = const Value.absent(),
          Value<String?> categoria = const Value.absent(),
          Value<String?> codigo = const Value.absent(),
          double? precio,
          Value<double?> pctSalon = const Value.absent(),
          bool? publicado,
          bool? destacado}) =>
      Producto(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        proveedorId: proveedorId.present ? proveedorId.value : this.proveedorId,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        categoria: categoria.present ? categoria.value : this.categoria,
        codigo: codigo.present ? codigo.value : this.codigo,
        precio: precio ?? this.precio,
        pctSalon: pctSalon.present ? pctSalon.value : this.pctSalon,
        publicado: publicado ?? this.publicado,
        destacado: destacado ?? this.destacado,
      );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      proveedorId:
          data.proveedorId.present ? data.proveedorId.value : this.proveedorId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      precio: data.precio.present ? data.precio.value : this.precio,
      pctSalon: data.pctSalon.present ? data.pctSalon.value : this.pctSalon,
      publicado: data.publicado.present ? data.publicado.value : this.publicado,
      destacado: data.destacado.present ? data.destacado.value : this.destacado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('proveedorId: $proveedorId, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoria: $categoria, ')
          ..write('codigo: $codigo, ')
          ..write('precio: $precio, ')
          ..write('pctSalon: $pctSalon, ')
          ..write('publicado: $publicado, ')
          ..write('destacado: $destacado')
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
      proveedorId,
      nombre,
      descripcion,
      categoria,
      codigo,
      precio,
      pctSalon,
      publicado,
      destacado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.proveedorId == this.proveedorId &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.categoria == this.categoria &&
          other.codigo == this.codigo &&
          other.precio == this.precio &&
          other.pctSalon == this.pctSalon &&
          other.publicado == this.publicado &&
          other.destacado == this.destacado);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> proveedorId;
  final Value<String> nombre;
  final Value<String?> descripcion;
  final Value<String?> categoria;
  final Value<String?> codigo;
  final Value<double> precio;
  final Value<double?> pctSalon;
  final Value<bool> publicado;
  final Value<bool> destacado;
  final Value<int> rowid;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.proveedorId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.categoria = const Value.absent(),
    this.codigo = const Value.absent(),
    this.precio = const Value.absent(),
    this.pctSalon = const Value.absent(),
    this.publicado = const Value.absent(),
    this.destacado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.proveedorId = const Value.absent(),
    required String nombre,
    this.descripcion = const Value.absent(),
    this.categoria = const Value.absent(),
    this.codigo = const Value.absent(),
    this.precio = const Value.absent(),
    this.pctSalon = const Value.absent(),
    this.publicado = const Value.absent(),
    this.destacado = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        nombre = Value(nombre);
  static Insertable<Producto> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? proveedorId,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<String>? categoria,
    Expression<String>? codigo,
    Expression<double>? precio,
    Expression<double>? pctSalon,
    Expression<bool>? publicado,
    Expression<bool>? destacado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (proveedorId != null) 'proveedor_id': proveedorId,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoria != null) 'categoria': categoria,
      if (codigo != null) 'codigo': codigo,
      if (precio != null) 'precio': precio,
      if (pctSalon != null) 'pct_salon': pctSalon,
      if (publicado != null) 'publicado': publicado,
      if (destacado != null) 'destacado': destacado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? proveedorId,
      Value<String>? nombre,
      Value<String?>? descripcion,
      Value<String?>? categoria,
      Value<String?>? codigo,
      Value<double>? precio,
      Value<double?>? pctSalon,
      Value<bool>? publicado,
      Value<bool>? destacado,
      Value<int>? rowid}) {
    return ProductosCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      proveedorId: proveedorId ?? this.proveedorId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      codigo: codigo ?? this.codigo,
      precio: precio ?? this.precio,
      pctSalon: pctSalon ?? this.pctSalon,
      publicado: publicado ?? this.publicado,
      destacado: destacado ?? this.destacado,
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
    if (proveedorId.present) {
      map['proveedor_id'] = Variable<String>(proveedorId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (precio.present) {
      map['precio'] = Variable<double>(precio.value);
    }
    if (pctSalon.present) {
      map['pct_salon'] = Variable<double>(pctSalon.value);
    }
    if (publicado.present) {
      map['publicado'] = Variable<bool>(publicado.value);
    }
    if (destacado.present) {
      map['destacado'] = Variable<bool>(destacado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('proveedorId: $proveedorId, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoria: $categoria, ')
          ..write('codigo: $codigo, ')
          ..write('precio: $precio, ')
          ..write('pctSalon: $pctSalon, ')
          ..write('publicado: $publicado, ')
          ..write('destacado: $destacado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductoVariantesTable extends ProductoVariantes
    with TableInfo<$ProductoVariantesTable, ProductoVariante> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductoVariantesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _productoIdMeta =
      const VerificationMeta('productoId');
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
      'producto_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _talleMeta = const VerificationMeta('talle');
  @override
  late final GeneratedColumn<String> talle = GeneratedColumn<String>(
      'talle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        productoId,
        talle,
        color,
        sku
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'producto_variantes';
  @override
  VerificationContext validateIntegrity(Insertable<ProductoVariante> instance,
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
    if (data.containsKey('producto_id')) {
      context.handle(
          _productoIdMeta,
          productoId.isAcceptableOrUnknown(
              data['producto_id']!, _productoIdMeta));
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('talle')) {
      context.handle(
          _talleMeta, talle.isAcceptableOrUnknown(data['talle']!, _talleMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductoVariante map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductoVariante(
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
      productoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}producto_id'])!,
      talle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}talle']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku']),
    );
  }

  @override
  $ProductoVariantesTable createAlias(String alias) {
    return $ProductoVariantesTable(attachedDatabase, alias);
  }
}

class ProductoVariante extends DataClass
    implements Insertable<ProductoVariante> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String productoId;
  final String? talle;
  final String? color;
  final String? sku;
  const ProductoVariante(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.productoId,
      this.talle,
      this.color,
      this.sku});
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
    map['producto_id'] = Variable<String>(productoId);
    if (!nullToAbsent || talle != null) {
      map['talle'] = Variable<String>(talle);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    return map;
  }

  ProductoVariantesCompanion toCompanion(bool nullToAbsent) {
    return ProductoVariantesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      productoId: Value(productoId),
      talle:
          talle == null && nullToAbsent ? const Value.absent() : Value(talle),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
    );
  }

  factory ProductoVariante.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductoVariante(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      productoId: serializer.fromJson<String>(json['productoId']),
      talle: serializer.fromJson<String?>(json['talle']),
      color: serializer.fromJson<String?>(json['color']),
      sku: serializer.fromJson<String?>(json['sku']),
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
      'productoId': serializer.toJson<String>(productoId),
      'talle': serializer.toJson<String?>(talle),
      'color': serializer.toJson<String?>(color),
      'sku': serializer.toJson<String?>(sku),
    };
  }

  ProductoVariante copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? productoId,
          Value<String?> talle = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<String?> sku = const Value.absent()}) =>
      ProductoVariante(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        productoId: productoId ?? this.productoId,
        talle: talle.present ? talle.value : this.talle,
        color: color.present ? color.value : this.color,
        sku: sku.present ? sku.value : this.sku,
      );
  ProductoVariante copyWithCompanion(ProductoVariantesCompanion data) {
    return ProductoVariante(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      productoId:
          data.productoId.present ? data.productoId.value : this.productoId,
      talle: data.talle.present ? data.talle.value : this.talle,
      color: data.color.present ? data.color.value : this.color,
      sku: data.sku.present ? data.sku.value : this.sku,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductoVariante(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('productoId: $productoId, ')
          ..write('talle: $talle, ')
          ..write('color: $color, ')
          ..write('sku: $sku')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      productoId, talle, color, sku);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductoVariante &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.productoId == this.productoId &&
          other.talle == this.talle &&
          other.color == this.color &&
          other.sku == this.sku);
}

class ProductoVariantesCompanion extends UpdateCompanion<ProductoVariante> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> productoId;
  final Value<String?> talle;
  final Value<String?> color;
  final Value<String?> sku;
  final Value<int> rowid;
  const ProductoVariantesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.productoId = const Value.absent(),
    this.talle = const Value.absent(),
    this.color = const Value.absent(),
    this.sku = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductoVariantesCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String productoId,
    this.talle = const Value.absent(),
    this.color = const Value.absent(),
    this.sku = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        productoId = Value(productoId);
  static Insertable<ProductoVariante> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? productoId,
    Expression<String>? talle,
    Expression<String>? color,
    Expression<String>? sku,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (productoId != null) 'producto_id': productoId,
      if (talle != null) 'talle': talle,
      if (color != null) 'color': color,
      if (sku != null) 'sku': sku,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductoVariantesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? productoId,
      Value<String?>? talle,
      Value<String?>? color,
      Value<String?>? sku,
      Value<int>? rowid}) {
    return ProductoVariantesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      productoId: productoId ?? this.productoId,
      talle: talle ?? this.talle,
      color: color ?? this.color,
      sku: sku ?? this.sku,
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
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (talle.present) {
      map['talle'] = Variable<String>(talle.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductoVariantesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('productoId: $productoId, ')
          ..write('talle: $talle, ')
          ..write('color: $color, ')
          ..write('sku: $sku, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockVariantesTable extends StockVariantes
    with TableInfo<$StockVariantesTable, StockVariante> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockVariantesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _varianteIdMeta =
      const VerificationMeta('varianteId');
  @override
  late final GeneratedColumn<String> varianteId = GeneratedColumn<String>(
      'variante_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _depositoIdMeta =
      const VerificationMeta('depositoId');
  @override
  late final GeneratedColumn<String> depositoId = GeneratedColumn<String>(
      'deposito_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        varianteId,
        depositoId,
        cantidad
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_variantes';
  @override
  VerificationContext validateIntegrity(Insertable<StockVariante> instance,
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
    if (data.containsKey('variante_id')) {
      context.handle(
          _varianteIdMeta,
          varianteId.isAcceptableOrUnknown(
              data['variante_id']!, _varianteIdMeta));
    } else if (isInserting) {
      context.missing(_varianteIdMeta);
    }
    if (data.containsKey('deposito_id')) {
      context.handle(
          _depositoIdMeta,
          depositoId.isAcceptableOrUnknown(
              data['deposito_id']!, _depositoIdMeta));
    } else if (isInserting) {
      context.missing(_depositoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockVariante map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockVariante(
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
      varianteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variante_id'])!,
      depositoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deposito_id'])!,
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cantidad'])!,
    );
  }

  @override
  $StockVariantesTable createAlias(String alias) {
    return $StockVariantesTable(attachedDatabase, alias);
  }
}

class StockVariante extends DataClass implements Insertable<StockVariante> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String varianteId;
  final String depositoId;
  final int cantidad;
  const StockVariante(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.varianteId,
      required this.depositoId,
      required this.cantidad});
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
    map['variante_id'] = Variable<String>(varianteId);
    map['deposito_id'] = Variable<String>(depositoId);
    map['cantidad'] = Variable<int>(cantidad);
    return map;
  }

  StockVariantesCompanion toCompanion(bool nullToAbsent) {
    return StockVariantesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      varianteId: Value(varianteId),
      depositoId: Value(depositoId),
      cantidad: Value(cantidad),
    );
  }

  factory StockVariante.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockVariante(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      varianteId: serializer.fromJson<String>(json['varianteId']),
      depositoId: serializer.fromJson<String>(json['depositoId']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
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
      'varianteId': serializer.toJson<String>(varianteId),
      'depositoId': serializer.toJson<String>(depositoId),
      'cantidad': serializer.toJson<int>(cantidad),
    };
  }

  StockVariante copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? varianteId,
          String? depositoId,
          int? cantidad}) =>
      StockVariante(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        varianteId: varianteId ?? this.varianteId,
        depositoId: depositoId ?? this.depositoId,
        cantidad: cantidad ?? this.cantidad,
      );
  StockVariante copyWithCompanion(StockVariantesCompanion data) {
    return StockVariante(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      varianteId:
          data.varianteId.present ? data.varianteId.value : this.varianteId,
      depositoId:
          data.depositoId.present ? data.depositoId.value : this.depositoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockVariante(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('varianteId: $varianteId, ')
          ..write('depositoId: $depositoId, ')
          ..write('cantidad: $cantidad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      varianteId, depositoId, cantidad);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockVariante &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.varianteId == this.varianteId &&
          other.depositoId == this.depositoId &&
          other.cantidad == this.cantidad);
}

class StockVariantesCompanion extends UpdateCompanion<StockVariante> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> varianteId;
  final Value<String> depositoId;
  final Value<int> cantidad;
  final Value<int> rowid;
  const StockVariantesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.varianteId = const Value.absent(),
    this.depositoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockVariantesCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String varianteId,
    required String depositoId,
    this.cantidad = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        varianteId = Value(varianteId),
        depositoId = Value(depositoId);
  static Insertable<StockVariante> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? varianteId,
    Expression<String>? depositoId,
    Expression<int>? cantidad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (varianteId != null) 'variante_id': varianteId,
      if (depositoId != null) 'deposito_id': depositoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockVariantesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? varianteId,
      Value<String>? depositoId,
      Value<int>? cantidad,
      Value<int>? rowid}) {
    return StockVariantesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      varianteId: varianteId ?? this.varianteId,
      depositoId: depositoId ?? this.depositoId,
      cantidad: cantidad ?? this.cantidad,
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
    if (varianteId.present) {
      map['variante_id'] = Variable<String>(varianteId.value);
    }
    if (depositoId.present) {
      map['deposito_id'] = Variable<String>(depositoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockVariantesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('varianteId: $varianteId, ')
          ..write('depositoId: $depositoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductoFotosTable extends ProductoFotos
    with TableInfo<$ProductoFotosTable, ProductoFoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductoFotosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _productoIdMeta =
      const VerificationMeta('productoId');
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
      'producto_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _varianteIdMeta =
      const VerificationMeta('varianteId');
  @override
  late final GeneratedColumn<String> varianteId = GeneratedColumn<String>(
      'variante_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
      'orden', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pendienteDeSubirMeta =
      const VerificationMeta('pendienteDeSubir');
  @override
  late final GeneratedColumn<bool> pendienteDeSubir = GeneratedColumn<bool>(
      'pendiente_de_subir', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pendiente_de_subir" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _rutaLocalMeta =
      const VerificationMeta('rutaLocal');
  @override
  late final GeneratedColumn<String> rutaLocal = GeneratedColumn<String>(
      'ruta_local', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        productoId,
        varianteId,
        path,
        orden,
        pendienteDeSubir,
        rutaLocal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'producto_fotos';
  @override
  VerificationContext validateIntegrity(Insertable<ProductoFoto> instance,
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
    if (data.containsKey('producto_id')) {
      context.handle(
          _productoIdMeta,
          productoId.isAcceptableOrUnknown(
              data['producto_id']!, _productoIdMeta));
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('variante_id')) {
      context.handle(
          _varianteIdMeta,
          varianteId.isAcceptableOrUnknown(
              data['variante_id']!, _varianteIdMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
          _ordenMeta, orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta));
    }
    if (data.containsKey('pendiente_de_subir')) {
      context.handle(
          _pendienteDeSubirMeta,
          pendienteDeSubir.isAcceptableOrUnknown(
              data['pendiente_de_subir']!, _pendienteDeSubirMeta));
    }
    if (data.containsKey('ruta_local')) {
      context.handle(_rutaLocalMeta,
          rutaLocal.isAcceptableOrUnknown(data['ruta_local']!, _rutaLocalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductoFoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductoFoto(
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
      productoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}producto_id'])!,
      varianteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variante_id']),
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      orden: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orden'])!,
      pendienteDeSubir: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}pendiente_de_subir'])!,
      rutaLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ruta_local']),
    );
  }

  @override
  $ProductoFotosTable createAlias(String alias) {
    return $ProductoFotosTable(attachedDatabase, alias);
  }
}

class ProductoFoto extends DataClass implements Insertable<ProductoFoto> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String productoId;

  /// Foto de un color puntual. Null = del producto en general.
  final String? varianteId;

  /// Ruta en el bucket `productos` de Supabase Storage.
  final String path;
  final int orden;

  /// La foto vive primero en el teléfono y se sube después. Mientras esto sea
  /// true, la ficha muestra "falta subir" en vez de una imagen rota: una
  /// imagen no se puede encolar como una fila de texto.
  final bool pendienteDeSubir;

  /// Dónde está el archivo local mientras no se subió.
  final String? rutaLocal;
  const ProductoFoto(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.productoId,
      this.varianteId,
      required this.path,
      required this.orden,
      required this.pendienteDeSubir,
      this.rutaLocal});
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
    map['producto_id'] = Variable<String>(productoId);
    if (!nullToAbsent || varianteId != null) {
      map['variante_id'] = Variable<String>(varianteId);
    }
    map['path'] = Variable<String>(path);
    map['orden'] = Variable<int>(orden);
    map['pendiente_de_subir'] = Variable<bool>(pendienteDeSubir);
    if (!nullToAbsent || rutaLocal != null) {
      map['ruta_local'] = Variable<String>(rutaLocal);
    }
    return map;
  }

  ProductoFotosCompanion toCompanion(bool nullToAbsent) {
    return ProductoFotosCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      productoId: Value(productoId),
      varianteId: varianteId == null && nullToAbsent
          ? const Value.absent()
          : Value(varianteId),
      path: Value(path),
      orden: Value(orden),
      pendienteDeSubir: Value(pendienteDeSubir),
      rutaLocal: rutaLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(rutaLocal),
    );
  }

  factory ProductoFoto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductoFoto(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      productoId: serializer.fromJson<String>(json['productoId']),
      varianteId: serializer.fromJson<String?>(json['varianteId']),
      path: serializer.fromJson<String>(json['path']),
      orden: serializer.fromJson<int>(json['orden']),
      pendienteDeSubir: serializer.fromJson<bool>(json['pendienteDeSubir']),
      rutaLocal: serializer.fromJson<String?>(json['rutaLocal']),
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
      'productoId': serializer.toJson<String>(productoId),
      'varianteId': serializer.toJson<String?>(varianteId),
      'path': serializer.toJson<String>(path),
      'orden': serializer.toJson<int>(orden),
      'pendienteDeSubir': serializer.toJson<bool>(pendienteDeSubir),
      'rutaLocal': serializer.toJson<String?>(rutaLocal),
    };
  }

  ProductoFoto copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? productoId,
          Value<String?> varianteId = const Value.absent(),
          String? path,
          int? orden,
          bool? pendienteDeSubir,
          Value<String?> rutaLocal = const Value.absent()}) =>
      ProductoFoto(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        productoId: productoId ?? this.productoId,
        varianteId: varianteId.present ? varianteId.value : this.varianteId,
        path: path ?? this.path,
        orden: orden ?? this.orden,
        pendienteDeSubir: pendienteDeSubir ?? this.pendienteDeSubir,
        rutaLocal: rutaLocal.present ? rutaLocal.value : this.rutaLocal,
      );
  ProductoFoto copyWithCompanion(ProductoFotosCompanion data) {
    return ProductoFoto(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      productoId:
          data.productoId.present ? data.productoId.value : this.productoId,
      varianteId:
          data.varianteId.present ? data.varianteId.value : this.varianteId,
      path: data.path.present ? data.path.value : this.path,
      orden: data.orden.present ? data.orden.value : this.orden,
      pendienteDeSubir: data.pendienteDeSubir.present
          ? data.pendienteDeSubir.value
          : this.pendienteDeSubir,
      rutaLocal: data.rutaLocal.present ? data.rutaLocal.value : this.rutaLocal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductoFoto(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('productoId: $productoId, ')
          ..write('varianteId: $varianteId, ')
          ..write('path: $path, ')
          ..write('orden: $orden, ')
          ..write('pendienteDeSubir: $pendienteDeSubir, ')
          ..write('rutaLocal: $rutaLocal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      productoId, varianteId, path, orden, pendienteDeSubir, rutaLocal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductoFoto &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.productoId == this.productoId &&
          other.varianteId == this.varianteId &&
          other.path == this.path &&
          other.orden == this.orden &&
          other.pendienteDeSubir == this.pendienteDeSubir &&
          other.rutaLocal == this.rutaLocal);
}

class ProductoFotosCompanion extends UpdateCompanion<ProductoFoto> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> productoId;
  final Value<String?> varianteId;
  final Value<String> path;
  final Value<int> orden;
  final Value<bool> pendienteDeSubir;
  final Value<String?> rutaLocal;
  final Value<int> rowid;
  const ProductoFotosCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.productoId = const Value.absent(),
    this.varianteId = const Value.absent(),
    this.path = const Value.absent(),
    this.orden = const Value.absent(),
    this.pendienteDeSubir = const Value.absent(),
    this.rutaLocal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductoFotosCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String productoId,
    this.varianteId = const Value.absent(),
    required String path,
    this.orden = const Value.absent(),
    this.pendienteDeSubir = const Value.absent(),
    this.rutaLocal = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        productoId = Value(productoId),
        path = Value(path);
  static Insertable<ProductoFoto> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? productoId,
    Expression<String>? varianteId,
    Expression<String>? path,
    Expression<int>? orden,
    Expression<bool>? pendienteDeSubir,
    Expression<String>? rutaLocal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (productoId != null) 'producto_id': productoId,
      if (varianteId != null) 'variante_id': varianteId,
      if (path != null) 'path': path,
      if (orden != null) 'orden': orden,
      if (pendienteDeSubir != null) 'pendiente_de_subir': pendienteDeSubir,
      if (rutaLocal != null) 'ruta_local': rutaLocal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductoFotosCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? productoId,
      Value<String?>? varianteId,
      Value<String>? path,
      Value<int>? orden,
      Value<bool>? pendienteDeSubir,
      Value<String?>? rutaLocal,
      Value<int>? rowid}) {
    return ProductoFotosCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      productoId: productoId ?? this.productoId,
      varianteId: varianteId ?? this.varianteId,
      path: path ?? this.path,
      orden: orden ?? this.orden,
      pendienteDeSubir: pendienteDeSubir ?? this.pendienteDeSubir,
      rutaLocal: rutaLocal ?? this.rutaLocal,
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
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (varianteId.present) {
      map['variante_id'] = Variable<String>(varianteId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (pendienteDeSubir.present) {
      map['pendiente_de_subir'] = Variable<bool>(pendienteDeSubir.value);
    }
    if (rutaLocal.present) {
      map['ruta_local'] = Variable<String>(rutaLocal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductoFotosCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('productoId: $productoId, ')
          ..write('varianteId: $varianteId, ')
          ..write('path: $path, ')
          ..write('orden: $orden, ')
          ..write('pendienteDeSubir: $pendienteDeSubir, ')
          ..write('rutaLocal: $rutaLocal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, Venta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _depositoIdMeta =
      const VerificationMeta('depositoId');
  @override
  late final GeneratedColumn<String> depositoId = GeneratedColumn<String>(
      'deposito_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vendedorIdMeta =
      const VerificationMeta('vendedorId');
  @override
  late final GeneratedColumn<String> vendedorId = GeneratedColumn<String>(
      'vendedor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
      'fecha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _descuentoMeta =
      const VerificationMeta('descuento');
  @override
  late final GeneratedColumn<double> descuento = GeneratedColumn<double>(
      'descuento', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _metodoMeta = const VerificationMeta('metodo');
  @override
  late final GeneratedColumn<String> metodo = GeneratedColumn<String>(
      'metodo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('efectivo'));
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('completada'));
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
        depositoId,
        vendedorId,
        clientId,
        fecha,
        total,
        descuento,
        metodo,
        estado,
        notas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(Insertable<Venta> instance,
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
    if (data.containsKey('deposito_id')) {
      context.handle(
          _depositoIdMeta,
          depositoId.isAcceptableOrUnknown(
              data['deposito_id']!, _depositoIdMeta));
    }
    if (data.containsKey('vendedor_id')) {
      context.handle(
          _vendedorIdMeta,
          vendedorId.isAcceptableOrUnknown(
              data['vendedor_id']!, _vendedorIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('descuento')) {
      context.handle(_descuentoMeta,
          descuento.isAcceptableOrUnknown(data['descuento']!, _descuentoMeta));
    }
    if (data.containsKey('metodo')) {
      context.handle(_metodoMeta,
          metodo.isAcceptableOrUnknown(data['metodo']!, _metodoMeta));
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
  Venta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Venta(
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
      depositoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deposito_id']),
      vendedorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendedor_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      descuento: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}descuento'])!,
      metodo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metodo'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
    );
  }

  @override
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }
}

class Venta extends DataClass implements Insertable<Venta> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? depositoId;

  /// Quién vendió. Null = la dueña desde su propia cuenta.
  final String? vendedorId;

  /// Alimenta el "total gastado" que ya muestra la ficha de clienta.
  final String? clientId;
  final String fecha;
  final double total;
  final double descuento;
  final String metodo;

  /// `completada` | `anulada`
  final String estado;
  final String? notas;
  const Venta(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.depositoId,
      this.vendedorId,
      this.clientId,
      required this.fecha,
      required this.total,
      required this.descuento,
      required this.metodo,
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
    if (!nullToAbsent || depositoId != null) {
      map['deposito_id'] = Variable<String>(depositoId);
    }
    if (!nullToAbsent || vendedorId != null) {
      map['vendedor_id'] = Variable<String>(vendedorId);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['fecha'] = Variable<String>(fecha);
    map['total'] = Variable<double>(total);
    map['descuento'] = Variable<double>(descuento);
    map['metodo'] = Variable<String>(metodo);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      depositoId: depositoId == null && nullToAbsent
          ? const Value.absent()
          : Value(depositoId),
      vendedorId: vendedorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vendedorId),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      fecha: Value(fecha),
      total: Value(total),
      descuento: Value(descuento),
      metodo: Value(metodo),
      estado: Value(estado),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
    );
  }

  factory Venta.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Venta(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      depositoId: serializer.fromJson<String?>(json['depositoId']),
      vendedorId: serializer.fromJson<String?>(json['vendedorId']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      total: serializer.fromJson<double>(json['total']),
      descuento: serializer.fromJson<double>(json['descuento']),
      metodo: serializer.fromJson<String>(json['metodo']),
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
      'depositoId': serializer.toJson<String?>(depositoId),
      'vendedorId': serializer.toJson<String?>(vendedorId),
      'clientId': serializer.toJson<String?>(clientId),
      'fecha': serializer.toJson<String>(fecha),
      'total': serializer.toJson<double>(total),
      'descuento': serializer.toJson<double>(descuento),
      'metodo': serializer.toJson<String>(metodo),
      'estado': serializer.toJson<String>(estado),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Venta copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> depositoId = const Value.absent(),
          Value<String?> vendedorId = const Value.absent(),
          Value<String?> clientId = const Value.absent(),
          String? fecha,
          double? total,
          double? descuento,
          String? metodo,
          String? estado,
          Value<String?> notas = const Value.absent()}) =>
      Venta(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        depositoId: depositoId.present ? depositoId.value : this.depositoId,
        vendedorId: vendedorId.present ? vendedorId.value : this.vendedorId,
        clientId: clientId.present ? clientId.value : this.clientId,
        fecha: fecha ?? this.fecha,
        total: total ?? this.total,
        descuento: descuento ?? this.descuento,
        metodo: metodo ?? this.metodo,
        estado: estado ?? this.estado,
        notas: notas.present ? notas.value : this.notas,
      );
  Venta copyWithCompanion(VentasCompanion data) {
    return Venta(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      depositoId:
          data.depositoId.present ? data.depositoId.value : this.depositoId,
      vendedorId:
          data.vendedorId.present ? data.vendedorId.value : this.vendedorId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      total: data.total.present ? data.total.value : this.total,
      descuento: data.descuento.present ? data.descuento.value : this.descuento,
      metodo: data.metodo.present ? data.metodo.value : this.metodo,
      estado: data.estado.present ? data.estado.value : this.estado,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Venta(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('depositoId: $depositoId, ')
          ..write('vendedorId: $vendedorId, ')
          ..write('clientId: $clientId, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total, ')
          ..write('descuento: $descuento, ')
          ..write('metodo: $metodo, ')
          ..write('estado: $estado, ')
          ..write('notas: $notas')
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
      depositoId,
      vendedorId,
      clientId,
      fecha,
      total,
      descuento,
      metodo,
      estado,
      notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Venta &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.depositoId == this.depositoId &&
          other.vendedorId == this.vendedorId &&
          other.clientId == this.clientId &&
          other.fecha == this.fecha &&
          other.total == this.total &&
          other.descuento == this.descuento &&
          other.metodo == this.metodo &&
          other.estado == this.estado &&
          other.notas == this.notas);
}

class VentasCompanion extends UpdateCompanion<Venta> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> depositoId;
  final Value<String?> vendedorId;
  final Value<String?> clientId;
  final Value<String> fecha;
  final Value<double> total;
  final Value<double> descuento;
  final Value<String> metodo;
  final Value<String> estado;
  final Value<String?> notas;
  final Value<int> rowid;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.depositoId = const Value.absent(),
    this.vendedorId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.total = const Value.absent(),
    this.descuento = const Value.absent(),
    this.metodo = const Value.absent(),
    this.estado = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentasCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.depositoId = const Value.absent(),
    this.vendedorId = const Value.absent(),
    this.clientId = const Value.absent(),
    required String fecha,
    this.total = const Value.absent(),
    this.descuento = const Value.absent(),
    this.metodo = const Value.absent(),
    this.estado = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        fecha = Value(fecha);
  static Insertable<Venta> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? depositoId,
    Expression<String>? vendedorId,
    Expression<String>? clientId,
    Expression<String>? fecha,
    Expression<double>? total,
    Expression<double>? descuento,
    Expression<String>? metodo,
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
      if (depositoId != null) 'deposito_id': depositoId,
      if (vendedorId != null) 'vendedor_id': vendedorId,
      if (clientId != null) 'client_id': clientId,
      if (fecha != null) 'fecha': fecha,
      if (total != null) 'total': total,
      if (descuento != null) 'descuento': descuento,
      if (metodo != null) 'metodo': metodo,
      if (estado != null) 'estado': estado,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentasCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? depositoId,
      Value<String?>? vendedorId,
      Value<String?>? clientId,
      Value<String>? fecha,
      Value<double>? total,
      Value<double>? descuento,
      Value<String>? metodo,
      Value<String>? estado,
      Value<String?>? notas,
      Value<int>? rowid}) {
    return VentasCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      depositoId: depositoId ?? this.depositoId,
      vendedorId: vendedorId ?? this.vendedorId,
      clientId: clientId ?? this.clientId,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
      descuento: descuento ?? this.descuento,
      metodo: metodo ?? this.metodo,
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
    if (depositoId.present) {
      map['deposito_id'] = Variable<String>(depositoId.value);
    }
    if (vendedorId.present) {
      map['vendedor_id'] = Variable<String>(vendedorId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (descuento.present) {
      map['descuento'] = Variable<double>(descuento.value);
    }
    if (metodo.present) {
      map['metodo'] = Variable<String>(metodo.value);
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
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('depositoId: $depositoId, ')
          ..write('vendedorId: $vendedorId, ')
          ..write('clientId: $clientId, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total, ')
          ..write('descuento: $descuento, ')
          ..write('metodo: $metodo, ')
          ..write('estado: $estado, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentaItemsTable extends VentaItems
    with TableInfo<$VentaItemsTable, VentaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentaItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _ventaIdMeta =
      const VerificationMeta('ventaId');
  @override
  late final GeneratedColumn<String> ventaId = GeneratedColumn<String>(
      'venta_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _varianteIdMeta =
      const VerificationMeta('varianteId');
  @override
  late final GeneratedColumn<String> varianteId = GeneratedColumn<String>(
      'variante_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _precioUnitMeta =
      const VerificationMeta('precioUnit');
  @override
  late final GeneratedColumn<double> precioUnit = GeneratedColumn<double>(
      'precio_unit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pctSalonMeta =
      const VerificationMeta('pctSalon');
  @override
  late final GeneratedColumn<double> pctSalon = GeneratedColumn<double>(
      'pct_salon', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pctVendedorMeta =
      const VerificationMeta('pctVendedor');
  @override
  late final GeneratedColumn<double> pctVendedor = GeneratedColumn<double>(
      'pct_vendedor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _montoProveedorMeta =
      const VerificationMeta('montoProveedor');
  @override
  late final GeneratedColumn<double> montoProveedor = GeneratedColumn<double>(
      'monto_proveedor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _montoSalonMeta =
      const VerificationMeta('montoSalon');
  @override
  late final GeneratedColumn<double> montoSalon = GeneratedColumn<double>(
      'monto_salon', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _montoVendedorMeta =
      const VerificationMeta('montoVendedor');
  @override
  late final GeneratedColumn<double> montoVendedor = GeneratedColumn<double>(
      'monto_vendedor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _liquidacionIdMeta =
      const VerificationMeta('liquidacionId');
  @override
  late final GeneratedColumn<String> liquidacionId = GeneratedColumn<String>(
      'liquidacion_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        ventaId,
        varianteId,
        descripcion,
        cantidad,
        precioUnit,
        pctSalon,
        pctVendedor,
        montoProveedor,
        montoSalon,
        montoVendedor,
        liquidacionId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'venta_items';
  @override
  VerificationContext validateIntegrity(Insertable<VentaItem> instance,
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
    if (data.containsKey('venta_id')) {
      context.handle(_ventaIdMeta,
          ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta));
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('variante_id')) {
      context.handle(
          _varianteIdMeta,
          varianteId.isAcceptableOrUnknown(
              data['variante_id']!, _varianteIdMeta));
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    }
    if (data.containsKey('precio_unit')) {
      context.handle(
          _precioUnitMeta,
          precioUnit.isAcceptableOrUnknown(
              data['precio_unit']!, _precioUnitMeta));
    }
    if (data.containsKey('pct_salon')) {
      context.handle(_pctSalonMeta,
          pctSalon.isAcceptableOrUnknown(data['pct_salon']!, _pctSalonMeta));
    }
    if (data.containsKey('pct_vendedor')) {
      context.handle(
          _pctVendedorMeta,
          pctVendedor.isAcceptableOrUnknown(
              data['pct_vendedor']!, _pctVendedorMeta));
    }
    if (data.containsKey('monto_proveedor')) {
      context.handle(
          _montoProveedorMeta,
          montoProveedor.isAcceptableOrUnknown(
              data['monto_proveedor']!, _montoProveedorMeta));
    }
    if (data.containsKey('monto_salon')) {
      context.handle(
          _montoSalonMeta,
          montoSalon.isAcceptableOrUnknown(
              data['monto_salon']!, _montoSalonMeta));
    }
    if (data.containsKey('monto_vendedor')) {
      context.handle(
          _montoVendedorMeta,
          montoVendedor.isAcceptableOrUnknown(
              data['monto_vendedor']!, _montoVendedorMeta));
    }
    if (data.containsKey('liquidacion_id')) {
      context.handle(
          _liquidacionIdMeta,
          liquidacionId.isAcceptableOrUnknown(
              data['liquidacion_id']!, _liquidacionIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VentaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VentaItem(
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
      ventaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venta_id'])!,
      varianteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variante_id']),
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cantidad'])!,
      precioUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio_unit'])!,
      pctSalon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pct_salon'])!,
      pctVendedor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pct_vendedor'])!,
      montoProveedor: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}monto_proveedor'])!,
      montoSalon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_salon'])!,
      montoVendedor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_vendedor'])!,
      liquidacionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}liquidacion_id']),
    );
  }

  @override
  $VentaItemsTable createAlias(String alias) {
    return $VentaItemsTable(attachedDatabase, alias);
  }
}

class VentaItem extends DataClass implements Insertable<VentaItem> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String ventaId;
  final String? varianteId;

  /// Denormalizado a propósito: si mañana se borra el producto, la venta vieja
  /// tiene que seguir siendo legible.
  final String? descripcion;
  final int cantidad;
  final double precioUnit;
  final double pctSalon;
  final double pctVendedor;
  final double montoProveedor;
  final double montoSalon;
  final double montoVendedor;

  /// Se marca al incluirlo en una liquidación, para no pagarlo dos veces.
  final String? liquidacionId;
  const VentaItem(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.ventaId,
      this.varianteId,
      this.descripcion,
      required this.cantidad,
      required this.precioUnit,
      required this.pctSalon,
      required this.pctVendedor,
      required this.montoProveedor,
      required this.montoSalon,
      required this.montoVendedor,
      this.liquidacionId});
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
    map['venta_id'] = Variable<String>(ventaId);
    if (!nullToAbsent || varianteId != null) {
      map['variante_id'] = Variable<String>(varianteId);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unit'] = Variable<double>(precioUnit);
    map['pct_salon'] = Variable<double>(pctSalon);
    map['pct_vendedor'] = Variable<double>(pctVendedor);
    map['monto_proveedor'] = Variable<double>(montoProveedor);
    map['monto_salon'] = Variable<double>(montoSalon);
    map['monto_vendedor'] = Variable<double>(montoVendedor);
    if (!nullToAbsent || liquidacionId != null) {
      map['liquidacion_id'] = Variable<String>(liquidacionId);
    }
    return map;
  }

  VentaItemsCompanion toCompanion(bool nullToAbsent) {
    return VentaItemsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      ventaId: Value(ventaId),
      varianteId: varianteId == null && nullToAbsent
          ? const Value.absent()
          : Value(varianteId),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      cantidad: Value(cantidad),
      precioUnit: Value(precioUnit),
      pctSalon: Value(pctSalon),
      pctVendedor: Value(pctVendedor),
      montoProveedor: Value(montoProveedor),
      montoSalon: Value(montoSalon),
      montoVendedor: Value(montoVendedor),
      liquidacionId: liquidacionId == null && nullToAbsent
          ? const Value.absent()
          : Value(liquidacionId),
    );
  }

  factory VentaItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VentaItem(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      ventaId: serializer.fromJson<String>(json['ventaId']),
      varianteId: serializer.fromJson<String?>(json['varianteId']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnit: serializer.fromJson<double>(json['precioUnit']),
      pctSalon: serializer.fromJson<double>(json['pctSalon']),
      pctVendedor: serializer.fromJson<double>(json['pctVendedor']),
      montoProveedor: serializer.fromJson<double>(json['montoProveedor']),
      montoSalon: serializer.fromJson<double>(json['montoSalon']),
      montoVendedor: serializer.fromJson<double>(json['montoVendedor']),
      liquidacionId: serializer.fromJson<String?>(json['liquidacionId']),
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
      'ventaId': serializer.toJson<String>(ventaId),
      'varianteId': serializer.toJson<String?>(varianteId),
      'descripcion': serializer.toJson<String?>(descripcion),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnit': serializer.toJson<double>(precioUnit),
      'pctSalon': serializer.toJson<double>(pctSalon),
      'pctVendedor': serializer.toJson<double>(pctVendedor),
      'montoProveedor': serializer.toJson<double>(montoProveedor),
      'montoSalon': serializer.toJson<double>(montoSalon),
      'montoVendedor': serializer.toJson<double>(montoVendedor),
      'liquidacionId': serializer.toJson<String?>(liquidacionId),
    };
  }

  VentaItem copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? ventaId,
          Value<String?> varianteId = const Value.absent(),
          Value<String?> descripcion = const Value.absent(),
          int? cantidad,
          double? precioUnit,
          double? pctSalon,
          double? pctVendedor,
          double? montoProveedor,
          double? montoSalon,
          double? montoVendedor,
          Value<String?> liquidacionId = const Value.absent()}) =>
      VentaItem(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        ventaId: ventaId ?? this.ventaId,
        varianteId: varianteId.present ? varianteId.value : this.varianteId,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        cantidad: cantidad ?? this.cantidad,
        precioUnit: precioUnit ?? this.precioUnit,
        pctSalon: pctSalon ?? this.pctSalon,
        pctVendedor: pctVendedor ?? this.pctVendedor,
        montoProveedor: montoProveedor ?? this.montoProveedor,
        montoSalon: montoSalon ?? this.montoSalon,
        montoVendedor: montoVendedor ?? this.montoVendedor,
        liquidacionId:
            liquidacionId.present ? liquidacionId.value : this.liquidacionId,
      );
  VentaItem copyWithCompanion(VentaItemsCompanion data) {
    return VentaItem(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      varianteId:
          data.varianteId.present ? data.varianteId.value : this.varianteId,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnit:
          data.precioUnit.present ? data.precioUnit.value : this.precioUnit,
      pctSalon: data.pctSalon.present ? data.pctSalon.value : this.pctSalon,
      pctVendedor:
          data.pctVendedor.present ? data.pctVendedor.value : this.pctVendedor,
      montoProveedor: data.montoProveedor.present
          ? data.montoProveedor.value
          : this.montoProveedor,
      montoSalon:
          data.montoSalon.present ? data.montoSalon.value : this.montoSalon,
      montoVendedor: data.montoVendedor.present
          ? data.montoVendedor.value
          : this.montoVendedor,
      liquidacionId: data.liquidacionId.present
          ? data.liquidacionId.value
          : this.liquidacionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VentaItem(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ventaId: $ventaId, ')
          ..write('varianteId: $varianteId, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnit: $precioUnit, ')
          ..write('pctSalon: $pctSalon, ')
          ..write('pctVendedor: $pctVendedor, ')
          ..write('montoProveedor: $montoProveedor, ')
          ..write('montoSalon: $montoSalon, ')
          ..write('montoVendedor: $montoVendedor, ')
          ..write('liquidacionId: $liquidacionId')
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
      ventaId,
      varianteId,
      descripcion,
      cantidad,
      precioUnit,
      pctSalon,
      pctVendedor,
      montoProveedor,
      montoSalon,
      montoVendedor,
      liquidacionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VentaItem &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.ventaId == this.ventaId &&
          other.varianteId == this.varianteId &&
          other.descripcion == this.descripcion &&
          other.cantidad == this.cantidad &&
          other.precioUnit == this.precioUnit &&
          other.pctSalon == this.pctSalon &&
          other.pctVendedor == this.pctVendedor &&
          other.montoProveedor == this.montoProveedor &&
          other.montoSalon == this.montoSalon &&
          other.montoVendedor == this.montoVendedor &&
          other.liquidacionId == this.liquidacionId);
}

class VentaItemsCompanion extends UpdateCompanion<VentaItem> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> ventaId;
  final Value<String?> varianteId;
  final Value<String?> descripcion;
  final Value<int> cantidad;
  final Value<double> precioUnit;
  final Value<double> pctSalon;
  final Value<double> pctVendedor;
  final Value<double> montoProveedor;
  final Value<double> montoSalon;
  final Value<double> montoVendedor;
  final Value<String?> liquidacionId;
  final Value<int> rowid;
  const VentaItemsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.varianteId = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnit = const Value.absent(),
    this.pctSalon = const Value.absent(),
    this.pctVendedor = const Value.absent(),
    this.montoProveedor = const Value.absent(),
    this.montoSalon = const Value.absent(),
    this.montoVendedor = const Value.absent(),
    this.liquidacionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentaItemsCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String ventaId,
    this.varianteId = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnit = const Value.absent(),
    this.pctSalon = const Value.absent(),
    this.pctVendedor = const Value.absent(),
    this.montoProveedor = const Value.absent(),
    this.montoSalon = const Value.absent(),
    this.montoVendedor = const Value.absent(),
    this.liquidacionId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        ventaId = Value(ventaId);
  static Insertable<VentaItem> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? ventaId,
    Expression<String>? varianteId,
    Expression<String>? descripcion,
    Expression<int>? cantidad,
    Expression<double>? precioUnit,
    Expression<double>? pctSalon,
    Expression<double>? pctVendedor,
    Expression<double>? montoProveedor,
    Expression<double>? montoSalon,
    Expression<double>? montoVendedor,
    Expression<String>? liquidacionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (ventaId != null) 'venta_id': ventaId,
      if (varianteId != null) 'variante_id': varianteId,
      if (descripcion != null) 'descripcion': descripcion,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnit != null) 'precio_unit': precioUnit,
      if (pctSalon != null) 'pct_salon': pctSalon,
      if (pctVendedor != null) 'pct_vendedor': pctVendedor,
      if (montoProveedor != null) 'monto_proveedor': montoProveedor,
      if (montoSalon != null) 'monto_salon': montoSalon,
      if (montoVendedor != null) 'monto_vendedor': montoVendedor,
      if (liquidacionId != null) 'liquidacion_id': liquidacionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentaItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? ventaId,
      Value<String?>? varianteId,
      Value<String?>? descripcion,
      Value<int>? cantidad,
      Value<double>? precioUnit,
      Value<double>? pctSalon,
      Value<double>? pctVendedor,
      Value<double>? montoProveedor,
      Value<double>? montoSalon,
      Value<double>? montoVendedor,
      Value<String?>? liquidacionId,
      Value<int>? rowid}) {
    return VentaItemsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      ventaId: ventaId ?? this.ventaId,
      varianteId: varianteId ?? this.varianteId,
      descripcion: descripcion ?? this.descripcion,
      cantidad: cantidad ?? this.cantidad,
      precioUnit: precioUnit ?? this.precioUnit,
      pctSalon: pctSalon ?? this.pctSalon,
      pctVendedor: pctVendedor ?? this.pctVendedor,
      montoProveedor: montoProveedor ?? this.montoProveedor,
      montoSalon: montoSalon ?? this.montoSalon,
      montoVendedor: montoVendedor ?? this.montoVendedor,
      liquidacionId: liquidacionId ?? this.liquidacionId,
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
    if (ventaId.present) {
      map['venta_id'] = Variable<String>(ventaId.value);
    }
    if (varianteId.present) {
      map['variante_id'] = Variable<String>(varianteId.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnit.present) {
      map['precio_unit'] = Variable<double>(precioUnit.value);
    }
    if (pctSalon.present) {
      map['pct_salon'] = Variable<double>(pctSalon.value);
    }
    if (pctVendedor.present) {
      map['pct_vendedor'] = Variable<double>(pctVendedor.value);
    }
    if (montoProveedor.present) {
      map['monto_proveedor'] = Variable<double>(montoProveedor.value);
    }
    if (montoSalon.present) {
      map['monto_salon'] = Variable<double>(montoSalon.value);
    }
    if (montoVendedor.present) {
      map['monto_vendedor'] = Variable<double>(montoVendedor.value);
    }
    if (liquidacionId.present) {
      map['liquidacion_id'] = Variable<String>(liquidacionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentaItemsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ventaId: $ventaId, ')
          ..write('varianteId: $varianteId, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnit: $precioUnit, ')
          ..write('pctSalon: $pctSalon, ')
          ..write('pctVendedor: $pctVendedor, ')
          ..write('montoProveedor: $montoProveedor, ')
          ..write('montoSalon: $montoSalon, ')
          ..write('montoVendedor: $montoVendedor, ')
          ..write('liquidacionId: $liquidacionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReservasTable extends Reservas with TableInfo<$ReservasTable, Reserva> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReservasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
      'codigo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendiente'));
  static const VerificationMeta _venceAtMeta =
      const VerificationMeta('venceAt');
  @override
  late final GeneratedColumn<DateTime> venceAt = GeneratedColumn<DateTime>(
      'vence_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
        codigo,
        nombre,
        telefono,
        estado,
        venceAt,
        notas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reservas';
  @override
  VerificationContext validateIntegrity(Insertable<Reserva> instance,
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
    if (data.containsKey('codigo')) {
      context.handle(_codigoMeta,
          codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta));
    } else if (isInserting) {
      context.missing(_codigoMeta);
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
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('vence_at')) {
      context.handle(_venceAtMeta,
          venceAt.isAcceptableOrUnknown(data['vence_at']!, _venceAtMeta));
    } else if (isInserting) {
      context.missing(_venceAtMeta);
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
  Reserva map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reserva(
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
      codigo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codigo'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      venceAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}vence_at'])!,
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
    );
  }

  @override
  $ReservasTable createAlias(String alias) {
    return $ReservasTable(attachedDatabase, alias);
  }
}

class Reserva extends DataClass implements Insertable<Reserva> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String codigo;
  final String nombre;
  final String? telefono;

  /// `pendiente` | `confirmada` | `entregada` | `cancelada`
  final String estado;
  final DateTime venceAt;
  final String? notas;
  const Reserva(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.codigo,
      required this.nombre,
      this.telefono,
      required this.estado,
      required this.venceAt,
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
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    map['estado'] = Variable<String>(estado);
    map['vence_at'] = Variable<DateTime>(venceAt);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  ReservasCompanion toCompanion(bool nullToAbsent) {
    return ReservasCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      codigo: Value(codigo),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      estado: Value(estado),
      venceAt: Value(venceAt),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
    );
  }

  factory Reserva.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reserva(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      estado: serializer.fromJson<String>(json['estado']),
      venceAt: serializer.fromJson<DateTime>(json['venceAt']),
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
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
      'estado': serializer.toJson<String>(estado),
      'venceAt': serializer.toJson<DateTime>(venceAt),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Reserva copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? codigo,
          String? nombre,
          Value<String?> telefono = const Value.absent(),
          String? estado,
          DateTime? venceAt,
          Value<String?> notas = const Value.absent()}) =>
      Reserva(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        codigo: codigo ?? this.codigo,
        nombre: nombre ?? this.nombre,
        telefono: telefono.present ? telefono.value : this.telefono,
        estado: estado ?? this.estado,
        venceAt: venceAt ?? this.venceAt,
        notas: notas.present ? notas.value : this.notas,
      );
  Reserva copyWithCompanion(ReservasCompanion data) {
    return Reserva(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      estado: data.estado.present ? data.estado.value : this.estado,
      venceAt: data.venceAt.present ? data.venceAt.value : this.venceAt,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reserva(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('estado: $estado, ')
          ..write('venceAt: $venceAt, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      codigo, nombre, telefono, estado, venceAt, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reserva &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.estado == this.estado &&
          other.venceAt == this.venceAt &&
          other.notas == this.notas);
}

class ReservasCompanion extends UpdateCompanion<Reserva> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<String> estado;
  final Value<DateTime> venceAt;
  final Value<String?> notas;
  final Value<int> rowid;
  const ReservasCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.estado = const Value.absent(),
    this.venceAt = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReservasCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String codigo,
    required String nombre,
    this.telefono = const Value.absent(),
    this.estado = const Value.absent(),
    required DateTime venceAt,
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        codigo = Value(codigo),
        nombre = Value(nombre),
        venceAt = Value(venceAt);
  static Insertable<Reserva> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? estado,
    Expression<DateTime>? venceAt,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (estado != null) 'estado': estado,
      if (venceAt != null) 'vence_at': venceAt,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReservasCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? codigo,
      Value<String>? nombre,
      Value<String?>? telefono,
      Value<String>? estado,
      Value<DateTime>? venceAt,
      Value<String?>? notas,
      Value<int>? rowid}) {
    return ReservasCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      estado: estado ?? this.estado,
      venceAt: venceAt ?? this.venceAt,
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
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (venceAt.present) {
      map['vence_at'] = Variable<DateTime>(venceAt.value);
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
    return (StringBuffer('ReservasCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('estado: $estado, ')
          ..write('venceAt: $venceAt, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReservaItemsTable extends ReservaItems
    with TableInfo<$ReservaItemsTable, ReservaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReservaItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _reservaIdMeta =
      const VerificationMeta('reservaId');
  @override
  late final GeneratedColumn<String> reservaId = GeneratedColumn<String>(
      'reserva_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _varianteIdMeta =
      const VerificationMeta('varianteId');
  @override
  late final GeneratedColumn<String> varianteId = GeneratedColumn<String>(
      'variante_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        createdAt,
        updatedAt,
        deletedAt,
        reservaId,
        varianteId,
        cantidad
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reserva_items';
  @override
  VerificationContext validateIntegrity(Insertable<ReservaItem> instance,
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
    if (data.containsKey('reserva_id')) {
      context.handle(_reservaIdMeta,
          reservaId.isAcceptableOrUnknown(data['reserva_id']!, _reservaIdMeta));
    } else if (isInserting) {
      context.missing(_reservaIdMeta);
    }
    if (data.containsKey('variante_id')) {
      context.handle(
          _varianteIdMeta,
          varianteId.isAcceptableOrUnknown(
              data['variante_id']!, _varianteIdMeta));
    } else if (isInserting) {
      context.missing(_varianteIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReservaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReservaItem(
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
      reservaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reserva_id'])!,
      varianteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variante_id'])!,
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cantidad'])!,
    );
  }

  @override
  $ReservaItemsTable createAlias(String alias) {
    return $ReservaItemsTable(attachedDatabase, alias);
  }
}

class ReservaItem extends DataClass implements Insertable<ReservaItem> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String reservaId;
  final String varianteId;
  final int cantidad;
  const ReservaItem(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.reservaId,
      required this.varianteId,
      required this.cantidad});
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
    map['reserva_id'] = Variable<String>(reservaId);
    map['variante_id'] = Variable<String>(varianteId);
    map['cantidad'] = Variable<int>(cantidad);
    return map;
  }

  ReservaItemsCompanion toCompanion(bool nullToAbsent) {
    return ReservaItemsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      reservaId: Value(reservaId),
      varianteId: Value(varianteId),
      cantidad: Value(cantidad),
    );
  }

  factory ReservaItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReservaItem(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      reservaId: serializer.fromJson<String>(json['reservaId']),
      varianteId: serializer.fromJson<String>(json['varianteId']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
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
      'reservaId': serializer.toJson<String>(reservaId),
      'varianteId': serializer.toJson<String>(varianteId),
      'cantidad': serializer.toJson<int>(cantidad),
    };
  }

  ReservaItem copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? reservaId,
          String? varianteId,
          int? cantidad}) =>
      ReservaItem(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        reservaId: reservaId ?? this.reservaId,
        varianteId: varianteId ?? this.varianteId,
        cantidad: cantidad ?? this.cantidad,
      );
  ReservaItem copyWithCompanion(ReservaItemsCompanion data) {
    return ReservaItem(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      reservaId: data.reservaId.present ? data.reservaId.value : this.reservaId,
      varianteId:
          data.varianteId.present ? data.varianteId.value : this.varianteId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReservaItem(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('reservaId: $reservaId, ')
          ..write('varianteId: $varianteId, ')
          ..write('cantidad: $cantidad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      reservaId, varianteId, cantidad);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReservaItem &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.reservaId == this.reservaId &&
          other.varianteId == this.varianteId &&
          other.cantidad == this.cantidad);
}

class ReservaItemsCompanion extends UpdateCompanion<ReservaItem> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> reservaId;
  final Value<String> varianteId;
  final Value<int> cantidad;
  final Value<int> rowid;
  const ReservaItemsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.reservaId = const Value.absent(),
    this.varianteId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReservaItemsCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String reservaId,
    required String varianteId,
    this.cantidad = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        reservaId = Value(reservaId),
        varianteId = Value(varianteId);
  static Insertable<ReservaItem> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? reservaId,
    Expression<String>? varianteId,
    Expression<int>? cantidad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (reservaId != null) 'reserva_id': reservaId,
      if (varianteId != null) 'variante_id': varianteId,
      if (cantidad != null) 'cantidad': cantidad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReservaItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? reservaId,
      Value<String>? varianteId,
      Value<int>? cantidad,
      Value<int>? rowid}) {
    return ReservaItemsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      reservaId: reservaId ?? this.reservaId,
      varianteId: varianteId ?? this.varianteId,
      cantidad: cantidad ?? this.cantidad,
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
    if (reservaId.present) {
      map['reserva_id'] = Variable<String>(reservaId.value);
    }
    if (varianteId.present) {
      map['variante_id'] = Variable<String>(varianteId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReservaItemsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('reservaId: $reservaId, ')
          ..write('varianteId: $varianteId, ')
          ..write('cantidad: $cantidad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LiquidacionesTable extends Liquidaciones
    with TableInfo<$LiquidacionesTable, Liquidacione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiquidacionesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _destinatarioIdMeta =
      const VerificationMeta('destinatarioId');
  @override
  late final GeneratedColumn<String> destinatarioId = GeneratedColumn<String>(
      'destinatario_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodoDesdeMeta =
      const VerificationMeta('periodoDesde');
  @override
  late final GeneratedColumn<String> periodoDesde = GeneratedColumn<String>(
      'periodo_desde', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodoHastaMeta =
      const VerificationMeta('periodoHasta');
  @override
  late final GeneratedColumn<String> periodoHasta = GeneratedColumn<String>(
      'periodo_hasta', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('borrador'));
  static const VerificationMeta _pagadaAtMeta =
      const VerificationMeta('pagadaAt');
  @override
  late final GeneratedColumn<DateTime> pagadaAt = GeneratedColumn<DateTime>(
      'pagada_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        tipo,
        destinatarioId,
        periodoDesde,
        periodoHasta,
        total,
        estado,
        pagadaAt,
        notas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'liquidaciones';
  @override
  VerificationContext validateIntegrity(Insertable<Liquidacione> instance,
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
    if (data.containsKey('destinatario_id')) {
      context.handle(
          _destinatarioIdMeta,
          destinatarioId.isAcceptableOrUnknown(
              data['destinatario_id']!, _destinatarioIdMeta));
    } else if (isInserting) {
      context.missing(_destinatarioIdMeta);
    }
    if (data.containsKey('periodo_desde')) {
      context.handle(
          _periodoDesdeMeta,
          periodoDesde.isAcceptableOrUnknown(
              data['periodo_desde']!, _periodoDesdeMeta));
    } else if (isInserting) {
      context.missing(_periodoDesdeMeta);
    }
    if (data.containsKey('periodo_hasta')) {
      context.handle(
          _periodoHastaMeta,
          periodoHasta.isAcceptableOrUnknown(
              data['periodo_hasta']!, _periodoHastaMeta));
    } else if (isInserting) {
      context.missing(_periodoHastaMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('pagada_at')) {
      context.handle(_pagadaAtMeta,
          pagadaAt.isAcceptableOrUnknown(data['pagada_at']!, _pagadaAtMeta));
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
  Liquidacione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Liquidacione(
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
      destinatarioId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destinatario_id'])!,
      periodoDesde: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}periodo_desde'])!,
      periodoHasta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}periodo_hasta'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      pagadaAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}pagada_at']),
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
    );
  }

  @override
  $LiquidacionesTable createAlias(String alias) {
    return $LiquidacionesTable(attachedDatabase, alias);
  }
}

class Liquidacione extends DataClass implements Insertable<Liquidacione> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// `proveedor` | `vendedor`
  final String tipo;
  final String destinatarioId;
  final String periodoDesde;
  final String periodoHasta;
  final double total;

  /// `borrador` | `pagada`
  final String estado;
  final DateTime? pagadaAt;
  final String? notas;
  const Liquidacione(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.tipo,
      required this.destinatarioId,
      required this.periodoDesde,
      required this.periodoHasta,
      required this.total,
      required this.estado,
      this.pagadaAt,
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
    map['tipo'] = Variable<String>(tipo);
    map['destinatario_id'] = Variable<String>(destinatarioId);
    map['periodo_desde'] = Variable<String>(periodoDesde);
    map['periodo_hasta'] = Variable<String>(periodoHasta);
    map['total'] = Variable<double>(total);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || pagadaAt != null) {
      map['pagada_at'] = Variable<DateTime>(pagadaAt);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  LiquidacionesCompanion toCompanion(bool nullToAbsent) {
    return LiquidacionesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      tipo: Value(tipo),
      destinatarioId: Value(destinatarioId),
      periodoDesde: Value(periodoDesde),
      periodoHasta: Value(periodoHasta),
      total: Value(total),
      estado: Value(estado),
      pagadaAt: pagadaAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pagadaAt),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
    );
  }

  factory Liquidacione.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Liquidacione(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      tipo: serializer.fromJson<String>(json['tipo']),
      destinatarioId: serializer.fromJson<String>(json['destinatarioId']),
      periodoDesde: serializer.fromJson<String>(json['periodoDesde']),
      periodoHasta: serializer.fromJson<String>(json['periodoHasta']),
      total: serializer.fromJson<double>(json['total']),
      estado: serializer.fromJson<String>(json['estado']),
      pagadaAt: serializer.fromJson<DateTime?>(json['pagadaAt']),
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
      'tipo': serializer.toJson<String>(tipo),
      'destinatarioId': serializer.toJson<String>(destinatarioId),
      'periodoDesde': serializer.toJson<String>(periodoDesde),
      'periodoHasta': serializer.toJson<String>(periodoHasta),
      'total': serializer.toJson<double>(total),
      'estado': serializer.toJson<String>(estado),
      'pagadaAt': serializer.toJson<DateTime?>(pagadaAt),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Liquidacione copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? tipo,
          String? destinatarioId,
          String? periodoDesde,
          String? periodoHasta,
          double? total,
          String? estado,
          Value<DateTime?> pagadaAt = const Value.absent(),
          Value<String?> notas = const Value.absent()}) =>
      Liquidacione(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        tipo: tipo ?? this.tipo,
        destinatarioId: destinatarioId ?? this.destinatarioId,
        periodoDesde: periodoDesde ?? this.periodoDesde,
        periodoHasta: periodoHasta ?? this.periodoHasta,
        total: total ?? this.total,
        estado: estado ?? this.estado,
        pagadaAt: pagadaAt.present ? pagadaAt.value : this.pagadaAt,
        notas: notas.present ? notas.value : this.notas,
      );
  Liquidacione copyWithCompanion(LiquidacionesCompanion data) {
    return Liquidacione(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      destinatarioId: data.destinatarioId.present
          ? data.destinatarioId.value
          : this.destinatarioId,
      periodoDesde: data.periodoDesde.present
          ? data.periodoDesde.value
          : this.periodoDesde,
      periodoHasta: data.periodoHasta.present
          ? data.periodoHasta.value
          : this.periodoHasta,
      total: data.total.present ? data.total.value : this.total,
      estado: data.estado.present ? data.estado.value : this.estado,
      pagadaAt: data.pagadaAt.present ? data.pagadaAt.value : this.pagadaAt,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Liquidacione(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tipo: $tipo, ')
          ..write('destinatarioId: $destinatarioId, ')
          ..write('periodoDesde: $periodoDesde, ')
          ..write('periodoHasta: $periodoHasta, ')
          ..write('total: $total, ')
          ..write('estado: $estado, ')
          ..write('pagadaAt: $pagadaAt, ')
          ..write('notas: $notas')
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
      destinatarioId,
      periodoDesde,
      periodoHasta,
      total,
      estado,
      pagadaAt,
      notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Liquidacione &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.tipo == this.tipo &&
          other.destinatarioId == this.destinatarioId &&
          other.periodoDesde == this.periodoDesde &&
          other.periodoHasta == this.periodoHasta &&
          other.total == this.total &&
          other.estado == this.estado &&
          other.pagadaAt == this.pagadaAt &&
          other.notas == this.notas);
}

class LiquidacionesCompanion extends UpdateCompanion<Liquidacione> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> tipo;
  final Value<String> destinatarioId;
  final Value<String> periodoDesde;
  final Value<String> periodoHasta;
  final Value<double> total;
  final Value<String> estado;
  final Value<DateTime?> pagadaAt;
  final Value<String?> notas;
  final Value<int> rowid;
  const LiquidacionesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.tipo = const Value.absent(),
    this.destinatarioId = const Value.absent(),
    this.periodoDesde = const Value.absent(),
    this.periodoHasta = const Value.absent(),
    this.total = const Value.absent(),
    this.estado = const Value.absent(),
    this.pagadaAt = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LiquidacionesCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String tipo,
    required String destinatarioId,
    required String periodoDesde,
    required String periodoHasta,
    this.total = const Value.absent(),
    this.estado = const Value.absent(),
    this.pagadaAt = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        tipo = Value(tipo),
        destinatarioId = Value(destinatarioId),
        periodoDesde = Value(periodoDesde),
        periodoHasta = Value(periodoHasta);
  static Insertable<Liquidacione> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? tipo,
    Expression<String>? destinatarioId,
    Expression<String>? periodoDesde,
    Expression<String>? periodoHasta,
    Expression<double>? total,
    Expression<String>? estado,
    Expression<DateTime>? pagadaAt,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (tipo != null) 'tipo': tipo,
      if (destinatarioId != null) 'destinatario_id': destinatarioId,
      if (periodoDesde != null) 'periodo_desde': periodoDesde,
      if (periodoHasta != null) 'periodo_hasta': periodoHasta,
      if (total != null) 'total': total,
      if (estado != null) 'estado': estado,
      if (pagadaAt != null) 'pagada_at': pagadaAt,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LiquidacionesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? tipo,
      Value<String>? destinatarioId,
      Value<String>? periodoDesde,
      Value<String>? periodoHasta,
      Value<double>? total,
      Value<String>? estado,
      Value<DateTime?>? pagadaAt,
      Value<String?>? notas,
      Value<int>? rowid}) {
    return LiquidacionesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tipo: tipo ?? this.tipo,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      periodoDesde: periodoDesde ?? this.periodoDesde,
      periodoHasta: periodoHasta ?? this.periodoHasta,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      pagadaAt: pagadaAt ?? this.pagadaAt,
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
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (destinatarioId.present) {
      map['destinatario_id'] = Variable<String>(destinatarioId.value);
    }
    if (periodoDesde.present) {
      map['periodo_desde'] = Variable<String>(periodoDesde.value);
    }
    if (periodoHasta.present) {
      map['periodo_hasta'] = Variable<String>(periodoHasta.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (pagadaAt.present) {
      map['pagada_at'] = Variable<DateTime>(pagadaAt.value);
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
    return (StringBuffer('LiquidacionesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tipo: $tipo, ')
          ..write('destinatarioId: $destinatarioId, ')
          ..write('periodoDesde: $periodoDesde, ')
          ..write('periodoHasta: $periodoHasta, ')
          ..write('total: $total, ')
          ..write('estado: $estado, ')
          ..write('pagadaAt: $pagadaAt, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovimientosStockTable extends MovimientosStock
    with TableInfo<$MovimientosStockTable, MovimientosStockData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosStockTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _varianteIdMeta =
      const VerificationMeta('varianteId');
  @override
  late final GeneratedColumn<String> varianteId = GeneratedColumn<String>(
      'variante_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _depositoIdMeta =
      const VerificationMeta('depositoId');
  @override
  late final GeneratedColumn<String> depositoId = GeneratedColumn<String>(
      'deposito_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
      'delta', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
      'motivo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenciaIdMeta =
      const VerificationMeta('referenciaId');
  @override
  late final GeneratedColumn<String> referenciaId = GeneratedColumn<String>(
      'referencia_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        varianteId,
        depositoId,
        delta,
        motivo,
        referenciaId,
        notas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_stock';
  @override
  VerificationContext validateIntegrity(
      Insertable<MovimientosStockData> instance,
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
    if (data.containsKey('variante_id')) {
      context.handle(
          _varianteIdMeta,
          varianteId.isAcceptableOrUnknown(
              data['variante_id']!, _varianteIdMeta));
    } else if (isInserting) {
      context.missing(_varianteIdMeta);
    }
    if (data.containsKey('deposito_id')) {
      context.handle(
          _depositoIdMeta,
          depositoId.isAcceptableOrUnknown(
              data['deposito_id']!, _depositoIdMeta));
    } else if (isInserting) {
      context.missing(_depositoIdMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
          _deltaMeta, delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta));
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(_motivoMeta,
          motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta));
    } else if (isInserting) {
      context.missing(_motivoMeta);
    }
    if (data.containsKey('referencia_id')) {
      context.handle(
          _referenciaIdMeta,
          referenciaId.isAcceptableOrUnknown(
              data['referencia_id']!, _referenciaIdMeta));
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
  MovimientosStockData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimientosStockData(
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
      varianteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variante_id'])!,
      depositoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deposito_id'])!,
      delta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}delta'])!,
      motivo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motivo'])!,
      referenciaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}referencia_id']),
      notas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notas']),
    );
  }

  @override
  $MovimientosStockTable createAlias(String alias) {
    return $MovimientosStockTable(attachedDatabase, alias);
  }
}

class MovimientosStockData extends DataClass
    implements Insertable<MovimientosStockData> {
  final String id;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String varianteId;
  final String depositoId;
  final int delta;

  /// `ingreso` | `venta` | `devolucion_proveedor` | `transferencia` |
  /// `ajuste` | `anulacion`
  final String motivo;
  final String? referenciaId;
  final String? notas;
  const MovimientosStockData(
      {required this.id,
      required this.tenantId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.varianteId,
      required this.depositoId,
      required this.delta,
      required this.motivo,
      this.referenciaId,
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
    map['variante_id'] = Variable<String>(varianteId);
    map['deposito_id'] = Variable<String>(depositoId);
    map['delta'] = Variable<int>(delta);
    map['motivo'] = Variable<String>(motivo);
    if (!nullToAbsent || referenciaId != null) {
      map['referencia_id'] = Variable<String>(referenciaId);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  MovimientosStockCompanion toCompanion(bool nullToAbsent) {
    return MovimientosStockCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      varianteId: Value(varianteId),
      depositoId: Value(depositoId),
      delta: Value(delta),
      motivo: Value(motivo),
      referenciaId: referenciaId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenciaId),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
    );
  }

  factory MovimientosStockData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimientosStockData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      varianteId: serializer.fromJson<String>(json['varianteId']),
      depositoId: serializer.fromJson<String>(json['depositoId']),
      delta: serializer.fromJson<int>(json['delta']),
      motivo: serializer.fromJson<String>(json['motivo']),
      referenciaId: serializer.fromJson<String?>(json['referenciaId']),
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
      'varianteId': serializer.toJson<String>(varianteId),
      'depositoId': serializer.toJson<String>(depositoId),
      'delta': serializer.toJson<int>(delta),
      'motivo': serializer.toJson<String>(motivo),
      'referenciaId': serializer.toJson<String?>(referenciaId),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  MovimientosStockData copyWith(
          {String? id,
          String? tenantId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? varianteId,
          String? depositoId,
          int? delta,
          String? motivo,
          Value<String?> referenciaId = const Value.absent(),
          Value<String?> notas = const Value.absent()}) =>
      MovimientosStockData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        varianteId: varianteId ?? this.varianteId,
        depositoId: depositoId ?? this.depositoId,
        delta: delta ?? this.delta,
        motivo: motivo ?? this.motivo,
        referenciaId:
            referenciaId.present ? referenciaId.value : this.referenciaId,
        notas: notas.present ? notas.value : this.notas,
      );
  MovimientosStockData copyWithCompanion(MovimientosStockCompanion data) {
    return MovimientosStockData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      varianteId:
          data.varianteId.present ? data.varianteId.value : this.varianteId,
      depositoId:
          data.depositoId.present ? data.depositoId.value : this.depositoId,
      delta: data.delta.present ? data.delta.value : this.delta,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      referenciaId: data.referenciaId.present
          ? data.referenciaId.value
          : this.referenciaId,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosStockData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('varianteId: $varianteId, ')
          ..write('depositoId: $depositoId, ')
          ..write('delta: $delta, ')
          ..write('motivo: $motivo, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, createdAt, updatedAt, deletedAt,
      varianteId, depositoId, delta, motivo, referenciaId, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimientosStockData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.varianteId == this.varianteId &&
          other.depositoId == this.depositoId &&
          other.delta == this.delta &&
          other.motivo == this.motivo &&
          other.referenciaId == this.referenciaId &&
          other.notas == this.notas);
}

class MovimientosStockCompanion extends UpdateCompanion<MovimientosStockData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> varianteId;
  final Value<String> depositoId;
  final Value<int> delta;
  final Value<String> motivo;
  final Value<String?> referenciaId;
  final Value<String?> notas;
  final Value<int> rowid;
  const MovimientosStockCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.varianteId = const Value.absent(),
    this.depositoId = const Value.absent(),
    this.delta = const Value.absent(),
    this.motivo = const Value.absent(),
    this.referenciaId = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovimientosStockCompanion.insert({
    required String id,
    required String tenantId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String varianteId,
    required String depositoId,
    required int delta,
    required String motivo,
    this.referenciaId = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        varianteId = Value(varianteId),
        depositoId = Value(depositoId),
        delta = Value(delta),
        motivo = Value(motivo);
  static Insertable<MovimientosStockData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? varianteId,
    Expression<String>? depositoId,
    Expression<int>? delta,
    Expression<String>? motivo,
    Expression<String>? referenciaId,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (varianteId != null) 'variante_id': varianteId,
      if (depositoId != null) 'deposito_id': depositoId,
      if (delta != null) 'delta': delta,
      if (motivo != null) 'motivo': motivo,
      if (referenciaId != null) 'referencia_id': referenciaId,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovimientosStockCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? varianteId,
      Value<String>? depositoId,
      Value<int>? delta,
      Value<String>? motivo,
      Value<String?>? referenciaId,
      Value<String?>? notas,
      Value<int>? rowid}) {
    return MovimientosStockCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      varianteId: varianteId ?? this.varianteId,
      depositoId: depositoId ?? this.depositoId,
      delta: delta ?? this.delta,
      motivo: motivo ?? this.motivo,
      referenciaId: referenciaId ?? this.referenciaId,
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
    if (varianteId.present) {
      map['variante_id'] = Variable<String>(varianteId.value);
    }
    if (depositoId.present) {
      map['deposito_id'] = Variable<String>(depositoId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (referenciaId.present) {
      map['referencia_id'] = Variable<String>(referenciaId.value);
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
    return (StringBuffer('MovimientosStockCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('varianteId: $varianteId, ')
          ..write('depositoId: $depositoId, ')
          ..write('delta: $delta, ')
          ..write('motivo: $motivo, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('notas: $notas, ')
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
  late final $ProveedoresTable proveedores = $ProveedoresTable(this);
  late final $DepositosTable depositos = $DepositosTable(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $ProductoVariantesTable productoVariantes =
      $ProductoVariantesTable(this);
  late final $StockVariantesTable stockVariantes = $StockVariantesTable(this);
  late final $ProductoFotosTable productoFotos = $ProductoFotosTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $VentaItemsTable ventaItems = $VentaItemsTable(this);
  late final $ReservasTable reservas = $ReservasTable(this);
  late final $ReservaItemsTable reservaItems = $ReservaItemsTable(this);
  late final $LiquidacionesTable liquidaciones = $LiquidacionesTable(this);
  late final $MovimientosStockTable movimientosStock =
      $MovimientosStockTable(this);
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
        accessCache,
        proveedores,
        depositos,
        productos,
        productoVariantes,
        stockVariantes,
        productoFotos,
        ventas,
        ventaItems,
        reservas,
        reservaItems,
        liquidaciones,
        movimientosStock
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
  required String appointmentId,
  required String serviceId,
  Value<double> precio,
  Value<int> rowid,
});
typedef $$AppointmentServicesTableUpdateCompanionBuilder
    = AppointmentServicesCompanion Function({
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
            Value<String> appointmentId = const Value.absent(),
            Value<String> serviceId = const Value.absent(),
            Value<double> precio = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentServicesCompanion(
            appointmentId: appointmentId,
            serviceId: serviceId,
            precio: precio,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String appointmentId,
            required String serviceId,
            Value<double> precio = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppointmentServicesCompanion.insert(
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
typedef $$ProveedoresTableCreateCompanionBuilder = ProveedoresCompanion
    Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String nombre,
  Value<String?> telefono,
  Value<String?> email,
  Value<double> pctSalon,
  Value<bool> descuentoLoAbsorbeSalon,
  Value<String?> notas,
  Value<bool> activo,
  Value<int> rowid,
});
typedef $$ProveedoresTableUpdateCompanionBuilder = ProveedoresCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> nombre,
  Value<String?> telefono,
  Value<String?> email,
  Value<double> pctSalon,
  Value<bool> descuentoLoAbsorbeSalon,
  Value<String?> notas,
  Value<bool> activo,
  Value<int> rowid,
});

class $$ProveedoresTableFilterComposer
    extends Composer<_$MirameDb, $ProveedoresTable> {
  $$ProveedoresTableFilterComposer({
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

  ColumnFilters<double> get pctSalon => $composableBuilder(
      column: $table.pctSalon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get descuentoLoAbsorbeSalon => $composableBuilder(
      column: $table.descuentoLoAbsorbeSalon,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnFilters(column));
}

class $$ProveedoresTableOrderingComposer
    extends Composer<_$MirameDb, $ProveedoresTable> {
  $$ProveedoresTableOrderingComposer({
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

  ColumnOrderings<double> get pctSalon => $composableBuilder(
      column: $table.pctSalon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get descuentoLoAbsorbeSalon => $composableBuilder(
      column: $table.descuentoLoAbsorbeSalon,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnOrderings(column));
}

class $$ProveedoresTableAnnotationComposer
    extends Composer<_$MirameDb, $ProveedoresTable> {
  $$ProveedoresTableAnnotationComposer({
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

  GeneratedColumn<double> get pctSalon =>
      $composableBuilder(column: $table.pctSalon, builder: (column) => column);

  GeneratedColumn<bool> get descuentoLoAbsorbeSalon => $composableBuilder(
      column: $table.descuentoLoAbsorbeSalon, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);
}

class $$ProveedoresTableTableManager extends RootTableManager<
    _$MirameDb,
    $ProveedoresTable,
    Proveedore,
    $$ProveedoresTableFilterComposer,
    $$ProveedoresTableOrderingComposer,
    $$ProveedoresTableAnnotationComposer,
    $$ProveedoresTableCreateCompanionBuilder,
    $$ProveedoresTableUpdateCompanionBuilder,
    (Proveedore, BaseReferences<_$MirameDb, $ProveedoresTable, Proveedore>),
    Proveedore,
    PrefetchHooks Function()> {
  $$ProveedoresTableTableManager(_$MirameDb db, $ProveedoresTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProveedoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProveedoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProveedoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<double> pctSalon = const Value.absent(),
            Value<bool> descuentoLoAbsorbeSalon = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<bool> activo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProveedoresCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            telefono: telefono,
            email: email,
            pctSalon: pctSalon,
            descuentoLoAbsorbeSalon: descuentoLoAbsorbeSalon,
            notas: notas,
            activo: activo,
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
            Value<double> pctSalon = const Value.absent(),
            Value<bool> descuentoLoAbsorbeSalon = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<bool> activo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProveedoresCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            telefono: telefono,
            email: email,
            pctSalon: pctSalon,
            descuentoLoAbsorbeSalon: descuentoLoAbsorbeSalon,
            notas: notas,
            activo: activo,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProveedoresTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ProveedoresTable,
    Proveedore,
    $$ProveedoresTableFilterComposer,
    $$ProveedoresTableOrderingComposer,
    $$ProveedoresTableAnnotationComposer,
    $$ProveedoresTableCreateCompanionBuilder,
    $$ProveedoresTableUpdateCompanionBuilder,
    (Proveedore, BaseReferences<_$MirameDb, $ProveedoresTable, Proveedore>),
    Proveedore,
    PrefetchHooks Function()>;
typedef $$DepositosTableCreateCompanionBuilder = DepositosCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String nombre,
  Value<String?> direccion,
  Value<bool> esPrincipal,
  Value<int> rowid,
});
typedef $$DepositosTableUpdateCompanionBuilder = DepositosCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> nombre,
  Value<String?> direccion,
  Value<bool> esPrincipal,
  Value<int> rowid,
});

class $$DepositosTableFilterComposer
    extends Composer<_$MirameDb, $DepositosTable> {
  $$DepositosTableFilterComposer({
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

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esPrincipal => $composableBuilder(
      column: $table.esPrincipal, builder: (column) => ColumnFilters(column));
}

class $$DepositosTableOrderingComposer
    extends Composer<_$MirameDb, $DepositosTable> {
  $$DepositosTableOrderingComposer({
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

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esPrincipal => $composableBuilder(
      column: $table.esPrincipal, builder: (column) => ColumnOrderings(column));
}

class $$DepositosTableAnnotationComposer
    extends Composer<_$MirameDb, $DepositosTable> {
  $$DepositosTableAnnotationComposer({
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

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<bool> get esPrincipal => $composableBuilder(
      column: $table.esPrincipal, builder: (column) => column);
}

class $$DepositosTableTableManager extends RootTableManager<
    _$MirameDb,
    $DepositosTable,
    Deposito,
    $$DepositosTableFilterComposer,
    $$DepositosTableOrderingComposer,
    $$DepositosTableAnnotationComposer,
    $$DepositosTableCreateCompanionBuilder,
    $$DepositosTableUpdateCompanionBuilder,
    (Deposito, BaseReferences<_$MirameDb, $DepositosTable, Deposito>),
    Deposito,
    PrefetchHooks Function()> {
  $$DepositosTableTableManager(_$MirameDb db, $DepositosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepositosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepositosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepositosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<bool> esPrincipal = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DepositosCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            direccion: direccion,
            esPrincipal: esPrincipal,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String nombre,
            Value<String?> direccion = const Value.absent(),
            Value<bool> esPrincipal = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DepositosCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nombre: nombre,
            direccion: direccion,
            esPrincipal: esPrincipal,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DepositosTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $DepositosTable,
    Deposito,
    $$DepositosTableFilterComposer,
    $$DepositosTableOrderingComposer,
    $$DepositosTableAnnotationComposer,
    $$DepositosTableCreateCompanionBuilder,
    $$DepositosTableUpdateCompanionBuilder,
    (Deposito, BaseReferences<_$MirameDb, $DepositosTable, Deposito>),
    Deposito,
    PrefetchHooks Function()>;
typedef $$ProductosTableCreateCompanionBuilder = ProductosCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> proveedorId,
  required String nombre,
  Value<String?> descripcion,
  Value<String?> categoria,
  Value<String?> codigo,
  Value<double> precio,
  Value<double?> pctSalon,
  Value<bool> publicado,
  Value<bool> destacado,
  Value<int> rowid,
});
typedef $$ProductosTableUpdateCompanionBuilder = ProductosCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> proveedorId,
  Value<String> nombre,
  Value<String?> descripcion,
  Value<String?> categoria,
  Value<String?> codigo,
  Value<double> precio,
  Value<double?> pctSalon,
  Value<bool> publicado,
  Value<bool> destacado,
  Value<int> rowid,
});

class $$ProductosTableFilterComposer
    extends Composer<_$MirameDb, $ProductosTable> {
  $$ProductosTableFilterComposer({
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

  ColumnFilters<String> get proveedorId => $composableBuilder(
      column: $table.proveedorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pctSalon => $composableBuilder(
      column: $table.pctSalon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get publicado => $composableBuilder(
      column: $table.publicado, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get destacado => $composableBuilder(
      column: $table.destacado, builder: (column) => ColumnFilters(column));
}

class $$ProductosTableOrderingComposer
    extends Composer<_$MirameDb, $ProductosTable> {
  $$ProductosTableOrderingComposer({
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

  ColumnOrderings<String> get proveedorId => $composableBuilder(
      column: $table.proveedorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pctSalon => $composableBuilder(
      column: $table.pctSalon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get publicado => $composableBuilder(
      column: $table.publicado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get destacado => $composableBuilder(
      column: $table.destacado, builder: (column) => ColumnOrderings(column));
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$MirameDb, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
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

  GeneratedColumn<String> get proveedorId => $composableBuilder(
      column: $table.proveedorId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<double> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<double> get pctSalon =>
      $composableBuilder(column: $table.pctSalon, builder: (column) => column);

  GeneratedColumn<bool> get publicado =>
      $composableBuilder(column: $table.publicado, builder: (column) => column);

  GeneratedColumn<bool> get destacado =>
      $composableBuilder(column: $table.destacado, builder: (column) => column);
}

class $$ProductosTableTableManager extends RootTableManager<
    _$MirameDb,
    $ProductosTable,
    Producto,
    $$ProductosTableFilterComposer,
    $$ProductosTableOrderingComposer,
    $$ProductosTableAnnotationComposer,
    $$ProductosTableCreateCompanionBuilder,
    $$ProductosTableUpdateCompanionBuilder,
    (Producto, BaseReferences<_$MirameDb, $ProductosTable, Producto>),
    Producto,
    PrefetchHooks Function()> {
  $$ProductosTableTableManager(_$MirameDb db, $ProductosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> proveedorId = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String?> categoria = const Value.absent(),
            Value<String?> codigo = const Value.absent(),
            Value<double> precio = const Value.absent(),
            Value<double?> pctSalon = const Value.absent(),
            Value<bool> publicado = const Value.absent(),
            Value<bool> destacado = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductosCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            proveedorId: proveedorId,
            nombre: nombre,
            descripcion: descripcion,
            categoria: categoria,
            codigo: codigo,
            precio: precio,
            pctSalon: pctSalon,
            publicado: publicado,
            destacado: destacado,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> proveedorId = const Value.absent(),
            required String nombre,
            Value<String?> descripcion = const Value.absent(),
            Value<String?> categoria = const Value.absent(),
            Value<String?> codigo = const Value.absent(),
            Value<double> precio = const Value.absent(),
            Value<double?> pctSalon = const Value.absent(),
            Value<bool> publicado = const Value.absent(),
            Value<bool> destacado = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductosCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            proveedorId: proveedorId,
            nombre: nombre,
            descripcion: descripcion,
            categoria: categoria,
            codigo: codigo,
            precio: precio,
            pctSalon: pctSalon,
            publicado: publicado,
            destacado: destacado,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductosTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ProductosTable,
    Producto,
    $$ProductosTableFilterComposer,
    $$ProductosTableOrderingComposer,
    $$ProductosTableAnnotationComposer,
    $$ProductosTableCreateCompanionBuilder,
    $$ProductosTableUpdateCompanionBuilder,
    (Producto, BaseReferences<_$MirameDb, $ProductosTable, Producto>),
    Producto,
    PrefetchHooks Function()>;
typedef $$ProductoVariantesTableCreateCompanionBuilder
    = ProductoVariantesCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String productoId,
  Value<String?> talle,
  Value<String?> color,
  Value<String?> sku,
  Value<int> rowid,
});
typedef $$ProductoVariantesTableUpdateCompanionBuilder
    = ProductoVariantesCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> productoId,
  Value<String?> talle,
  Value<String?> color,
  Value<String?> sku,
  Value<int> rowid,
});

class $$ProductoVariantesTableFilterComposer
    extends Composer<_$MirameDb, $ProductoVariantesTable> {
  $$ProductoVariantesTableFilterComposer({
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

  ColumnFilters<String> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get talle => $composableBuilder(
      column: $table.talle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));
}

class $$ProductoVariantesTableOrderingComposer
    extends Composer<_$MirameDb, $ProductoVariantesTable> {
  $$ProductoVariantesTableOrderingComposer({
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

  ColumnOrderings<String> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get talle => $composableBuilder(
      column: $table.talle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));
}

class $$ProductoVariantesTableAnnotationComposer
    extends Composer<_$MirameDb, $ProductoVariantesTable> {
  $$ProductoVariantesTableAnnotationComposer({
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

  GeneratedColumn<String> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => column);

  GeneratedColumn<String> get talle =>
      $composableBuilder(column: $table.talle, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);
}

class $$ProductoVariantesTableTableManager extends RootTableManager<
    _$MirameDb,
    $ProductoVariantesTable,
    ProductoVariante,
    $$ProductoVariantesTableFilterComposer,
    $$ProductoVariantesTableOrderingComposer,
    $$ProductoVariantesTableAnnotationComposer,
    $$ProductoVariantesTableCreateCompanionBuilder,
    $$ProductoVariantesTableUpdateCompanionBuilder,
    (
      ProductoVariante,
      BaseReferences<_$MirameDb, $ProductoVariantesTable, ProductoVariante>
    ),
    ProductoVariante,
    PrefetchHooks Function()> {
  $$ProductoVariantesTableTableManager(
      _$MirameDb db, $ProductoVariantesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductoVariantesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductoVariantesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductoVariantesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> productoId = const Value.absent(),
            Value<String?> talle = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductoVariantesCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            productoId: productoId,
            talle: talle,
            color: color,
            sku: sku,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String productoId,
            Value<String?> talle = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductoVariantesCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            productoId: productoId,
            talle: talle,
            color: color,
            sku: sku,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductoVariantesTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ProductoVariantesTable,
    ProductoVariante,
    $$ProductoVariantesTableFilterComposer,
    $$ProductoVariantesTableOrderingComposer,
    $$ProductoVariantesTableAnnotationComposer,
    $$ProductoVariantesTableCreateCompanionBuilder,
    $$ProductoVariantesTableUpdateCompanionBuilder,
    (
      ProductoVariante,
      BaseReferences<_$MirameDb, $ProductoVariantesTable, ProductoVariante>
    ),
    ProductoVariante,
    PrefetchHooks Function()>;
typedef $$StockVariantesTableCreateCompanionBuilder = StockVariantesCompanion
    Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String varianteId,
  required String depositoId,
  Value<int> cantidad,
  Value<int> rowid,
});
typedef $$StockVariantesTableUpdateCompanionBuilder = StockVariantesCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> varianteId,
  Value<String> depositoId,
  Value<int> cantidad,
  Value<int> rowid,
});

class $$StockVariantesTableFilterComposer
    extends Composer<_$MirameDb, $StockVariantesTable> {
  $$StockVariantesTableFilterComposer({
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

  ColumnFilters<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));
}

class $$StockVariantesTableOrderingComposer
    extends Composer<_$MirameDb, $StockVariantesTable> {
  $$StockVariantesTableOrderingComposer({
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

  ColumnOrderings<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));
}

class $$StockVariantesTableAnnotationComposer
    extends Composer<_$MirameDb, $StockVariantesTable> {
  $$StockVariantesTableAnnotationComposer({
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

  GeneratedColumn<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => column);

  GeneratedColumn<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);
}

class $$StockVariantesTableTableManager extends RootTableManager<
    _$MirameDb,
    $StockVariantesTable,
    StockVariante,
    $$StockVariantesTableFilterComposer,
    $$StockVariantesTableOrderingComposer,
    $$StockVariantesTableAnnotationComposer,
    $$StockVariantesTableCreateCompanionBuilder,
    $$StockVariantesTableUpdateCompanionBuilder,
    (
      StockVariante,
      BaseReferences<_$MirameDb, $StockVariantesTable, StockVariante>
    ),
    StockVariante,
    PrefetchHooks Function()> {
  $$StockVariantesTableTableManager(_$MirameDb db, $StockVariantesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockVariantesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockVariantesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockVariantesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> varianteId = const Value.absent(),
            Value<String> depositoId = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockVariantesCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            varianteId: varianteId,
            depositoId: depositoId,
            cantidad: cantidad,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String varianteId,
            required String depositoId,
            Value<int> cantidad = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockVariantesCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            varianteId: varianteId,
            depositoId: depositoId,
            cantidad: cantidad,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockVariantesTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $StockVariantesTable,
    StockVariante,
    $$StockVariantesTableFilterComposer,
    $$StockVariantesTableOrderingComposer,
    $$StockVariantesTableAnnotationComposer,
    $$StockVariantesTableCreateCompanionBuilder,
    $$StockVariantesTableUpdateCompanionBuilder,
    (
      StockVariante,
      BaseReferences<_$MirameDb, $StockVariantesTable, StockVariante>
    ),
    StockVariante,
    PrefetchHooks Function()>;
typedef $$ProductoFotosTableCreateCompanionBuilder = ProductoFotosCompanion
    Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String productoId,
  Value<String?> varianteId,
  required String path,
  Value<int> orden,
  Value<bool> pendienteDeSubir,
  Value<String?> rutaLocal,
  Value<int> rowid,
});
typedef $$ProductoFotosTableUpdateCompanionBuilder = ProductoFotosCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> productoId,
  Value<String?> varianteId,
  Value<String> path,
  Value<int> orden,
  Value<bool> pendienteDeSubir,
  Value<String?> rutaLocal,
  Value<int> rowid,
});

class $$ProductoFotosTableFilterComposer
    extends Composer<_$MirameDb, $ProductoFotosTable> {
  $$ProductoFotosTableFilterComposer({
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

  ColumnFilters<String> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orden => $composableBuilder(
      column: $table.orden, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendienteDeSubir => $composableBuilder(
      column: $table.pendienteDeSubir,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rutaLocal => $composableBuilder(
      column: $table.rutaLocal, builder: (column) => ColumnFilters(column));
}

class $$ProductoFotosTableOrderingComposer
    extends Composer<_$MirameDb, $ProductoFotosTable> {
  $$ProductoFotosTableOrderingComposer({
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

  ColumnOrderings<String> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orden => $composableBuilder(
      column: $table.orden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendienteDeSubir => $composableBuilder(
      column: $table.pendienteDeSubir,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rutaLocal => $composableBuilder(
      column: $table.rutaLocal, builder: (column) => ColumnOrderings(column));
}

class $$ProductoFotosTableAnnotationComposer
    extends Composer<_$MirameDb, $ProductoFotosTable> {
  $$ProductoFotosTableAnnotationComposer({
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

  GeneratedColumn<String> get productoId => $composableBuilder(
      column: $table.productoId, builder: (column) => column);

  GeneratedColumn<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<bool> get pendienteDeSubir => $composableBuilder(
      column: $table.pendienteDeSubir, builder: (column) => column);

  GeneratedColumn<String> get rutaLocal =>
      $composableBuilder(column: $table.rutaLocal, builder: (column) => column);
}

class $$ProductoFotosTableTableManager extends RootTableManager<
    _$MirameDb,
    $ProductoFotosTable,
    ProductoFoto,
    $$ProductoFotosTableFilterComposer,
    $$ProductoFotosTableOrderingComposer,
    $$ProductoFotosTableAnnotationComposer,
    $$ProductoFotosTableCreateCompanionBuilder,
    $$ProductoFotosTableUpdateCompanionBuilder,
    (
      ProductoFoto,
      BaseReferences<_$MirameDb, $ProductoFotosTable, ProductoFoto>
    ),
    ProductoFoto,
    PrefetchHooks Function()> {
  $$ProductoFotosTableTableManager(_$MirameDb db, $ProductoFotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductoFotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductoFotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductoFotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> productoId = const Value.absent(),
            Value<String?> varianteId = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<int> orden = const Value.absent(),
            Value<bool> pendienteDeSubir = const Value.absent(),
            Value<String?> rutaLocal = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductoFotosCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            productoId: productoId,
            varianteId: varianteId,
            path: path,
            orden: orden,
            pendienteDeSubir: pendienteDeSubir,
            rutaLocal: rutaLocal,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String productoId,
            Value<String?> varianteId = const Value.absent(),
            required String path,
            Value<int> orden = const Value.absent(),
            Value<bool> pendienteDeSubir = const Value.absent(),
            Value<String?> rutaLocal = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductoFotosCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            productoId: productoId,
            varianteId: varianteId,
            path: path,
            orden: orden,
            pendienteDeSubir: pendienteDeSubir,
            rutaLocal: rutaLocal,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductoFotosTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ProductoFotosTable,
    ProductoFoto,
    $$ProductoFotosTableFilterComposer,
    $$ProductoFotosTableOrderingComposer,
    $$ProductoFotosTableAnnotationComposer,
    $$ProductoFotosTableCreateCompanionBuilder,
    $$ProductoFotosTableUpdateCompanionBuilder,
    (
      ProductoFoto,
      BaseReferences<_$MirameDb, $ProductoFotosTable, ProductoFoto>
    ),
    ProductoFoto,
    PrefetchHooks Function()>;
typedef $$VentasTableCreateCompanionBuilder = VentasCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> depositoId,
  Value<String?> vendedorId,
  Value<String?> clientId,
  required String fecha,
  Value<double> total,
  Value<double> descuento,
  Value<String> metodo,
  Value<String> estado,
  Value<String?> notas,
  Value<int> rowid,
});
typedef $$VentasTableUpdateCompanionBuilder = VentasCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> depositoId,
  Value<String?> vendedorId,
  Value<String?> clientId,
  Value<String> fecha,
  Value<double> total,
  Value<double> descuento,
  Value<String> metodo,
  Value<String> estado,
  Value<String?> notas,
  Value<int> rowid,
});

class $$VentasTableFilterComposer extends Composer<_$MirameDb, $VentasTable> {
  $$VentasTableFilterComposer({
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

  ColumnFilters<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vendedorId => $composableBuilder(
      column: $table.vendedorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get descuento => $composableBuilder(
      column: $table.descuento, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metodo => $composableBuilder(
      column: $table.metodo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));
}

class $$VentasTableOrderingComposer extends Composer<_$MirameDb, $VentasTable> {
  $$VentasTableOrderingComposer({
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

  ColumnOrderings<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vendedorId => $composableBuilder(
      column: $table.vendedorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get descuento => $composableBuilder(
      column: $table.descuento, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metodo => $composableBuilder(
      column: $table.metodo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));
}

class $$VentasTableAnnotationComposer
    extends Composer<_$MirameDb, $VentasTable> {
  $$VentasTableAnnotationComposer({
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

  GeneratedColumn<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => column);

  GeneratedColumn<String> get vendedorId => $composableBuilder(
      column: $table.vendedorId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get descuento =>
      $composableBuilder(column: $table.descuento, builder: (column) => column);

  GeneratedColumn<String> get metodo =>
      $composableBuilder(column: $table.metodo, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$VentasTableTableManager extends RootTableManager<
    _$MirameDb,
    $VentasTable,
    Venta,
    $$VentasTableFilterComposer,
    $$VentasTableOrderingComposer,
    $$VentasTableAnnotationComposer,
    $$VentasTableCreateCompanionBuilder,
    $$VentasTableUpdateCompanionBuilder,
    (Venta, BaseReferences<_$MirameDb, $VentasTable, Venta>),
    Venta,
    PrefetchHooks Function()> {
  $$VentasTableTableManager(_$MirameDb db, $VentasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> depositoId = const Value.absent(),
            Value<String?> vendedorId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> fecha = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<double> descuento = const Value.absent(),
            Value<String> metodo = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VentasCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            depositoId: depositoId,
            vendedorId: vendedorId,
            clientId: clientId,
            fecha: fecha,
            total: total,
            descuento: descuento,
            metodo: metodo,
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
            Value<String?> depositoId = const Value.absent(),
            Value<String?> vendedorId = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            required String fecha,
            Value<double> total = const Value.absent(),
            Value<double> descuento = const Value.absent(),
            Value<String> metodo = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VentasCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            depositoId: depositoId,
            vendedorId: vendedorId,
            clientId: clientId,
            fecha: fecha,
            total: total,
            descuento: descuento,
            metodo: metodo,
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

typedef $$VentasTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $VentasTable,
    Venta,
    $$VentasTableFilterComposer,
    $$VentasTableOrderingComposer,
    $$VentasTableAnnotationComposer,
    $$VentasTableCreateCompanionBuilder,
    $$VentasTableUpdateCompanionBuilder,
    (Venta, BaseReferences<_$MirameDb, $VentasTable, Venta>),
    Venta,
    PrefetchHooks Function()>;
typedef $$VentaItemsTableCreateCompanionBuilder = VentaItemsCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String ventaId,
  Value<String?> varianteId,
  Value<String?> descripcion,
  Value<int> cantidad,
  Value<double> precioUnit,
  Value<double> pctSalon,
  Value<double> pctVendedor,
  Value<double> montoProveedor,
  Value<double> montoSalon,
  Value<double> montoVendedor,
  Value<String?> liquidacionId,
  Value<int> rowid,
});
typedef $$VentaItemsTableUpdateCompanionBuilder = VentaItemsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> ventaId,
  Value<String?> varianteId,
  Value<String?> descripcion,
  Value<int> cantidad,
  Value<double> precioUnit,
  Value<double> pctSalon,
  Value<double> pctVendedor,
  Value<double> montoProveedor,
  Value<double> montoSalon,
  Value<double> montoVendedor,
  Value<String?> liquidacionId,
  Value<int> rowid,
});

class $$VentaItemsTableFilterComposer
    extends Composer<_$MirameDb, $VentaItemsTable> {
  $$VentaItemsTableFilterComposer({
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

  ColumnFilters<String> get ventaId => $composableBuilder(
      column: $table.ventaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioUnit => $composableBuilder(
      column: $table.precioUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pctSalon => $composableBuilder(
      column: $table.pctSalon, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pctVendedor => $composableBuilder(
      column: $table.pctVendedor, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoProveedor => $composableBuilder(
      column: $table.montoProveedor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoSalon => $composableBuilder(
      column: $table.montoSalon, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoVendedor => $composableBuilder(
      column: $table.montoVendedor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get liquidacionId => $composableBuilder(
      column: $table.liquidacionId, builder: (column) => ColumnFilters(column));
}

class $$VentaItemsTableOrderingComposer
    extends Composer<_$MirameDb, $VentaItemsTable> {
  $$VentaItemsTableOrderingComposer({
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

  ColumnOrderings<String> get ventaId => $composableBuilder(
      column: $table.ventaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioUnit => $composableBuilder(
      column: $table.precioUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pctSalon => $composableBuilder(
      column: $table.pctSalon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pctVendedor => $composableBuilder(
      column: $table.pctVendedor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoProveedor => $composableBuilder(
      column: $table.montoProveedor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoSalon => $composableBuilder(
      column: $table.montoSalon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoVendedor => $composableBuilder(
      column: $table.montoVendedor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get liquidacionId => $composableBuilder(
      column: $table.liquidacionId,
      builder: (column) => ColumnOrderings(column));
}

class $$VentaItemsTableAnnotationComposer
    extends Composer<_$MirameDb, $VentaItemsTable> {
  $$VentaItemsTableAnnotationComposer({
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

  GeneratedColumn<String> get ventaId =>
      $composableBuilder(column: $table.ventaId, builder: (column) => column);

  GeneratedColumn<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnit => $composableBuilder(
      column: $table.precioUnit, builder: (column) => column);

  GeneratedColumn<double> get pctSalon =>
      $composableBuilder(column: $table.pctSalon, builder: (column) => column);

  GeneratedColumn<double> get pctVendedor => $composableBuilder(
      column: $table.pctVendedor, builder: (column) => column);

  GeneratedColumn<double> get montoProveedor => $composableBuilder(
      column: $table.montoProveedor, builder: (column) => column);

  GeneratedColumn<double> get montoSalon => $composableBuilder(
      column: $table.montoSalon, builder: (column) => column);

  GeneratedColumn<double> get montoVendedor => $composableBuilder(
      column: $table.montoVendedor, builder: (column) => column);

  GeneratedColumn<String> get liquidacionId => $composableBuilder(
      column: $table.liquidacionId, builder: (column) => column);
}

class $$VentaItemsTableTableManager extends RootTableManager<
    _$MirameDb,
    $VentaItemsTable,
    VentaItem,
    $$VentaItemsTableFilterComposer,
    $$VentaItemsTableOrderingComposer,
    $$VentaItemsTableAnnotationComposer,
    $$VentaItemsTableCreateCompanionBuilder,
    $$VentaItemsTableUpdateCompanionBuilder,
    (VentaItem, BaseReferences<_$MirameDb, $VentaItemsTable, VentaItem>),
    VentaItem,
    PrefetchHooks Function()> {
  $$VentaItemsTableTableManager(_$MirameDb db, $VentaItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> ventaId = const Value.absent(),
            Value<String?> varianteId = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<double> precioUnit = const Value.absent(),
            Value<double> pctSalon = const Value.absent(),
            Value<double> pctVendedor = const Value.absent(),
            Value<double> montoProveedor = const Value.absent(),
            Value<double> montoSalon = const Value.absent(),
            Value<double> montoVendedor = const Value.absent(),
            Value<String?> liquidacionId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VentaItemsCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            ventaId: ventaId,
            varianteId: varianteId,
            descripcion: descripcion,
            cantidad: cantidad,
            precioUnit: precioUnit,
            pctSalon: pctSalon,
            pctVendedor: pctVendedor,
            montoProveedor: montoProveedor,
            montoSalon: montoSalon,
            montoVendedor: montoVendedor,
            liquidacionId: liquidacionId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String ventaId,
            Value<String?> varianteId = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<double> precioUnit = const Value.absent(),
            Value<double> pctSalon = const Value.absent(),
            Value<double> pctVendedor = const Value.absent(),
            Value<double> montoProveedor = const Value.absent(),
            Value<double> montoSalon = const Value.absent(),
            Value<double> montoVendedor = const Value.absent(),
            Value<String?> liquidacionId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VentaItemsCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            ventaId: ventaId,
            varianteId: varianteId,
            descripcion: descripcion,
            cantidad: cantidad,
            precioUnit: precioUnit,
            pctSalon: pctSalon,
            pctVendedor: pctVendedor,
            montoProveedor: montoProveedor,
            montoSalon: montoSalon,
            montoVendedor: montoVendedor,
            liquidacionId: liquidacionId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VentaItemsTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $VentaItemsTable,
    VentaItem,
    $$VentaItemsTableFilterComposer,
    $$VentaItemsTableOrderingComposer,
    $$VentaItemsTableAnnotationComposer,
    $$VentaItemsTableCreateCompanionBuilder,
    $$VentaItemsTableUpdateCompanionBuilder,
    (VentaItem, BaseReferences<_$MirameDb, $VentaItemsTable, VentaItem>),
    VentaItem,
    PrefetchHooks Function()>;
typedef $$ReservasTableCreateCompanionBuilder = ReservasCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String codigo,
  required String nombre,
  Value<String?> telefono,
  Value<String> estado,
  required DateTime venceAt,
  Value<String?> notas,
  Value<int> rowid,
});
typedef $$ReservasTableUpdateCompanionBuilder = ReservasCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> codigo,
  Value<String> nombre,
  Value<String?> telefono,
  Value<String> estado,
  Value<DateTime> venceAt,
  Value<String?> notas,
  Value<int> rowid,
});

class $$ReservasTableFilterComposer
    extends Composer<_$MirameDb, $ReservasTable> {
  $$ReservasTableFilterComposer({
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

  ColumnFilters<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get venceAt => $composableBuilder(
      column: $table.venceAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));
}

class $$ReservasTableOrderingComposer
    extends Composer<_$MirameDb, $ReservasTable> {
  $$ReservasTableOrderingComposer({
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

  ColumnOrderings<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get venceAt => $composableBuilder(
      column: $table.venceAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));
}

class $$ReservasTableAnnotationComposer
    extends Composer<_$MirameDb, $ReservasTable> {
  $$ReservasTableAnnotationComposer({
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

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get venceAt =>
      $composableBuilder(column: $table.venceAt, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$ReservasTableTableManager extends RootTableManager<
    _$MirameDb,
    $ReservasTable,
    Reserva,
    $$ReservasTableFilterComposer,
    $$ReservasTableOrderingComposer,
    $$ReservasTableAnnotationComposer,
    $$ReservasTableCreateCompanionBuilder,
    $$ReservasTableUpdateCompanionBuilder,
    (Reserva, BaseReferences<_$MirameDb, $ReservasTable, Reserva>),
    Reserva,
    PrefetchHooks Function()> {
  $$ReservasTableTableManager(_$MirameDb db, $ReservasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReservasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReservasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReservasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> codigo = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime> venceAt = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReservasCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            codigo: codigo,
            nombre: nombre,
            telefono: telefono,
            estado: estado,
            venceAt: venceAt,
            notas: notas,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String codigo,
            required String nombre,
            Value<String?> telefono = const Value.absent(),
            Value<String> estado = const Value.absent(),
            required DateTime venceAt,
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReservasCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            codigo: codigo,
            nombre: nombre,
            telefono: telefono,
            estado: estado,
            venceAt: venceAt,
            notas: notas,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReservasTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ReservasTable,
    Reserva,
    $$ReservasTableFilterComposer,
    $$ReservasTableOrderingComposer,
    $$ReservasTableAnnotationComposer,
    $$ReservasTableCreateCompanionBuilder,
    $$ReservasTableUpdateCompanionBuilder,
    (Reserva, BaseReferences<_$MirameDb, $ReservasTable, Reserva>),
    Reserva,
    PrefetchHooks Function()>;
typedef $$ReservaItemsTableCreateCompanionBuilder = ReservaItemsCompanion
    Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String reservaId,
  required String varianteId,
  Value<int> cantidad,
  Value<int> rowid,
});
typedef $$ReservaItemsTableUpdateCompanionBuilder = ReservaItemsCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> reservaId,
  Value<String> varianteId,
  Value<int> cantidad,
  Value<int> rowid,
});

class $$ReservaItemsTableFilterComposer
    extends Composer<_$MirameDb, $ReservaItemsTable> {
  $$ReservaItemsTableFilterComposer({
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

  ColumnFilters<String> get reservaId => $composableBuilder(
      column: $table.reservaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));
}

class $$ReservaItemsTableOrderingComposer
    extends Composer<_$MirameDb, $ReservaItemsTable> {
  $$ReservaItemsTableOrderingComposer({
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

  ColumnOrderings<String> get reservaId => $composableBuilder(
      column: $table.reservaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));
}

class $$ReservaItemsTableAnnotationComposer
    extends Composer<_$MirameDb, $ReservaItemsTable> {
  $$ReservaItemsTableAnnotationComposer({
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

  GeneratedColumn<String> get reservaId =>
      $composableBuilder(column: $table.reservaId, builder: (column) => column);

  GeneratedColumn<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);
}

class $$ReservaItemsTableTableManager extends RootTableManager<
    _$MirameDb,
    $ReservaItemsTable,
    ReservaItem,
    $$ReservaItemsTableFilterComposer,
    $$ReservaItemsTableOrderingComposer,
    $$ReservaItemsTableAnnotationComposer,
    $$ReservaItemsTableCreateCompanionBuilder,
    $$ReservaItemsTableUpdateCompanionBuilder,
    (ReservaItem, BaseReferences<_$MirameDb, $ReservaItemsTable, ReservaItem>),
    ReservaItem,
    PrefetchHooks Function()> {
  $$ReservaItemsTableTableManager(_$MirameDb db, $ReservaItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReservaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReservaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReservaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> reservaId = const Value.absent(),
            Value<String> varianteId = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReservaItemsCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            reservaId: reservaId,
            varianteId: varianteId,
            cantidad: cantidad,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String reservaId,
            required String varianteId,
            Value<int> cantidad = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReservaItemsCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            reservaId: reservaId,
            varianteId: varianteId,
            cantidad: cantidad,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReservaItemsTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $ReservaItemsTable,
    ReservaItem,
    $$ReservaItemsTableFilterComposer,
    $$ReservaItemsTableOrderingComposer,
    $$ReservaItemsTableAnnotationComposer,
    $$ReservaItemsTableCreateCompanionBuilder,
    $$ReservaItemsTableUpdateCompanionBuilder,
    (ReservaItem, BaseReferences<_$MirameDb, $ReservaItemsTable, ReservaItem>),
    ReservaItem,
    PrefetchHooks Function()>;
typedef $$LiquidacionesTableCreateCompanionBuilder = LiquidacionesCompanion
    Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String tipo,
  required String destinatarioId,
  required String periodoDesde,
  required String periodoHasta,
  Value<double> total,
  Value<String> estado,
  Value<DateTime?> pagadaAt,
  Value<String?> notas,
  Value<int> rowid,
});
typedef $$LiquidacionesTableUpdateCompanionBuilder = LiquidacionesCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> tipo,
  Value<String> destinatarioId,
  Value<String> periodoDesde,
  Value<String> periodoHasta,
  Value<double> total,
  Value<String> estado,
  Value<DateTime?> pagadaAt,
  Value<String?> notas,
  Value<int> rowid,
});

class $$LiquidacionesTableFilterComposer
    extends Composer<_$MirameDb, $LiquidacionesTable> {
  $$LiquidacionesTableFilterComposer({
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

  ColumnFilters<String> get destinatarioId => $composableBuilder(
      column: $table.destinatarioId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get periodoDesde => $composableBuilder(
      column: $table.periodoDesde, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get periodoHasta => $composableBuilder(
      column: $table.periodoHasta, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pagadaAt => $composableBuilder(
      column: $table.pagadaAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));
}

class $$LiquidacionesTableOrderingComposer
    extends Composer<_$MirameDb, $LiquidacionesTable> {
  $$LiquidacionesTableOrderingComposer({
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

  ColumnOrderings<String> get destinatarioId => $composableBuilder(
      column: $table.destinatarioId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get periodoDesde => $composableBuilder(
      column: $table.periodoDesde,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get periodoHasta => $composableBuilder(
      column: $table.periodoHasta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pagadaAt => $composableBuilder(
      column: $table.pagadaAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));
}

class $$LiquidacionesTableAnnotationComposer
    extends Composer<_$MirameDb, $LiquidacionesTable> {
  $$LiquidacionesTableAnnotationComposer({
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

  GeneratedColumn<String> get destinatarioId => $composableBuilder(
      column: $table.destinatarioId, builder: (column) => column);

  GeneratedColumn<String> get periodoDesde => $composableBuilder(
      column: $table.periodoDesde, builder: (column) => column);

  GeneratedColumn<String> get periodoHasta => $composableBuilder(
      column: $table.periodoHasta, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get pagadaAt =>
      $composableBuilder(column: $table.pagadaAt, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$LiquidacionesTableTableManager extends RootTableManager<
    _$MirameDb,
    $LiquidacionesTable,
    Liquidacione,
    $$LiquidacionesTableFilterComposer,
    $$LiquidacionesTableOrderingComposer,
    $$LiquidacionesTableAnnotationComposer,
    $$LiquidacionesTableCreateCompanionBuilder,
    $$LiquidacionesTableUpdateCompanionBuilder,
    (
      Liquidacione,
      BaseReferences<_$MirameDb, $LiquidacionesTable, Liquidacione>
    ),
    Liquidacione,
    PrefetchHooks Function()> {
  $$LiquidacionesTableTableManager(_$MirameDb db, $LiquidacionesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiquidacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiquidacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiquidacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String> destinatarioId = const Value.absent(),
            Value<String> periodoDesde = const Value.absent(),
            Value<String> periodoHasta = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime?> pagadaAt = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LiquidacionesCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            tipo: tipo,
            destinatarioId: destinatarioId,
            periodoDesde: periodoDesde,
            periodoHasta: periodoHasta,
            total: total,
            estado: estado,
            pagadaAt: pagadaAt,
            notas: notas,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String tipo,
            required String destinatarioId,
            required String periodoDesde,
            required String periodoHasta,
            Value<double> total = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime?> pagadaAt = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LiquidacionesCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            tipo: tipo,
            destinatarioId: destinatarioId,
            periodoDesde: periodoDesde,
            periodoHasta: periodoHasta,
            total: total,
            estado: estado,
            pagadaAt: pagadaAt,
            notas: notas,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LiquidacionesTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $LiquidacionesTable,
    Liquidacione,
    $$LiquidacionesTableFilterComposer,
    $$LiquidacionesTableOrderingComposer,
    $$LiquidacionesTableAnnotationComposer,
    $$LiquidacionesTableCreateCompanionBuilder,
    $$LiquidacionesTableUpdateCompanionBuilder,
    (
      Liquidacione,
      BaseReferences<_$MirameDb, $LiquidacionesTable, Liquidacione>
    ),
    Liquidacione,
    PrefetchHooks Function()>;
typedef $$MovimientosStockTableCreateCompanionBuilder
    = MovimientosStockCompanion Function({
  required String id,
  required String tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String varianteId,
  required String depositoId,
  required int delta,
  required String motivo,
  Value<String?> referenciaId,
  Value<String?> notas,
  Value<int> rowid,
});
typedef $$MovimientosStockTableUpdateCompanionBuilder
    = MovimientosStockCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> varianteId,
  Value<String> depositoId,
  Value<int> delta,
  Value<String> motivo,
  Value<String?> referenciaId,
  Value<String?> notas,
  Value<int> rowid,
});

class $$MovimientosStockTableFilterComposer
    extends Composer<_$MirameDb, $MovimientosStockTable> {
  $$MovimientosStockTableFilterComposer({
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

  ColumnFilters<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get delta => $composableBuilder(
      column: $table.delta, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motivo => $composableBuilder(
      column: $table.motivo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenciaId => $composableBuilder(
      column: $table.referenciaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnFilters(column));
}

class $$MovimientosStockTableOrderingComposer
    extends Composer<_$MirameDb, $MovimientosStockTable> {
  $$MovimientosStockTableOrderingComposer({
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

  ColumnOrderings<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get delta => $composableBuilder(
      column: $table.delta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motivo => $composableBuilder(
      column: $table.motivo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenciaId => $composableBuilder(
      column: $table.referenciaId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notas => $composableBuilder(
      column: $table.notas, builder: (column) => ColumnOrderings(column));
}

class $$MovimientosStockTableAnnotationComposer
    extends Composer<_$MirameDb, $MovimientosStockTable> {
  $$MovimientosStockTableAnnotationComposer({
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

  GeneratedColumn<String> get varianteId => $composableBuilder(
      column: $table.varianteId, builder: (column) => column);

  GeneratedColumn<String> get depositoId => $composableBuilder(
      column: $table.depositoId, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<String> get referenciaId => $composableBuilder(
      column: $table.referenciaId, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$MovimientosStockTableTableManager extends RootTableManager<
    _$MirameDb,
    $MovimientosStockTable,
    MovimientosStockData,
    $$MovimientosStockTableFilterComposer,
    $$MovimientosStockTableOrderingComposer,
    $$MovimientosStockTableAnnotationComposer,
    $$MovimientosStockTableCreateCompanionBuilder,
    $$MovimientosStockTableUpdateCompanionBuilder,
    (
      MovimientosStockData,
      BaseReferences<_$MirameDb, $MovimientosStockTable, MovimientosStockData>
    ),
    MovimientosStockData,
    PrefetchHooks Function()> {
  $$MovimientosStockTableTableManager(
      _$MirameDb db, $MovimientosStockTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosStockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosStockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> varianteId = const Value.absent(),
            Value<String> depositoId = const Value.absent(),
            Value<int> delta = const Value.absent(),
            Value<String> motivo = const Value.absent(),
            Value<String?> referenciaId = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MovimientosStockCompanion(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            varianteId: varianteId,
            depositoId: depositoId,
            delta: delta,
            motivo: motivo,
            referenciaId: referenciaId,
            notas: notas,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String varianteId,
            required String depositoId,
            required int delta,
            required String motivo,
            Value<String?> referenciaId = const Value.absent(),
            Value<String?> notas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MovimientosStockCompanion.insert(
            id: id,
            tenantId: tenantId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            varianteId: varianteId,
            depositoId: depositoId,
            delta: delta,
            motivo: motivo,
            referenciaId: referenciaId,
            notas: notas,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MovimientosStockTableProcessedTableManager = ProcessedTableManager<
    _$MirameDb,
    $MovimientosStockTable,
    MovimientosStockData,
    $$MovimientosStockTableFilterComposer,
    $$MovimientosStockTableOrderingComposer,
    $$MovimientosStockTableAnnotationComposer,
    $$MovimientosStockTableCreateCompanionBuilder,
    $$MovimientosStockTableUpdateCompanionBuilder,
    (
      MovimientosStockData,
      BaseReferences<_$MirameDb, $MovimientosStockTable, MovimientosStockData>
    ),
    MovimientosStockData,
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
  $$ProveedoresTableTableManager get proveedores =>
      $$ProveedoresTableTableManager(_db, _db.proveedores);
  $$DepositosTableTableManager get depositos =>
      $$DepositosTableTableManager(_db, _db.depositos);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$ProductoVariantesTableTableManager get productoVariantes =>
      $$ProductoVariantesTableTableManager(_db, _db.productoVariantes);
  $$StockVariantesTableTableManager get stockVariantes =>
      $$StockVariantesTableTableManager(_db, _db.stockVariantes);
  $$ProductoFotosTableTableManager get productoFotos =>
      $$ProductoFotosTableTableManager(_db, _db.productoFotos);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$VentaItemsTableTableManager get ventaItems =>
      $$VentaItemsTableTableManager(_db, _db.ventaItems);
  $$ReservasTableTableManager get reservas =>
      $$ReservasTableTableManager(_db, _db.reservas);
  $$ReservaItemsTableTableManager get reservaItems =>
      $$ReservaItemsTableTableManager(_db, _db.reservaItems);
  $$LiquidacionesTableTableManager get liquidaciones =>
      $$LiquidacionesTableTableManager(_db, _db.liquidaciones);
  $$MovimientosStockTableTableManager get movimientosStock =>
      $$MovimientosStockTableTableManager(_db, _db.movimientosStock);
}
