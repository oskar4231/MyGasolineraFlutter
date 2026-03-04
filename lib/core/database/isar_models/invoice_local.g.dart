// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInvoiceLocalCollection on Isar {
  IsarCollection<InvoiceLocal> get invoiceLocals => this.collection();
}

const InvoiceLocalSchema = CollectionSchema(
  name: r'InvoiceLocal',
  id: -8884237325263031963,
  properties: {
    r'carLocalId': PropertySchema(
      id: 0,
      name: r'carLocalId',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'gasStationName': PropertySchema(
      id: 2,
      name: r'gasStationName',
      type: IsarType.string,
    ),
    r'receiptImagePath': PropertySchema(
      id: 3,
      name: r'receiptImagePath',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 4,
      name: r'remoteId',
      type: IsarType.long,
    ),
    r'totalAmount': PropertySchema(
      id: 5,
      name: r'totalAmount',
      type: IsarType.double,
    )
  },
  estimateSize: _invoiceLocalEstimateSize,
  serialize: _invoiceLocalSerialize,
  deserialize: _invoiceLocalDeserialize,
  deserializeProp: _invoiceLocalDeserializeProp,
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
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'carLocalId': IndexSchema(
      id: -4109693389607890623,
      name: r'carLocalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'carLocalId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _invoiceLocalGetId,
  getLinks: _invoiceLocalGetLinks,
  attach: _invoiceLocalAttach,
  version: '3.1.0+1',
);

int _invoiceLocalEstimateSize(
  InvoiceLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.gasStationName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.receiptImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _invoiceLocalSerialize(
  InvoiceLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.carLocalId);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.gasStationName);
  writer.writeString(offsets[3], object.receiptImagePath);
  writer.writeLong(offsets[4], object.remoteId);
  writer.writeDouble(offsets[5], object.totalAmount);
}

InvoiceLocal _invoiceLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InvoiceLocal();
  object.carLocalId = reader.readLongOrNull(offsets[0]);
  object.date = reader.readDateTimeOrNull(offsets[1]);
  object.gasStationName = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.receiptImagePath = reader.readStringOrNull(offsets[3]);
  object.remoteId = reader.readLongOrNull(offsets[4]);
  object.totalAmount = reader.readDoubleOrNull(offsets[5]);
  return object;
}

P _invoiceLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _invoiceLocalGetId(InvoiceLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _invoiceLocalGetLinks(InvoiceLocal object) {
  return [];
}

void _invoiceLocalAttach(
    IsarCollection<dynamic> col, Id id, InvoiceLocal object) {
  object.id = id;
}

extension InvoiceLocalByIndex on IsarCollection<InvoiceLocal> {
  Future<InvoiceLocal?> getByRemoteId(int? remoteId) {
    return getByIndex(r'remoteId', [remoteId]);
  }

  InvoiceLocal? getByRemoteIdSync(int? remoteId) {
    return getByIndexSync(r'remoteId', [remoteId]);
  }

  Future<bool> deleteByRemoteId(int? remoteId) {
    return deleteByIndex(r'remoteId', [remoteId]);
  }

  bool deleteByRemoteIdSync(int? remoteId) {
    return deleteByIndexSync(r'remoteId', [remoteId]);
  }

  Future<List<InvoiceLocal?>> getAllByRemoteId(List<int?> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteId', values);
  }

  List<InvoiceLocal?> getAllByRemoteIdSync(List<int?> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteId', values);
  }

  Future<int> deleteAllByRemoteId(List<int?> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteId', values);
  }

  int deleteAllByRemoteIdSync(List<int?> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteId', values);
  }

  Future<Id> putByRemoteId(InvoiceLocal object) {
    return putByIndex(r'remoteId', object);
  }

  Id putByRemoteIdSync(InvoiceLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteId(List<InvoiceLocal> objects) {
    return putAllByIndex(r'remoteId', objects);
  }

  List<Id> putAllByRemoteIdSync(List<InvoiceLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'remoteId', objects, saveLinks: saveLinks);
  }
}

extension InvoiceLocalQueryWhereSort
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QWhere> {
  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhere> anyRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'remoteId'),
      );
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhere> anyCarLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'carLocalId'),
      );
    });
  }
}

extension InvoiceLocalQueryWhere
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QWhereClause> {
  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> idBetween(
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

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remoteId',
        value: [null],
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause>
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

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> remoteIdEqualTo(
      int? remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remoteId',
        value: [remoteId],
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause>
      remoteIdNotEqualTo(int? remoteId) {
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

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause>
      remoteIdGreaterThan(
    int? remoteId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remoteId',
        lower: [remoteId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> remoteIdLessThan(
    int? remoteId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remoteId',
        lower: [],
        upper: [remoteId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> remoteIdBetween(
    int? lowerRemoteId,
    int? upperRemoteId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'remoteId',
        lower: [lowerRemoteId],
        includeLower: includeLower,
        upper: [upperRemoteId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause>
      carLocalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'carLocalId',
        value: [null],
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause>
      carLocalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'carLocalId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> carLocalIdEqualTo(
      int? carLocalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'carLocalId',
        value: [carLocalId],
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause>
      carLocalIdNotEqualTo(int? carLocalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'carLocalId',
              lower: [],
              upper: [carLocalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'carLocalId',
              lower: [carLocalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'carLocalId',
              lower: [carLocalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'carLocalId',
              lower: [],
              upper: [carLocalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause>
      carLocalIdGreaterThan(
    int? carLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'carLocalId',
        lower: [carLocalId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause>
      carLocalIdLessThan(
    int? carLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'carLocalId',
        lower: [],
        upper: [carLocalId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterWhereClause> carLocalIdBetween(
    int? lowerCarLocalId,
    int? upperCarLocalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'carLocalId',
        lower: [lowerCarLocalId],
        includeLower: includeLower,
        upper: [upperCarLocalId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension InvoiceLocalQueryFilter
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QFilterCondition> {
  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      carLocalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'carLocalId',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      carLocalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'carLocalId',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      carLocalIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      carLocalIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      carLocalIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      carLocalIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carLocalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition> dateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      dateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition> dateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gasStationName',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gasStationName',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gasStationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gasStationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gasStationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gasStationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gasStationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gasStationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gasStationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gasStationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gasStationName',
        value: '',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      gasStationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gasStationName',
        value: '',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receiptImagePath',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receiptImagePath',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'receiptImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'receiptImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'receiptImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'receiptImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      receiptImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receiptImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      remoteIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      remoteIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      remoteIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      remoteIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      totalAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalAmount',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      totalAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalAmount',
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      totalAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      totalAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      totalAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterFilterCondition>
      totalAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension InvoiceLocalQueryObject
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QFilterCondition> {}

extension InvoiceLocalQueryLinks
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QFilterCondition> {}

extension InvoiceLocalQuerySortBy
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QSortBy> {
  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> sortByCarLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carLocalId', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      sortByCarLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carLocalId', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      sortByGasStationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasStationName', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      sortByGasStationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasStationName', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      sortByReceiptImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptImagePath', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      sortByReceiptImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptImagePath', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }
}

extension InvoiceLocalQuerySortThenBy
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QSortThenBy> {
  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> thenByCarLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carLocalId', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      thenByCarLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carLocalId', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      thenByGasStationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasStationName', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      thenByGasStationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasStationName', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      thenByReceiptImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptImagePath', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      thenByReceiptImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptImagePath', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy> thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QAfterSortBy>
      thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }
}

extension InvoiceLocalQueryWhereDistinct
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QDistinct> {
  QueryBuilder<InvoiceLocal, InvoiceLocal, QDistinct> distinctByCarLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carLocalId');
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QDistinct> distinctByGasStationName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gasStationName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QDistinct>
      distinctByReceiptImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QDistinct> distinctByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId');
    });
  }

  QueryBuilder<InvoiceLocal, InvoiceLocal, QDistinct> distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }
}

extension InvoiceLocalQueryProperty
    on QueryBuilder<InvoiceLocal, InvoiceLocal, QQueryProperty> {
  QueryBuilder<InvoiceLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InvoiceLocal, int?, QQueryOperations> carLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carLocalId');
    });
  }

  QueryBuilder<InvoiceLocal, DateTime?, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<InvoiceLocal, String?, QQueryOperations>
      gasStationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gasStationName');
    });
  }

  QueryBuilder<InvoiceLocal, String?, QQueryOperations>
      receiptImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptImagePath');
    });
  }

  QueryBuilder<InvoiceLocal, int?, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<InvoiceLocal, double?, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }
}
