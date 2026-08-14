import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class AreaReportData {
  final String areaName;
  final String zone;
  final int filesProcessed;
  final int totalPages;
  final double syncPercentage;

  const AreaReportData({
    required this.areaName,
    required this.zone,
    required this.filesProcessed,
    required this.totalPages,
    required this.syncPercentage,
  });
}

class ReportExporterService {
  /// Generate a PDF report file matching the Stitch design.
  Future<File> generatePdfReport({
    required String dateStr,
    required List<AreaReportData> areas,
  }) async {
    final pdf = pw.Document();

    int totalFiles = areas.fold(0, (sum, item) => sum + item.filesProcessed);
    int totalPages = areas.fold(0, (sum, item) => sum + item.totalPages);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('ScanDigitize Enterprise Report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text(dateStr, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Area-Wise Digitization Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Area Name', 'Zone', 'Files Processed', 'Total Pages', 'Sync Status'],
                data: areas.map((a) => [
                  a.areaName,
                  a.zone,
                  a.filesProcessed.toString(),
                  a.totalPages.toString(),
                  '${(a.syncPercentage * 100).toInt()}%'
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL METRICS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Total Files: $totalFiles  |  Total Pages: $totalPages', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ScanDigitize_Report_$dateStr.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Generate an Excel spreadsheet report.
  Future<File> generateExcelReport({
    required String dateStr,
    required List<AreaReportData> areas,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Daily Report'];
    excel.delete('Sheet1');

    sheetObject.appendRow([
      TextCellValue('Area Name'),
      TextCellValue('Zone'),
      TextCellValue('Files Processed'),
      TextCellValue('Total Pages'),
      TextCellValue('Sync Progress'),
    ]);

    for (final area in areas) {
      sheetObject.appendRow([
        TextCellValue(area.areaName),
        TextCellValue(area.zone),
        IntCellValue(area.filesProcessed),
        IntCellValue(area.totalPages),
        TextCellValue('${(area.syncPercentage * 100).toInt()}%'),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ScanDigitize_Report_$dateStr.xlsx');
    final fileBytes = excel.save();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
    }
    return file;
  }
}
