class Usuario {
  final String id;
  final String nome;
  final String email;
  final String senha;
  final String? profileImageUrl;
  final String? telefone;
  final String? apartamento;
  final String role; 

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.profileImageUrl,
    this.telefone,
    this.apartamento,
    this.role = 'morador',
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] ?? '',
      nome: json['nome'] ?? 'Nome não informado',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
      profileImageUrl: json['profileImage'],
      telefone: json['telefone'],
      apartamento: json['apartamento'],
      role: json['role'] ?? 'morador', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'profileImage': profileImageUrl,
      'telefone': telefone,
      'apartamento': apartamento,
      'role': role,
    };
  }
}
