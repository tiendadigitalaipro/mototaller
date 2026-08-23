class Producto {
  final int id;
  final String codigo;
  final String nombre;
  final String emoji;
  final String categoria;
  final String marca;
  final String modelo;
  final double precio;
  final double costo;
  final double stock;
  final double stockMin;
  final String descripcion;
  final String? imagen;

  const Producto({
    required this.id,
    this.codigo = '',
    required this.nombre,
    this.emoji = '🔧',
    this.categoria = 'Motor y Transmisión',
    this.marca = '',
    this.modelo = '',
    required this.precio,
    this.costo = 0,
    this.stock = 0,
    this.stockMin = 3,
    this.descripcion = '',
    this.imagen,
  });

  bool get stockBajo => stock <= stockMin;

  /// true si esta pieza sirve para cualquier marca/modelo (repuesto universal).
  bool get esUniversal => marca.isEmpty || marca == 'Universal';

  Producto copyWith({
    String? codigo,
    String? nombre,
    String? emoji,
    String? categoria,
    String? marca,
    String? modelo,
    double? precio,
    double? costo,
    double? stock,
    double? stockMin,
    String? descripcion,
    String? imagen,
  }) {
    return Producto(
      id: id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      emoji: emoji ?? this.emoji,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      precio: precio ?? this.precio,
      costo: costo ?? this.costo,
      stock: stock ?? this.stock,
      stockMin: stockMin ?? this.stockMin,
      descripcion: descripcion ?? this.descripcion,
      imagen: imagen ?? this.imagen,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'codigo': codigo,
        'nombre': nombre,
        'emoji': emoji,
        'categoria': categoria,
        'marca': marca,
        'modelo': modelo,
        'precio': precio,
        'costo': costo,
        'stock': stock,
        'stockMin': stockMin,
        'descripcion': descripcion,
        'imagen': imagen,
      };

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json['id'] as int,
        codigo: json['codigo'] ?? '',
        nombre: json['nombre'] ?? '',
        emoji: json['emoji'] ?? '🔧',
        categoria: json['categoria'] ?? 'Motor y Transmisión',
        marca: json['marca'] ?? '',
        modelo: json['modelo'] ?? '',
        precio: (json['precio'] as num?)?.toDouble() ?? 0,
        costo: (json['costo'] as num?)?.toDouble() ?? 0,
        stock: (json['stock'] as num?)?.toDouble() ?? 0,
        stockMin: (json['stockMin'] as num?)?.toDouble() ?? 3,
        descripcion: json['descripcion'] ?? '',
        imagen: json['imagen'] as String?,
      );
}

/// Las 10 categorías reales de Repuestos de Motos Pro legacy.
const List<String> categoriasMotos = [
  'Motor y Transmisión', 'Eléctrico', 'Frenos', 'Suspensión', 'Llantas y Rin',
  'Carrocería', 'Lubricantes y Filtros', 'Cascos y Periquitos', 'Accesorios', 'Herramientas',
];
