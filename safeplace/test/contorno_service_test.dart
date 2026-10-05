import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeplace/services/contorno_service.dart';

void main() {
  test('interpreta o poligono do bairro e troca longitude por latitude', () {
    final contorno = interpretarContorno(const [
      {
        'display_name': 'Padaria Pinheiros',
        'class': 'amenity',
        'type': 'cafe',
        'geojson': {
          'type': 'Point',
          'coordinates': [-46.69, -23.56],
        },
      },
      {
        'display_name': 'Pinheiros, São Paulo',
        'class': 'place',
        'type': 'suburb',
        'geojson': {
          'type': 'Polygon',
          'coordinates': [
            [
              [-46.70, -23.56],
              [-46.69, -23.56],
              [-46.69, -23.55],
              [-46.70, -23.56],
            ],
            [
              [-46.695, -23.558],
              [-46.694, -23.558],
              [-46.694, -23.557],
              [-46.695, -23.558],
            ],
          ],
        },
      },
    ]);

    expect(contorno, isNotNull);
    expect(contorno!.nomeExibido, 'Pinheiros, São Paulo');
    expect(contorno.aneis, hasLength(1));
    expect(
      contorno.aneis.first.externo.first,
      const LatLng(-23.56, -46.70),
    );
    expect(contorno.aneis.first.furos, hasLength(1));
  });

  test('ignora resposta sem area', () {
    expect(
      interpretarContorno(const [
        {
          'type': 'yes',
          'class': 'amenity',
          'geojson': {
            'type': 'Point',
            'coordinates': [-46.6, -23.5],
          },
        },
      ]),
      isNull,
    );
  });
}
