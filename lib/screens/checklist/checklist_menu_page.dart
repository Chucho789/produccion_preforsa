import 'package:flutter/material.dart';
import 'checklist_maquinas_page.dart';

class ChecklistMenuPage extends StatelessWidget {
  const ChecklistMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Checklist"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _buildMenuCard(
              context,
              icon: Icons.play_circle,
              title: "Check de Arranque",
              color: Colors.greenAccent,
              tipoId: 1,
            ),
            const SizedBox(height: 5),
            _buildMenuCard(
              context,
              icon: Icons.refresh,
              title: "Check de Rutina",
              color: Colors.orangeAccent,
              tipoId: 2,
            ),
            const SizedBox(height: 5),
            _buildMenuCard(
              context,
              icon: Icons.ac_unit,
              title: "Check de Chiller",
              color: Colors.lightBlueAccent,
              tipoId: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,{
    required IconData icon,
    required String title,
    required Color color,
    required int tipoId,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChecklistMaquinasPage(
                tipoId: tipoId,
                titulo: title,
              ),
            ),
          );
        },
        child: Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.iconTheme.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}