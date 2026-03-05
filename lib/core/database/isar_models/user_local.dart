import 'package:isar/isar.dart';

part 'user_local.g.dart';

@collection
class UserLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? remoteId;

  String? email;
  String? name;
  DateTime? lastSync;
}
