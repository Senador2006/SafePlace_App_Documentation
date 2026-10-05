import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:safeplace/config/locationiq_chave.dart';

class AnelContorno {
  const AnelContorno({required this.externo, this.furos = const []});

  final List<LatLng> externo;
  final List<List<LatLng>> furos;
}

class ContornoBairro {
  const ContornoBairro({required this.nomeExibido, required this.aneis});

  final String nomeExibido;
  final List<AnelContorno> aneis;

  List<LatLng> get pontos => [
        for (final anel in aneis) ...anel.externo,
      ];
}

class ContornoException implements Exception {
  const ContornoException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Busca o bairro na LocationIQ e devolve o polígono do contorno.
class ContornoService {
  ContornoService({http.Client? cliente, String? chave})
      : _cliente = cliente ?? http.Client(),
        _chave = (chave ?? chaveLocationIq).trim();

  final http.Client _cliente;
  final String _chave;
  final _cache = <String, ContornoBairro?>{};

  bool get temChave => _chave.isNotEmpty;

  /// Tiles escuros da mesma conta. Sem chave, o mapa usa o OpenStreetMap.
  String get urlTiles => temChave
      ? 'https://{s}-tiles.locationiq.com/v3/dark/r/{z}/{x}/{y}.png?key=$_chave'
      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  List<String> get subdominiosTiles => temChave ? const ['a', 'b', 'c'] : const [];

  Future<ContornoBairro?> buscar(String nome) async {
    if (!temChave) {
      throw const ContornoException(
        'Cole o token da LocationIQ para desenhar o contorno.',
      );
    }

    final chaveCache = nome.trim().toLowerCase();
    if (_cache.containsKey(chaveCache)) return _cache[chaveCache];

    final uri = Uri.https('us1.locationiq.com', '/v1/search', {
      'key': _chave,
      'q': '$nome, São Paulo, Brasil',
      'format': 'json',
      'polygon_geojson': '1',
      'limit': '5',
      'countrycodes': 'br',
      'bounded': '1',
      'viewbox': '-46.365,-23.356,-46.826,-24.008',
      'accept-language': 'pt',
    });

    final resposta = await _cliente.get(
      uri,
      headers: const {
        'User-Agent': 'SafePlace/1.0 (FIAP; academic)',
        'Accept': 'application/json',
      },
    );

    if (resposta.statusCode != 200) {
      throw ContornoException(
        'A LocationIQ respondeu ${resposta.statusCode}.',
      );
    }

    final corpo = jsonDecode(resposta.body);
    if (corpo is! List) {
      throw const ContornoException('Resposta inesperada da LocationIQ.');
    }

    final contorno = interpretarContorno(corpo);
    _cache[chaveCache] = contorno;
    return contorno;
  }
}

/// Escolhe o primeiro resultado que seja uma área (polígono), não um ponto.
ContornoBairro? interpretarContorno(List<dynamic> resultados) {
  Map<String, dynamic>? melhor;
  var melhorNota = 0;

  for (final item in resultados) {
    if (item is! Map) continue;
    final mapa = Map<String, dynamic>.from(item);
    final nota = _notaArea(mapa);
    if (nota > melhorNota) {
      melhorNota = nota;
      melhor = mapa;
    }
  }

  if (melhor == null) return null;
  final geo = melhor['geojson'];
  if (geo is! Map) return null;
  final aneis = aneisDeGeoJson(Map<String, dynamic>.from(geo));
  if (aneis.isEmpty) return null;

  final nome = melhor['display_name'];
  return ContornoBairro(
    nomeExibido: nome is String ? nome : '',
    aneis: aneis,
  );
}

List<AnelContorno> aneisDeGeoJson(Map<String, dynamic> geo) {
  final tipo = geo['type'];
  final coordenadas = geo['coordinates'];
  if (coordenadas is! List) return const [];

  if (tipo == 'Polygon') {
    final anel = _anel(coordenadas);
    return anel.externo.length >= 3 ? [anel] : const [];
  }

  if (tipo == 'MultiPolygon') {
    return [
      for (final poligono in coordenadas)
        if (poligono is List) _anel(poligono),
    ].where((anel) => anel.externo.length >= 3).toList();
  }

  return const [];
}

int _notaArea(Map<String, dynamic> item) {
  final geo = item['geojson'];
  if (geo is! Map) return 0;
  final tipoGeo = geo['type'];
  if (tipoGeo != 'Polygon' && tipoGeo != 'MultiPolygon') return 0;

  final classe = item['class'] as String? ?? '';
  final tipo = item['type'] as String? ?? '';
  var nota = 1;
  if (classe == 'boundary' || classe == 'place') nota += 2;
  if (const {
    'administrative',
    'suburb',
    'neighbourhood',
    'quarter',
    'city_district',
    'borough',
  }.contains(tipo)) {
    nota += 3;
  }
  return nota;
}

AnelContorno _anel(List<dynamic> aneis) {
  List<LatLng> anel(dynamic bruto) {
    if (bruto is! List) return const [];
    final pontos = <LatLng>[];
    for (final par in bruto) {
      if (par is! List || par.length < 2) continue;
      final lon = par[0];
      final lat = par[1];
      if (lon is! num || lat is! num) continue;
      pontos.add(LatLng(lat.toDouble(), lon.toDouble()));
    }
    return pontos;
  }

  final externo = aneis.isEmpty ? <LatLng>[] : anel(aneis.first);
  final furos = <List<LatLng>>[];
  for (final furo in aneis.skip(1)) {
    final pontos = anel(furo);
    if (pontos.length >= 3) furos.add(pontos);
  }
  return AnelContorno(externo: externo, furos: furos);
}
