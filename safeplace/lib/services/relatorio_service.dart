import 'package:safeplace/models/bairro.dart';

enum Tendencia { subiu, caiu, estavel }

class CrimeIndicador {
  const CrimeIndicador({
    required this.nome,
    required this.quantidade,
    required this.tendencia,
    required this.serie,
  });

  final String nome;
  final int quantidade;
  final Tendencia tendencia;
  final List<int> serie;
}

class ComparacaoCrime {
  const ComparacaoCrime({
    required this.nome,
    required this.regiao,
    required this.mediaDemais,
  });

  final String nome;
  final int regiao;
  final double mediaDemais;
}

class Relatorio {
  const Relatorio({
    required this.indice,
    required this.crimes,
    required this.serieMensal,
    required this.resumo,
    required this.comparacoes,
  });

  /// Volume do bairro em relação ao maior volume da base, de 0 a 100.
  final int indice;
  final List<CrimeIndicador> crimes;
  final List<int> serieMensal;
  final String resumo;
  final List<ComparacaoCrime> comparacoes;

  List<CrimeIndicador> get maisComuns => crimes.take(2).toList();
}

/// Relatório a partir dos totais já carregados (jan–jun/2026).
///
/// A base não traz mês a mês. A série reparte o total do semestre de forma
/// estável: a soma dos seis meses é exatamente o total do bairro.
abstract final class RelatorioService {
  static const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];

  static const notaSerie =
      'A base traz o total de jan–jun/2026. A série mensal reparte esse total '
      'de forma estável: a soma dos meses é o total do bairro. Não é a '
      'estatística mensal publicada pela SSP.';

  static Relatorio of(Bairro bairro, List<Bairro> todos) {
    final crimes = <CrimeIndicador>[
      for (final tipo in _tipos)
        CrimeIndicador(
          nome: tipo.nome,
          quantidade: tipo.quantidade(bairro),
          serie: _distribuirSemestre(
            tipo.quantidade(bairro),
            bairro.id * 10 + tipo.ordem,
          ),
          tendencia: Tendencia.estavel,
        ),
    ];

    final comTendencia = [
      for (final crime in crimes)
        CrimeIndicador(
          nome: crime.nome,
          quantidade: crime.quantidade,
          serie: crime.serie,
          tendencia: _tendencia(crime.serie),
        ),
    ]..sort((a, b) {
        final porQuantidade = b.quantidade.compareTo(a.quantidade);
        if (porQuantidade != 0) return porQuantidade;
        return a.nome.compareTo(b.nome);
      });

    final serieMensal = List<int>.filled(6, 0);
    for (final crime in comTendencia) {
      for (var mes = 0; mes < 6; mes++) {
        serieMensal[mes] += crime.serie[mes];
      }
    }

    final anterior = serieMensal[0] + serieMensal[1] + serieMensal[2];
    final recente = serieMensal[3] + serieMensal[4] + serieMensal[5];

    return Relatorio(
      indice: _indice(bairro, todos),
      crimes: comTendencia,
      serieMensal: serieMensal,
      resumo: resumoOcorrencias(anterior, recente),
      comparacoes: [
        for (final tipo in _tipos)
          ComparacaoCrime(
            nome: tipo.nome,
            regiao: tipo.quantidade(bairro),
            mediaDemais: _mediaDemais(tipo, bairro, todos),
          ),
      ],
    );
  }

  static String resumoOcorrencias(int anterior, int recente) {
    if (anterior == 0 && recente == 0) {
      return 'As ocorrências permaneceram estáveis em relação ao período anterior.';
    }
    if (anterior == 0) {
      return 'O período recente registra ocorrências e o período anterior não tem base para um percentual.';
    }
    final pontos = (((recente - anterior) / anterior) * 100).round();
    if (pontos == 0) {
      return 'As ocorrências permaneceram estáveis em relação ao período anterior.';
    }
    if (pontos < 0) {
      return 'As ocorrências diminuíram ${pontos.abs()}% em relação ao período anterior.';
    }
    return 'As ocorrências aumentaram $pontos% em relação ao período anterior.';
  }

  static int _indice(Bairro bairro, List<Bairro> todos) {
    var maior = 0;
    for (final item in todos) {
      if (item.ocorrencias > maior) maior = item.ocorrencias;
    }
    if (maior == 0) return 0;
    return ((bairro.ocorrencias / maior) * 100).round();
  }

  static double _mediaDemais(_TipoCrime tipo, Bairro bairro, List<Bairro> todos) {
    final outros = todos.where((item) => item.id != bairro.id).toList();
    if (outros.isEmpty) return 0;
    final soma = outros.fold<int>(0, (total, item) => total + tipo.quantidade(item));
    return soma / outros.length;
  }

  static Tendencia _tendencia(List<int> serie) {
    final anterior = serie[0] + serie[1] + serie[2];
    final recente = serie[3] + serie[4] + serie[5];
    if (recente > anterior) return Tendencia.subiu;
    if (recente < anterior) return Tendencia.caiu;
    return Tendencia.estavel;
  }

  /// Reparte [total] em 6 meses. A soma dos meses é [total].
  static List<int> _distribuirSemestre(int total, int semente) {
    if (total <= 0) return List<int>.filled(6, 0);

    var estado = semente & 0x7fffffff;
    if (estado == 0) estado = 1;

    final pesos = List<double>.generate(6, (_) {
      estado = (1103515245 * estado + 12345) & 0x7fffffff;
      return 0.55 + (estado % 1000) / 1000;
    });
    final somaPesos = pesos.reduce((a, b) => a + b);
    final brutos = [for (final peso in pesos) total * peso / somaPesos];
    final inteiros = [for (final valor in brutos) valor.floor()];
    var resto = total - inteiros.reduce((a, b) => a + b);

    final ordem = List<int>.generate(6, (indice) => indice)
      ..sort((a, b) {
        final fracaoA = brutos[a] - inteiros[a];
        final fracaoB = brutos[b] - inteiros[b];
        return fracaoB.compareTo(fracaoA);
      });

    var cursor = 0;
    while (resto > 0) {
      inteiros[ordem[cursor % 6]] += 1;
      resto--;
      cursor++;
    }
    return inteiros;
  }
}

class _TipoCrime {
  const _TipoCrime(this.nome, this.ordem, this.quantidade);

  final String nome;
  final int ordem;
  final int Function(Bairro bairro) quantidade;
}

const _tipos = <_TipoCrime>[
  _TipoCrime('Furtos', 0, _furtos),
  _TipoCrime('Roubos', 1, _roubos),
  _TipoCrime('Homicídios', 2, _homicidios),
];

int _furtos(Bairro bairro) => bairro.furtos;
int _roubos(Bairro bairro) => bairro.roubos;
int _homicidios(Bairro bairro) => bairro.homicidios;
