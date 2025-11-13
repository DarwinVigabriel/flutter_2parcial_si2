class User {
  final String id;
  final String email;
  final String nombre;
  final String apellido;
  final String? tipoUsuario;
  final String? telefono;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    this.tipoUsuario,
    this.telefono,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      tipoUsuario: json['tipo_usuario'],
      telefono: json['telefono'],
    );
  }

  String get fullName => '$nombre $apellido';
}
