// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasolinera_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGasolineraLocalCollection on Isar {
  IsarCollection<GasolineraLocal> get gasolineraLocals => this.collection();
}

const GasolineraLocalSchema = CollectionSchema(
  name: r'GasolineraLocal',
  id: -7497215940300846322,
  properties: {
    r'biodiesel': PropertySchema(
      id: 0,
      name: r'biodiesel',
      type: IsarType.double,
    ),
    r'bioetanol': PropertySchema(
      id: 1,
      name: r'bioetanol',
      type: IsarType.double,
    ),
    r'direccion': PropertySchema(
      id: 2,
      name: r'direccion',
      type: IsarType.string,
    ),
    r'esterMetilico': PropertySchema(
      id: 3,
      name: r'esterMetilico',
      type: IsarType.double,
    ),
    r'gasoleoA': PropertySchema(
      id: 4,
      name: r'gasoleoA',
      type: IsarType.double,
    ),
    r'gasoleoPremium': PropertySchema(
      id: 5,
      name: r'gasoleoPremium',
      type: IsarType.double,
    ),
    r'gasolina95': PropertySchema(
      id: 6,
      name: r'gasolina95',
      type: IsarType.double,
    ),
    r'gasolina95E10': PropertySchema(
      id: 7,
      name: r'gasolina95E10',
      type: IsarType.double,
    ),
    r'gasolina98': PropertySchema(
      id: 8,
      name: r'gasolina98',
      type: IsarType.double,
    ),
    r'glp': PropertySchema(
      id: 9,
      name: r'glp',
      type: IsarType.double,
    ),
    r'hidrogeno': PropertySchema(
      id: 10,
      name: r'hidrogeno',
      type: IsarType.double,
    ),
    r'horario': PropertySchema(
      id: 11,
      name: r'horario',
      type: IsarType.string,
    ),
    r'idProvincia': PropertySchema(
      id: 12,
      name: r'idProvincia',
      type: IsarType.string,
    ),
    r'lat': PropertySchema(
      id: 13,
      name: r'lat',
      type: IsarType.double,
    ),
    r'lng': PropertySchema(
      id: 14,
      name: r'lng',
      type: IsarType.double,
    ),
    r'provincia': PropertySchema(
      id: 15,
      name: r'provincia',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 16,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'rotulo': PropertySchema(
      id: 17,
      name: r'rotulo',
      type: IsarType.string,
    )
  },
  estimateSize: _gasolineraLocalEstimateSize,
  serialize: _gasolineraLocalSerialize,
  deserialize: _gasolineraLocalDeserialize,
  deserializeProp: _gasolineraLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteId': IndexSchema(
      id: 6301175856541681032,
      name: r'remoteId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'remoteId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _gasolineraLocalGetId,
  getLinks: _gasolineraLocalGetLinks,
  attach: _gasolineraLocalAttach,
  version: '3.1.0+1',
);

int _gasolineraLocalEstimateSize(
  GasolineraLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.direccion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.horario;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.idProvincia;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.provincia;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.remoteId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rotulo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _gasolineraLocalSerialize(
  GasolineraLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.biodiesel);
  writer.writeDouble(offsets[1], object.bioetanol);
  writer.writeString(offsets[2], object.direccion);
  writer.writeDouble(offsets[3], object.esterMetilico);
  writer.writeDouble(offsets[4], object.gasoleoA);
  writer.writeDouble(offsets[5], object.gasoleoPremium);
  writer.writeDouble(offsets[6], object.gasolina95);
  writer.writeDouble(offsets[7], object.gasolina95E10);
  writer.writeDouble(offsets[8], object.gasolina98);
  writer.writeDouble(offsets[9], object.glp);
  writer.writeDouble(offsets[10], object.hidrogeno);
  writer.writeString(offsets[11], object.horario);
  writer.writeString(offsets[12], object.idProvincia);
  writer.writeDouble(offsets[13], object.lat);
  writer.writeDouble(offsets[14], object.lng);
  writer.writeString(offsets[15], object.provincia);
  writer.writeString(offsets[16], object.remoteId);
  writer.writeString(offsets[17], object.rotulo);
}

GasolineraLocal _gasolineraLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GasolineraLocal();
  object.biodiesel = reader.readDoubleOrNull(offsets[0]);
  object.bioetanol = reader.readDoubleOrNull(offsets[1]);
  object.direccion = reader.readStringOrNull(offsets[2]);
  object.esterMetilico = reader.readDoubleOrNull(offsets[3]);
  object.gasoleoA = reader.readDoubleOrNull(offsets[4]);
  object.gasoleoPremium = reader.readDoubleOrNull(offsets[5]);
  object.gasolina95 = reader.readDoubleOrNull(offsets[6]);
  object.gasolina95E10 = reader.readDoubleOrNull(offsets[7]);
  object.gasolina98 = reader.readDoubleOrNull(offsets[8]);
  object.glp = reader.readDoubleOrNull(offsets[9]);
  object.hidrogeno = reader.readDoubleOrNull(offsets[10]);
  object.horario = reader.readStringOrNull(offsets[11]);
  object.id = id;
  object.idProvincia = reader.readStringOrNull(offsets[12]);
  object.lat = reader.readDoubleOrNull(offsets[13]);
  object.lng = reader.readDoubleOrNull(offsets[14]);
  object.provincia = reader.readStringOrNull(offsets[15]);
  object.remoteId = reader.readStringOrNull(offsets[16]);
  object.rotulo = reader.readStringOrNull(offsets[17]);
  return object;
}

P _gasolineraLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gasolineraLocalGetId(GasolineraLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gasolineraLocalGetLinks(GasolineraLocal object) {
  return [];
}

void _gasolineraLocalAttach(
    IsarCollection<dynamic> col, Id id, GasolineraLocal object) {
  object.id = id;
}

extension GasolineraLocalByIndex on IsarCollection<GasolineraLocal> {
  Future<GasolineraLocal?> getByRemoteId(String? remoteId) {
    return getByIndex(r'remoteId', [remoteId]);
  }

  GasolineraLocal? getByRemoteIdSync(String? remoteId) {
    return getByIndexSync(r'remoteId', [remoteId]);
  }

  Future<bool> deleteByRemoteId(String? remoteId) {
    return deleteByIndex(r'remoteId', [remoteId]);
  }

  bool deleteByRemoteIdSync(String? remoteId) {
    return deleteByIndexSync(r'remoteId', [remoteId]);
  }

  Future<List<GasolineraLocal?>> getAllByRemoteId(
      List<String?> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteId', values);
  }

  List<GasolineraLocal?> getAllByRemoteIdSync(List<String?> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteId', values);
  }

  Future<int> deleteAllByRemoteId(List<String?> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteId', values);
  }

  int deleteAllByRemoteIdSync(List<String?> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteId', values);
  }

  Future<Id> putByRemoteId(GasolineraLocal object) {
    return putByIndex(r'remoteId', object);
  }

  Id putByRemoteIdSync(GasolineraLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteId(List<GasolineraLocal> objects) {
    return putAllByIndex(r'remoteId', objects);
  }

  List<Id> putAllByRemoteIdSync(List<GasolineraLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'remoteId', objects, saveLinks: saveLinks);
  }
}

extension GasolineraLocalQueryWhereSort
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QWhere> {
  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GasolineraLocalQueryWhere
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QWhereClause> {
  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause>
      remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remoteId',
        value: [null],
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause>
      remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remoteId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause>
      remoteIdEqualTo(String? remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remoteId',
        value: [remoteId],
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterWhereClause>
      remoteIdNotEqualTo(String? remoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [],
              upper: [remoteId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [remoteId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [remoteId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [],
              upper: [remoteId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GasolineraLocalQueryFilter
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QFilterCondition> {
  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      biodieselIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'biodiesel',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      biodieselIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'biodiesel',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      biodieselEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'biodiesel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      biodieselGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'biodiesel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      biodieselLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'biodiesel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      biodieselBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'biodiesel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      bioetanolIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bioetanol',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      bioetanolIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bioetanol',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      bioetanolEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bioetanol',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      bioetanolGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bioetanol',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      bioetanolLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bioetanol',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      bioetanolBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bioetanol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'direccion',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'direccion',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'direccion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'direccion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direccion',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      direccionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'direccion',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      esterMetilicoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'esterMetilico',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      esterMetilicoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'esterMetilico',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      esterMetilicoEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esterMetilico',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      esterMetilicoGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'esterMetilico',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      esterMetilicoLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'esterMetilico',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      esterMetilicoBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'esterMetilico',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoAIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gasoleoA',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoAIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gasoleoA',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoAEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gasoleoA',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoAGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gasoleoA',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoALessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gasoleoA',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoABetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gasoleoA',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoPremiumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gasoleoPremium',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoPremiumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gasoleoPremium',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoPremiumEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gasoleoPremium',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoPremiumGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gasoleoPremium',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoPremiumLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gasoleoPremium',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasoleoPremiumBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gasoleoPremium',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gasolina95',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gasolina95',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95EqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gasolina95',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95GreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gasolina95',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95LessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gasolina95',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95Between(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gasolina95',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95E10IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gasolina95E10',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95E10IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gasolina95E10',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95E10EqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gasolina95E10',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95E10GreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gasolina95E10',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95E10LessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gasolina95E10',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina95E10Between(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gasolina95E10',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina98IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gasolina98',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina98IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gasolina98',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina98EqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gasolina98',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina98GreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gasolina98',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina98LessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gasolina98',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      gasolina98Between(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gasolina98',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      glpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'glp',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      glpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'glp',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      glpEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'glp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      glpGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'glp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      glpLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'glp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      glpBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'glp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      hidrogenoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hidrogeno',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      hidrogenoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hidrogeno',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      hidrogenoEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hidrogeno',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      hidrogenoGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hidrogeno',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      hidrogenoLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hidrogeno',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      hidrogenoBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hidrogeno',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'horario',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'horario',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'horario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'horario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'horario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'horario',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'horario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'horario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'horario',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'horario',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'horario',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      horarioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'horario',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idProvincia',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idProvincia',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idProvincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idProvincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idProvincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idProvincia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'idProvincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'idProvincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'idProvincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'idProvincia',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idProvincia',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      idProvinciaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'idProvincia',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      latIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lat',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      latIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lat',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      latEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      latGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      latLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      latBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      lngIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lng',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      lngIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lng',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      lngEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      lngGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      lngLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      lngBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lng',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'provincia',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'provincia',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'provincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'provincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'provincia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'provincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'provincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'provincia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'provincia',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provincia',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      provinciaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'provincia',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rotulo',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rotulo',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rotulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rotulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rotulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rotulo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rotulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rotulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rotulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rotulo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rotulo',
        value: '',
      ));
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterFilterCondition>
      rotuloIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rotulo',
        value: '',
      ));
    });
  }
}

extension GasolineraLocalQueryObject
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QFilterCondition> {}

extension GasolineraLocalQueryLinks
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QFilterCondition> {}

extension GasolineraLocalQuerySortBy
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QSortBy> {
  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByBiodiesel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biodiesel', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByBiodieselDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biodiesel', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByBioetanol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bioetanol', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByBioetanolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bioetanol', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByDireccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direccion', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByDireccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direccion', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByEsterMetilico() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esterMetilico', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByEsterMetilicoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esterMetilico', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasoleoA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasoleoA', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasoleoADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasoleoA', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasoleoPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasoleoPremium', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasoleoPremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasoleoPremium', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasolina95() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina95', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasolina95Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina95', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasolina95E10() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina95E10', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasolina95E10Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina95E10', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasolina98() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina98', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByGasolina98Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina98', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> sortByGlp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glp', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> sortByGlpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glp', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByHidrogeno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidrogeno', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByHidrogenoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidrogeno', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> sortByHorario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horario', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByHorarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horario', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByIdProvincia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idProvincia', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByIdProvinciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idProvincia', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> sortByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> sortByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> sortByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> sortByLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByProvincia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provincia', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByProvinciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provincia', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> sortByRotulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rotulo', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      sortByRotuloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rotulo', Sort.desc);
    });
  }
}

extension GasolineraLocalQuerySortThenBy
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QSortThenBy> {
  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByBiodiesel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biodiesel', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByBiodieselDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biodiesel', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByBioetanol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bioetanol', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByBioetanolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bioetanol', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByDireccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direccion', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByDireccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direccion', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByEsterMetilico() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esterMetilico', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByEsterMetilicoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esterMetilico', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasoleoA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasoleoA', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasoleoADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasoleoA', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasoleoPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasoleoPremium', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasoleoPremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasoleoPremium', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasolina95() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina95', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasolina95Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina95', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasolina95E10() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina95E10', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasolina95E10Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina95E10', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasolina98() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina98', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByGasolina98Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasolina98', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByGlp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glp', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByGlpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glp', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByHidrogeno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidrogeno', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByHidrogenoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hidrogeno', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByHorario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horario', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByHorarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horario', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByIdProvincia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idProvincia', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByIdProvinciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idProvincia', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByProvincia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provincia', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByProvinciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provincia', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy> thenByRotulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rotulo', Sort.asc);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QAfterSortBy>
      thenByRotuloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rotulo', Sort.desc);
    });
  }
}

extension GasolineraLocalQueryWhereDistinct
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> {
  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByBiodiesel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'biodiesel');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByBioetanol() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bioetanol');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> distinctByDireccion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direccion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByEsterMetilico() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'esterMetilico');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByGasoleoA() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gasoleoA');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByGasoleoPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gasoleoPremium');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByGasolina95() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gasolina95');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByGasolina95E10() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gasolina95E10');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByGasolina98() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gasolina98');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> distinctByGlp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'glp');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByHidrogeno() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hidrogeno');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> distinctByHorario(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'horario', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct>
      distinctByIdProvincia({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idProvincia', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> distinctByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lat');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> distinctByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lng');
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> distinctByProvincia(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'provincia', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> distinctByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GasolineraLocal, GasolineraLocal, QDistinct> distinctByRotulo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rotulo', caseSensitive: caseSensitive);
    });
  }
}

extension GasolineraLocalQueryProperty
    on QueryBuilder<GasolineraLocal, GasolineraLocal, QQueryProperty> {
  QueryBuilder<GasolineraLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations> biodieselProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'biodiesel');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations> bioetanolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bioetanol');
    });
  }

  QueryBuilder<GasolineraLocal, String?, QQueryOperations> direccionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direccion');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations>
      esterMetilicoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'esterMetilico');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations> gasoleoAProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gasoleoA');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations>
      gasoleoPremiumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gasoleoPremium');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations>
      gasolina95Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gasolina95');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations>
      gasolina95E10Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gasolina95E10');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations>
      gasolina98Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gasolina98');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations> glpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'glp');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations> hidrogenoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hidrogeno');
    });
  }

  QueryBuilder<GasolineraLocal, String?, QQueryOperations> horarioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'horario');
    });
  }

  QueryBuilder<GasolineraLocal, String?, QQueryOperations>
      idProvinciaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idProvincia');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations> latProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lat');
    });
  }

  QueryBuilder<GasolineraLocal, double?, QQueryOperations> lngProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lng');
    });
  }

  QueryBuilder<GasolineraLocal, String?, QQueryOperations> provinciaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'provincia');
    });
  }

  QueryBuilder<GasolineraLocal, String?, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<GasolineraLocal, String?, QQueryOperations> rotuloProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rotulo');
    });
  }
}
