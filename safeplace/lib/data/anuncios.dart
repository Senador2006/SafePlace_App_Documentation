import 'package:flutter/material.dart';
import 'package:safeplace/models/anuncio.dart';

/// Anúncios de exemplo, fixos no app. Sem rede de publicidade.
abstract final class Anuncios {
  static const todos = <Anuncio>[
    Anuncio(
      titulo: 'Alarmes residenciais',
      texto:
          'Alarmes registram aberturas e podem avisar o morador. Compare cobertura e tipo de instalação.',
      url: 'https://pt.wikipedia.org/wiki/Alarme',
      icone: Icons.sensors_outlined,
    ),
    Anuncio(
      titulo: 'Câmeras de segurança',
      texto:
          'Câmeras registram áreas comuns do imóvel. A escolha depende do ambiente e da iluminação.',
      url: 'https://pt.wikipedia.org/wiki/Circuito_fechado_de_televis%C3%A3o',
      icone: Icons.videocam_outlined,
    ),
    Anuncio(
      titulo: 'Fechaduras eletrônicas',
      texto:
          'Fechaduras eletrônicas controlam o acesso por senha ou aplicativo. Confira a compatibilidade com a porta.',
      url: 'https://pt.wikipedia.org/wiki/Fechadura',
      icone: Icons.lock_outline,
    ),
    Anuncio(
      titulo: 'Seguro residencial',
      texto:
          'O seguro residencial cobre danos ao imóvel e, em alguns planos, bens no interior. Leia as coberturas antes de contratar.',
      url: 'https://pt.wikipedia.org/wiki/Seguro',
      icone: Icons.home_outlined,
    ),
    Anuncio(
      titulo: 'Seguro de veículo',
      texto:
          'O seguro de veículo cobre colisão, roubo e assistência conforme a apólice. Compare franquia e serviços inclusos.',
      url: 'https://pt.wikipedia.org/wiki/Autom%C3%B3vel',
      icone: Icons.directions_car_outlined,
    ),
    Anuncio(
      titulo: 'Rastreador veicular',
      texto:
          'Rastreadores indicam a localização do veículo e podem ajudar na recuperação. Veja os requisitos de instalação.',
      url: 'https://pt.wikipedia.org/wiki/Sistema_de_posicionamento_global',
      icone: Icons.gps_fixed,
    ),
  ];

  static Anuncio get principal => todos.first;

  static List<Anuncio> get ofertasRelatorio => todos.sublist(1, 3);
}
