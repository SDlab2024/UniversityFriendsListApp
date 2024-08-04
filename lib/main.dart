import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加
import 'dart:convert'; // 追加

void main() {
  runApp(FriendListApp());
}

class Friend {
  String name;
  String grade;
  String meetPlace; // 今回変更：知り合った場所を表すプロパティを追加
  String instagramId; // 今回変更：インスタIDを表すプロパティを追加
  String club; // 今回変更：部活を表すプロパティを追加
  String hobby; // 今回変更：趣味を表すプロパティを追加

  Friend(this.name, this.grade, this.meetPlace, this.instagramId, this.club, this.hobby); // 今回変更：コンストラクタを更新
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

  @override
  void initState() {
    super.initState();
    _loadFriends(); //アプリ起動時に友達リストを読み込む
  }

  void _addFriend() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String grade = ''; // 今回変更：学年用の変数
        String meetPlace = ''; // 今回変更：知り合った場所用の変数
        String instagramId = ''; // 今回変更：インスタID用の変数
        String club = ''; // 今回変更：部活用の変数
        String hobby = ''; // 今回変更：趣味用の変数

        return AlertDialog(
          title: Text('友達を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('名前', (value) => name = value),
              _buildTextField('学年', (value) => grade = value), // 今回変更：学年入力フィールド
              _buildTextField('知り合った場所', (value) => meetPlace = value), // 今回変更：知り合った場所入力フィールド
              _buildTextField('インスタID', (value) => instagramId = value), // 今回変更：インスタID入力フィールド
              _buildTextField('部活', (value) => club = value), // 今回変更：部活入力フィールド
              _buildTextField('趣味', (value) => hobby = value), // 今回変更：趣味入力フィールド
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  friends.add(Friend(name, grade, meetPlace, instagramId, club, hobby)); // 今回変更：Friendオブジェクト作成時に新しい情報を使用
                  _saveFriends(); //友達を追加した後に保存
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
        String grade = friends[index].grade; // 今回変更：学年の変数
        String meetPlace = friends[index].meetPlace; // 今回変更：知り合った場所の変数
        String instagramId = friends[index].instagramId; // 今回変更：インスタIDの変数
        String club = friends[index].club; // 今回変更：部活の変数
        String hobby = friends[index].hobby; // 今回変更：趣味の変数

        return AlertDialog(
          title: Text('友達を編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('名前', (value) => name = value, initialValue: name),
              _buildTextField('学年', (value) => grade = value, initialValue: grade), // 今回変更：学年入力フィールド
              _buildTextField('知り合った場所', (value) => meetPlace = value, initialValue: meetPlace), // 今回変更：知り合った場所入力フィールド
              _buildTextField('インスタID', (value) => instagramId = value, initialValue: instagramId), // 今回変更：インスタID入力フィールド
              _buildTextField('部活', (value) => club = value, initialValue: club), // 今回変更：部活入力フィールド
              _buildTextField('趣味', (value) => hobby = value, initialValue: hobby), // 今回変更：趣味入力フィールド
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  friends[index] = Friend(name, grade, meetPlace, instagramId, club, hobby); // 今回変更：Friendオブジェクトの更新
                  _saveFriends(); //友達を編集した後に保存
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
      _saveFriends(); //友達を削除した後に保存
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

  //友達リストを保存するメソッド
  void _saveFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> friendList = friends.map((friend) => json.encode({
      'name': friend.name,
      'grade': friend.grade, // 今回変更：学年の保存
      'meetPlace': friend.meetPlace, // 今回変更：知り合った場所の保存
      'instagramId': friend.instagramId, // 今回変更：インスタIDの保存
      'club': friend.club, // 今回変更：部活の保存
      'hobby': friend.hobby, // 今回変更：趣味の保存
    })).toList();
    await prefs.setStringList('friendList', friendList);
  }

  //友達リストを読み込むメソッド
  void _loadFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? friendList = prefs.getStringList('friendList');
    if (friendList != null) {
      setState(() {
        friends = friendList.map((item) {
          Map<String, dynamic> friendData = json.decode(item);
          return Friend(
            friendData['name'],
            friendData['grade'], // 今回変更：学年の読み込み
            friendData['meetPlace'], // 今回変更：知り合った場所の読み込み
            friendData['instagramId'], // 今回変更：インスタIDの読み込み
            friendData['club'], // 今回変更：部活の読み込み
            friendData['hobby'], // 今回変更：趣味の読み込み
          );
        }).toList();
      });
    }
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
