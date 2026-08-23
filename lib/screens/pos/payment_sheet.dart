import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/metodo_pago.dart';
import '../../services/analytics_service.dart';
import '../../state/cart_controller.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({super.key});

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  MetodoPago? _seleccionado;
  final _recibidoCtrl = TextEditingController();
  bool _procesando = false;

  @override
  void dispose() {
    _recibidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final metodo = _seleccionado;
    if (metodo == null) return;
    final cart = context.read<CartController>();
    final productos = context.read<ProductosController>();

    setState(() => _procesando = true);
    try {
      double recibidoUsd;
      if (metodo.esEfectivo) {
        final recibido = double.tryParse(_recibidoCtrl.text) ?? cart.total;
        recibidoUsd = metodo.moneda == Moneda.bs ? recibido / cart.tasaCambio : recibido;
      } else {
        recibidoUsd = cart.total;
      }

      final items = List.of(cart.items);
      final venta = await cart.confirmarVenta(metodo: metodo.nombre, recibidoUsd: recibidoUsd);
      for (final item in items) {
        await productos.ajustarStock(item.productId, -item.qty);
      }
      AnalyticsService.track('venta_registrada', {
        'metodo_pago': metodo.nombre,
        'total_usd': venta.totalUsd,
        'cantidad_items': items.length,
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Venta registrada'), backgroundColor: Colors.green.shade700));
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Método de pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Total: ${formatMoney(cart.total)}  ·  ${formatBs(cart.total, cart.tasaCambio)}', style: const TextStyle(color: AppColors.racing, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.6),
                itemCount: metodosPago.length,
                itemBuilder: (context, i) {
                  final m = metodosPago[i];
                  final activo = m == _seleccionado;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _seleccionado = m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: activo ? AppColors.racing.withValues(alpha: 0.15) : AppColors.surfaceLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: activo ? AppColors.racing : Colors.transparent)),
                      child: Row(
                        children: [
                          Icon(m.icon, color: activo ? AppColors.racing : Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(m.nombre, style: TextStyle(color: activo ? Colors.white : Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_seleccionado?.esEfectivo == true) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _recibidoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: _seleccionado!.moneda == Moneda.bs ? 'Monto recibido (Bs)' : 'Monto recibido (\$)'),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_seleccionado == null || _procesando) ? null : _confirmar,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.racing, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: _procesando ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('✅ Confirmar venta', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
