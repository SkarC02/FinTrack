// ═══════════════════════════════════════════════════════════════════════════
//  lib/features/gastos/screens/gasto_form_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../auth/services/auth_service.dart';
import '../models/gasto_model.dart';
import '../services/gasto_service.dart';

class GastoFormScreen extends ConsumerStatefulWidget {
  final String? gastoId;

  const GastoFormScreen({super.key, this.gastoId});

  @override
  ConsumerState<GastoFormScreen> createState() => _GastoFormScreenState();
}

class _GastoFormScreenState extends ConsumerState<GastoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripCtrl = TextEditingController();
  final _proveedorCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _aprobadoCtrl = TextEditingController();
  final _facturaCtrl = TextEditingController();

  String _categoria = AppConstants.catServicios;
  String _metodoPago = AppConstants.pagoEfectivo;
  String _estado = 'pagado';
  DateTime _fecha = DateTime.now();
  bool _loading = false;

  bool get _isEditing => widget.gastoId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _cargarGasto();
    }
  }

  Future<void> _cargarGasto() async {
    setState(() => _loading = true);

    try {
      final gasto =
          await ref.read(gastoServiceProvider).obtenerPorId(widget.gastoId!);

      if (gasto != null && mounted) {
        setState(() {
          _categoria = gasto.categoria;
          _metodoPago = gasto.metodoPago;
          _estado = gasto.estado;
          _fecha = gasto.fecha;
          _descripCtrl.text = gasto.descripcion;
          _proveedorCtrl.text = gasto.proveedor;
          _montoCtrl.text = gasto.monto.toStringAsFixed(2);
          _aprobadoCtrl.text = gasto.aprobadoPor;
          _facturaCtrl.text = gasto.numeroFactura;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar gasto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final uid = ref.read(authServiceProvider).currentUid ?? '';
      final monto = CurrencyUtils.parse(_montoCtrl.text) ?? 0.0;

      final gasto = GastoModel(
        id: widget.gastoId ?? '',
        monto: monto,
        descripcion: _descripCtrl.text.trim(),
        categoria: _categoria,
        proveedor: _proveedorCtrl.text.trim(),
        fecha: _fecha,
        metodoPago: _metodoPago,
        estado: _estado,
        aprobadoPor: _aprobadoCtrl.text.trim(),
        numeroFactura: _facturaCtrl.text.trim(),
        createdBy: uid,
      );

      if (_isEditing) {
        await ref.read(gastoServiceProvider).actualizar(widget.gastoId!, gasto);
      } else {
        await ref.read(gastoServiceProvider).crear(gasto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Gasto ${_isEditing ? 'actualizado' : 'registrado'} correctamente',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _descripCtrl.dispose();
    _proveedorCtrl.dispose();
    _montoCtrl.dispose();
    _aprobadoCtrl.dispose();
    _facturaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: Text(
          _isEditing ? 'Editar Gasto' : 'Registrar Gasto',
          style: const TextStyle(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _lbl('CATEGORÍA'),
                  _buildCategoriaSelector(),
                  const SizedBox(height: 16),

                  _lbl('DESCRIPCIÓN'),
                  TextFormField(
                    controller: _descripCtrl,
                    validator: (v) =>
                        Validators.required(v, fieldName: 'Descripción'),
                    decoration: const InputDecoration(
                      hintText: '¿En qué se gastó?',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _lbl('PROVEEDOR'),
                  TextFormField(
                    controller: _proveedorCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nombre del proveedor',
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _lbl('MONTO (L.)'),
                  TextFormField(
                    controller: _montoCtrl,
                    validator: Validators.monto,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                      prefixText: 'L. ',
                    ),
                  ),
                  const SizedBox(height: 14),

                  _lbl('FECHA'),
                  _buildDatePicker(),
                  const SizedBox(height: 14),

                  _lbl('MÉTODO DE PAGO'),
                  _buildMetodoPago(),
                  const SizedBox(height: 14),

                  _lbl('ESTADO'),
                  _buildEstadoSelector(),
                  const SizedBox(height: 14),

                  _lbl('APROBADO POR'),
                  TextFormField(
                    controller: _aprobadoCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Pastor / Diácono / Junta',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _lbl('Nº FACTURA / RECIBO'),
                  TextFormField(
                    controller: _facturaCtrl,
                    decoration: const InputDecoration(
                      hintText: '000-000-0000',
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                    ),
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: _loading ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: Text(
                      _isEditing ? 'Actualizar Gasto' : 'Guardar Gasto',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _lbl(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: AppTextStyles.sectionLabel),
    );
  }

  Widget _buildCategoriaSelector() {
    final cats = [
      (AppConstants.catServicios, '⚡', 'Servicios'),
      (AppConstants.catMantenimiento, '🔧', 'Mantenimiento'),
      (AppConstants.catActividades, '🎵', 'Actividades'),
      (AppConstants.catPersonal, '👤', 'Personal'),
      (AppConstants.catMisiones, '✈️', 'Misiones'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cats.map((c) {
        final isSel = _categoria == c.$1;
        return GestureDetector(
          onTap: () => setState(() => _categoria = c.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSel
                  ? AppColors.redLight.withOpacity(0.1)
                  : AppColors.white,
              border: Border.all(
                color: isSel ? AppColors.redLight : AppColors.borderLight,
                width: isSel ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.$2, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  c.$3,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSel ? AppColors.red : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final p = await showDatePicker(
          context: context,
          initialDate: _fecha,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.gold),
            ),
            child: child!,
          ),
        );

        if (p != null) {
          setState(() => _fecha = p);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.dark3,
          border: Border.all(color: AppColors.borderDark, width: 1.5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.goldDim,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              SICDateUtils.formatLong(_fecha),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodoPago() {
    const metodos = [
      (AppConstants.pagoEfectivo, Icons.payments_outlined, 'Efectivo'),
      (
        AppConstants.pagoTransferencia,
        Icons.swap_horiz_rounded,
        'Transferencia',
      ),
      (AppConstants.pagoCheque, Icons.receipt_outlined, 'Cheque'),
    ];

    return Row(
      children: metodos.map((m) {
        final isSel = _metodoPago == m.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _metodoPago = m.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: m.$1 != AppConstants.pagoCheque ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSel
                    ? AppColors.gold.withOpacity(0.1)
                    : AppColors.dark3,
                border: Border.all(
                  color: isSel ? AppColors.gold : AppColors.borderDark,
                  width: isSel ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    m.$2,
                    color: isSel ? AppColors.gold : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.$3,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSel
                          ? AppColors.goldDim
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEstadoSelector() {
    return Row(
      children: ['pagado', 'pendiente'].map((e) {
        final isSel = _estado == e;
        final color = e == 'pagado' ? AppColors.greenLight : AppColors.orange;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _estado = e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: e == 'pagado' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? color.withOpacity(0.1) : AppColors.dark3,
                border: Border.all(
                  color: isSel ? color : AppColors.borderDark,
                  width: isSel ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                e[0].toUpperCase() + e.substring(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSel ? color : AppColors.textMutedLight,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}