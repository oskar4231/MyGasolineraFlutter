import 'package:isar/isar.dart';

part 'invoice_local.g.dart';

@collection
class InvoiceLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? remoteId;

  DateTime? date;
  double? totalAmount;
  String? gasStationName;
  String? receiptImagePath; // Store relative path or backend URL

  @Index()
  int? carLocalId; // To link to specific Car
}
