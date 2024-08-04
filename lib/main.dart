import 'package:flutter/material.dart';

void main() {
  runApp(FriendListApp());
}

class Friend {
  String name;
  String university;
  String faculty;
  String year;
  String email;

  Friend(this.name, this.university, this.faculty, this.year, this.email);
}

class FriendListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FriendListPage(),
      theme: ThemeData(
        primaryColor: Colors.white,
        hintColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class FriendListPage extends StatefulWidget {
  @override
  _FriendListPageState createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  List<Friend> friends = [];

  void _addFriend() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String university = '';
        String faculty = '';
        String year = '';
        String email = '';

        return AlertDialog(
          title: Text('友達を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('名前', (value) => name = value),
              _buildTextField('大学名', (value) => university = value),
              _buildTextField('学部', (value) => faculty = value),
              _buildTextField('学年', (value) => year = value),
              _buildTextField('メールアドレス', (value) => email = value),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  friends.add(Friend(name, university, faculty, year, email));
                });
                Navigator.of(context).pop();
              },
              child: Text('追加'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  void _editFriend(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = friends[index].name;
        String university = friends[index].university;
        String faculty = friends[index].faculty;
        String year = friends[index].year;
        String email = friends[index].email;

        return AlertDialog(
          title: Text('友達を編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('名前', (value) => name = value, initialValue: name),
              _buildTextField('大学名', (value) => university = value, initialValue: university),
              _buildTextField('学部', (value) => faculty = value, initialValue: faculty),
              _buildTextField('学年', (value) => year = value, initialValue: year),
              _buildTextField('メールアドレス', (value) => email = value, initialValue: email),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  friends[index] = Friend(name, university, faculty, year, email);
                });
                Navigator.of(context).pop();
              },
              child: Text('保存'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFriend(int index) {
    setState(() {
      friends.removeAt(index);
    });
  }

  TextField _buildTextField(String label, Function(String) onChanged, {String initialValue = ''}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      controller: TextEditingController(text: initialValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('友達リスト'),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(friends[index].name),
            onTap: () => _editFriend(index),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteFriend(index),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _addFriend,
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ],
      ),
    );
  }
}
