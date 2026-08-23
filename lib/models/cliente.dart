/// Ficha de cliente simple — MotoTaller legacy no maneja fiados (no hay
/// método de pago "Fiado"), solo un directorio de contactos: nombre,
/// teléfono, correo, dirección y notas.
class Cliente {
  final int id;
  final String nombre;
  final String telefono;
  final String email;
  final String direccion;
  final String notas;

  const Cliente({
    required this.id,
    required this.nombre,
    this.telefono = '',
    this.email = '',
    this.direccion = '',
    this.notas = '',
  });

  Cliente copyWith({
    String? nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? notas,
  }) {
    return Cliente(
      id: id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      notas: notas ?? this.notas,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'notas': notas,
      };

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: json['id'] as int,
        nombre: json['nombre'] ?? '',
        telefono: json['telefono'] ?? '',
        email: json['email'] ?? '',
        direccion: json['direccion'] ?? '',
        notas: json['notas'] ?? '',
      );
}
