import 'package:isar/isar.dart';

part 'gasolinera_local.g.dart';

@collection
class GasolineraLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId;

  String? rotulo;
  String? direccion;

  // Isar doesn't support Google Maps LatLng directly, so we store doubles
  double? lat;
  double? lng;

  String? horario;
  String? provincia;
  String? idProvincia;

  double? gasolina95;
  double? gasolina95E10;
  double? gasolina98;
  double? gasoleoA;
  double? gasoleoPremium;
  double? glp;
  double? biodiesel;
  double? bioetanol;
  double? esterMetilico;
  double? hidrogeno;
}
