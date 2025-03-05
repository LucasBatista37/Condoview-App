class Condominium {
  final String name;
  final String address;
  final String cnpj;
  final String email;
  final String phone;
  final String description;

  Condominium({
    required this.name,
    required this.address,
    required this.cnpj,
    required this.email,
    required this.phone,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'cnpj': cnpj,
      'email': email,
      'phone': phone,
      'description': description,
    };
  }
}
