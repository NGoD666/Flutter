import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class DetailTodoPage extends StatelessWidget {
  final TodoItem todoItem;

  const DetailTodoPage({super.key, required this.todoItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail To Do'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todoItem.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Kategori: ${todoItem.category}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Deskripsi:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              todoItem.description.isNotEmpty
                  ? todoItem.description
                  : 'Tidak ada deskripsi.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Ditambahkan pada: ${todoItem.date.day}/${todoItem.date.month}/${todoItem.date.year}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
