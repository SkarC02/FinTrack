import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../ingresos/models/ingreso_model.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  DateTime _desde = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _hasta = DateTime.now();
  bool _isLoading = false;

  static const List<String> _opcionesReporte = [
    'Ingresos por tipo',
    'Ingresos por aportador',
    'Ingresos generales',
    'Gastos generales por mes',
    'Gastos por tipo'
  ];

  String _reporteSeleccionado = _opcionesReporte[0];
  List<String> _headers = [];
  List<List<String>> _dataRows = [];
  double _totalGeneral = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    _totalGeneral = 0;
    _dataRows = [];

    try {
      final inicio = Timestamp.fromDate(_desde);
      final fin = Timestamp.fromDate(_hasta.add(const Duration(days: 1)));

      if (_reporteSeleccionado == 'Ingresos por tipo') {
        _headers = ['Fecha', 'Tipo', 'Cantidad'];
        final snap = await FirebaseFirestore.instance
            .collection('ingresos')
            .where('fecha', isGreaterThanOrEqualTo: inicio)
            .where('fecha', isLessThanOrEqualTo: fin)
            .get();

        final docs =
            snap.docs.map((d) => IngresoModel.fromFirestore(d)).toList();
        docs.sort((a, b) => b.fecha.compareTo(a.fecha));

        for (var i in docs) {
          _dataRows.add([
            SICDateUtils.format(i.fecha),
            i.tipo.label,
            CurrencyUtils.format(i.monto)
          ]);
          _totalGeneral += i.monto;
        }
      } else if (_reporteSeleccionado == 'Ingresos por aportador') {
        _headers = ['Fecha', 'Aportador', 'Cantidad'];
        final snap = await FirebaseFirestore.instance
            .collection('ingresos')
            .where('fecha', isGreaterThanOrEqualTo: inicio)
            .where('fecha', isLessThanOrEqualTo: fin)
            .get();

        for (var doc in snap.docs) {
          final m = doc.data();
          final monto = (m['monto'] as num).toDouble();
          _dataRows.add([
            SICDateUtils.format((m['fecha'] as Timestamp).toDate()),
            m['memberName'] ?? 'Anónimo',
            CurrencyUtils.format(monto)
          ]);
          _totalGeneral += monto;
        }
      }

      // 3. REPORTE: Ingresos generales (Ingreso por día del mes)
      else if (_reporteSeleccionado == 'Ingresos generales') {
        _headers = ['Día / Fecha', 'Total del Día'];
        final snap = await FirebaseFirestore.instance
            .collection('ingresos')
            .where('fecha', isGreaterThanOrEqualTo: inicio)
            .where('fecha', isLessThanOrEqualTo: fin)
            .get();

        Map<String, double> porDia = {};
        for (var doc in snap.docs) {
          final fecha = (doc.data()['fecha'] as Timestamp).toDate();
          final diaKey = SICDateUtils.format(fecha);
          porDia[diaKey] =
              (porDia[diaKey] ?? 0) + (doc.data()['monto'] as num).toDouble();
        }

        porDia.forEach((dia, total) {
          _dataRows.add([dia, CurrencyUtils.format(total)]);
          _totalGeneral += total;
        });
      }

      // 4. REPORTE: Gastos (Simulados hasta que tengas la colección 'gastos')
      else if (_reporteSeleccionado == 'Gastos por tipo') {
        _headers = ['Tipo de Gasto', 'Monto'];
        _dataRows = [
          ['Mantenimiento', 'L. 0.00'],
          ['Servicios', 'L. 0.00'],
          ['Actividades', 'L. 0.00'],
        ];
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- NUEVA FUNCIÓN PARA IMPRIMIR Y PDF ---
  Future<void> _imprimirReporte() async {
    if (_dataRows.isEmpty) return;

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(_reporteSeleccionado.toUpperCase(),
                      style: pw.TextStyle(font: fontBold, fontSize: 18)),
                  pw.Text(SICDateUtils.format(DateTime.now()),
                      style: pw.TextStyle(font: font, fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
                'Periodo: ${SICDateUtils.format(_desde)} al ${SICDateUtils.format(_hasta)}',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: _headers,
              data: _dataRows,
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellStyle: pw.TextStyle(font: font, fontSize: 10),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'TOTAL: ${CurrencyUtils.format(_totalGeneral)}',
                style: pw.TextStyle(font: fontBold, fontSize: 14),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Reporte_${_reporteSeleccionado}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.dark,
        title: const Text('Reportes Generales',
            style:
                TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: AppColors.white),
            onPressed: _imprimirReporte,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSelector(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold))
                : _buildTabla(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSelector() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            dropdownColor: const Color.fromARGB(255, 136, 129, 116),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Seleccione el Reporte',
              filled: true,
              fillColor: const Color.fromARGB(255, 122, 101, 58),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _opcionesReporte
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _reporteSeleccionado = v);
                _cargarDatos();
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _dateBtn(
                      "Desde", _desde, (d) => setState(() => _desde = d))),
              const SizedBox(width: 8),
              Expanded(
                  child: _dateBtn(
                      "Hasta", _hasta, (d) => setState(() => _hasta = d))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateBtn(String label, DateTime date, Function(DateTime) onSelect) {
    return OutlinedButton(
      onPressed: () async {
        final d = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2024),
            lastDate: DateTime.now());
        if (d != null) {
          onSelect(d);
          _cargarDatos();
        }
      },
      child: Text("$label: ${SICDateUtils.format(date)}",
          style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
    );
  }

  Widget _buildTabla() {
    if (_dataRows.isEmpty)
      return const Center(
          child: Text("No se encontraron registros en este periodo"));

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.dark,
          child: Row(
              children: _headers
                  .map((h) => Expanded(
                      child: Text(h,
                          style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))))
                  .toList()),
        ),
        ..._dataRows.map((row) => Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.borderLight, width: 0.5))),
              child: Row(
                  children: row
                      .map((cell) => Expanded(
                          child:
                              Text(cell, style: const TextStyle(fontSize: 12))))
                      .toList()),
            )),
        _buildTotalUI(),
      ],
    );
  }

  Widget _buildTotalUI() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFFFFBF0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('TOTAL DEL PERIODO',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.goldDim)),
          Text(CurrencyUtils.format(_totalGeneral),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}
