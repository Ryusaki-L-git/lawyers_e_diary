import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/case_model.dart';
import '../widgets/calendar_components.dart';

abstract final class CaseActionsHelper {
  /// Opens WhatsApp using the universal web/deep link format:
  /// `https://wa.me/<number>?text=<encoded_message>`
  /// Never auto-sends; opens chat draft for confirmation.
  static Future<bool> openWhatsAppClient({
    required BuildContext context,
    required CaseModel caseItem,
  }) async {
    final rawPhone = caseItem.clientPhone?.trim();
    if (rawPhone == null || rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number recorded for this client.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    // Clean phone number (strip spaces, dashes, parentheses)
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');

    final hearingText = caseItem.nextHearingDate != null
        ? CalendarDateHelper.formatDateDigits(caseItem.nextHearingDate!)
        : 'To be scheduled';

    final message =
        'Dear ${caseItem.clientName},\n\n'
        'This is an update regarding your case "${caseItem.caseTitle}" '
        '(${caseItem.caseNumber}) at ${caseItem.courtName}.\n'
        'Next Scheduled Hearing: $hearingText.\n\n'
        'Regards,\n'
        'Lawyer\'s E-Diary';

    final encodedMessage = Uri.encodeComponent(message);
    final urlString = 'https://wa.me/$cleanPhone?text=$encodedMessage';
    final uri = Uri.parse(urlString);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Please verify the client number.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return launched;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to launch WhatsApp: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Shares case details using system share sheet.
  static Future<void> shareCase({
    required CaseModel caseItem,
    bool fullDetails = true,
  }) async {
    final hearingText = caseItem.nextHearingDate != null
        ? CalendarDateHelper.formatDateDigits(caseItem.nextHearingDate!)
        : 'To be announced';

    final text = fullDetails
        ? 'CASE DOSSIER: ${caseItem.caseTitle}\n'
            'Case Number: ${caseItem.caseNumber}\n'
            'Type: ${caseItem.caseType}\n'
            'Status: ${caseItem.status.toUpperCase()}\n'
            'Client: ${caseItem.clientName}\n'
            'Opponent: ${caseItem.opponentName.isEmpty ? "N/A" : caseItem.opponentName}\n'
            'Court: ${caseItem.courtName}\n'
            'Next Hearing: $hearingText\n'
            'Counsel: ${caseItem.handledBy}\n'
            'Notes: ${caseItem.notes.isEmpty ? "None" : caseItem.notes.join("; ")}'
        : 'Case Summary: ${caseItem.caseTitle} (${caseItem.caseNumber}) at ${caseItem.courtName}. '
            'Next Date: $hearingText.';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'Case Summary: ${caseItem.caseTitle}',
      ),
    );
  }

  /// Generates a professional legal PDF document and invokes the Printing system.
  static Future<void> printCaseDetails({
    required BuildContext context,
    required CaseModel caseItem,
  }) async {
    final pdf = pw.Document();

    final hearingText = caseItem.nextHearingDate != null
        ? CalendarDateHelper.formatDateDigits(caseItem.nextHearingDate!)
        : 'None Scheduled';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'LAWYER\'S E-DIARY',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#13382E'),
                    ),
                  ),
                  pw.Text(
                    'CONFIDENTIAL LEGAL DOSSIER',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#888888'),
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#13382E')),
              pw.SizedBox(height: 12),

              // Title & Number
              pw.Text(
                caseItem.caseTitle,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1A1A1A'),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'CNR / Case Number: ${caseItem.caseNumber}',
                style: pw.TextStyle(fontSize: 12, color: PdfColor.fromHex('#555555')),
              ),
              pw.SizedBox(height: 16),

              // Details Grid
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F7F5F2'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _pdfRow('Case Type', caseItem.caseType),
                    _pdfRow('Current Status', caseItem.status.toUpperCase()),
                    _pdfRow('Client', caseItem.clientName),
                    _pdfRow(
                      'Opponent',
                      caseItem.opponentName.isEmpty ? 'N/A' : caseItem.opponentName,
                    ),
                    _pdfRow('Court / Forum', caseItem.courtName),
                    _pdfRow('Next Hearing Date', hearingText),
                    _pdfRow('Assigned Counsel', caseItem.handledBy),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),

              // Notes Section
              pw.Text(
                'Case Notes & Observations',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              if (caseItem.notes.isEmpty)
                pw.Text(
                  'No docket notes entered.',
                  style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
                )
              else
                ...caseItem.notes.map(
                  (note) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text('• $note', style: const pw.TextStyle(fontSize: 11)),
                  ),
                ),

              pw.Spacer(),
              pw.Divider(color: PdfColor.fromHex('#CCCCCC')),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated on ${CalendarDateHelper.formatDateDigits(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                  ),
                  pw.Text(
                    'Lawyer\'s E-Diary System',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Case_${caseItem.caseNumber.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Prints multiple selected cases summary report.
  static Future<void> printMultipleCases({
    required BuildContext context,
    required List<CaseModel> cases,
    String title = 'Cause List Report',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#13382E'),
                  ),
                ),
                pw.Text(
                  'Total: ${cases.length}',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#13382E')),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Case Title', 'Number', 'Type', 'Court', 'Hearing Date'],
              data: cases.map((c) {
                final d = c.nextHearingDate != null
                    ? CalendarDateHelper.formatDateDigits(c.nextHearingDate!)
                    : '-';
                return [c.caseTitle, c.caseNumber, c.caseType, c.courtName, d];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F7F5F2')),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Cause_List_Report.pdf',
    );
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#555555'),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
