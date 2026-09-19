import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jornada.dart';

class DonarScreen extends ConsumerStatefulWidget {
  final Jornada? jornada;

  const DonarScreen({super.key, this.jornada});

  @override
  ConsumerState<DonarScreen> createState() => _DonarScreenState();
}

class _DonarScreenState extends ConsumerState<DonarScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Dinero form controllers & state
  final _montoController = TextEditingController();
  String _metodoPago = 'tarjeta';
  bool _isLoading = false;
  double _montoSeleccionado = 10.0;
  final List<double> _montosRapidos = [5.0, 10.0, 25.0, 50.0, 100.0];

  // Artículo form controllers & state
  final _descripcionArticuloController = TextEditingController();
  final _cantidadArticuloController = TextEditingController(text: '1');
  String? _articuloSeleccionadoSugerido;

  @override
  void initState() {
    super.initState();
    _montoController.text = _montoSeleccionado.toStringAsFixed(0);

    final j = widget.jornada;
    bool hasDinero = j == null || j.aceptaDonacionesDinero;
    bool hasArticulos = j != null && j.aceptaDonacionesArticulos;

    if (hasDinero && hasArticulos) {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionArticuloController.dispose();
    _cantidadArticuloController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _procesarDonacionDinero() async {
    final montoText = _montoController.text.trim();
    if (montoText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido')),
      );
      return;
    }

    final monto = double.tryParse(montoText);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto debe ser mayor a 0')),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para donar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // -------------------------------------------------------------
      // TODO: INTEGRACIÓN DE PASARELA DE PAGO (Stripe / PayPal / SDK Bancario)
      // Aquí se debe invocar el SDK de Stripe, PayPal o pasarela bancaria
      // para procesar el cobro real antes de registrar la transacción.
      // Ejemplo:
      // final paymentResult = await StripePaymentService.pay(monto);
      // if (!paymentResult.success) throw 'Pago rechazado';
      // -------------------------------------------------------------

      final supabase = Supabase.instance.client;
      await supabase.from('donaciones').insert({
        'donante_id': user.id,
        if (widget.jornada != null) 'jornada_id': widget.jornada!.id,
        'tipo': 'dinero',
        'monto': monto,
        'estado': 'pendiente',
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text('¡Donación Registrada!'),
              ],
            ),
            content: Text(
              'Tu intención de donación quedó registrada. Te contactaremos para coordinar el pago.${widget.jornada != null ? '\nApoyando a la jornada: ${widget.jornada!.titulo}' : ''}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Aceptar', style: TextStyle(color: Color(0xFF2E7D32))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar donación: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _procesarDonacionArticulo() async {
    final descripcion = _articuloSeleccionadoSugerido ?? _descripcionArticuloController.text.trim();
    if (descripcion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor especifica el artículo que deseas donar')),
      );
      return;
    }

    final cantidad = int.tryParse(_cantidadArticuloController.text.trim()) ?? 1;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para donar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('donaciones').insert({
        'donante_id': user.id,
        if (widget.jornada != null) 'jornada_id': widget.jornada!.id,
        'tipo': 'articulo',
        'articulo_descripcion': descripcion,
        'cantidad': cantidad,
        'estado': 'pendiente',
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.inventory_2, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text('¡Aporte Registrado!'),
              ],
            ),
            content: Text(
              '¡Gracias por tu aporte de artículo! Tu donación de $cantidad x "$descripcion" ha sido registrada con éxito.${widget.jornada != null ? '\nPara la jornada: ${widget.jornada!.titulo}' : ''}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Aceptar', style: TextStyle(color: Color(0xFF2E7D32))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar aporte: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.jornada;
    bool aceptaDinero = j == null || j.aceptaDonacionesDinero;
    bool aceptaArticulos = j != null && j.aceptaDonacionesArticulos;

    return Scaffold(
      appBar: AppBar(
        title: Text(j != null ? 'Apoyar Jornada' : 'Hacer Donación'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        bottom: (aceptaDinero && aceptaArticulos && _tabController != null)
            ? TabBar(
                controller: _tabController!,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Donar Dinero', icon: Icon(Icons.attach_money, size: 20)),
                  Tab(text: 'Donar Artículo', icon: Icon(Icons.inventory_2, size: 20)),
                ],
              )
            : null,
      ),
      body: (aceptaDinero && aceptaArticulos && _tabController != null)
          ? TabBarView(
              controller: _tabController!,
              children: [
                _buildDineroView(),
                _buildArticuloView(),
              ],
            )
          : (aceptaArticulos && !aceptaDinero)
              ? _buildArticuloView()
              : _buildDineroView(),
    );
  }

  Widget _buildDineroView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.jornada != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.jornada!.titulo,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                    if (widget.jornada!.metaDonacionDinero != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Meta de donación: \$${widget.jornada!.metaDonacionDinero!.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Selecciona o ingresa el monto a donar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _montosRapidos.map((monto) {
              final isSelected = _montoSeleccionado == monto;
              return ChoiceChip(
                label: Text('\$$monto'),
                selected: isSelected,
                selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _montoSeleccionado = monto;
                      _montoController.text = monto.toStringAsFixed(0);
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _montoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Monto personalizado (\$)',
              prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF2E7D32)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onChanged: (val) {
              final valNum = double.tryParse(val);
              if (valNum != null) {
                setState(() => _montoSeleccionado = valNum);
              }
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Método de pago',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _metodoPago,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta de Crédito / Débito (Stripe)')),
              DropdownMenuItem(value: 'transferencia', child: Text('Transferencia Bancaria')),
              DropdownMenuItem(value: 'qr', child: Text('Billetera Digital (Yape / Plin / PayPal)')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _metodoPago = val);
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _procesarDonacionDinero,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Confirmar Donación',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticuloView() {
    final solicitudItems = widget.jornada?.articulosSolicitados ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.jornada != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.jornada!.titulo,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Artículos solicitados por el organizador:',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (solicitudItems.isNotEmpty) ...[
            const Text(
              'Selecciona un artículo solicitado:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: solicitudItems.map((item) {
                final isSelected = _articuloSeleccionadoSugerido == item;
                return ChoiceChip(
                  label: Text(item),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _articuloSeleccionadoSugerido = selected ? item : null;
                      if (selected) _descripcionArticuloController.clear();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'O describe el artículo que deseas aportar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcionArticuloController,
            decoration: InputDecoration(
              labelText: 'Descripción del artículo (ej. 2 pares de guantes)',
              prefixIcon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF2E7D32)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onChanged: (val) {
              if (val.trim().isNotEmpty && _articuloSeleccionadoSugerido != null) {
                setState(() => _articuloSeleccionadoSugerido = null);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cantidadArticuloController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cantidad',
              prefixIcon: const Icon(Icons.numbers, color: Color(0xFF2E7D32)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _procesarDonacionArticulo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Confirmar Aporte de Artículo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

final donacionesJornadaProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, jornadaId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('donaciones')
      .select()
      .eq('jornada_id', jornadaId);
  return List<Map<String, dynamic>>.from(response);
});

class DonacionesResumenWidget extends ConsumerWidget {
  final String jornadaId;
  const DonacionesResumenWidget({super.key, required this.jornadaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donacionesAsync = ref.watch(donacionesJornadaProvider(jornadaId));

    return donacionesAsync.when(
      data: (donaciones) {
        double totalDinero = 0;
        int countDinero = 0;
        List<Map<String, dynamic>> articulosDonados = [];

        for (var d in donaciones) {
          if (d['tipo'] == 'dinero') {
            totalDinero += (d['monto'] as num?)?.toDouble() ?? 0.0;
            countDinero++;
          } else if (d['tipo'] == 'articulo') {
            articulosDonados.add(d);
          }
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.pink.shade50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.pink.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de Donaciones Recibidas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.pink),
              ),
              const SizedBox(height: 6),
              Text(
                '• Dinero: \$$totalDinero ($countDinero donaciones)',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                '• Artículos: ${articulosDonados.length} aportes registrados',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              if (articulosDonados.isNotEmpty) ...[
                const SizedBox(height: 6),
                ...articulosDonados.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '  - ${a['cantidad'] ?? 1}x ${a['articulo_descripcion'] ?? 'Artículo'}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                )),
              ],
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(color: Color(0xFF2E7D32)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
