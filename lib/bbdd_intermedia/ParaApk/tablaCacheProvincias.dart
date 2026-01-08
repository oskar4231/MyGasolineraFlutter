import 'package:drift/drift.dart';

/// Tabla para rastrear la frescura de los datos por provincia
class ProvinciaCacheTable extends Table {
  // ID de la provincia
  TextColumn get provinciaId => text()();

  // Nombre de la provincia
  TextColumn get provinciaNombre => text()();

  // Última actualización de datos
  DateTimeColumn get lastUpdated => dateTime()();

  // Número de gasolineras en cache para esta provincia
  IntColumn get recordCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {provinciaId};
}
