import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/ingreso_model.dart';
import '../services/ingreso_service.dart';
import '../../../core/constants/app_routes.dart';

class HistorialIngresosScreen extends StatefulWidget {
  const HistorialIngresosScreen({super.key});

  @override
  State<HistorialIngresosScreen> createState() =>
      _HistorialIngresosScreenState();
}

class _HistorialIngresosScreenState extends State<HistorialIngresosScreen> {
  TipoIngreso? _tipoFiltro;
  DateTime? _desde;
  DateTime? _hasta;
  String _busqueda = '';

  final _fmt = NumberFormat('#,##0.00');
  final _fmtFecha = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ingresos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
            tooltip: 'Filtros',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('${AppRoutes.ingresos}/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _busqueda = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Buscar por miembro...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          if (_tipoFiltro != null || _desde != null || _hasta != null)
            _FiltrosActivos(
              tipo: _tipoFiltro,
              desde: _desde,
              hasta: _hasta,
              onClear: _limpiarFiltros,
            ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<List<IngresoModel>>(
              stream: _buildStream(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                      child: Text('Error: ${snap.error}',
                          style: TextStyle(color: cs.error)));
                }

                final todos = snap.data ?? [];
                final lista = _busqueda.isEmpty
                    ? todos
                    : todos
                        .where((i) =>
                            i.memberName.toLowerCase().contains(_busqueda))
                        .toList();

                if (lista.isEmpty) {
                  return _EmptyState(tipoFiltro: _tipoFiltro);
                }

                final total = lista.fold(0.0, (s, i) => s + i.monto);

                return Column(
                  children: [
                    // Resumen total
                    _ResumenBanner(total: total, cantidad: lista.length),

                    // Lista
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: lista.length,
                        itemBuilder: (ctx, i) => _IngresoTile(
                          ingreso: lista[i],
                          fmtMonto: _fmt,
                          fmtFecha: _fmtFecha,
                          onTap: () => _abrirDetalle(lista[i]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<IngresoModel>> _buildStream() {
    if (_desde != null && _hasta != null) {
      return IngresoService.instance.streamPorRango(_desde!, _hasta!);
    }
    if (_tipoFiltro != null) {
      return IngresoService.instance.streamPorTipo(_tipoFiltro!);
    }
    final now = DateTime.now();
    return IngresoService.instance.streamPorMes(now.year, now.month);
  }

  Future<void> _mostrarFiltros() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FiltrosSheet(
        tipoInicial: _tipoFiltro,
        desdeInicial: _desde,
        hastaInicial: _hasta,
        onAplicar: (tipo, desde, hasta) {
          setState(() {
            _tipoFiltro = tipo;
            _desde = desde;
            _hasta = hasta;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _tipoFiltro = null;
      _desde = null;
      _hasta = null;
    });
  }

  void _abrirDetalle(IngresoModel ingreso) {
    context.go('${AppRoutes.ingresos}/editar/${ingreso.id}');
  }
}

class _IngresoTile extends StatelessWidget {
  final IngresoModel ingreso;
  final NumberFormat fmtMonto;
  final DateFormat fmtFecha;
  final VoidCallback onTap;

  const _IngresoTile({
    required this.ingreso,
    required this.fmtMonto,
    required this.fmtFecha,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: _colorTipo(ingreso.tipo).withOpacity(0.15),
          child: Text(
            ingreso.memberName.isNotEmpty
                ? ingreso.memberName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: _colorTipo(ingreso.tipo),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                ingreso.memberName.isEmpty ? 'Sin nombre' : ingreso.memberName,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'L ${fmtMonto.format(ingreso.monto)}',
              style: TextStyle(
                color: cs.secondary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            _TipoBadge(tipo: ingreso.tipo),
            const SizedBox(width: 8),
            Text(
              fmtFecha.format(ingreso.fecha),
              style:
                  TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.5)),
            ),
            const Spacer(),
            Icon(_iconMetodo(ingreso.metodo),
                size: 14, color: cs.onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Color _colorTipo(TipoIngreso t) {
    switch (t) {
      case TipoIngreso.diezmo:
        return Colors.green;
      case TipoIngreso.ofrenda:
        return Colors.blue;
      case TipoIngreso.donacion:
        return Colors.purple;
      case TipoIngreso.primicia:
        return Colors.orange;
      case TipoIngreso.misiones:
        return Colors.teal;
    }
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
}

class _TipoBadge extends StatelessWidget {
  final TipoIngreso tipo;
  const _TipoBadge({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        tipo.label,
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _color() {
    switch (tipo) {
      case TipoIngreso.diezmo:
        return Colors.green;
      case TipoIngreso.ofrenda:
        return Colors.blue;
      case TipoIngreso.donacion:
        return Colors.purple;
      case TipoIngreso.primicia:
        return Colors.orange;
      case TipoIngreso.misiones:
        return Colors.teal;
    }
  }
}

class _ResumenBanner extends StatelessWidget {
  final double total;
  final int cantidad;
  const _ResumenBanner({required this.total, required this.cantidad});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = NumberFormat('#,##0.00');
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: cs.primary, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total del período',
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurface.withOpacity(0.6))),
              Text('L ${fmt.format(total)}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.primary)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$cantidad registros',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltrosActivos extends StatelessWidget {
  final TipoIngreso? tipo;
  final DateTime? desde;
  final DateTime? hasta;
  final VoidCallback onClear;

  const _FiltrosActivos({
    this.tipo,
    this.desde,
    this.hasta,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yy');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 14),
          const SizedBox(width: 6),
          if (tipo != null) _Chip(label: tipo!.label),
          if (desde != null && hasta != null)
            _Chip(label: '${fmt.format(desde!)} - ${fmt.format(hasta!)}'),
          const Spacer(),
          GestureDetector(
            onTap: onClear,
            child: Text('Limpiar',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: cs.primary, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TipoIngreso? tipoFiltro;
  const _EmptyState({this.tipoFiltro});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            tipoFiltro != null
                ? 'Sin ${tipoFiltro!.label.toLowerCase()}s registrados'
                : 'Sin ingresos este mes',
            style: TextStyle(
                fontSize: 15,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          Text('Presiona + para agregar uno',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.35))),
        ],
      ),
    );
  }
}

class _FiltrosSheet extends StatefulWidget {
  final TipoIngreso? tipoInicial;
  final DateTime? desdeInicial;
  final DateTime? hastaInicial;
  final Function(TipoIngreso?, DateTime?, DateTime?) onAplicar;

  const _FiltrosSheet({
    this.tipoInicial,
    this.desdeInicial,
    this.hastaInicial,
    required this.onAplicar,
  });

  @override
  State<_FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<_FiltrosSheet> {
  TipoIngreso? _tipo;
  DateTime? _desde;
  DateTime? _hasta;
  final _fmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial;
    _desde = widget.desdeInicial;
    _hasta = widget.hastaInicial;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('Filtrar por tipo',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  letterSpacing: 1.2)),
          const SizedBox(height: 10),

          // Tipo chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FiltroChip(
                label: 'Todos',
                selected: _tipo == null,
                onTap: () => setState(() => _tipo = null),
              ),
              ...TipoIngreso.values.map((t) => _FiltroChip(
                    label: t.label,
                    selected: _tipo == t,
                    onTap: () => setState(() => _tipo = t),
                  )),
            ],
          ),

          const SizedBox(height: 24),
          Text('Rango de fechas',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  letterSpacing: 1.2)),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: _desde != null ? _fmt.format(_desde!) : 'Desde',
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: _hasta != null ? _fmt.format(_hasta!) : 'Hasta',
                  onTap: () => _pickDate(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => widget.onAplicar(_tipo, _desde, _hasta),
              child: const Text('Aplicar filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool esDesde) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          esDesde ? (_desde ?? DateTime.now()) : (_hasta ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (esDesde)
          _desde = picked;
        else
          _hasta = picked;
      });
    }
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FiltroChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : cs.outline.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? cs.onPrimary : cs.onSurface,
            )),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: cs.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
