import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

class VehicleService {
  static const String _zipUrl =
      'https://github.com/ilyasozkurt/automobile-models-and-specs/raw/master/automobiles.json.zip';
  static const String _jsonFileName = 'automobiles.json';

  static List<dynamic> _vehicleData = [];

  /// Checks if data exists locally. If not, downloads and unzips it.
  /// Then loads the JSON into memory.
  static Future<void> initializeData() async {
    if (_vehicleData.isNotEmpty) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final jsonFile = File('${directory.path}/$_jsonFileName');

      if (!await jsonFile.exists()) {
        await _downloadAndUnzip(directory.path);
      }

      final jsonString = await jsonFile.readAsString();
      _vehicleData = json.decode(jsonString);
      print('✅ Vehicle Models Loaded: ${_vehicleData.length} records');
    } catch (e) {
      print('❌ Error initializing vehicle data: $e');
      throw Exception('Failed to load vehicle data: $e');
    }
  }

  static Future<void> _downloadAndUnzip(String storagePath) async {
    print('⬇️ Downloading vehicle database...');
    final response = await http.get(Uri.parse(_zipUrl));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        if (file.name == _jsonFileName) {
          final data = file.content as List<int>;
          File('$storagePath/$_jsonFileName')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
          print('✅ Database extracted to $storagePath/$_jsonFileName');
          return;
        }
      }
      throw Exception('JSON file not found in ZIP archive');
    } else {
      throw Exception(
          'Failed to download database. Status: ${response.statusCode}');
    }
  }

  /// Returns sorted list of unique Brands (Makes)
  static List<String> getMakes() {
    if (_vehicleData.isEmpty) return [];

    final makes =
        _vehicleData.map((car) => car['make'].toString()).toSet().toList();

    makes.sort();
    return makes;
  }

  /// Returns sorted list of Models for a given Make
  static List<String> getModels(String make) {
    if (_vehicleData.isEmpty) return [];

    final models = _vehicleData
        .where((car) => car['make'].toString() == make)
        .map((car) => car['model'].toString())
        .toSet()
        .toList();

    models.sort();
    return models;
  }

  /// Returns list of details (Engine Version) for a given Make and Model
  /// Returns a list of Maps to keep track of technical details
  static List<Map<String, dynamic>> getVersions(String make, String model) {
    if (_vehicleData.isEmpty) return [];

    // Filter by make and model
    final versions = _vehicleData
        .where((car) =>
            car['make'].toString() == make && car['model'].toString() == model)
        .toList();

    return versions.map((v) => v as Map<String, dynamic>).toList();
  }
}
