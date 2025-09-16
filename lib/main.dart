import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

//Todo class
class Todo {
  String title;
  bool isDone;

  Todo({
    required this.title,
    this.isDone = false,
  });
}

// App
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

//Startsida
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedFilter = 'all'; // vilket filter man valt
  final List<Todo> _todos = []; //listan med todos

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _todos.where((todo) {
      if (_selectedFilter == "done") return todo.isDone; 
      if (_selectedFilter == "undone") return !todo.isDone;
      return true;
    }).toList();

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
              const PopupMenuItem(value: 'all', child: Text('All'),),
              const PopupMenuItem(value: 'undone', child: Text('Undone'),),
              const PopupMenuItem(value: 'done', child: Text('Done'),),
            ],
          ),
        ],
      ),

      //Listan
      body: ListView.builder(
        itemCount: filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = filteredTodos[index];
          return ListTile(
            leading: Checkbox(
              value: todo.isDone,
              onChanged: (value) {
                setState(() {
                  todo.isDone = value ?? false;

                  //sortera listan så att ogjord ligger först och gjorde sist
                  _todos.sort((a,b){
                    if (a.isDone == b.isDone) return 0;
                    return a.isDone? 1 : -1;
                  });
                });
              },
            ),
            title: Text(
              todo.title,
              style: todo.isDone ? const TextStyle(decoration: TextDecoration.lineThrough): null,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _todos.remove(todo);
                });
              },
            ),
          );
        },
      ),

      //+ knappen
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewTaskPage()),
          );

          if (newTask != null && newTask is String &&newTask.trim().isNotEmpty) {
            setState(() {
              _todos.add(Todo(title: newTask));
            });
          }
        },
        tooltip: "Add new to do",
        child: const Icon(Icons.add),
      ),
    );
  }
}

//Lägg till ny todo sida
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
            // Textfält där man kan skriva sin todo
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'What are you going to do?',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Knapp för att spara todo (+ Add knappen)
            ElevatedButton(
              onPressed: () {
                // Här ska vi senare lägga till todon i listan
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