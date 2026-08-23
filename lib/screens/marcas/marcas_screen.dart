import 'package:flutter/material.dart';
import '../../models/marcas_motos.dart';
import '../../theme/app_theme.dart';

/// Catálogo de marcas/modelos de motos — referencia rápida para saber qué
/// modelos existen de cada marca al cargar compatibilidad de un repuesto.
class MarcasScreen extends StatefulWidget {
  const MarcasScreen({super.key});

  @override
  State<MarcasScreen> createState() => _MarcasScreenState();
}

class _MarcasScreenState extends State<MarcasScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final marcas = marcasMotos.keys.where((m) => _busqueda.isEmpty || m.toLowerCase().contains(_busqueda.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Marcas / Modelos', style: TextStyle(color: Colors.white))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar marca...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.search, color: AppColors.racing),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              itemCount: marcas.length,
              itemBuilder: (context, i) {
                final marca = marcas[i];
                final modelos = marcasMotos[marca]!;
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.two_wheeler, color: AppColors.racing),
                    title: Text(marca, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${modelos.length} modelos', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    iconColor: AppColors.racing,
                    collapsedIconColor: Colors.white54,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: modelos.map((m) => Chip(
                                label: Text(m, style: const TextStyle(fontSize: 11, color: Colors.white)),
                                backgroundColor: AppColors.surfaceLight,
                                side: const BorderSide(color: AppColors.chromeDim),
                              )).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
