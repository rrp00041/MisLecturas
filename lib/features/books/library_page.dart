import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Biblioteca', style: TextStyle(fontSize: 24)),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text('Buscador Google Books'),
            subtitle: Text('Buscar por título, autor o ISBN (pendiente API).'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Listas dinámicas'),
            subtitle: Text('Crear/editar/borrar listas personalizadas sin límite.'),
          ),
        ),
      ],
    );
  }
}
