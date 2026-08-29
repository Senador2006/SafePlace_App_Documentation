import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:safeplace/models/bairro.dart';

class LocalRepository {
  const LocalRepository();

  Future<List<Bairro>> loadBairros() async {
    final raw = await rootBundle.loadString('assets/data/bairros.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final lista = json['bairros'] as List<dynamic>;
    return lista
        .map((item) => Bairro.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
