import 'package:flutter/material.dart';
import 'package:safeplace/services/risk_service.dart';

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.risco});

  final RiskResult risco;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: risco.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: risco.color),
      ),
      child: Text(
        risco.label,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: risco.color,
        ),
      ),
    );
  }
}
