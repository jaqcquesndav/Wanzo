import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart'; // For sharing

import '../../settings/models/settings.dart'; // For company info
import '../models/operation_journal_entry.dart'; // For OperationJournalEntry

class JournalService {
  Future<Uint8List> generateJournalPdf({
    required Map<DateTime, List<OperationJournalEntry>> groupedOperations,
    required DateTime startDate,
    required DateTime endDate,
    required Settings settings,
    required double openingBalance, // Added openingBalance parameter
  }) async {
    final pdf = pw.Document();

    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(), // Use built-in Helvetica
      bold: pw.Font.helveticaBold(), // Use built-in Helvetica-Bold
    );

    // Header
    final Uint8List? logoBytes = settings.companyLogo.isNotEmpty // Changed from settings.logoPath
        ? await File(settings.companyLogo).readAsBytes() // Changed from settings.logoPath
        : null;
    final pw.ImageProvider? logoImage = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (settings.companyName.isNotEmpty)
                        pw.Text(settings.companyName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                      if (settings.companyAddress.isNotEmpty) 
                        pw.Text(settings.companyAddress), 
                      if (settings.companyPhone.isNotEmpty) // Changed from settings.phoneNumber
                        pw.Text('Tél: ${settings.companyPhone}'), // Changed from settings.phoneNumber
                      if (settings.companyEmail.isNotEmpty) // Changed from settings.email
                        pw.Text('Email: ${settings.companyEmail}'), // Changed from settings.email
                    ],
                  ),
                  if (logoImage != null)
                    pw.SizedBox(
                      width: 80,
                      height: 80,
                      child: pw.Image(logoImage),
                    ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Journal des Opérations',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20, color: PdfColors.blueGrey800),
              ),
              pw.Text(
                'Période du ${DateFormat('dd/MM/yyyy', 'fr_FR').format(startDate)} au ${DateFormat('dd/MM/yyyy', 'fr_FR').format(endDate)}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Divider(thickness: 2, color: PdfColors.blueGrey800),
              pw.SizedBox(height: 10),
            ],
          );
        },
        build: (pw.Context context) {
          List<pw.Widget> content = [];
          double currentBalance = openingBalance; // Initialize with openingBalance

          content.add(
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                0: pw.Alignment.centerLeft, // Date
                1: pw.Alignment.centerLeft, // Heure
                2: pw.Alignment.centerLeft, // Description
                3: pw.Alignment.centerLeft, // Type
                4: pw.Alignment.centerRight, // Débit
                5: pw.Alignment.centerRight, // Crédit
                6: pw.Alignment.centerRight, // Solde
              },
              columnWidths: {
                0: const pw.FixedColumnWidth(60),
                1: const pw.FixedColumnWidth(40),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FixedColumnWidth(70),
                4: const pw.FixedColumnWidth(60),
                5: const pw.FixedColumnWidth(60),
                6: const pw.FixedColumnWidth(70),
              },
              data: <List<String>>[
                <String>['Date', 'Heure', 'Description', 'Type', 'Débit', 'Crédit', 'Solde'],
                // Row for opening balance
                <String>[
                  DateFormat('dd/MM/yy', 'fr_FR').format(startDate),
                  '',
                  'Solde d\'ouverture',
                  '',
                  '',
                  '',
                  NumberFormat.currency(locale: 'fr_FR', symbol: 'FC', decimalDigits: 0).format(openingBalance),
                ],
              ],
            ),
          );
          
          List<List<String>> rows = [];
          final sortedDates = groupedOperations.keys.toList()..sort();

          for (var dateKey in sortedDates) {
            final operationsOnDate = groupedOperations[dateKey]!;
            operationsOnDate.sort((a, b) => a.date.compareTo(b.date)); // Sort operations by time

            for (var op in operationsOnDate) {
              double debit = op.amount < 0 ? op.amount.abs() : 0;
              double credit = op.amount > 0 ? op.amount : 0;
              currentBalance += op.amount;

              rows.add([
                DateFormat('dd/MM/yy', 'fr_FR').format(op.date),
                DateFormat('HH:mm').format(op.date),
                op.description,
                op.type.displayName,
                debit > 0 ? NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0).format(debit) : '',
                credit > 0 ? NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0).format(credit) : '',
                NumberFormat.currency(locale: 'fr_FR', symbol: 'FC', decimalDigits: 0).format(currentBalance),
              ]);
            }
          }
          
          content.add(
             pw.TableHelper.fromTextArray(
              context: context,
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
               cellAlignments: {
                0: pw.Alignment.centerLeft, // Date
                1: pw.Alignment.centerLeft, // Heure
                2: pw.Alignment.centerLeft, // Description
                3: pw.Alignment.centerLeft, // Type
                4: pw.Alignment.centerRight, // Débit
                5: pw.Alignment.centerRight, // Crédit
                6: pw.Alignment.centerRight, // Solde
              },
              columnWidths: {
                0: const pw.FixedColumnWidth(60),
                1: const pw.FixedColumnWidth(40),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FixedColumnWidth(70),
                4: const pw.FixedColumnWidth(60),
                5: const pw.FixedColumnWidth(60),
                6: const pw.FixedColumnWidth(70),
              },
              data: rows,
            ),
          );


          // Summary / Closing Balance
          content.add(pw.SizedBox(height: 20));
          content.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Solde de clôture: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  NumberFormat.currency(locale: 'fr_FR', symbol: 'FC', decimalDigits: 0).format(currentBalance),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ],
            )
          );

          return content;
        },
        footer: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(thickness: 1),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null) // Reuse logoImage from header
                    pw.Container(
                      width: 20, // Small logo
                      height: 20,
                      child: pw.Image(logoImage),
                      margin: const pw.EdgeInsets.only(right: 5),
                    ),
                  pw.Text(
                    'Généré par Wanzo, développé par i-KiotaHub Goma',
                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey),
                  ),
                ]
              ),
              pw.SizedBox(height: 2), // Add some space
              pw.Text(
                'Page ${context.pageNumber} sur ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> printJournal({
    required Map<DateTime, List<OperationJournalEntry>> groupedOperations,
    required DateTime startDate,
    required DateTime endDate,
    required Settings settings,
    required double openingBalance, // Added openingBalance parameter
  }) async {
    final Uint8List pdfBytes = await generateJournalPdf(
      groupedOperations: groupedOperations,
      startDate: startDate,
      endDate: endDate,
      settings: settings,
      openingBalance: openingBalance, // Pass openingBalance
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  Future<void> shareJournal({
    required Map<DateTime, List<OperationJournalEntry>> groupedOperations,
    required DateTime startDate,
    required DateTime endDate,
    required Settings settings,
    required double openingBalance, // Added openingBalance parameter
    String? subject,
  }) async {
    final Uint8List pdfBytes = await generateJournalPdf(
      groupedOperations: groupedOperations,
      startDate: startDate,
      endDate: endDate,
      settings: settings,
      openingBalance: openingBalance, // Pass openingBalance
    );

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/journal_operations_${DateFormat('yyyyMMdd').format(startDate)}-${DateFormat('yyyyMMdd').format(endDate)}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles( // Changed from SharePlus.shareXFiles to Share.shareXFiles
      [XFile(filePath)],
      text: subject ?? 'Journal des opérations du ${DateFormat('dd/MM/yyyy').format(startDate)} au ${DateFormat('dd/MM/yyyy').format(endDate)}',
      subject: subject ?? 'Journal des Opérations Wanzo',
    );
  }
}
