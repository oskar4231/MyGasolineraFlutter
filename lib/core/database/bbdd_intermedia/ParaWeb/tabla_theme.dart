import 'package:drift/drift.dart';

/// Tabla para guardar la preferencia de tema del usuario (Web)
class ThemeTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get themeId => integer().withDefault(const Constant(0))();
}
