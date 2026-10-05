import 'package:flutter/material.dart';

class Anuncio {
  const Anuncio({
    required this.titulo,
    required this.texto,
    required this.url,
    required this.icone,
  });

  final String titulo;
  final String texto;
  final String url;
  final IconData icone;
}
