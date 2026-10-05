import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:safeplace/config/supabase_chave.dart';
import 'package:safeplace/models/bairro.dart';

class LocalRepository {
  const LocalRepository();

  static List<Bairro>? _cache;

  Future<List<Bairro>> loadBairros() async {
    final emCache = _cache;
    if (emCache != null) return emCache;

    if (supabaseLigado) {
      try {
        final linhas = await clienteSupabase.from('bairro').select(
              'id, nome, latitude, longitude, indicador_criminalidade(quantidade, tipo_crime(codigo))',
            );
        final remotos = bairrosDeSupabase(linhas);
        if (remotos.isNotEmpty) {
          _cache = remotos;
          return remotos;
        }
      } catch (_) {
        // Tabela vazia ou sem sessão: segue o JSON local.
      }
    }

    final raw = await rootBundle.loadString('assets/data/bairros.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final lista = json['bairros'] as List<dynamic>;
    final bairros = lista.map((item) => Bairro.fromJson(item as Map<String, dynamic>)).toList();
    _cache = bairros;
    return bairros;
  }
}

/// Monta os bairros no formato do app a partir do select do Supabase.
List<Bairro> bairrosDeSupabase(List<dynamic> linhas) {
  final bairros = <Bairro>[];
  for (final item in linhas) {
    if (item is Map<String, dynamic>) {
      bairros.add(_bairroDeLinha(item));
    } else if (item is Map) {
      bairros.add(_bairroDeLinha(Map<String, dynamic>.from(item)));
    }
  }
  return bairros;
}

Bairro _bairroDeLinha(Map<String, dynamic> json) {
  final indicadores = json['indicador_criminalidade'];
  var furtos = 0;
  var roubos = 0;
  var homicidios = 0;
  if (indicadores is List) {
    for (final bruto in indicadores) {
      if (bruto is! Map) continue;
      final linha = Map<String, dynamic>.from(bruto);
      final quantidade = (linha['quantidade'] as num?)?.toInt() ?? 0;
      final tipo = linha['tipo_crime'];
      final codigo = tipo is Map ? tipo['codigo']?.toString() : null;
      switch (codigo) {
        case 'furto':
          furtos += quantidade;
        case 'roubo':
          roubos += quantidade;
        case 'homicidio':
          homicidios += quantidade;
      }
    }
  }
  return Bairro(
    id: (json['id'] as num).toInt(),
    nome: json['nome'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    furtos: furtos,
    roubos: roubos,
    homicidios: homicidios,
  );
}
