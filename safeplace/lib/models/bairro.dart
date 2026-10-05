class Bairro {
  const Bairro({
    required this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.furtos,
    required this.roubos,
    required this.homicidios,
  });

  final int id;
  final String nome;
  final double latitude;
  final double longitude;
  final int furtos;
  final int roubos;
  final int homicidios;

  int get ocorrencias => furtos + roubos + homicidios;

  factory Bairro.fromJson(Map<String, dynamic> json) {
    final indicadores = json['indicadores'] as Map<String, dynamic>;
    return Bairro(
      id: json['id'] as int,
      nome: json['nome'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      furtos: indicadores['furtos'] as int,
      roubos: indicadores['roubos'] as int,
      homicidios: indicadores['homicidios'] as int,
    );
  }
}
