import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'isar_models/user_local.dart';
import 'isar_models/car_local.dart';
import 'isar_models/invoice_local.dart';
import 'isar_models/gasolinera_local.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = _initDb();
  }

  Future<Isar> _initDb() async {
    final dir = await getTemporaryDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          UserLocalSchema,
          CarLocalSchema,
          InvoiceLocalSchema,
          GasolineraLocalSchema,
        ],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
