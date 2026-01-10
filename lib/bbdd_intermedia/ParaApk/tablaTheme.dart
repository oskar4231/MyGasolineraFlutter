import 'package:drift/drift.dart';

/// Tabla para guardar la preferencia de tema del usuario
/// id: Identificador único (siempre 1 para el usuario actual local)
/// theme_id:
/// 0: Predeterminado
/// 1: Modo Oscuro
/// 2: Daltonismo 1 (Protanopia)
/// 3: Daltonismo 2 (Deuteranopia)
/// 4: Daltonismo 3 (Tritanopia)
/// 5: Daltonismo 4 (Achromatopsia)
class ThemeTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get themeId => integer().withDefault(const Constant(0))();
}
