import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class ExportService {
  // ==================== EXCEL ====================
  static Future<void> exportarExcel(List<Map<String, dynamic>> facturas) async {
    try {
      debugPrint('📊 Iniciando exportación de Excel...');
      debugPrint('📊 Número de facturas a exportar: ${facturas.length}');
      var excel = Excel.createExcel();

      // Crear la hoja "Facturas" primero
      Sheet sheetObject = excel['Facturas'];

      // Eliminar la hoja por defecto "Sheet1" si existe
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
        debugPrint('📊 Hoja "Sheet1" eliminada');
      }

      // Headers
      List<String> headers = [
        'ID',
        'Título',
        'Fecha',
        'Hora',
        'Coste (€)',
        'Litros',
        'Precio/L (€)',
        'Combustible',
        'Kilometraje',
        'Descripción',
        'Gasolinera'
      ];

      // Agregar headers
      sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());
      debugPrint('📊 Headers agregados');

      // Agregar datos
      for (var factura in facturas) {
        List<CellValue> row = [
          IntCellValue(factura['id_factura'] ??
              factura['id'] ??
              factura['facturaId'] ??
              0),
          TextCellValue(factura['titulo'] ?? ''),
          TextCellValue(factura['fecha'] ?? ''),
          TextCellValue(factura['hora'] ?? ''),
          DoubleCellValue(
              double.tryParse(factura['coste']?.toString() ?? '0') ?? 0.0),
          DoubleCellValue(double.tryParse(
                  factura['litros_repostados']?.toString() ?? '0') ??
              0.0),
          DoubleCellValue(
              double.tryParse(factura['precio_por_litro']?.toString() ?? '0') ??
                  0.0),
          TextCellValue(factura['tipo_combustible'] ?? ''),
          IntCellValue(
              int.tryParse(factura['kilometraje_actual']?.toString() ?? '0') ??
                  0),
          TextCellValue(factura['descripcion'] ?? ''),
          TextCellValue(factura['nombre_gasolinera'] ?? ''),
        ];
        sheetObject.appendRow(row);
      }
      debugPrint('📊 ${facturas.length} filas de datos agregadas');

      // Guardar archivo - usar encode() en lugar de save()
      var fileBytes = excel.encode();
      if (fileBytes == null || fileBytes.isEmpty) {
        debugPrint('❌ Error: excel.encode() retornó null o vacío');
        throw Exception('No se pudieron generar los bytes del archivo Excel');
      }
      debugPrint('📊 Bytes generados: ${fileBytes.length} bytes');

      if (kIsWeb) {
        debugPrint('🌐 Modo Web detectado, iniciando descarga...');
        // Lógica específica para Web
        final blob = html.Blob(
          [Uint8List.fromList(fileBytes)],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'facturas_exported.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
        debugPrint('✅ Descarga Web iniciada correctamente');
      } else {
        debugPrint('📱 Modo Móvil/Desktop detectado');
        // Lógica para Móvil/Desktop
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/facturas_exported.xlsx';
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        // Compartir archivo
        await Share.shareXFiles([XFile(path)],
            text: 'Aquí tienes tus facturas exportadas.');
      }
    } catch (e) {
      debugPrint('Error exportando Excel: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>?> importarExcel() async {
    try {
      debugPrint('📂 Iniciando importación de Excel...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true, // Importante para Web
      );

      if (result != null) {
        debugPrint('📂 Archivo seleccionado: ${result.files.single.name}');
        List<int> bytes;

        if (kIsWeb) {
          debugPrint('🌐 Modo Web: leyendo bytes directamente...');
          // En web usamos 'bytes' directamente
          if (result.files.single.bytes == null) {
            throw Exception('No se pudieron leer los bytes del archivo (Web)');
          }
          bytes = result.files.single.bytes!;
        } else {
          debugPrint('📱 Modo Móvil: leyendo desde path...');
          // En móvil usamos 'path'
          if (result.files.single.path == null) {
            throw Exception('No se pudo determinar la ruta del archivo');
          }
          bytes = File(result.files.single.path!).readAsBytesSync();
        }

        if (bytes.isEmpty) {
          throw Exception('El archivo seleccionado está vacío');
        }
        debugPrint('📂 Bytes leídos: ${bytes.length} bytes');

        var excel = Excel.decodeBytes(bytes);
        debugPrint(
            '📂 Excel decodificado, tablas encontradas: ${excel.tables.length}');

        List<Map<String, dynamic>> facturasImportadas = [];

        for (var table in excel.tables.keys) {
          debugPrint('📂 Procesando tabla: $table');
          var sheet = excel.tables[table];
          if (sheet == null) continue;

          debugPrint('📂 Filas en la tabla: ${sheet.rows.length}');

          // Asumimos que la primera fila son headers
          bool isHeader = true;

          for (var row in sheet.rows) {
            if (isHeader) {
              isHeader = false;
              debugPrint(
                  '📂 Headers: ${row.map((cell) => cell?.value).toList()}');
              continue;
            }

            // ID [0], Titulo [1], Fecha [2], Hora [3], Coste [4] ...
            if (row.length < 5) {
              debugPrint(
                  '⚠️ Fila omitida (menos de 5 columnas): ${row.length}');
              continue;
            }

            // Helper function to safely get cell value
            String? getCellValue(int index) {
              if (index >= row.length) return null;
              final cell = row[index];
              if (cell == null || cell.value == null) return null;
              return cell.value.toString();
            }

            Map<String, dynamic> factura = {
              'titulo': getCellValue(1) ?? 'Importada',
              'fecha': getCellValue(2),
              'hora': getCellValue(3),
              'coste': double.tryParse(getCellValue(4) ?? '0') ?? 0,
              'litros_repostados': double.tryParse(getCellValue(5) ?? '0'),
              'precio_por_litro': double.tryParse(getCellValue(6) ?? '0'),
              'tipo_combustible': getCellValue(7),
              'kilometraje_actual': int.tryParse(getCellValue(8) ?? '0'),
              'descripcion': getCellValue(9),
            };

            debugPrint(
                '📂 Factura importada: ${factura['titulo']} - ${factura['coste']}€');
            facturasImportadas.add(factura);
          }
        }
        debugPrint(
            '✅ Importación completada: ${facturasImportadas.length} facturas importadas');
        return facturasImportadas;
      }
    } catch (e) {
      debugPrint('Error importando Excel: $e');
      rethrow;
    }
    return null;
  }

  // ==================== PDF ====================
  static Future<void> exportarPDF(List<Map<String, dynamic>> facturas) async {
    try {
      final pdf = pw.Document();
      final theme = pw.ThemeData.withFont(
        base: await PdfGoogleFonts.openSansRegular(),
        bold: await PdfGoogleFonts.openSansBold(),
      );

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(theme: theme, pageFormat: PdfPageFormat.a4),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('Reporte de Facturas - MyGasolinera',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: [
                  'Fecha',
                  'Título',
                  'Combustible',
                  'Litros',
                  'Coste (EUR)'
                ],
                data: facturas
                    .map((f) => [
                          f['fecha'] ?? '',
                          f['titulo'] ?? '',
                          f['tipo_combustible'] ?? '-',
                          f['litros_repostados']?.toString() ?? '-',
                          '${double.tryParse(f['coste']?.toString() ?? '0')?.toStringAsFixed(2)} €'
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total Gastado: ${facturas.fold<double>(0, (sum, f) => sum + (double.tryParse(f['coste']?.toString() ?? '0') ?? 0)).toStringAsFixed(2)} €',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ];
          },
        ),
      );

      // Guardar y compartir (Printing maneja web automáticamente)
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'reporte_facturas.pdf');
    } catch (e) {
      debugPrint('Error exportando PDF: $e');
      rethrow;
    }
  }
}
