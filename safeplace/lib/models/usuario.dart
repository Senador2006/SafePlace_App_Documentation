class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
  });

  final String id;
  final String nome;
  final String email;
  final String senhaHash;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'senhaHash': senhaHash,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      senhaHash: json['senhaHash'] as String,
    );
  }
}
