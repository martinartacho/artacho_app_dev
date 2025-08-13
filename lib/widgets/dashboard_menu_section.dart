import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardMenuSection extends StatelessWidget {
  const DashboardMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menú',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildMenuOption(
          context,
          icon: Icons.person,
          title: 'Perfil',
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        _buildMenuOption(
          context,
          icon: Icons.feedback,
          title: 'Enviar sugerencia',
          onTap: () => Navigator.pushNamed(context, '/feedback'),
        ),
        const Divider(height: 30),
        _buildMenuOption(
          context,
          icon: Icons.logout,
          title: 'Cerrar sesión',
          color: Colors.red,
          onTap: () {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            authProvider.logout();
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
