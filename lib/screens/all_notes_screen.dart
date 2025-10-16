import 'package:flutter/material.dart';

class AllNotesScreen extends StatelessWidget {
  const AllNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes mes notes'),
      ),
      body: const Center(
        child: Text('Contenu de toutes les notes ici.'),
      ),
    );
  }
}
