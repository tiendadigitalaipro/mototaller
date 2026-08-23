import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../state/cart_controller.dart';
import '../../state/configuracion_controller.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import '../../widgets/pressable_scale.dart';
import 'cart_sheet.dart';

const String _todas = 'Todas';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _categoriaActiva = _todas;
  String _busqueda = '';

  List<Producto> _filtrados(List<Producto> productos) {
    return productos.where((p) {
      final coincideCategoria = _categoriaActiva == _todas || p.categoria == _categoriaActiva;
      final coincideBusqueda = _busqueda.isEmpty || p.nombre.toLowerCase().contains(_busqueda.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  void _abrirCarrito() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const CartSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final productosController = context.watch<ProductosController>();
    final config = context.watch<ConfiguracionController>().config;
    final categorias = [_todas, ...productosController.categorias];
    final productos = _filtrados(productosController.productos);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              prefixIcon: const Icon(Icons.search, color: AppColors.racing),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() => _busqueda = v),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categorias.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categorias[i];
              final activa = cat == _categoriaActiva;
              return ChoiceChip(
                label: Text(cat),
                selected: activa,
                onSelected: (_) => setState(() => _categoriaActiva = cat),
                selectedColor: AppColors.racing.withValues(alpha: 0.25),
                backgroundColor: AppColors.surfaceLight,
                labelStyle: TextStyle(color: activa ? AppColors.racing : Colors.white70, fontWeight: activa ? FontWeight.bold : FontWeight.normal),
                side: BorderSide(color: activa ? AppColors.racing : Colors.transparent),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildGrid(productos, config.tasa)),
        if (cart.items.isNotEmpty)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ElevatedButton(
                onPressed: _abrirCarrito,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.racing,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🛒 ${cart.items.length}', overflow: TextOverflow.ellipsis),
                    Flexible(
                      child: Text('Ver ticket — ${formatMoney(cart.total)}', overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGrid(List<Producto> productos, double tasa) {
    if (productos.isEmpty) {
      return Center(
        child: Text('No hay productos.\nAgrégalos desde el módulo Inventario.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.95),
      itemCount: productos.length,
      itemBuilder: (context, i) {
        final p = productos[i];
        final sinStock = p.stock <= 0;
        return _ProductoCard(
          producto: p,
          tasa: tasa,
          disabled: sinStock,
          onTap: sinStock ? null : () => context.read<CartController>().agregarProducto(p),
        );
      },
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final double tasa;
  final bool disabled;
  final VoidCallback? onTap;

  const _ProductoCard({required this.producto, required this.tasa, required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = disabled ? Colors.white24 : AppColors.racing;
    return PressableScale(
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Container(
          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12), border: Border(top: BorderSide(color: color, width: 2))),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(producto.emoji, style: const TextStyle(fontSize: 26)),
              Text(producto.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(formatMoney(producto.precio), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(formatBs(producto.precio, tasa), style: const TextStyle(color: AppColors.chrome, fontWeight: FontWeight.bold, fontSize: 11)),
              Text(disabled ? 'Sin stock' : '${producto.stock.toStringAsFixed(0)} und${producto.marca.isNotEmpty ? ' · ${producto.marca}' : ''}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
