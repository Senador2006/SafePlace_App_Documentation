import 'package:flutter/material.dart';
import 'package:safeplace/services/plano_controller.dart';
import 'package:safeplace/theme/colors.dart';

class PlanosScreen extends StatelessWidget {
  const PlanosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plano = PlanoScope.of(context);

    return Scaffold(
      backgroundColor: SafePlaceColors.nightBlue,
      appBar: AppBar(title: const Text('Planos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text(
            'O plano Gratuito consulta todas as regiões. O Pro tira os anúncios e libera relatórios detalhados sem limite.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.45,
              color: SafePlaceColors.lightGray,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final gratuito = _PlanoCard(
                nome: 'Gratuito',
                atual: !plano.ehPro,
                beneficios: const [
                  'Dados de todas as regiões',
                  'Anúncios na experiência',
                  '1 relatório detalhado',
                ],
              );
              final pro = _PlanoCard(
                nome: 'Pro',
                atual: plano.ehPro,
                destaque: true,
                beneficios: const [
                  'Dados de todas as regiões',
                  'Sem anúncios',
                  'Relatórios detalhados ilimitados',
                ],
              );

              if (constraints.maxWidth >= 720) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: gratuito),
                    const SizedBox(width: 16),
                    Expanded(child: pro),
                  ],
                );
              }

              return Column(
                children: [
                  gratuito,
                  const SizedBox(height: 16),
                  pro,
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          if (!plano.ehPro) ...[
            const Text(
              'Sem cobrança. A assinatura fica salva neste aparelho.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: SafePlaceColors.mediumGray,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: plano.assinarPro,
              style: FilledButton.styleFrom(
                backgroundColor: SafePlaceColors.safeBlue,
                foregroundColor: SafePlaceColors.white,
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              child: const Text('Assinar Pro'),
            ),
          ] else
            const Text(
              'Assinatura Pro ativa neste aparelho.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: SafePlaceColors.safeGreen,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanoCard extends StatelessWidget {
  const _PlanoCard({
    required this.nome,
    required this.atual,
    required this.beneficios,
    this.destaque = false,
  });

  final String nome;
  final bool atual;
  final List<String> beneficios;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final borda = atual
        ? SafePlaceColors.safeBlue
        : destaque
            ? SafePlaceColors.alertPurple
            : SafePlaceColors.panel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SafePlaceColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borda, width: atual ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: SafePlaceColors.white,
                  ),
                ),
                const Spacer(),
                if (atual)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SafePlaceColors.safeBlue.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Plano atual',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: SafePlaceColors.safeBlue,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            for (final beneficio in beneficios)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check,
                      size: 18,
                      color: SafePlaceColors.safeGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        beneficio,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: SafePlaceColors.lightGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
