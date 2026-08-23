import 'package:flutter/material.dart';
import '../models/app_module.dart';
import '../theme/app_theme.dart';
import 'caja/caja_screen.dart';
import 'clientes/clientes_screen.dart';
import 'configuracion/configuracion_screen.dart';
import 'dashboard_screen.dart';
import 'historial/historial_screen.dart';
import 'inventario/inventario_screen.dart';
import 'marcas/marcas_screen.dart';
import 'pos/pos_screen.dart';
import 'reportes/reportes_screen.dart';

/// Módulos reales de Repuestos de Motos Pro legacy: Dashboard/POS ·
/// Inventario/Clientes/Ventas/Marcas-Modelos · Caja/Reportes · Configuración.
final List<AppModule> appModules = [
  AppModule(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard, builder: (_) => const DashboardScreen()),
  AppModule(id: 'pos', label: 'Punto de Venta', icon: Icons.point_of_sale, builder: (_) => const PosScreen(), hasOwnFab: true),
  AppModule(id: 'inventario', label: 'Inventario', icon: Icons.inventory_2, builder: (_) => const InventarioScreen(), hasOwnFab: true),
  AppModule(id: 'clientes', label: 'Clientes', icon: Icons.people, builder: (_) => const ClientesScreen(), hasOwnFab: true),
  AppModule(id: 'ventas', label: 'Ventas', icon: Icons.receipt_long, builder: (_) => const HistorialScreen()),
  AppModule(id: 'marcas', label: 'Marcas / Modelos', icon: Icons.two_wheeler, builder: (_) => const MarcasScreen()),
  AppModule(id: 'caja', label: 'Caja', icon: Icons.account_balance_wallet, builder: (_) => const CajaScreen()),
  AppModule(id: 'reportes', label: 'Reportes', icon: Icons.bar_chart, builder: (_) => const ReportesScreen()),
  AppModule(id: 'config', label: 'Configuración', icon: Icons.settings, builder: (_) => const ConfiguracionScreen()),
];

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  void _selectModule(int index) => setState(() => _selectedIndex = index);

  void _selectModuleFromDrawer(int index) {
    _selectModule(index);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final current = appModules[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.two_wheeler, color: AppColors.racing),
            const SizedBox(width: 8),
            const Text('MotoTaller'),
            const SizedBox(width: 8),
            Expanded(child: Text(current.label, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5)))),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.surface),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.two_wheeler, color: AppColors.racing, size: 36),
                  SizedBox(height: 8),
                  Text('MotoTaller', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Elaborado por A2K Digital Studio', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            for (var i = 0; i < appModules.length; i++)
              ListTile(
                leading: Icon(appModules[i].icon, color: i == _selectedIndex ? AppColors.racing : Colors.white70),
                title: Text(appModules[i].label, style: TextStyle(color: i == _selectedIndex ? AppColors.racing : Colors.white70, fontWeight: i == _selectedIndex ? FontWeight.bold : FontWeight.normal)),
                selected: i == _selectedIndex,
                selectedTileColor: AppColors.racing.withValues(alpha: 0.08),
                onTap: () => _selectModuleFromDrawer(i),
              ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation), child: child)),
        child: KeyedSubtree(key: ValueKey(current.id), child: current.builder(context)),
      ),
      floatingActionButton: current.hasOwnFab ? null : FloatingActionButton(backgroundColor: AppColors.racing, foregroundColor: Colors.white, onPressed: () => _selectModule(1), tooltip: 'Nueva venta', child: const Icon(Icons.point_of_sale)),
    );
  }
}
