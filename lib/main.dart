import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(255, 131, 222, 1)),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'TIG333 TO DO LIST:'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedFilter = 'all';   // håller koll på valt filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),

        // Högra hörnet i appbaren:
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: 'undone',
                child: Text('Undone'),
              ),
              const PopupMenuItem(
                value: 'done',
                child: Text('Done'),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Checkbox(value: false, onChanged: null),
                  title: Text('Write a book'),
                  trailing: Icon(Icons.close),
                ),
                ListTile(
                  leading: Checkbox(value: false, onChanged: null),
                  title: Text('Do homework'),
                  trailing: Icon(Icons.close),
                ),
                ListTile(
                  leading: Checkbox(value: true, onChanged: null),
                  title: Text(
                    'Tidy room',
                    style: TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  trailing: Icon(Icons.close),
                ),
                ListTile(
                  leading: Checkbox(value: false, onChanged: null),
                  title: Text('Watch TV'),
                  trailing: Icon(Icons.close),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewTaskPage()),
          );

          if (newTask != null && newTask is String) {
            // Här kan vi senare lägga till uppgiften i listan
            print("Ny uppgift: $newTask");
          }
        },
        tooltip: 'Add new to do',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewTaskPage extends StatelessWidget {
  const NewTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new to do'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Textfält där man kan skriva sin uppgift
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'What are you going to do?',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Knapp för att spara uppgiften
            ElevatedButton(
              onPressed: () {
                // Här ska vi senare lägga till uppgiften i listan
                Navigator.pop(context, _controller.text); 
              },
              child: const Text('+ Add'),
            ),
          ],
        ),
      ),
    );
  }
}