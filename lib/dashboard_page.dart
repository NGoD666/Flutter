import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_todo_page.dart';

class TodoItem {
  final String title;
  final String description;
  final String category;
  final DateTime date;

  TodoItem({
    required this.title,
    required this.description,
    required this.category,
    required this.date,
  });
}

class DashboardPage extends StatefulWidget {
  final String userEmail;

  const DashboardPage({super.key, required this.userEmail});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<TodoItem> _todoList = [];
  late String _username;
  String _selectedDrawerCategory = 'To-Do';

  @override
  void initState() {
    super.initState();
    _username = widget.userEmail.split('@')[0];
    _loadTodosFromFirestore();
  }

  void _loadTodosFromFirestore() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('todos')
        .where('userEmail', isEqualTo: widget.userEmail)
        .get();

    setState(() {
      _todoList.clear();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _todoList.add(TodoItem(
          title: data['title'],
          description: data['description'],
          category: data['category'],
          date: DateTime.parse(data['date']),
        ));
      }
    });
  }

  void _addTodo() {
    String title = '';
    String description = '';
    String category = 'To-Do';
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah To Do'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Judul'),
                      onChanged: (value) => title = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      value: category,
                      items: ['To-Do', 'Important'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => category = value!);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(selectedDate == null
                              ? 'Pilih tanggal'
                              : 'Tanggal: ${_formatDate(selectedDate!)}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (title.trim().isNotEmpty && selectedDate != null) {
                      Navigator.pop(context);
                      setState(() {
                        _todoList.add(TodoItem(
                          title: title.trim(),
                          description: description.trim(),
                          category: category.trim(),
                          date: selectedDate!,
                        ));
                      });

                      await FirebaseFirestore.instance.collection('todos').add({
                        'title': title.trim(),
                        'description': description.trim(),
                        'category': category.trim(),
                        'date': selectedDate!.toIso8601String(),
                        'userEmail': widget.userEmail,
                      });
                    }
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editTodo(int index) {
    TodoItem item = _todoList[index];
    String title = item.title;
    String description = item.description;
    String category = item.category;
    DateTime selectedDate = item.date;

    final titleController = TextEditingController(text: title);
    final descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit To Do'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Judul'),
                    controller: titleController,
                    onChanged: (val) => title = val,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    controller: descriptionController,
                    onChanged: (val) => description = val,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    value: category,
                    items: ['To-Do', 'Important'].map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => category = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text('Tanggal: ${_formatDate(selectedDate)}')),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (title.trim().isNotEmpty) {
                    Navigator.pop(context);
                    setState(() {
                      _todoList[index] = TodoItem(
                        title: title.trim(),
                        description: description.trim(),
                        category: category,
                        date: selectedDate,
                      );
                    });
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  void _removeTodo(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    List<TodoItem> filteredList = _todoList
        .where((item) => item.category == _selectedDrawerCategory)
        .toList();

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_username),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: NetworkImage('https://www.gravatar.com/avatar/placeholder'),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.check_box_outlined),
              title: const Text('To-Do'),
              selected: _selectedDrawerCategory == 'To-Do',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedDrawerCategory = 'To-Do';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Important'),
              selected: _selectedDrawerCategory == 'Important',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedDrawerCategory = 'Important';
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(_selectedDrawerCategory),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredList.isEmpty
            ? const Center(child: Text('Belum ada To Do'))
            : ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(filteredList[index].title),
                      subtitle: Text('${filteredList[index].category} - ${_formatDate(filteredList[index].date)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              int originalIndex = _todoList.indexOf(filteredList[index]);
                              _editTodo(originalIndex);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              int originalIndex = _todoList.indexOf(filteredList[index]);
                              _removeTodo(originalIndex);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTodoPage(todoItem: filteredList[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
