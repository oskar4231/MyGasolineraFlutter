import 'package:drift/drift.dart';

/// Tabla para almacenar gasolineras en cache local
class GasolinerasTable extends Table {
  // Identificación
  TextColumn get id => text()();
  TextColumn get rotulo => text()();
  TextColumn get direccion => text()();

  // Ubicación
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get provincia => text()();
  TextColumn get idProvincia => text()();

  // Horario
  TextColumn get horario => text()();

  // Precios de combustibles
  RealColumn get gasolina95 => real().withDefault(const Constant(0.0))();
  RealColumn get gasolina95E10 => real().withDefault(const Constant(0.0))();
  RealColumn get gasolina98 => real().withDefault(const Constant(0.0))();
  RealColumn get gasoleoA => real().withDefault(const Constant(0.0))();
  RealColumn get gasoleoPremium => real().withDefault(const Constant(0.0))();
  RealColumn get glp => real().withDefault(const Constant(0.0))();
  RealColumn get biodiesel => real().withDefault(const Constant(0.0))();
  RealColumn get bioetanol => real().withDefault(const Constant(0.0))();
  RealColumn get esterMetilico => real().withDefault(const Constant(0.0))();
  RealColumn get hidrogeno => real().withDefault(const Constant(0.0))();

  // Metadata de cache
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
