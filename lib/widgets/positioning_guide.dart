import 'package:flutter/material.dart';

class PositioningGuide extends StatelessWidget {
  final bool isWellPositioned;
  
  const PositioningGuide({super.key, required this.isWellPositioned});

  @override
  Widget build(BuildContext context) {
    final color = isWellPositioned ? Colors.greenAccent : Colors.white54;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Définir la zone de ciblage (cadre central)
        final width = constraints.maxWidth * 0.7;
        final height = constraints.maxHeight * 0.8;
        
        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: isWellPositioned ? 4.0 : 2.0,
              ),
              borderRadius: BorderRadius.circular(20),
              color: isWellPositioned 
                  ? Colors.greenAccent.withValues(alpha: 0.1) 
                  : Colors.transparent,
            ),
            child: Stack(
              children: [
                // Indicateur de Tête
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.face, color: color, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          isWellPositioned ? 'PARFAIT !' : 'Tête ici',
                          style: TextStyle(
                            color: color, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Indicateur de Pieds
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pieds ici',
                          style: TextStyle(
                            color: color, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(Icons.directions_walk, color: color, size: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
