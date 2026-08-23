import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cliente.dart';
import '../../state/clientes_controller.dart';
import '../../theme/app_theme.dart';

class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  void _abrirFormulario(BuildContext context, {Cliente? cliente}) {
    final nombreCtrl = TextEditingController(text: cliente?.nombre ?? '');
    final telCtrl = TextEditingController(text: cliente?.telefono ?? '');
    final emailCtrl = TextEditingController(text: cliente?.email ?? '');
    final direccionCtrl = TextEditingController(text: cliente?.direccion ?? '');
    final notasCtrl = TextEditingController(text: cliente?.notas ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cliente != null ? 'Editar cliente' : 'Nuevo cliente', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre *')),
                const SizedBox(height: 12),
                TextField(controller: telCtrl, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Teléfono')),
                const SizedBox(height: 12),
                TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Correo')),
                const SizedBox(height: 12),
                TextField(controller: direccionCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Dirección')),
                const SizedBox(height: 12),
                TextField(controller: notasCtrl, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Notas')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (nombreCtrl.text.trim().isEmpty) return;
                    context.read<ClientesController>().guardar(Cliente(
                          id: cliente?.id ?? 0,
                          nombre: nombreCtrl.text.trim(),
                          telefono: telCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          direccion: direccionCtrl.text.trim(),
                          notas: notasCtrl.text.trim(),
                        ));
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.racing, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(cliente != null ? 'Guardar cambios' : 'Agregar cliente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Cliente c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar cliente', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${c.nombre}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () { context.read<ClientesController>().eliminar(c.id); Navigator.pop(ctx); }, child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ClientesController>().clientes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(heroTag: 'cli_fab', backgroundColor: AppColors.racing, foregroundColor: Colors.white, onPressed: () => _abrirFormulario(context), child: const Icon(Icons.add)),
      body: clientes.isEmpty
          ? Center(child: Text('No hay clientes registrados.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: clientes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = clientes[i];
                return Card(
                  child: ListTile(
                    onTap: () => _abrirFormulario(context, cliente: c),
                    leading: CircleAvatar(backgroundColor: AppColors.racing.withValues(alpha: 0.15), child: Text(c.nombre.isNotEmpty ? c.nombre[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.racing, fontWeight: FontWeight.bold))),
                    title: Text(c.nombre, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(c.telefono.isNotEmpty ? c.telefono : (c.email.isNotEmpty ? c.email : 'Sin datos de contacto'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white38), onPressed: () => _confirmarEliminar(context, c)),
                  ),
                );
              },
            ),
    );
  }
}
