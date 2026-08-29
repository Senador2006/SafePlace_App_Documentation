import 'package:flutter/material.dart';
import 'package:safeplace/models/bairro.dart';
import 'package:safeplace/theme/colors.dart';

enum RiskLevel { baixo, medio, alto }

class RiskResult {
  const RiskResult({required this.score, required this.level});

  final int score;
  final RiskLevel level;

  String get label => switch (level) {
        RiskLevel.baixo => 'Baixo',
        RiskLevel.medio => 'Médio',
        RiskLevel.alto => 'Alto',
      };

  Color get color => switch (level) {
        RiskLevel.baixo => SafePlaceColors.safeGreen,
        RiskLevel.medio => SafePlaceColors.mediumRisk,
        RiskLevel.alto => SafePlaceColors.highRisk,
      };
}

/// RN04 — score = furtos×1 + roubos×3 + homicídios×10
abstract final class RiskService {
  static RiskResult of(Bairro bairro) {
    final score =
        (bairro.furtos * 1) + (bairro.roubos * 3) + (bairro.homicidios * 10);
    final level = score >= 150
        ? RiskLevel.alto
        : score >= 50
            ? RiskLevel.medio
            : RiskLevel.baixo;
    return RiskResult(score: score, level: level);
  }
}
