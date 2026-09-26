import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF315BDB)),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Color(0xFF68748B))),
      ],
    ),
  );
}
