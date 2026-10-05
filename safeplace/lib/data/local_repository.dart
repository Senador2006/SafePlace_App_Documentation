import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:safeplace/models/bairro.dart';

class LocalRepository {
  const LocalRepository();

  static List<Bairro>? _cache;

  Future<List<Bairro>> loadBairros() async {
    final emCache = _cache;
    if (emCache != null) return emCache;

    final raw = await rootBundle.loadString('assets/data/bairros.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final lista = json['bairros'] as List<dynamic>;
    final bairros = lista
        .map((item) => Bairro.fromJson(item as Map<String, dynamic>))
        .toList();
    _cache = bairros;
    return bairros;
  }
}
