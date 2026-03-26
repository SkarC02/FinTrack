// ═══════════════════════════════════════════════════════════════════════════
//  lib/features/ingresos/screens/ingreso_form_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ingreso_model.dart';
import '../services/ingreso_service.dart';

class IngresoFormScreen extends StatefulWidget {
  final String? ingresoId; // null = nuevo, con valor = editar

  const IngresoFormScreen({super.key, this.ingresoId});

  @override
  State<IngresoFormScreen> createState() => _IngresoFormScreenState();
}

class _IngresoFormScreenState extends State<IngresoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _buscarCtrl = TextEditingController();

  TipoIngreso _tipo = TipoIngreso.ofrenda;
  MetodoPago _metodo = MetodoPago.efectivo;
  DateTime _fecha = DateTime.now();
  bool _loading = false;
  bool _cargandoIngreso = false;

  // Miembro seleccionado
  String _memberId = '';
  String _memberName = '';

  // Lista de miembros buscados
  List<Map<String, dynamic>> _miembros = [];
  bool _buscando = false;
  bool _mostrarLista = false;

  bool get _esEdicion => widget.ingresoId != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) _cargarIngresoDesdeFirestore();
  }

  Future<void> _cargarIngresoDesdeFirestore() async {
    setState(() => _cargandoIngreso = true);
    try {
      final ingreso =
          await IngresoService.instance.obtenerPorId(widget.ingresoId!);
      if (ingreso != null && mounted) {
        _montoCtrl.text = ingreso.monto.toStringAsFixed(2);
        _notasCtrl.text = ingreso.notas;
        _buscarCtrl.text = ingreso.memberName;
        setState(() {
          _tipo = ingreso.tipo;
          _metodo = ingreso.metodo;
          _fecha = ingreso.fecha;
          _memberId = ingreso.memberId;
          _memberName = ingreso.memberName;
        });
      }
    } catch (e) {
      if (mounted) _mostrarError('Error al cargar el ingreso: $e');
    } finally {
      if (mounted) setState(() => _cargandoIngreso = false);
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _notasCtrl.dispose();
    _buscarCtrl.dispose();
    super.dispose();
  }

  // ── Buscar miembros en Firestore ─────────────────────────────
  Future<void> _buscarMiembros(String query) async {
    if (query.isEmpty) {
      setState(() {
        _miembros = [];
        _mostrarLista = false;
      });
      return;
    }
    setState(() => _buscando = true);
    try {
      // Traemos todos los activos y filtramos localmente
      // (evita necesidad de índice compuesto en Firestore)
      final snap = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('activo', isEqualTo: true)
          .limit(50)
          .get();

      final queryLower = query.toLowerCase();
      final resultados = snap.docs
          .where((d) {
            final nombre =
                (d.data()['nombreCompleto'] ?? '').toString().toLowerCase();
            final codigo =
                (d.data()['codigoSobre'] ?? '').toString().toLowerCase();
            return nombre.contains(queryLower) || codigo.contains(queryLower);
          })
          .take(8)
          .map((d) => {
                'id': d.id,
                'nombre': d.data()['nombreCompleto'] ?? '',
                'codigo': d.data()['codigoSobre'] ?? '',
              })
          .toList();

      setState(() {
        _miembros = resultados;
        _mostrarLista = resultados.isNotEmpty;
      });
    } catch (_) {
      setState(() => _miembros = []);
    } finally {
      setState(() => _buscando = false);
    }
  }

  void _seleccionarMiembro(Map<String, dynamic> m) {
    setState(() {
      _memberId = m['id'];
      _memberName = m['nombre'];
      _buscarCtrl.text = '${m['nombre']} (${m['codigo']})';
      _mostrarLista = false;
    });
  }

  // ── Selector de fecha ────────────────────────────────────────
  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  // ── Guardar ──────────────────────────────────────────────────
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_memberId.isEmpty) {
      _mostrarError('Debes seleccionar un miembro de la lista');
      return;
    }

    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final monto = double.parse(_montoCtrl.text.replaceAll(',', '.'));

      final ingreso = IngresoModel(
        id: _esEdicion ? widget.ingresoId! : '',
        tipo: _tipo,
        monto: monto,
        memberId: _memberId,
        memberName: _memberName,
        fecha: _fecha,
        metodo: _metodo,
        notas: _notasCtrl.text.trim(),
        registradoPor: uid,
      );

      if (_esEdicion) {
        await IngresoService.instance.actualizar(ingreso);
      } else {
        await IngresoService.instance.crear(ingreso);
      }

      if (mounted) {
        _mostrarExito(_esEdicion
            ? 'Ingreso actualizado correctamente'
            : 'Ingreso registrado correctamente');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _mostrarError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mostrarExito(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(msg),
      ]),
      backgroundColor: Colors.green.shade700,
    ));
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: Colors.red.shade700,
    ));
  }

  // ── UI ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Ingreso' : 'Nuevo Ingreso'),
        centerTitle: true,
        actions: [
          if (_esEdicion)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.shade300,
              onPressed: _confirmarEliminar,
            ),
        ],
      ),
      body: _cargandoIngreso
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                setState(() => _mostrarLista = false);
              },
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Monto ────────────────────────────────────────
                    _SectionLabel(label: 'MONTO (L)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _montoCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        prefixText: 'L ',
                        prefixStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa el monto';
                        final n = double.tryParse(v.replaceAll(',', '.'));
                        if (n == null || n <= 0)
                          return 'El monto debe ser mayor a 0';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Tipo de ingreso ──────────────────────────────
                    _SectionLabel(label: 'TIPO DE INGRESO'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TipoIngreso.values.map((tipo) {
                        final sel = _tipo == tipo;
                        return GestureDetector(
                          onTap: () => setState(() => _tipo = tipo),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? cs.primary : cs.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? cs.primary
                                    : cs.outline.withOpacity(0.3),
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              tipo.label,
                              style: TextStyle(
                                color: sel ? cs.onPrimary : cs.onSurface,
                                fontWeight:
                                    sel ? FontWeight.w700 : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ── Miembro ──────────────────────────────────────
                    _SectionLabel(label: 'MIEMBRO'),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _buscarCtrl,
                          onChanged: _buscarMiembros,
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre o código...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _buscando
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ))
                                : _memberId.isNotEmpty
                                    ? Icon(Icons.check_circle,
                                        color: Colors.green.shade400)
                                    : null,
                          ),
                          validator: (_) => _memberId.isEmpty
                              ? 'Selecciona un miembro'
                              : null,
                        ),
                        if (_mostrarLista)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.primary.withOpacity(0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    _miembros.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final m = entry.value;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (i > 0)
                                        Divider(
                                          height: 1,
                                          color: cs.primary.withOpacity(0.15),
                                        ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _seleccionarMiembro(m),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: cs.primary
                                                      .withOpacity(0.2),
                                                  child: Text(
                                                    (m['nombre'] as String)
                                                            .isNotEmpty
                                                        ? (m['nombre']
                                                                as String)[0]
                                                            .toUpperCase()
                                                        : '?',
                                                    style: TextStyle(
                                                      color: cs.primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        m['nombre'],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: cs.onSurface,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Código: ${m['codigo']}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: cs.onSurface
                                                              .withOpacity(
                                                                  0.55),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(Icons.chevron_right,
                                                    size: 16,
                                                    color: cs.primary
                                                        .withOpacity(0.5)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Método de pago ───────────────────────────────
                    _SectionLabel(label: 'MÉTODO DE PAGO'),
                    const SizedBox(height: 10),
                    Row(
                      children: MetodoPago.values.map((m) {
                        final sel = _metodo == m;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _metodo = m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: sel
                                    ? cs.primary.withOpacity(0.15)
                                    : cs.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel
                                      ? cs.primary
                                      : cs.outline.withOpacity(0.3),
                                  width: sel ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _iconMetodo(m),
                                    color: sel
                                        ? cs.primary
                                        : cs.onSurface.withOpacity(0.5),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: sel
                                          ? cs.primary
                                          : cs.onSurface.withOpacity(0.6),
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ── Fecha ────────────────────────────────────────
                    _SectionLabel(label: 'FECHA'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _seleccionarFecha,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: theme.inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                              color: cs.outline.withOpacity(0.3), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: cs.primary, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              '${_fecha.day.toString().padLeft(2, '0')}/'
                              '${_fecha.month.toString().padLeft(2, '0')}/'
                              '${_fecha.year}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right,
                                color: cs.onSurface.withOpacity(0.4)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Notas ────────────────────────────────────────
                    _SectionLabel(label: 'NOTAS (OPCIONAL)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notasCtrl,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        hintText: 'Observaciones adicionales...',
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Botón guardar ────────────────────────────────
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _guardar,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_outlined),
                        label: Text(
                            _esEdicion ? 'Actualizar' : 'Registrar Ingreso'),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  IconData _iconMetodo(MetodoPago m) {
    switch (m) {
      case MetodoPago.efectivo:
        return Icons.payments_outlined;
      case MetodoPago.transferencia:
        return Icons.account_balance_outlined;
      case MetodoPago.cheque:
        return Icons.receipt_outlined;
    }
  }

  Future<void> _confirmarEliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este ingreso? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await IngresoService.instance.eliminar(widget.ingresoId!);
      if (mounted) Navigator.pop(context, true);
    }
  }
}

// ── Widget auxiliar: etiqueta de sección ─────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.5,
      ),
    );
  }
}
