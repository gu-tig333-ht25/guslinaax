import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todo_provider.dart'; // provider som hanterar logik & API-koppling

//Appens startpunkt
void main() {
   runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider()..loadTodos(),
      //Provider håller koll på state (listan med todo) och laddar direkt vid start
      child: const MyApp(),
    ),
  );
}

//Todo class - modellklass som beskriver en todo
class Todo {
  String? id; //Unik ID som vi får från API:et
  String title; //Själva texten
  bool isDone; //Om upgiften är done eller undone

  Todo({
    this.id,
    required this.title,
    this.isDone = false,
  });

  //Metod för att skapa en Todo från JSON (Api-data)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isDone: json['done'],
    );
  }
}

// Root-widget för Appen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //tar bort debug-banderoll i hörnet
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(255, 131, 222, 1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'TIG333 TO DO LIST:'), //startsidan
    );
  }
}

//Startsida
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title; //titel för appBar

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
  //Hämtar provider (listan med todos & funktioner)
  final todoProvider = Provider.of<TodoProvider>(context);
  final filteredTodos = todoProvider.todos; //filtrerat lista beroende på filter

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
      actions: [
        //Dropdown-meny för att välja filter
        PopupMenuButton<String>(
          onSelected: (value) => todoProvider.setFilter(value),
          itemBuilder: (BuildContext context) => const[
            PopupMenuItem(value: 'all', child: Text('All')),
            PopupMenuItem(value: 'undone', child: Text('Undone')),
            PopupMenuItem(value: 'done', child: Text('Done')),
          ],
        ),
      ],
    ),
    
    //Listan med todos
    body: ListView.builder(
      itemCount: filteredTodos.length,
      //Körs en gång för varje rad i listan
      itemBuilder: (context, index) {
        final todo = filteredTodos[index];
        //retunerar en widget som ska visas för just denna todo
        return ListTile(
          leading: Checkbox( 
            value: todo.isDone, 
            //när man klickar i boxen kallas toggleTodo i providern
            onChanged: (_) => todoProvider.toggleTodo(todo), 
          ), 
          title: Text( 
            todo.title, 
            //gör så att färdiga todos från genomstruken text
            style: todo.isDone ? const TextStyle(
            decoration: TextDecoration.lineThrough) : null, 
          ),   
          trailing: IconButton( 
            icon: const Icon(Icons.close), 
            onPressed: () => todoProvider.removeTodo(todo),
          ),
        );
      },
    ),
    
    //Knapp för att lägga till todo
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        //Öppnar new task page och väntar på resultat
        final newTask = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewTaskPage()),
        );

        //Om man skrivit något läggs det till
        if (newTask != null && newTask is String && newTask.trim().isNotEmpty) {
          await todoProvider.addTodo(newTask);
        }
      },
      tooltip: "Add new to do",
      child: const Icon(Icons.add),
    ),
  );
}
}

//Lägg till ny todo-sida 
//StatefulWidget används för att behålla TextEditingCOntroller mellan rebuilds
class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

//State-klassen för NewTakPage
class _NewTaskPageState extends State<NewTaskPage> {
  //TextEditingController för att läsa texten från Textfield (placeras här för att bevaras mellan rebuild)
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    //frigör minne när sidan stängs
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar högst upp med titel
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
                // När man trycker på knappen stängs sidan och skickar tillbaka texten som skrivits
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