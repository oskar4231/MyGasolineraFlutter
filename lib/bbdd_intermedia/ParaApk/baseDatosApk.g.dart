// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baseDatosApk.dart';

// ignore_for_file: type=lint
class $GasolinerasTableTable extends GasolinerasTable
    with TableInfo<$GasolinerasTableTable, GasolinerasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GasolinerasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rotuloMeta = const VerificationMeta('rotulo');
  @override
  late final GeneratedColumn<String> rotulo = GeneratedColumn<String>(
      'rotulo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _provinciaMeta =
      const VerificationMeta('provincia');
  @override
  late final GeneratedColumn<String> provincia = GeneratedColumn<String>(
      'provincia', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idProvinciaMeta =
      const VerificationMeta('idProvincia');
  @override
  late final GeneratedColumn<String> idProvincia = GeneratedColumn<String>(
      'id_provincia', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _horarioMeta =
      const VerificationMeta('horario');
  @override
  late final GeneratedColumn<String> horario = GeneratedColumn<String>(
      'horario', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gasolina95Meta =
      const VerificationMeta('gasolina95');
  @override
  late final GeneratedColumn<double> gasolina95 = GeneratedColumn<double>(
      'gasolina95', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _gasolina95E10Meta =
      const VerificationMeta('gasolina95E10');
  @override
  late final GeneratedColumn<double> gasolina95E10 = GeneratedColumn<double>(
      'gasolina95_e10', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _gasolina98Meta =
      const VerificationMeta('gasolina98');
  @override
  late final GeneratedColumn<double> gasolina98 = GeneratedColumn<double>(
      'gasolina98', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _gasoleoAMeta =
      const VerificationMeta('gasoleoA');
  @override
  late final GeneratedColumn<double> gasoleoA = GeneratedColumn<double>(
      'gasoleo_a', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _gasoleoPremiumMeta =
      const VerificationMeta('gasoleoPremium');
  @override
  late final GeneratedColumn<double> gasoleoPremium = GeneratedColumn<double>(
      'gasoleo_premium', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _glpMeta = const VerificationMeta('glp');
  @override
  late final GeneratedColumn<double> glp = GeneratedColumn<double>(
      'glp', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _biodieselMeta =
      const VerificationMeta('biodiesel');
  @override
  late final GeneratedColumn<double> biodiesel = GeneratedColumn<double>(
      'biodiesel', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _bioetanolMeta =
      const VerificationMeta('bioetanol');
  @override
  late final GeneratedColumn<double> bioetanol = GeneratedColumn<double>(
      'bioetanol', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _esterMetilicoMeta =
      const VerificationMeta('esterMetilico');
  @override
  late final GeneratedColumn<double> esterMetilico = GeneratedColumn<double>(
      'ester_metilico', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _hidrogenoMeta =
      const VerificationMeta('hidrogeno');
  @override
  late final GeneratedColumn<double> hidrogeno = GeneratedColumn<double>(
      'hidrogeno', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        rotulo,
        direccion,
        lat,
        lng,
        provincia,
        idProvincia,
        horario,
        gasolina95,
        gasolina95E10,
        gasolina98,
        gasoleoA,
        gasoleoPremium,
        glp,
        biodiesel,
        bioetanol,
        esterMetilico,
        hidrogeno,
        lastUpdated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gasolineras_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<GasolinerasTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rotulo')) {
      context.handle(_rotuloMeta,
          rotulo.isAcceptableOrUnknown(data['rotulo']!, _rotuloMeta));
    } else if (isInserting) {
      context.missing(_rotuloMeta);
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    } else if (isInserting) {
      context.missing(_direccionMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('provincia')) {
      context.handle(_provinciaMeta,
          provincia.isAcceptableOrUnknown(data['provincia']!, _provinciaMeta));
    } else if (isInserting) {
      context.missing(_provinciaMeta);
    }
    if (data.containsKey('id_provincia')) {
      context.handle(
          _idProvinciaMeta,
          idProvincia.isAcceptableOrUnknown(
              data['id_provincia']!, _idProvinciaMeta));
    } else if (isInserting) {
      context.missing(_idProvinciaMeta);
    }
    if (data.containsKey('horario')) {
      context.handle(_horarioMeta,
          horario.isAcceptableOrUnknown(data['horario']!, _horarioMeta));
    } else if (isInserting) {
      context.missing(_horarioMeta);
    }
    if (data.containsKey('gasolina95')) {
      context.handle(
          _gasolina95Meta,
          gasolina95.isAcceptableOrUnknown(
              data['gasolina95']!, _gasolina95Meta));
    }
    if (data.containsKey('gasolina95_e10')) {
      context.handle(
          _gasolina95E10Meta,
          gasolina95E10.isAcceptableOrUnknown(
              data['gasolina95_e10']!, _gasolina95E10Meta));
    }
    if (data.containsKey('gasolina98')) {
      context.handle(
          _gasolina98Meta,
          gasolina98.isAcceptableOrUnknown(
              data['gasolina98']!, _gasolina98Meta));
    }
    if (data.containsKey('gasoleo_a')) {
      context.handle(_gasoleoAMeta,
          gasoleoA.isAcceptableOrUnknown(data['gasoleo_a']!, _gasoleoAMeta));
    }
    if (data.containsKey('gasoleo_premium')) {
      context.handle(
          _gasoleoPremiumMeta,
          gasoleoPremium.isAcceptableOrUnknown(
              data['gasoleo_premium']!, _gasoleoPremiumMeta));
    }
    if (data.containsKey('glp')) {
      context.handle(
          _glpMeta, glp.isAcceptableOrUnknown(data['glp']!, _glpMeta));
    }
    if (data.containsKey('biodiesel')) {
      context.handle(_biodieselMeta,
          biodiesel.isAcceptableOrUnknown(data['biodiesel']!, _biodieselMeta));
    }
    if (data.containsKey('bioetanol')) {
      context.handle(_bioetanolMeta,
          bioetanol.isAcceptableOrUnknown(data['bioetanol']!, _bioetanolMeta));
    }
    if (data.containsKey('ester_metilico')) {
      context.handle(
          _esterMetilicoMeta,
          esterMetilico.isAcceptableOrUnknown(
              data['ester_metilico']!, _esterMetilicoMeta));
    }
    if (data.containsKey('hidrogeno')) {
      context.handle(_hidrogenoMeta,
          hidrogeno.isAcceptableOrUnknown(data['hidrogeno']!, _hidrogenoMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GasolinerasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GasolinerasTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      rotulo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rotulo'])!,
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      provincia: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provincia'])!,
      idProvincia: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_provincia'])!,
      horario: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}horario'])!,
      gasolina95: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gasolina95'])!,
      gasolina95E10: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gasolina95_e10'])!,
      gasolina98: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gasolina98'])!,
      gasoleoA: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gasoleo_a'])!,
      gasoleoPremium: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}gasoleo_premium'])!,
      glp: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}glp'])!,
      biodiesel: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}biodiesel'])!,
      bioetanol: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bioetanol'])!,
      esterMetilico: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ester_metilico'])!,
      hidrogeno: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hidrogeno'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
    );
  }

  @override
  $GasolinerasTableTable createAlias(String alias) {
    return $GasolinerasTableTable(attachedDatabase, alias);
  }
}

class GasolinerasTableData extends DataClass
    implements Insertable<GasolinerasTableData> {
  final String id;
  final String rotulo;
  final String direccion;
  final double lat;
  final double lng;
  final String provincia;
  final String idProvincia;
  final String horario;
  final double gasolina95;
  final double gasolina95E10;
  final double gasolina98;
  final double gasoleoA;
  final double gasoleoPremium;
  final double glp;
  final double biodiesel;
  final double bioetanol;
  final double esterMetilico;
  final double hidrogeno;
  final DateTime lastUpdated;
  const GasolinerasTableData(
      {required this.id,
      required this.rotulo,
      required this.direccion,
      required this.lat,
      required this.lng,
      required this.provincia,
      required this.idProvincia,
      required this.horario,
      required this.gasolina95,
      required this.gasolina95E10,
      required this.gasolina98,
      required this.gasoleoA,
      required this.gasoleoPremium,
      required this.glp,
      required this.biodiesel,
      required this.bioetanol,
      required this.esterMetilico,
      required this.hidrogeno,
      required this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rotulo'] = Variable<String>(rotulo);
    map['direccion'] = Variable<String>(direccion);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['provincia'] = Variable<String>(provincia);
    map['id_provincia'] = Variable<String>(idProvincia);
    map['horario'] = Variable<String>(horario);
    map['gasolina95'] = Variable<double>(gasolina95);
    map['gasolina95_e10'] = Variable<double>(gasolina95E10);
    map['gasolina98'] = Variable<double>(gasolina98);
    map['gasoleo_a'] = Variable<double>(gasoleoA);
    map['gasoleo_premium'] = Variable<double>(gasoleoPremium);
    map['glp'] = Variable<double>(glp);
    map['biodiesel'] = Variable<double>(biodiesel);
    map['bioetanol'] = Variable<double>(bioetanol);
    map['ester_metilico'] = Variable<double>(esterMetilico);
    map['hidrogeno'] = Variable<double>(hidrogeno);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  GasolinerasTableCompanion toCompanion(bool nullToAbsent) {
    return GasolinerasTableCompanion(
      id: Value(id),
      rotulo: Value(rotulo),
      direccion: Value(direccion),
      lat: Value(lat),
      lng: Value(lng),
      provincia: Value(provincia),
      idProvincia: Value(idProvincia),
      horario: Value(horario),
      gasolina95: Value(gasolina95),
      gasolina95E10: Value(gasolina95E10),
      gasolina98: Value(gasolina98),
      gasoleoA: Value(gasoleoA),
      gasoleoPremium: Value(gasoleoPremium),
      glp: Value(glp),
      biodiesel: Value(biodiesel),
      bioetanol: Value(bioetanol),
      esterMetilico: Value(esterMetilico),
      hidrogeno: Value(hidrogeno),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory GasolinerasTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GasolinerasTableData(
      id: serializer.fromJson<String>(json['id']),
      rotulo: serializer.fromJson<String>(json['rotulo']),
      direccion: serializer.fromJson<String>(json['direccion']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      provincia: serializer.fromJson<String>(json['provincia']),
      idProvincia: serializer.fromJson<String>(json['idProvincia']),
      horario: serializer.fromJson<String>(json['horario']),
      gasolina95: serializer.fromJson<double>(json['gasolina95']),
      gasolina95E10: serializer.fromJson<double>(json['gasolina95E10']),
      gasolina98: serializer.fromJson<double>(json['gasolina98']),
      gasoleoA: serializer.fromJson<double>(json['gasoleoA']),
      gasoleoPremium: serializer.fromJson<double>(json['gasoleoPremium']),
      glp: serializer.fromJson<double>(json['glp']),
      biodiesel: serializer.fromJson<double>(json['biodiesel']),
      bioetanol: serializer.fromJson<double>(json['bioetanol']),
      esterMetilico: serializer.fromJson<double>(json['esterMetilico']),
      hidrogeno: serializer.fromJson<double>(json['hidrogeno']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rotulo': serializer.toJson<String>(rotulo),
      'direccion': serializer.toJson<String>(direccion),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'provincia': serializer.toJson<String>(provincia),
      'idProvincia': serializer.toJson<String>(idProvincia),
      'horario': serializer.toJson<String>(horario),
      'gasolina95': serializer.toJson<double>(gasolina95),
      'gasolina95E10': serializer.toJson<double>(gasolina95E10),
      'gasolina98': serializer.toJson<double>(gasolina98),
      'gasoleoA': serializer.toJson<double>(gasoleoA),
      'gasoleoPremium': serializer.toJson<double>(gasoleoPremium),
      'glp': serializer.toJson<double>(glp),
      'biodiesel': serializer.toJson<double>(biodiesel),
      'bioetanol': serializer.toJson<double>(bioetanol),
      'esterMetilico': serializer.toJson<double>(esterMetilico),
      'hidrogeno': serializer.toJson<double>(hidrogeno),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  GasolinerasTableData copyWith(
          {String? id,
          String? rotulo,
          String? direccion,
          double? lat,
          double? lng,
          String? provincia,
          String? idProvincia,
          String? horario,
          double? gasolina95,
          double? gasolina95E10,
          double? gasolina98,
          double? gasoleoA,
          double? gasoleoPremium,
          double? glp,
          double? biodiesel,
          double? bioetanol,
          double? esterMetilico,
          double? hidrogeno,
          DateTime? lastUpdated}) =>
      GasolinerasTableData(
        id: id ?? this.id,
        rotulo: rotulo ?? this.rotulo,
        direccion: direccion ?? this.direccion,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        provincia: provincia ?? this.provincia,
        idProvincia: idProvincia ?? this.idProvincia,
        horario: horario ?? this.horario,
        gasolina95: gasolina95 ?? this.gasolina95,
        gasolina95E10: gasolina95E10 ?? this.gasolina95E10,
        gasolina98: gasolina98 ?? this.gasolina98,
        gasoleoA: gasoleoA ?? this.gasoleoA,
        gasoleoPremium: gasoleoPremium ?? this.gasoleoPremium,
        glp: glp ?? this.glp,
        biodiesel: biodiesel ?? this.biodiesel,
        bioetanol: bioetanol ?? this.bioetanol,
        esterMetilico: esterMetilico ?? this.esterMetilico,
        hidrogeno: hidrogeno ?? this.hidrogeno,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
  GasolinerasTableData copyWithCompanion(GasolinerasTableCompanion data) {
    return GasolinerasTableData(
      id: data.id.present ? data.id.value : this.id,
      rotulo: data.rotulo.present ? data.rotulo.value : this.rotulo,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      provincia: data.provincia.present ? data.provincia.value : this.provincia,
      idProvincia:
          data.idProvincia.present ? data.idProvincia.value : this.idProvincia,
      horario: data.horario.present ? data.horario.value : this.horario,
      gasolina95:
          data.gasolina95.present ? data.gasolina95.value : this.gasolina95,
      gasolina95E10: data.gasolina95E10.present
          ? data.gasolina95E10.value
          : this.gasolina95E10,
      gasolina98:
          data.gasolina98.present ? data.gasolina98.value : this.gasolina98,
      gasoleoA: data.gasoleoA.present ? data.gasoleoA.value : this.gasoleoA,
      gasoleoPremium: data.gasoleoPremium.present
          ? data.gasoleoPremium.value
          : this.gasoleoPremium,
      glp: data.glp.present ? data.glp.value : this.glp,
      biodiesel: data.biodiesel.present ? data.biodiesel.value : this.biodiesel,
      bioetanol: data.bioetanol.present ? data.bioetanol.value : this.bioetanol,
      esterMetilico: data.esterMetilico.present
          ? data.esterMetilico.value
          : this.esterMetilico,
      hidrogeno: data.hidrogeno.present ? data.hidrogeno.value : this.hidrogeno,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GasolinerasTableData(')
          ..write('id: $id, ')
          ..write('rotulo: $rotulo, ')
          ..write('direccion: $direccion, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('provincia: $provincia, ')
          ..write('idProvincia: $idProvincia, ')
          ..write('horario: $horario, ')
          ..write('gasolina95: $gasolina95, ')
          ..write('gasolina95E10: $gasolina95E10, ')
          ..write('gasolina98: $gasolina98, ')
          ..write('gasoleoA: $gasoleoA, ')
          ..write('gasoleoPremium: $gasoleoPremium, ')
          ..write('glp: $glp, ')
          ..write('biodiesel: $biodiesel, ')
          ..write('bioetanol: $bioetanol, ')
          ..write('esterMetilico: $esterMetilico, ')
          ..write('hidrogeno: $hidrogeno, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      rotulo,
      direccion,
      lat,
      lng,
      provincia,
      idProvincia,
      horario,
      gasolina95,
      gasolina95E10,
      gasolina98,
      gasoleoA,
      gasoleoPremium,
      glp,
      biodiesel,
      bioetanol,
      esterMetilico,
      hidrogeno,
      lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GasolinerasTableData &&
          other.id == this.id &&
          other.rotulo == this.rotulo &&
          other.direccion == this.direccion &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.provincia == this.provincia &&
          other.idProvincia == this.idProvincia &&
          other.horario == this.horario &&
          other.gasolina95 == this.gasolina95 &&
          other.gasolina95E10 == this.gasolina95E10 &&
          other.gasolina98 == this.gasolina98 &&
          other.gasoleoA == this.gasoleoA &&
          other.gasoleoPremium == this.gasoleoPremium &&
          other.glp == this.glp &&
          other.biodiesel == this.biodiesel &&
          other.bioetanol == this.bioetanol &&
          other.esterMetilico == this.esterMetilico &&
          other.hidrogeno == this.hidrogeno &&
          other.lastUpdated == this.lastUpdated);
}

class GasolinerasTableCompanion extends UpdateCompanion<GasolinerasTableData> {
  final Value<String> id;
  final Value<String> rotulo;
  final Value<String> direccion;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> provincia;
  final Value<String> idProvincia;
  final Value<String> horario;
  final Value<double> gasolina95;
  final Value<double> gasolina95E10;
  final Value<double> gasolina98;
  final Value<double> gasoleoA;
  final Value<double> gasoleoPremium;
  final Value<double> glp;
  final Value<double> biodiesel;
  final Value<double> bioetanol;
  final Value<double> esterMetilico;
  final Value<double> hidrogeno;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const GasolinerasTableCompanion({
    this.id = const Value.absent(),
    this.rotulo = const Value.absent(),
    this.direccion = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.provincia = const Value.absent(),
    this.idProvincia = const Value.absent(),
    this.horario = const Value.absent(),
    this.gasolina95 = const Value.absent(),
    this.gasolina95E10 = const Value.absent(),
    this.gasolina98 = const Value.absent(),
    this.gasoleoA = const Value.absent(),
    this.gasoleoPremium = const Value.absent(),
    this.glp = const Value.absent(),
    this.biodiesel = const Value.absent(),
    this.bioetanol = const Value.absent(),
    this.esterMetilico = const Value.absent(),
    this.hidrogeno = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GasolinerasTableCompanion.insert({
    required String id,
    required String rotulo,
    required String direccion,
    required double lat,
    required double lng,
    required String provincia,
    required String idProvincia,
    required String horario,
    this.gasolina95 = const Value.absent(),
    this.gasolina95E10 = const Value.absent(),
    this.gasolina98 = const Value.absent(),
    this.gasoleoA = const Value.absent(),
    this.gasoleoPremium = const Value.absent(),
    this.glp = const Value.absent(),
    this.biodiesel = const Value.absent(),
    this.bioetanol = const Value.absent(),
    this.esterMetilico = const Value.absent(),
    this.hidrogeno = const Value.absent(),
    required DateTime lastUpdated,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rotulo = Value(rotulo),
        direccion = Value(direccion),
        lat = Value(lat),
        lng = Value(lng),
        provincia = Value(provincia),
        idProvincia = Value(idProvincia),
        horario = Value(horario),
        lastUpdated = Value(lastUpdated);
  static Insertable<GasolinerasTableData> custom({
    Expression<String>? id,
    Expression<String>? rotulo,
    Expression<String>? direccion,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? provincia,
    Expression<String>? idProvincia,
    Expression<String>? horario,
    Expression<double>? gasolina95,
    Expression<double>? gasolina95E10,
    Expression<double>? gasolina98,
    Expression<double>? gasoleoA,
    Expression<double>? gasoleoPremium,
    Expression<double>? glp,
    Expression<double>? biodiesel,
    Expression<double>? bioetanol,
    Expression<double>? esterMetilico,
    Expression<double>? hidrogeno,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rotulo != null) 'rotulo': rotulo,
      if (direccion != null) 'direccion': direccion,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (provincia != null) 'provincia': provincia,
      if (idProvincia != null) 'id_provincia': idProvincia,
      if (horario != null) 'horario': horario,
      if (gasolina95 != null) 'gasolina95': gasolina95,
      if (gasolina95E10 != null) 'gasolina95_e10': gasolina95E10,
      if (gasolina98 != null) 'gasolina98': gasolina98,
      if (gasoleoA != null) 'gasoleo_a': gasoleoA,
      if (gasoleoPremium != null) 'gasoleo_premium': gasoleoPremium,
      if (glp != null) 'glp': glp,
      if (biodiesel != null) 'biodiesel': biodiesel,
      if (bioetanol != null) 'bioetanol': bioetanol,
      if (esterMetilico != null) 'ester_metilico': esterMetilico,
      if (hidrogeno != null) 'hidrogeno': hidrogeno,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GasolinerasTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? rotulo,
      Value<String>? direccion,
      Value<double>? lat,
      Value<double>? lng,
      Value<String>? provincia,
      Value<String>? idProvincia,
      Value<String>? horario,
      Value<double>? gasolina95,
      Value<double>? gasolina95E10,
      Value<double>? gasolina98,
      Value<double>? gasoleoA,
      Value<double>? gasoleoPremium,
      Value<double>? glp,
      Value<double>? biodiesel,
      Value<double>? bioetanol,
      Value<double>? esterMetilico,
      Value<double>? hidrogeno,
      Value<DateTime>? lastUpdated,
      Value<int>? rowid}) {
    return GasolinerasTableCompanion(
      id: id ?? this.id,
      rotulo: rotulo ?? this.rotulo,
      direccion: direccion ?? this.direccion,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      provincia: provincia ?? this.provincia,
      idProvincia: idProvincia ?? this.idProvincia,
      horario: horario ?? this.horario,
      gasolina95: gasolina95 ?? this.gasolina95,
      gasolina95E10: gasolina95E10 ?? this.gasolina95E10,
      gasolina98: gasolina98 ?? this.gasolina98,
      gasoleoA: gasoleoA ?? this.gasoleoA,
      gasoleoPremium: gasoleoPremium ?? this.gasoleoPremium,
      glp: glp ?? this.glp,
      biodiesel: biodiesel ?? this.biodiesel,
      bioetanol: bioetanol ?? this.bioetanol,
      esterMetilico: esterMetilico ?? this.esterMetilico,
      hidrogeno: hidrogeno ?? this.hidrogeno,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rotulo.present) {
      map['rotulo'] = Variable<String>(rotulo.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (provincia.present) {
      map['provincia'] = Variable<String>(provincia.value);
    }
    if (idProvincia.present) {
      map['id_provincia'] = Variable<String>(idProvincia.value);
    }
    if (horario.present) {
      map['horario'] = Variable<String>(horario.value);
    }
    if (gasolina95.present) {
      map['gasolina95'] = Variable<double>(gasolina95.value);
    }
    if (gasolina95E10.present) {
      map['gasolina95_e10'] = Variable<double>(gasolina95E10.value);
    }
    if (gasolina98.present) {
      map['gasolina98'] = Variable<double>(gasolina98.value);
    }
    if (gasoleoA.present) {
      map['gasoleo_a'] = Variable<double>(gasoleoA.value);
    }
    if (gasoleoPremium.present) {
      map['gasoleo_premium'] = Variable<double>(gasoleoPremium.value);
    }
    if (glp.present) {
      map['glp'] = Variable<double>(glp.value);
    }
    if (biodiesel.present) {
      map['biodiesel'] = Variable<double>(biodiesel.value);
    }
    if (bioetanol.present) {
      map['bioetanol'] = Variable<double>(bioetanol.value);
    }
    if (esterMetilico.present) {
      map['ester_metilico'] = Variable<double>(esterMetilico.value);
    }
    if (hidrogeno.present) {
      map['hidrogeno'] = Variable<double>(hidrogeno.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GasolinerasTableCompanion(')
          ..write('id: $id, ')
          ..write('rotulo: $rotulo, ')
          ..write('direccion: $direccion, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('provincia: $provincia, ')
          ..write('idProvincia: $idProvincia, ')
          ..write('horario: $horario, ')
          ..write('gasolina95: $gasolina95, ')
          ..write('gasolina95E10: $gasolina95E10, ')
          ..write('gasolina98: $gasolina98, ')
          ..write('gasoleoA: $gasoleoA, ')
          ..write('gasoleoPremium: $gasoleoPremium, ')
          ..write('glp: $glp, ')
          ..write('biodiesel: $biodiesel, ')
          ..write('bioetanol: $bioetanol, ')
          ..write('esterMetilico: $esterMetilico, ')
          ..write('hidrogeno: $hidrogeno, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProvinciaCacheTableTable extends ProvinciaCacheTable
    with TableInfo<$ProvinciaCacheTableTable, ProvinciaCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvinciaCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _provinciaIdMeta =
      const VerificationMeta('provinciaId');
  @override
  late final GeneratedColumn<String> provinciaId = GeneratedColumn<String>(
      'provincia_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _provinciaNombreMeta =
      const VerificationMeta('provinciaNombre');
  @override
  late final GeneratedColumn<String> provinciaNombre = GeneratedColumn<String>(
      'provincia_nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _recordCountMeta =
      const VerificationMeta('recordCount');
  @override
  late final GeneratedColumn<int> recordCount = GeneratedColumn<int>(
      'record_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [provinciaId, provinciaNombre, lastUpdated, recordCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provincia_cache_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProvinciaCacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provincia_id')) {
      context.handle(
          _provinciaIdMeta,
          provinciaId.isAcceptableOrUnknown(
              data['provincia_id']!, _provinciaIdMeta));
    } else if (isInserting) {
      context.missing(_provinciaIdMeta);
    }
    if (data.containsKey('provincia_nombre')) {
      context.handle(
          _provinciaNombreMeta,
          provinciaNombre.isAcceptableOrUnknown(
              data['provincia_nombre']!, _provinciaNombreMeta));
    } else if (isInserting) {
      context.missing(_provinciaNombreMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('record_count')) {
      context.handle(
          _recordCountMeta,
          recordCount.isAcceptableOrUnknown(
              data['record_count']!, _recordCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {provinciaId};
  @override
  ProvinciaCacheTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProvinciaCacheTableData(
      provinciaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provincia_id'])!,
      provinciaNombre: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}provincia_nombre'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      recordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}record_count'])!,
    );
  }

  @override
  $ProvinciaCacheTableTable createAlias(String alias) {
    return $ProvinciaCacheTableTable(attachedDatabase, alias);
  }
}

class ProvinciaCacheTableData extends DataClass
    implements Insertable<ProvinciaCacheTableData> {
  final String provinciaId;
  final String provinciaNombre;
  final DateTime lastUpdated;
  final int recordCount;
  const ProvinciaCacheTableData(
      {required this.provinciaId,
      required this.provinciaNombre,
      required this.lastUpdated,
      required this.recordCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provincia_id'] = Variable<String>(provinciaId);
    map['provincia_nombre'] = Variable<String>(provinciaNombre);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['record_count'] = Variable<int>(recordCount);
    return map;
  }

  ProvinciaCacheTableCompanion toCompanion(bool nullToAbsent) {
    return ProvinciaCacheTableCompanion(
      provinciaId: Value(provinciaId),
      provinciaNombre: Value(provinciaNombre),
      lastUpdated: Value(lastUpdated),
      recordCount: Value(recordCount),
    );
  }

  factory ProvinciaCacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProvinciaCacheTableData(
      provinciaId: serializer.fromJson<String>(json['provinciaId']),
      provinciaNombre: serializer.fromJson<String>(json['provinciaNombre']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      recordCount: serializer.fromJson<int>(json['recordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'provinciaId': serializer.toJson<String>(provinciaId),
      'provinciaNombre': serializer.toJson<String>(provinciaNombre),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'recordCount': serializer.toJson<int>(recordCount),
    };
  }

  ProvinciaCacheTableData copyWith(
          {String? provinciaId,
          String? provinciaNombre,
          DateTime? lastUpdated,
          int? recordCount}) =>
      ProvinciaCacheTableData(
        provinciaId: provinciaId ?? this.provinciaId,
        provinciaNombre: provinciaNombre ?? this.provinciaNombre,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        recordCount: recordCount ?? this.recordCount,
      );
  ProvinciaCacheTableData copyWithCompanion(ProvinciaCacheTableCompanion data) {
    return ProvinciaCacheTableData(
      provinciaId:
          data.provinciaId.present ? data.provinciaId.value : this.provinciaId,
      provinciaNombre: data.provinciaNombre.present
          ? data.provinciaNombre.value
          : this.provinciaNombre,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      recordCount:
          data.recordCount.present ? data.recordCount.value : this.recordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProvinciaCacheTableData(')
          ..write('provinciaId: $provinciaId, ')
          ..write('provinciaNombre: $provinciaNombre, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('recordCount: $recordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(provinciaId, provinciaNombre, lastUpdated, recordCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProvinciaCacheTableData &&
          other.provinciaId == this.provinciaId &&
          other.provinciaNombre == this.provinciaNombre &&
          other.lastUpdated == this.lastUpdated &&
          other.recordCount == this.recordCount);
}

class ProvinciaCacheTableCompanion
    extends UpdateCompanion<ProvinciaCacheTableData> {
  final Value<String> provinciaId;
  final Value<String> provinciaNombre;
  final Value<DateTime> lastUpdated;
  final Value<int> recordCount;
  final Value<int> rowid;
  const ProvinciaCacheTableCompanion({
    this.provinciaId = const Value.absent(),
    this.provinciaNombre = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvinciaCacheTableCompanion.insert({
    required String provinciaId,
    required String provinciaNombre,
    required DateTime lastUpdated,
    this.recordCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : provinciaId = Value(provinciaId),
        provinciaNombre = Value(provinciaNombre),
        lastUpdated = Value(lastUpdated);
  static Insertable<ProvinciaCacheTableData> custom({
    Expression<String>? provinciaId,
    Expression<String>? provinciaNombre,
    Expression<DateTime>? lastUpdated,
    Expression<int>? recordCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (provinciaId != null) 'provincia_id': provinciaId,
      if (provinciaNombre != null) 'provincia_nombre': provinciaNombre,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (recordCount != null) 'record_count': recordCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvinciaCacheTableCompanion copyWith(
      {Value<String>? provinciaId,
      Value<String>? provinciaNombre,
      Value<DateTime>? lastUpdated,
      Value<int>? recordCount,
      Value<int>? rowid}) {
    return ProvinciaCacheTableCompanion(
      provinciaId: provinciaId ?? this.provinciaId,
      provinciaNombre: provinciaNombre ?? this.provinciaNombre,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      recordCount: recordCount ?? this.recordCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (provinciaId.present) {
      map['provincia_id'] = Variable<String>(provinciaId.value);
    }
    if (provinciaNombre.present) {
      map['provincia_nombre'] = Variable<String>(provinciaNombre.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (recordCount.present) {
      map['record_count'] = Variable<int>(recordCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvinciaCacheTableCompanion(')
          ..write('provinciaId: $provinciaId, ')
          ..write('provinciaNombre: $provinciaNombre, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('recordCount: $recordCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThemeTableTable extends ThemeTable
    with TableInfo<$ThemeTableTable, ThemeTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemeTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _themeIdMeta =
      const VerificationMeta('themeId');
  @override
  late final GeneratedColumn<int> themeId = GeneratedColumn<int>(
      'theme_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, themeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'theme_table';
  @override
  VerificationContext validateIntegrity(Insertable<ThemeTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_id')) {
      context.handle(_themeIdMeta,
          themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThemeTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      themeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}theme_id'])!,
    );
  }

  @override
  $ThemeTableTable createAlias(String alias) {
    return $ThemeTableTable(attachedDatabase, alias);
  }
}

class ThemeTableData extends DataClass implements Insertable<ThemeTableData> {
  final int id;
  final int themeId;
  const ThemeTableData({required this.id, required this.themeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_id'] = Variable<int>(themeId);
    return map;
  }

  ThemeTableCompanion toCompanion(bool nullToAbsent) {
    return ThemeTableCompanion(
      id: Value(id),
      themeId: Value(themeId),
    );
  }

  factory ThemeTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeTableData(
      id: serializer.fromJson<int>(json['id']),
      themeId: serializer.fromJson<int>(json['themeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeId': serializer.toJson<int>(themeId),
    };
  }

  ThemeTableData copyWith({int? id, int? themeId}) => ThemeTableData(
        id: id ?? this.id,
        themeId: themeId ?? this.themeId,
      );
  ThemeTableData copyWithCompanion(ThemeTableCompanion data) {
    return ThemeTableData(
      id: data.id.present ? data.id.value : this.id,
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeTableData(')
          ..write('id: $id, ')
          ..write('themeId: $themeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, themeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeTableData &&
          other.id == this.id &&
          other.themeId == this.themeId);
}

class ThemeTableCompanion extends UpdateCompanion<ThemeTableData> {
  final Value<int> id;
  final Value<int> themeId;
  const ThemeTableCompanion({
    this.id = const Value.absent(),
    this.themeId = const Value.absent(),
  });
  ThemeTableCompanion.insert({
    this.id = const Value.absent(),
    this.themeId = const Value.absent(),
  });
  static Insertable<ThemeTableData> custom({
    Expression<int>? id,
    Expression<int>? themeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeId != null) 'theme_id': themeId,
    });
  }

  ThemeTableCompanion copyWith({Value<int>? id, Value<int>? themeId}) {
    return ThemeTableCompanion(
      id: id ?? this.id,
      themeId: themeId ?? this.themeId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeId.present) {
      map['theme_id'] = Variable<int>(themeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemeTableCompanion(')
          ..write('id: $id, ')
          ..write('themeId: $themeId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GasolinerasTableTable gasolinerasTable =
      $GasolinerasTableTable(this);
  late final $ProvinciaCacheTableTable provinciaCacheTable =
      $ProvinciaCacheTableTable(this);
  late final $ThemeTableTable themeTable = $ThemeTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [gasolinerasTable, provinciaCacheTable, themeTable];
}

typedef $$GasolinerasTableTableCreateCompanionBuilder
    = GasolinerasTableCompanion Function({
  required String id,
  required String rotulo,
  required String direccion,
  required double lat,
  required double lng,
  required String provincia,
  required String idProvincia,
  required String horario,
  Value<double> gasolina95,
  Value<double> gasolina95E10,
  Value<double> gasolina98,
  Value<double> gasoleoA,
  Value<double> gasoleoPremium,
  Value<double> glp,
  Value<double> biodiesel,
  Value<double> bioetanol,
  Value<double> esterMetilico,
  Value<double> hidrogeno,
  required DateTime lastUpdated,
  Value<int> rowid,
});
typedef $$GasolinerasTableTableUpdateCompanionBuilder
    = GasolinerasTableCompanion Function({
  Value<String> id,
  Value<String> rotulo,
  Value<String> direccion,
  Value<double> lat,
  Value<double> lng,
  Value<String> provincia,
  Value<String> idProvincia,
  Value<String> horario,
  Value<double> gasolina95,
  Value<double> gasolina95E10,
  Value<double> gasolina98,
  Value<double> gasoleoA,
  Value<double> gasoleoPremium,
  Value<double> glp,
  Value<double> biodiesel,
  Value<double> bioetanol,
  Value<double> esterMetilico,
  Value<double> hidrogeno,
  Value<DateTime> lastUpdated,
  Value<int> rowid,
});

class $$GasolinerasTableTableFilterComposer
    extends Composer<_$AppDatabase, $GasolinerasTableTable> {
  $$GasolinerasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rotulo => $composableBuilder(
      column: $table.rotulo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provincia => $composableBuilder(
      column: $table.provincia, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idProvincia => $composableBuilder(
      column: $table.idProvincia, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horario => $composableBuilder(
      column: $table.horario, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gasolina95 => $composableBuilder(
      column: $table.gasolina95, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gasolina95E10 => $composableBuilder(
      column: $table.gasolina95E10, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gasolina98 => $composableBuilder(
      column: $table.gasolina98, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gasoleoA => $composableBuilder(
      column: $table.gasoleoA, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gasoleoPremium => $composableBuilder(
      column: $table.gasoleoPremium,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get glp => $composableBuilder(
      column: $table.glp, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get biodiesel => $composableBuilder(
      column: $table.biodiesel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bioetanol => $composableBuilder(
      column: $table.bioetanol, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get esterMetilico => $composableBuilder(
      column: $table.esterMetilico, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hidrogeno => $composableBuilder(
      column: $table.hidrogeno, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$GasolinerasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GasolinerasTableTable> {
  $$GasolinerasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rotulo => $composableBuilder(
      column: $table.rotulo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provincia => $composableBuilder(
      column: $table.provincia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idProvincia => $composableBuilder(
      column: $table.idProvincia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horario => $composableBuilder(
      column: $table.horario, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gasolina95 => $composableBuilder(
      column: $table.gasolina95, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gasolina95E10 => $composableBuilder(
      column: $table.gasolina95E10,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gasolina98 => $composableBuilder(
      column: $table.gasolina98, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gasoleoA => $composableBuilder(
      column: $table.gasoleoA, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gasoleoPremium => $composableBuilder(
      column: $table.gasoleoPremium,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get glp => $composableBuilder(
      column: $table.glp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get biodiesel => $composableBuilder(
      column: $table.biodiesel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bioetanol => $composableBuilder(
      column: $table.bioetanol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get esterMetilico => $composableBuilder(
      column: $table.esterMetilico,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hidrogeno => $composableBuilder(
      column: $table.hidrogeno, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$GasolinerasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GasolinerasTableTable> {
  $$GasolinerasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rotulo =>
      $composableBuilder(column: $table.rotulo, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get provincia =>
      $composableBuilder(column: $table.provincia, builder: (column) => column);

  GeneratedColumn<String> get idProvincia => $composableBuilder(
      column: $table.idProvincia, builder: (column) => column);

  GeneratedColumn<String> get horario =>
      $composableBuilder(column: $table.horario, builder: (column) => column);

  GeneratedColumn<double> get gasolina95 => $composableBuilder(
      column: $table.gasolina95, builder: (column) => column);

  GeneratedColumn<double> get gasolina95E10 => $composableBuilder(
      column: $table.gasolina95E10, builder: (column) => column);

  GeneratedColumn<double> get gasolina98 => $composableBuilder(
      column: $table.gasolina98, builder: (column) => column);

  GeneratedColumn<double> get gasoleoA =>
      $composableBuilder(column: $table.gasoleoA, builder: (column) => column);

  GeneratedColumn<double> get gasoleoPremium => $composableBuilder(
      column: $table.gasoleoPremium, builder: (column) => column);

  GeneratedColumn<double> get glp =>
      $composableBuilder(column: $table.glp, builder: (column) => column);

  GeneratedColumn<double> get biodiesel =>
      $composableBuilder(column: $table.biodiesel, builder: (column) => column);

  GeneratedColumn<double> get bioetanol =>
      $composableBuilder(column: $table.bioetanol, builder: (column) => column);

  GeneratedColumn<double> get esterMetilico => $composableBuilder(
      column: $table.esterMetilico, builder: (column) => column);

  GeneratedColumn<double> get hidrogeno =>
      $composableBuilder(column: $table.hidrogeno, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);
}

class $$GasolinerasTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GasolinerasTableTable,
    GasolinerasTableData,
    $$GasolinerasTableTableFilterComposer,
    $$GasolinerasTableTableOrderingComposer,
    $$GasolinerasTableTableAnnotationComposer,
    $$GasolinerasTableTableCreateCompanionBuilder,
    $$GasolinerasTableTableUpdateCompanionBuilder,
    (
      GasolinerasTableData,
      BaseReferences<_$AppDatabase, $GasolinerasTableTable,
          GasolinerasTableData>
    ),
    GasolinerasTableData,
    PrefetchHooks Function()> {
  $$GasolinerasTableTableTableManager(
      _$AppDatabase db, $GasolinerasTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GasolinerasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GasolinerasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GasolinerasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> rotulo = const Value.absent(),
            Value<String> direccion = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<String> provincia = const Value.absent(),
            Value<String> idProvincia = const Value.absent(),
            Value<String> horario = const Value.absent(),
            Value<double> gasolina95 = const Value.absent(),
            Value<double> gasolina95E10 = const Value.absent(),
            Value<double> gasolina98 = const Value.absent(),
            Value<double> gasoleoA = const Value.absent(),
            Value<double> gasoleoPremium = const Value.absent(),
            Value<double> glp = const Value.absent(),
            Value<double> biodiesel = const Value.absent(),
            Value<double> bioetanol = const Value.absent(),
            Value<double> esterMetilico = const Value.absent(),
            Value<double> hidrogeno = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GasolinerasTableCompanion(
            id: id,
            rotulo: rotulo,
            direccion: direccion,
            lat: lat,
            lng: lng,
            provincia: provincia,
            idProvincia: idProvincia,
            horario: horario,
            gasolina95: gasolina95,
            gasolina95E10: gasolina95E10,
            gasolina98: gasolina98,
            gasoleoA: gasoleoA,
            gasoleoPremium: gasoleoPremium,
            glp: glp,
            biodiesel: biodiesel,
            bioetanol: bioetanol,
            esterMetilico: esterMetilico,
            hidrogeno: hidrogeno,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String rotulo,
            required String direccion,
            required double lat,
            required double lng,
            required String provincia,
            required String idProvincia,
            required String horario,
            Value<double> gasolina95 = const Value.absent(),
            Value<double> gasolina95E10 = const Value.absent(),
            Value<double> gasolina98 = const Value.absent(),
            Value<double> gasoleoA = const Value.absent(),
            Value<double> gasoleoPremium = const Value.absent(),
            Value<double> glp = const Value.absent(),
            Value<double> biodiesel = const Value.absent(),
            Value<double> bioetanol = const Value.absent(),
            Value<double> esterMetilico = const Value.absent(),
            Value<double> hidrogeno = const Value.absent(),
            required DateTime lastUpdated,
            Value<int> rowid = const Value.absent(),
          }) =>
              GasolinerasTableCompanion.insert(
            id: id,
            rotulo: rotulo,
            direccion: direccion,
            lat: lat,
            lng: lng,
            provincia: provincia,
            idProvincia: idProvincia,
            horario: horario,
            gasolina95: gasolina95,
            gasolina95E10: gasolina95E10,
            gasolina98: gasolina98,
            gasoleoA: gasoleoA,
            gasoleoPremium: gasoleoPremium,
            glp: glp,
            biodiesel: biodiesel,
            bioetanol: bioetanol,
            esterMetilico: esterMetilico,
            hidrogeno: hidrogeno,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GasolinerasTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GasolinerasTableTable,
    GasolinerasTableData,
    $$GasolinerasTableTableFilterComposer,
    $$GasolinerasTableTableOrderingComposer,
    $$GasolinerasTableTableAnnotationComposer,
    $$GasolinerasTableTableCreateCompanionBuilder,
    $$GasolinerasTableTableUpdateCompanionBuilder,
    (
      GasolinerasTableData,
      BaseReferences<_$AppDatabase, $GasolinerasTableTable,
          GasolinerasTableData>
    ),
    GasolinerasTableData,
    PrefetchHooks Function()>;
typedef $$ProvinciaCacheTableTableCreateCompanionBuilder
    = ProvinciaCacheTableCompanion Function({
  required String provinciaId,
  required String provinciaNombre,
  required DateTime lastUpdated,
  Value<int> recordCount,
  Value<int> rowid,
});
typedef $$ProvinciaCacheTableTableUpdateCompanionBuilder
    = ProvinciaCacheTableCompanion Function({
  Value<String> provinciaId,
  Value<String> provinciaNombre,
  Value<DateTime> lastUpdated,
  Value<int> recordCount,
  Value<int> rowid,
});

class $$ProvinciaCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProvinciaCacheTableTable> {
  $$ProvinciaCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provinciaId => $composableBuilder(
      column: $table.provinciaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provinciaNombre => $composableBuilder(
      column: $table.provinciaNombre,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => ColumnFilters(column));
}

class $$ProvinciaCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProvinciaCacheTableTable> {
  $$ProvinciaCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provinciaId => $composableBuilder(
      column: $table.provinciaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provinciaNombre => $composableBuilder(
      column: $table.provinciaNombre,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => ColumnOrderings(column));
}

class $$ProvinciaCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProvinciaCacheTableTable> {
  $$ProvinciaCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provinciaId => $composableBuilder(
      column: $table.provinciaId, builder: (column) => column);

  GeneratedColumn<String> get provinciaNombre => $composableBuilder(
      column: $table.provinciaNombre, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => column);
}

class $$ProvinciaCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProvinciaCacheTableTable,
    ProvinciaCacheTableData,
    $$ProvinciaCacheTableTableFilterComposer,
    $$ProvinciaCacheTableTableOrderingComposer,
    $$ProvinciaCacheTableTableAnnotationComposer,
    $$ProvinciaCacheTableTableCreateCompanionBuilder,
    $$ProvinciaCacheTableTableUpdateCompanionBuilder,
    (
      ProvinciaCacheTableData,
      BaseReferences<_$AppDatabase, $ProvinciaCacheTableTable,
          ProvinciaCacheTableData>
    ),
    ProvinciaCacheTableData,
    PrefetchHooks Function()> {
  $$ProvinciaCacheTableTableTableManager(
      _$AppDatabase db, $ProvinciaCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvinciaCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvinciaCacheTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvinciaCacheTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> provinciaId = const Value.absent(),
            Value<String> provinciaNombre = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<int> recordCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProvinciaCacheTableCompanion(
            provinciaId: provinciaId,
            provinciaNombre: provinciaNombre,
            lastUpdated: lastUpdated,
            recordCount: recordCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String provinciaId,
            required String provinciaNombre,
            required DateTime lastUpdated,
            Value<int> recordCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProvinciaCacheTableCompanion.insert(
            provinciaId: provinciaId,
            provinciaNombre: provinciaNombre,
            lastUpdated: lastUpdated,
            recordCount: recordCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProvinciaCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProvinciaCacheTableTable,
    ProvinciaCacheTableData,
    $$ProvinciaCacheTableTableFilterComposer,
    $$ProvinciaCacheTableTableOrderingComposer,
    $$ProvinciaCacheTableTableAnnotationComposer,
    $$ProvinciaCacheTableTableCreateCompanionBuilder,
    $$ProvinciaCacheTableTableUpdateCompanionBuilder,
    (
      ProvinciaCacheTableData,
      BaseReferences<_$AppDatabase, $ProvinciaCacheTableTable,
          ProvinciaCacheTableData>
    ),
    ProvinciaCacheTableData,
    PrefetchHooks Function()>;
typedef $$ThemeTableTableCreateCompanionBuilder = ThemeTableCompanion Function({
  Value<int> id,
  Value<int> themeId,
});
typedef $$ThemeTableTableUpdateCompanionBuilder = ThemeTableCompanion Function({
  Value<int> id,
  Value<int> themeId,
});

class $$ThemeTableTableFilterComposer
    extends Composer<_$AppDatabase, $ThemeTableTable> {
  $$ThemeTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get themeId => $composableBuilder(
      column: $table.themeId, builder: (column) => ColumnFilters(column));
}

class $$ThemeTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ThemeTableTable> {
  $$ThemeTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get themeId => $composableBuilder(
      column: $table.themeId, builder: (column) => ColumnOrderings(column));
}

class $$ThemeTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThemeTableTable> {
  $$ThemeTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get themeId =>
      $composableBuilder(column: $table.themeId, builder: (column) => column);
}

class $$ThemeTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ThemeTableTable,
    ThemeTableData,
    $$ThemeTableTableFilterComposer,
    $$ThemeTableTableOrderingComposer,
    $$ThemeTableTableAnnotationComposer,
    $$ThemeTableTableCreateCompanionBuilder,
    $$ThemeTableTableUpdateCompanionBuilder,
    (
      ThemeTableData,
      BaseReferences<_$AppDatabase, $ThemeTableTable, ThemeTableData>
    ),
    ThemeTableData,
    PrefetchHooks Function()> {
  $$ThemeTableTableTableManager(_$AppDatabase db, $ThemeTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemeTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemeTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemeTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> themeId = const Value.absent(),
          }) =>
              ThemeTableCompanion(
            id: id,
            themeId: themeId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> themeId = const Value.absent(),
          }) =>
              ThemeTableCompanion.insert(
            id: id,
            themeId: themeId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ThemeTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ThemeTableTable,
    ThemeTableData,
    $$ThemeTableTableFilterComposer,
    $$ThemeTableTableOrderingComposer,
    $$ThemeTableTableAnnotationComposer,
    $$ThemeTableTableCreateCompanionBuilder,
    $$ThemeTableTableUpdateCompanionBuilder,
    (
      ThemeTableData,
      BaseReferences<_$AppDatabase, $ThemeTableTable, ThemeTableData>
    ),
    ThemeTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GasolinerasTableTableTableManager get gasolinerasTable =>
      $$GasolinerasTableTableTableManager(_db, _db.gasolinerasTable);
  $$ProvinciaCacheTableTableTableManager get provinciaCacheTable =>
      $$ProvinciaCacheTableTableTableManager(_db, _db.provinciaCacheTable);
  $$ThemeTableTableTableManager get themeTable =>
      $$ThemeTableTableTableManager(_db, _db.themeTable);
}
