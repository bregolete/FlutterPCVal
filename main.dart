import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite CRUD Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SQLite CRUD Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}
class MyHomePageState extends State<MyHomePage> {
  late Database _database;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'my_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            address TEXT
          )
        ''');
      },
    );
  }

  Future<void> createUser() async {
    final String name = _nameController.text;
    final String address = _addressController.text;

    final row = {
      'name': name,
      'address': address,
    };

    final id = await _database.insert('users', row);

    setState(() {
      _nameController.text = '';
      _addressController.text = '';
    });

    if (id != null) {
      debugPrint('User created successfully with id: $id');
    } else {
      debugPrint('Failed to create user');
    }
  }

  Future<void> readUsers() async {
    final List<Map<String, dynamic>> users = await _database.query('users');

    setState(() {
      _users = users;
    });

    if (_users.isNotEmpty) {
      for (final user in _users) {
        final name = user['name'];
        final address = user['address'];
        debugPrint('Name: $name, Address: $address');
      }
    } else {
      debugPrint('No users found');
    }
  }

  Future<void> updateUser() async {
    final String name = _nameController.text;
    final String address = _addressController.text;

    final row = {
      'name': name,
      'address': address,
    };

    final updatedRows = await _database.update(
      'users',
      row,
      where: 'name = ?',
      whereArgs: [name],
    );

    setState(() {
      _nameController.text = '';
      _addressController.text = '';
    });

    if (updatedRows > 0) {
      debugPrint('User updated successfully');
    } else {
      debugPrint('Failed to update user');
    }
  }

  Future<void> deleteUser() async {
    final String name = _nameController.text;

    final deletedRows = await _database.delete(
      'users',
      where: 'name = ?',
      whereArgs: [name],
    );

    setState(() {
      _nameController.text = '';
      _addressController.text = '';
    });

    if (deletedRows > 0) {
      debugPrint('User deleted successfully');
    } else {
      debugPrint('Failed to delete user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: createUser,
              child: const Text('Create User'),
            ),
            ElevatedButton(
              onPressed: readUsers,
              child: const Text('Read Users'),
            ),
            ElevatedButton(
              onPressed: updateUser,
              child: const Text('Update User'),
            ),
            ElevatedButton(
              onPressed: deleteUser,
              child: const Text('Delete User'),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final name = user['name'];
                  final address = user['address'];

                  return ListTile(
                    title: Text('Name: $name'),
                    subtitle: Text('Address: $address'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
