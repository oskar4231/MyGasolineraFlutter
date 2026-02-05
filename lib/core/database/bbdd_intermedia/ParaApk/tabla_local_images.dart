import 'package:drift/drift.dart';

/// Tabla para registrar imágenes guardadas localmente y encriptadas
/// Ahora almacena el contenido directamente (BLOB) para compatibilidad Web/Nativo
class LocalImagesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imageType => text()(); // 'factura', 'perfil'
  TextColumn get relatedId =>
      text().nullable()(); // ID de la factura o email usuario
  TextColumn get localPath => text().nullable()(); // Opcional, por si se usa
  BlobColumn get content => blob()(); // Contenido encriptado de la imagen
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
