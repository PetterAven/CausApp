import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jornada.dart';

class DonarScreen extends ConsumerStatefulWidget {
  final Jornada? jornada; // Opcional, si se dona a una jornada específica

  const DonarScreen({super.key, this.jornada});

  @override
  ConsumerState<DonarScreen> createState() => _DonarScreenState();
}

class _DonarScreenState extends ConsumerState<DonarScreen> {
  final _montoController = TextEditingController();
  String _metodoPago = 'tarjeta';
  bool _isLoading = false;
  double _montoSeleccionado = 10.0;

  final List<double> _montosRapidos = [5.0, 10.0, 25.0, 50.0, 100.0];

  @override
  void initState() {
    super.initState();
    _montoController.text = _montoSeleccionado.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _procesarDonacion() async {
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
      // Aquí se debe invocar el SDK de Stripe o PayPal antes de registrar
      // la transacción en la base de datos.
      // Ejemplo:
      // final paymentResult = await StripePaymentService.pay(monto);
      // if (!paymentResult.success) throw 'Pago rechazado';
      // -------------------------------------------------------------

      final supabase = Supabase.instance.client;
      await supabase.from('donaciones').insert({
        'usuario_id': user.id,
        if (widget.jornada != null) 'jornada_id': widget.jornada!.id,
        'monto': monto,
        'metodo_pago': _metodoPago,
        'estado': 'completada', // simulado exitoso por ahora
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text('¡Gracias por tu apoyo!'),
              ],
            ),
            content: Text(
              'Tu donación de \$$monto ha sido registrada con éxito.${widget.jornada != null ? ' Apoyando a la jornada: ${widget.jornada!.titulo}' : ''}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar diálogo
                  Navigator.pop(context); // Cerrar pantalla de donar
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jornada != null ? 'Apoyar Jornada' : 'Hacer Donación'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                      const SizedBox(height: 6),
                      Text(
                        widget.jornada!.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
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
                onPressed: _isLoading ? null : _procesarDonacion,
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
      ),
    );
  }
}
