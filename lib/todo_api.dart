import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart'; // för Todo-klassen

//Bas-URL för todo API
const String baseUrl = "https://todoapp-api.apps.k8s.gu.se";

//Min personliga API-nyckeö, som identifierar min todo-lista
const String apiKey = "09f9a93f-da5b-41cb-8f73-889fd2acd0d7";

//TodoApi-klass som hanterar alla HTTP-anrop mot Todo-servern
class TodoApi {
  
  // Hämta alla todos från servern
  static Future<List<Todo>> fetchTodos() async {
    //Skcikar GET-förfrågan till API med din nyckel
    final response = await http.get(Uri.parse("$baseUrl/todos?key=$apiKey"));
    //Om förfrågan lyckas omvandlas JSON-listan till en dart-lista (med jsonDecode)
    if (response.statusCode == 200) { 
      final List data = jsonDecode(response.body);
      return data.map((t) => Todo.fromJson(t)).toList(); //koverterar varje JSON-objekt till ett todo-objekt mmed fromJson
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // Skapa en ny todo → returnerar hela listan med todos efter den nya lagts till
  static Future<List<Todo>> createTodo(String title) async {
    final response = await http.post(
      Uri.parse("$baseUrl/todos?key=$apiKey"), //Post URL med API-nyckel
      headers: {'Content-Type': 'application/json'}, //JSON payload
      body: jsonEncode({'title': title, 'done': false}), //Skcikar ny todo
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List data = jsonDecode(response.body); //API retunerar hela listan
      return data.map((t) => Todo.fromJson(t)).toList(); //Konvertera till todo
    } else {
      throw Exception('Failed to create todo');
    }
  }

  // Uppdatera en todo & retunera hela listan efter updatering
  static Future<List<Todo>> updateTodo(Todo todo) async {
    if (todo.id == null) return [];
    final response = await http.put(
      Uri.parse("$baseUrl/todos/${todo.id}?key=$apiKey"), //PUT URL med todo-id
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': todo.title, 'done': todo.isDone}), //Updatera title & done
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body); //API retunerar hela listan
      return data.map((t) => Todo.fromJson(t)).toList(); //KOnvertera till todo
    } else {
      throw Exception('Failed to update todo');
    }
  }

  // Ta bort en todo & retunera hela listan efter borttagning
  static Future<List<Todo>> deleteTodo(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/todos/$id?key=$apiKey"), //DELETE URL med todo-id
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body); //API retunerar hela listan
      return data.map((t) => Todo.fromJson(t)).toList(); //Konvertera till todo
    } else {
      throw Exception('Failed to delete todo');
    }
  }
}