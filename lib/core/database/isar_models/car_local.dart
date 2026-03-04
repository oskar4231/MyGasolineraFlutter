import 'package:isar/isar.dart';

part 'car_local.g.dart';

@collection
class CarLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? remoteId;

  String? brand;
  String? model;
  String? plate;

  @Index()
  int? userLocalId; // To link to the UserLocal ID
}
