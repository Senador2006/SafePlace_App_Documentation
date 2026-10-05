import 'package:flutter_test/flutter_test.dart';
import 'package:safeplace/data/local_repository.dart';

void main() {
  test('monta furtos, roubos e homicidios a partir do select', () {
    final bairros = bairrosDeSupabase([
      {
        'id': 1,
        'nome': 'Pinheiros',
        'latitude': -23.5615,
        'longitude': -46.6917,
        'indicador_criminalidade': [
          {
            'quantidade': 40,
            'tipo_crime': {'codigo': 'furto'},
          },
          {
            'quantidade': 12,
            'tipo_crime': {'codigo': 'roubo'},
          },
          {
            'quantidade': 0,
            'tipo_crime': {'codigo': 'homicidio'},
          },
        ],
      },
    ]);

    expect(bairros, hasLength(1));
    expect(bairros.single.nome, 'Pinheiros');
    expect(bairros.single.furtos, 40);
    expect(bairros.single.roubos, 12);
    expect(bairros.single.homicidios, 0);
    expect(bairros.single.ocorrencias, 52);
  });
}
