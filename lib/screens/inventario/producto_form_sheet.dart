import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/marcas_motos.dart';
import '../../models/producto.dart';
import '../../state/productos_controller.dart';
import '../../theme/app_theme.dart';

class ProductoFormSheet extends StatefulWidget {
  final Producto? producto;
  const ProductoFormSheet({super.key, this.producto});

  @override
  State<ProductoFormSheet> createState() => _ProductoFormSheetState();
}

class _ProductoFormSheetState extends State<ProductoFormSheet> {
  late final _emojiCtrl = TextEditingController(text: widget.producto?.emoji ?? '🔧');
  late final _codigoCtrl = TextEditingController(text: widget.producto?.codigo ?? '');
  late final _nombreCtrl = TextEditingController(text: widget.producto?.nombre ?? '');
  late final _descCtrl = TextEditingController(text: widget.producto?.descripcion ?? '');
  late final _precioCtrl = TextEditingController(text: widget.producto?.precio.toString() ?? '');
  late final _costoCtrl = TextEditingController(text: widget.producto?.costo.toString() ?? '0');
  late final _stockCtrl = TextEditingController(text: widget.producto?.stock.toString() ?? '0');
  late final _stockMinCtrl = TextEditingController(text: widget.producto?.stockMin.toString() ?? '3');
  late final _margenCtrl = TextEditingController(
    text: widget.producto != null && widget.producto!.precio > 0
        ? (((widget.producto!.precio - widget.producto!.costo) / widget.producto!.precio) * 100).toStringAsFixed(0)
        : '',
  );
  late String _categoria = widget.producto?.categoria ?? categoriasMotos.first;
  late String _marca = widget.producto?.marca ?? '';
  late String _modelo = widget.producto?.modelo ?? '';
  late String? _imagen = widget.producto?.imagen;

  @override
  void dispose() {
    _emojiCtrl.dispose();
    _codigoCtrl.dispose();
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    _costoCtrl.dispose();
    _stockCtrl.dispose();
    _stockMinCtrl.dispose();
    _margenCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final archivo = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (archivo == null) return;
    final bytes = await File(archivo.path).readAsBytes();
    if (!mounted) return;
    setState(() => _imagen = base64Encode(bytes));
  }

  double get _costo => double.tryParse(_costoCtrl.text) ?? 0;
  double get _precio => double.tryParse(_precioCtrl.text) ?? 0;
  double get _gananciaPorUnidad => _precio - _costo;

  /// Costo + % ganancia deseado → precio de venta. El margen es sobre el
  /// PRECIO DE VENTA, no sobre el costo (mismo criterio que el resto del
  /// catálogo — ver lección de Bodega Pro).
  void _calcularPrecio() {
    final margen = double.tryParse(_margenCtrl.text);
    if (_costo > 0 && margen != null && margen >= 0 && margen < 100) {
      _precioCtrl.text = (_costo / (1 - margen / 100)).toStringAsFixed(2);
    }
    setState(() {});
  }

  void _guardar() {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio'), backgroundColor: Colors.redAccent));
      return;
    }
    final controller = context.read<ProductosController>();
    final datos = Producto(
      id: widget.producto?.id ?? 0,
      codigo: _codigoCtrl.text.trim().toUpperCase(),
      nombre: _nombreCtrl.text.trim(),
      emoji: _emojiCtrl.text.trim().isEmpty ? '🔧' : _emojiCtrl.text.trim(),
      categoria: _categoria,
      marca: _marca,
      modelo: _modelo,
      precio: _precio,
      costo: _costo,
      stock: double.tryParse(_stockCtrl.text) ?? 0,
      stockMin: double.tryParse(_stockMinCtrl.text) ?? 3,
      descripcion: _descCtrl.text.trim(),
      imagen: _imagen,
    );
    if (widget.producto != null) {
      controller.guardar(datos);
    } else {
      controller.crear(datos);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.producto != null;
    final modelosDisponibles = _marca.isNotEmpty && _marca != 'Universal' ? (marcasMotos[_marca] ?? const []) : const <String>[];
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(editando ? 'Editar repuesto' : 'Nuevo repuesto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Center(child: _FotoPicker(base64: _imagen, onTap: _elegirFoto, onQuitar: _imagen != null ? () => setState(() => _imagen = null) : null)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(controller: _nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre *'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _codigoCtrl, textCapitalization: TextCapitalization.characters, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Código / SKU'))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                SizedBox(width: 70, child: TextField(controller: _emojiCtrl, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20), decoration: const InputDecoration(labelText: 'Emoji'))),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _categoria,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categoriasMotos.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setState(() => _categoria = v ?? _categoria),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _marca.isEmpty ? null : _marca,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Marca de moto'),
                    hint: const Text('Todas', style: TextStyle(color: Colors.white38)),
                    items: [
                      const DropdownMenuItem(value: 'Universal', child: Text('Universal (todas)')),
                      ...marcasMotos.keys.map((m) => DropdownMenuItem(value: m, child: Text(m))),
                    ],
                    onChanged: (v) => setState(() { _marca = v ?? ''; _modelo = ''; }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _modelo.isEmpty ? null : _modelo,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Modelo'),
                    hint: const Text('Todos', style: TextStyle(color: Colors.white38)),
                    items: modelosDisponibles.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: modelosDisponibles.isEmpty ? null : (v) => setState(() => _modelo = v ?? ''),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextField(controller: _descCtrl, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Descripción')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: _costoCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Costo'), onChanged: (_) => _calcularPrecio())),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _margenCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: '% ganancia', hintText: 'ej: 30'), onChanged: (_) => _calcularPrecio())),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _precioCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Precio venta *'), onChanged: (_) => setState(() {}))),
              ]),
              if (_costo > 0 && _precio > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Ganancia: \$${_gananciaPorUnidad.toStringAsFixed(2)} · Margen ${(_gananciaPorUnidad / _precio * 100).toStringAsFixed(0)}% sobre PVP',
                    style: const TextStyle(color: AppColors.chrome, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: _stockCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Stock'), onChanged: (_) => setState(() {}))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _stockMinCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Stock mínimo'))),
              ]),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.racing, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text(editando ? 'Guardar cambios' : 'Agregar repuesto', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FotoPicker extends StatelessWidget {
  final String? base64;
  final VoidCallback onTap;
  final VoidCallback? onQuitar;

  const _FotoPicker({required this.base64, required this.onTap, required this.onQuitar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 96,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: base64 != null ? AppColors.racing.withValues(alpha: 0.6) : Colors.white24),
            ),
            child: base64 != null
                ? Image.memory(base64Decode(base64!), fit: BoxFit.cover)
                : const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate, color: Colors.white38, size: 26),
                        SizedBox(height: 2),
                        Text('Foto', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
          ),
        ),
        if (onQuitar != null)
          TextButton(
            onPressed: onQuitar,
            style: TextButton.styleFrom(minimumSize: const Size(0, 30), padding: EdgeInsets.zero),
            child: const Text('Quitar', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
