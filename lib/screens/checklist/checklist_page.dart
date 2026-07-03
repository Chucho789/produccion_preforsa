import 'package:flutter/material.dart';

class ChecklistPage extends StatelessWidget {
  const ChecklistPage({super.key});

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
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            _buildMenuCard(
              context,
              icon: Icons.play_circle,
              title: "Check de Arranque",
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 15),

            _buildMenuCard(
              context,
              icon: Icons.refresh,
              title: "Check de Rutina",
              color: Colors.orange,
            ),

            const SizedBox(height: 15),

            _buildMenuCard(
              context,
              icon: Icons.ac_unit,
              title: "Check de Chiller",
              color: Colors.deepPurple,
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {

    final theme = Theme.of(context);

    return Card(
      elevation: 5,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: () {},

        child: Container(
          height: 100,
          padding: const EdgeInsets.all(15),

          child: Row(
            children: [

              Icon(
                icon,
                size: 40,
                color: color,
              ),

              const SizedBox(width: 15),

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