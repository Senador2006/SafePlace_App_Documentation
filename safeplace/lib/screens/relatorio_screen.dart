import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:safeplace/data/anuncios.dart';
import 'package:safeplace/models/bairro.dart';
import 'package:safeplace/screens/planos_screen.dart';
import 'package:safeplace/services/plano_controller.dart';
import 'package:safeplace/services/relatorio_service.dart';
import 'package:safeplace/services/risk_service.dart';
import 'package:safeplace/theme/colors.dart';
import 'package:safeplace/widgets/anuncio_card.dart';
import 'package:safeplace/widgets/risk_badge.dart';
import 'package:safeplace/widgets/tendencia_indicador.dart';

class RelatorioScreen extends StatelessWidget {
  const RelatorioScreen({
    super.key,
    required this.bairro,
    required this.bairros,
    required this.avisoGratis,
  });

  final Bairro bairro;
  final List<Bairro> bairros;
  final bool avisoGratis;

  @override
  Widget build(BuildContext context) {
    final plano = PlanoScope.of(context);
    final relatorio = RelatorioService.of(bairro, bairros);
    final risco = RiskService.of(bairro);
    final mostrarAnuncios = !plano.ehPro;

    return Scaffold(
      backgroundColor: SafePlaceColors.nightBlue,
      appBar: AppBar(title: Text(bairro.nome)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (avisoGratis && mostrarAnuncios) ...[
            _AvisoGratis(
              onPlanos: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PlanosScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'Criminalidade ${relatorio.indice}%',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: SafePlaceColors.white,
                  ),
                ),
              ),
              RiskBadge(risco: risco),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Percentual do maior volume entre os bairros desta base.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: SafePlaceColors.mediumGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            relatorio.resumo,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 1.45,
              color: SafePlaceColors.lightGray,
            ),
          ),
          const SizedBox(height: 24),
          const _SecaoTitulo('Evolução das ocorrências'),
          const SizedBox(height: 12),
          _GraficoLinha(serie: relatorio.serieMensal),
          const SizedBox(height: 8),
          const Text(
            RelatorioService.notaSerie,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              height: 1.4,
              color: SafePlaceColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          const _SecaoTitulo('Crimes mais comuns'),
          const SizedBox(height: 8),
          for (final crime in relatorio.crimes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      crime.nome,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: SafePlaceColors.lightGray,
                      ),
                    ),
                  ),
                  Text(
                    '${crime.quantidade}',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: SafePlaceColors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  TendenciaIndicador(tendencia: crime.tendencia),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const _SecaoTitulo('Comparação com a média'),
          const SizedBox(height: 4),
          const Text(
            'Barras da região ao lado da média das demais regiões.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: SafePlaceColors.mediumGray,
            ),
          ),
          const SizedBox(height: 12),
          _GraficoBarras(comparacoes: relatorio.comparacoes),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Legenda(cor: SafePlaceColors.safeBlue, texto: 'Esta região'),
              _Legenda(cor: SafePlaceColors.alertPurple, texto: 'Média das demais'),
            ],
          ),
          if (mostrarAnuncios) ...[
            const SizedBox(height: 28),
            const _SecaoTitulo('Ofertas de parceiros'),
            const SizedBox(height: 12),
            for (final anuncio in Anuncios.ofertasRelatorio) ...[
              AnuncioCard(anuncio: anuncio),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 16),
          const Text(
            'Fonte: SSP/SP (microdados). Agregação acadêmica — não substitui estatística oficial.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: SafePlaceColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoGratis extends StatelessWidget {
  const _AvisoGratis({required this.onPlanos});

  final VoidCallback onPlanos;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SafePlaceColors.indigo.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SafePlaceColors.safeBlue),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Este foi o seu relatório gratuito. Os próximos relatórios detalhados fazem parte do plano Pro.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.4,
                color: SafePlaceColors.lightGray,
              ),
            ),
            TextButton(
              onPressed: onPlanos,
              style: TextButton.styleFrom(
                foregroundColor: SafePlaceColors.safeBlue,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Ver planos'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  const _SecaoTitulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: SafePlaceColors.white,
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: SafePlaceColors.mediumGray,
          ),
        ),
      ],
    );
  }
}

class _GraficoLinha extends StatelessWidget {
  const _GraficoLinha({required this.serie});

  final List<int> serie;

  @override
  Widget build(BuildContext context) {
    final maxY = _tetoY(serie.map((valor) => valor.toDouble()));
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 5,
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _intervalo(maxY),
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0x22FFFFFF),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: _intervalo(maxY),
                getTitlesWidget: (value, meta) => Text(
                  value.round().toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: SafePlaceColors.mediumGray,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final indice = value.round();
                  if ((value - indice).abs() > 0.01 ||
                      indice < 0 ||
                      indice >= RelatorioService.meses.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      RelatorioService.meses[indice],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: SafePlaceColors.mediumGray,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < serie.length; i++)
                  FlSpot(i.toDouble(), serie[i].toDouble()),
              ],
              isCurved: true,
              color: SafePlaceColors.safeBlue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: SafePlaceColors.safeBlue.withValues(alpha: 0.16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraficoBarras extends StatelessWidget {
  const _GraficoBarras({required this.comparacoes});

  final List<ComparacaoCrime> comparacoes;

  @override
  Widget build(BuildContext context) {
    final valores = [
      for (final item in comparacoes) ...[
        item.regiao.toDouble(),
        item.mediaDemais,
      ],
    ];
    final maxY = _tetoY(valores);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _intervalo(maxY),
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0x22FFFFFF),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: _intervalo(maxY),
                getTitlesWidget: (value, meta) => Text(
                  value.round().toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: SafePlaceColors.mediumGray,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final indice = value.toInt();
                  if (indice < 0 || indice >= comparacoes.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      comparacoes[indice].nome,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: SafePlaceColors.mediumGray,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < comparacoes.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 6,
                barRods: [
                  BarChartRodData(
                    toY: comparacoes[i].regiao.toDouble(),
                    color: SafePlaceColors.safeBlue,
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: comparacoes[i].mediaDemais,
                    color: SafePlaceColors.alertPurple,
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

double _tetoY(Iterable<double> valores) {
  var maior = 0.0;
  for (final valor in valores) {
    if (valor > maior) maior = valor;
  }
  if (maior <= 0) return 1;
  return maior * 1.25;
}

double _intervalo(double maxY) {
  if (maxY <= 5) return 1;
  if (maxY <= 20) return 5;
  if (maxY <= 50) return 10;
  if (maxY <= 100) return 20;
  return 50;
}
