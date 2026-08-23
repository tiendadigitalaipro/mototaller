import 'package:flutter/material.dart';

enum Moneda { usd, bs, especial }

class MetodoPago {
  final String nombre;
  final IconData icon;
  final Moneda moneda;
  final bool esEfectivo;

  const MetodoPago({
    required this.nombre,
    required this.icon,
    required this.moneda,
    this.esEfectivo = false,
  });
}

/// Los 8 métodos reales de Repuestos de Motos Pro legacy (METODOS_PAGO) —
/// sin Fiado (esta app no maneja crédito a clientes, a diferencia del resto
/// del catálogo).
const List<MetodoPago> metodosPago = [
  MetodoPago(nombre: 'Efectivo USD', icon: Icons.attach_money, moneda: Moneda.usd, esEfectivo: true),
  MetodoPago(nombre: 'Efectivo Bolívares', icon: Icons.payments, moneda: Moneda.bs, esEfectivo: true),
  MetodoPago(nombre: 'Pago Móvil', icon: Icons.smartphone, moneda: Moneda.bs),
  MetodoPago(nombre: 'Transferencia', icon: Icons.account_balance, moneda: Moneda.bs),
  MetodoPago(nombre: 'Punto de Venta', icon: Icons.credit_card, moneda: Moneda.bs),
  MetodoPago(nombre: 'Zelle', icon: Icons.account_balance_wallet, moneda: Moneda.usd),
  MetodoPago(nombre: 'Biopago', icon: Icons.fingerprint, moneda: Moneda.bs),
  MetodoPago(nombre: 'Pago Mixto', icon: Icons.sync_alt, moneda: Moneda.especial),
];
