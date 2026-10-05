import 'package:flutter/material.dart';
import 'package:safeplace/services/relatorio_service.dart';
import 'package:safeplace/theme/colors.dart';

class TendenciaIndicador extends StatelessWidget {
  const TendenciaIndicador({
    super.key,
    required this.tendencia,
    this.size = 16,
  });

  final Tendencia tendencia;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (tendencia) {
      Tendencia.subiu => (Icons.arrow_upward, SafePlaceColors.highRisk),
      Tendencia.caiu => (Icons.arrow_downward, SafePlaceColors.safeGreen),
      Tendencia.estavel => (Icons.remove, SafePlaceColors.mediumGray),
    };

    return Icon(icon, size: size, color: color);
  }
}
