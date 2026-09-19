import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';
import '../repositories/encuesta_repository.dart';

class SatisfaccionPrompt extends ConsumerWidget {
  const SatisfaccionPrompt({super.key});

  static bool _yaMostradaEstaSesion = false;

  static Future<void> verificarYMostrarSiProcede(BuildContext context, WidgetRef ref) async {
    if (_yaMostradaEstaSesion) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final repo = EncuestaRepository();
      final currentCount = await repo.contarJornadasCompletadas(user.id);
      if (currentCount == 0) return;

      final estadoMap = await repo.obtenerEstado(user.id);

      final lastShownAtStr = estadoMap?['last_shown_at'] as String?;
      final lastShownAt = lastShownAtStr != null ? DateTime.parse(lastShownAtStr) : null;
      final lastCountAtShown = estadoMap?['last_completed_jornada_count_at_shown'] as int? ?? 0;

      bool debeMostrar = false;

      if (lastShownAt == null) {
        if (currentCount >= 1) {
          debeMostrar = true;
        }
      } else {
        final diasPasados = DateTime.now().difference(lastShownAt).inDays;
        final hayNuevaJornada = currentCount > lastCountAtShown;

        if (diasPasados >= 90 && hayNuevaJornada) {
          debeMostrar = true;
        }
      }

      if (debeMostrar && context.mounted) {
        _yaMostradaEstaSesion = true;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => const SatisfaccionPrompt(),
        );
      }
    } catch (_) {
      // Ignorar errores de red
    }
  }

  Future<void> _guardarFeedback(BuildContext context, WidgetRef ref, int valor) async {
    try {
      final user = ref.read(currentUserProvider);
      final supabase = Supabase.instance.client;

      if (user != null) {
        await supabase.from('feedback_satisfaccion').insert({
          'usuario_id': user.id,
          'valor': valor,
          'fecha': DateTime.now().toIso8601String().split('T').first,
        });

        final repo = EncuestaRepository();
        final currentCount = await repo.contarJornadasCompletadas(user.id);
        await repo.guardarEstado(
          userId: user.id,
          lastShownAt: DateTime.now(),
          countAtShown: currentCount,
          respondida: true,
          descartada: false,
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Muchas gracias por tu opinión! Nos ayuda a mejorar CausApp.'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gracias por tu feedback.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _descartarEncuesta(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final repo = EncuestaRepository();
        final currentCount = await repo.contarJornadasCompletadas(user.id);
        await repo.guardarEstado(
          userId: user.id,
          lastShownAt: DateTime.now(),
          countAtShown: currentCount,
          respondida: false,
          descartada: true,
        );
      }
    } catch (_) {}
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '¿Qué tan contento estás con CausApp?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu opinión es muy importante para nuestra comunidad.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmojiOption(context, ref, '😞', 1),
              _buildEmojiOption(context, ref, '😕', 2),
              _buildEmojiOption(context, ref, '😐', 3),
              _buildEmojiOption(context, ref, '🙂', 4),
              _buildEmojiOption(context, ref, '🤩', 5),
            ],
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => _descartarEncuesta(context, ref),
            child: const Text(
              'Ahora no',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiOption(BuildContext context, WidgetRef ref, String emoji, int valor) {
    return InkWell(
      onTap: () => _guardarFeedback(context, ref, valor),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
