import 'package:flutter_test/flutter_test.dart';
import 'package:mototaller/models/marcas_motos.dart';
import 'package:mototaller/models/producto.dart';

void main() {
  group('Catálogo de marcas/modelos', () {
    test('tiene las marcas reales del legacy', () {
      expect(marcasMotos.length, 32);
      expect(marcasMotos.containsKey('Honda'), isTrue);
      expect(marcasMotos.containsKey('Yamaha'), isTrue);
      expect(marcasMotos['Honda'], contains('CB300R'));
    });
  });

  group('Producto — repuesto de moto', () {
    test('sin marca asignada se considera universal', () {
      const p = Producto(id: 1, nombre: 'Bujía', precio: 3);
      expect(p.esUniversal, isTrue);
    });

    test('con marca específica no es universal', () {
      const p = Producto(id: 2, nombre: 'Kit de arrastre', precio: 25, marca: 'Honda', modelo: 'CG125');
      expect(p.esUniversal, isFalse);
    });

    test('round-trip a JSON conserva código, marca y modelo', () {
      const original = Producto(id: 3, codigo: 'MOT-001', nombre: 'Pastillas de freno', categoria: 'Frenos', marca: 'Yamaha', modelo: 'YBR125', precio: 12);
      final restaurado = Producto.fromJson(original.toJson());
      expect(restaurado.codigo, 'MOT-001');
      expect(restaurado.marca, 'Yamaha');
      expect(restaurado.modelo, 'YBR125');
    });
  });
}
