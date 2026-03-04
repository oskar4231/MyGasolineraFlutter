/// Stub de IsarService para Web.
/// En web, Isar no está disponible. Esta clase no hace nada.
class IsarService {
  // En web no hay base de datos local. db nunca se resuelve a un objeto real.
  // Usamos un completer que nunca completa para que el código que espera la DB
  // simplemente no haga nada en web.
  final Future<Never> db = Future.error(
    UnsupportedError('Isar no está disponible en Web'),
  );

  IsarService();
}
