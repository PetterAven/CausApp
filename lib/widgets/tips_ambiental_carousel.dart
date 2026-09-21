import 'dart:async';
import 'package:flutter/material.dart';

class TipAmbiental {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final String categoria;

  const TipAmbiental({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.categoria,
  });
}

class TipsAmbientalCarousel extends StatefulWidget {
  const TipsAmbientalCarousel({super.key});

  @override
  State<TipsAmbientalCarousel> createState() => _TipsAmbientalCarouselState();
}

class _TipsAmbientalCarouselState extends State<TipsAmbientalCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<TipAmbiental> _tips = [
    const TipAmbiental(
      titulo: 'Movilidad Activa',
      descripcion: 'Usa la bicicleta o camina para trayectos cortos. Reduces emisiones y mejoras tu salud física.',
      icono: Icons.directions_bike,
      categoria: 'Movilidad Urbana',
    ),
    const TipAmbiental(
      titulo: 'Separación de Residuos',
      descripcion: 'Separa orgánicos, plásticos y papel en casa. Facilita el reciclaje y disminuye el impacto en vertederos.',
      icono: Icons.recycling,
      categoria: 'Cuidado Ambiental',
    ),
    const TipAmbiental(
      titulo: 'Cultura Vial',
      descripcion: 'Respeta el cruce peatonal y cede el paso a los transeúntes. La seguridad vial es responsabilidad de todos.',
      icono: Icons.security,
      categoria: 'Uso de Vialidades',
    ),
    const TipAmbiental(
      titulo: 'Ahorro de Agua en Jornadas',
      descripcion: 'Utiliza sistemas a presión o cubetas al limpiar espacios públicos para evitar el desperdicio del recurso hídrico.',
      icono: Icons.water_drop,
      categoria: 'Cuidado Ambiental',
    ),
    const TipAmbiental(
      titulo: 'Transporte Compartido',
      descripcion: 'Organiza viajes compartidos (carpooling) con vecinos o compañeros de trabajo para reducir el parque vehicular.',
      icono: Icons.car_rental,
      categoria: 'Movilidad Urbana',
    ),
    const TipAmbiental(
      titulo: 'Cero Baches y Reportes',
      descripcion: 'Reporta baches y daños en vialidades a tiempo para prevenir accidentes vehiculares y daños mecánicos.',
      icono: Icons.add_road,
      categoria: 'Uso de Vialidades',
    ),
    const TipAmbiental(
      titulo: 'Reforestación Urbana',
      descripcion: 'Planta árboles nativos en banquetas y áreas comunes; ayudan a regular la temperatura y purifican el aire.',
      icono: Icons.park,
      categoria: 'Cuidado Ambiental',
    ),
    const TipAmbiental(
      titulo: 'Velocidad Moderada',
      descripcion: 'Respeta los límites de velocidad en zonas urbanas para proteger a ciclistas, peatones y reducir ruido ambiental.',
      icono: Icons.speed,
      categoria: 'Uso de Vialidades',
    ),
    const TipAmbiental(
      titulo: 'Uso Eficiente de Energía',
      descripcion: 'Apaga luces y dispositivos innecesarios. Promueve el uso de energías limpias en tu comunidad.',
      icono: Icons.bolt,
      categoria: 'Cuidado Ambiental',
    ),
    const TipAmbiental(
      titulo: 'Respeto al Ciclista',
      descripcion: 'Mantén una distancia prudente al rebasar ciclistas en avenidas y evita estacionarte en ciclovías.',
      icono: Icons.pedal_bike,
      categoria: 'Movilidad Urbana',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tips.shuffle(); // Mezcla aleatoria cada vez que se carga
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _tips.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _tips.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final tip = _tips[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(tip.icono, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tip.categoria,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.titulo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tip.descripcion,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _tips.length > 5 ? 5 : _tips.length, // Mostrar hasta 5 puntos indicadores para limpieza visual
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage % (_tips.length > 5 ? 5 : _tips.length) == index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage % (_tips.length > 5 ? 5 : _tips.length) == index
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
