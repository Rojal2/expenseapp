import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'analytics_dashboard.dart';

Future<void> exportCurrentReport(AnalyticsDashboard view) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) =>
          pw.Center(child: pw.Text('Exported Report for $view')),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
