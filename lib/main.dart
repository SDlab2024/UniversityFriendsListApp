import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加
import 'dart:convert'; // 追加

void main() {
  runApp(FriendListApp());
}

class Friend {
  String name;
  String grade;
  String meetPlace;
  String instagramId;
  String club;
  String hobby;
  DateTime addedDate; // 追加：追加日を表すプロパティを追加

  Friend(this.name, this.grade, this.meetPlace, this.instagramId, this.club, this.hobby, this.addedDate); // 追加：コンストラクタを更新
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
  bool _isSortedByNewest = true; // 追加：新しい順か古い順かを判定するフラグ

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
        String grade = '';
        String meetPlace = '';
        String instagramId = '';
        String club = '';
        String hobby = '';

        return AlertDialog(
          title: Text('友達を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('名前', (value) => name = value),
              _buildTextField('学年', (value) => grade = value),
              _buildTextField('知り合った場所', (value) => meetPlace = value),
              _buildTextField('インスタID', (value) => instagramId = value),
              _buildTextField('部活', (value) => club = value),
              _buildTextField('趣味', (value) => hobby = value),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  friends.add(Friend(name, grade, meetPlace, instagramId, club, hobby, DateTime.now())); // 追加：追加日を設定
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
        String grade = friends[index].grade;
        String meetPlace = friends[index].meetPlace;
        String instagramId = friends[index].instagramId;
        String club = friends[index].club;
        String hobby = friends[index].hobby;

        return AlertDialog(
          title: Text('友達を編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField('名前', (value) => name = value, initialValue: name),
              _buildTextField('学年', (value) => grade = value, initialValue: grade),
              _buildTextField('知り合った場所', (value) => meetPlace = value, initialValue: meetPlace),
              _buildTextField('インスタID', (value) => instagramId = value, initialValue: instagramId),
              _buildTextField('部活', (value) => club = value, initialValue: club),
              _buildTextField('趣味', (value) => hobby = value, initialValue: hobby),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  friends[index] = Friend(name, grade, meetPlace, instagramId, club, hobby, friends[index].addedDate); // 追加：追加日は変更しない
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
      'grade': friend.grade,
      'meetPlace': friend.meetPlace,
      'instagramId': friend.instagramId,
      'club': friend.club,
      'hobby': friend.hobby,
      'addedDate': friend.addedDate.toIso8601String(), // 追加：追加日を保存
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
            friendData['grade'],
            friendData['meetPlace'],
            friendData['instagramId'],
            friendData['club'],
            friendData['hobby'],
            DateTime.parse(friendData['addedDate']), // 追加：追加日を読み込み
          );
        }).toList();
        _sortFriends(); // 追加：読み込み後に並び替え
      });
    }
  }

  // 追加：友達リストを新しい順か古い順に並び替えるメソッド
  void _sortFriends() {
    friends.sort((a, b) => _isSortedByNewest
        ? b.addedDate.compareTo(a.addedDate)
        : a.addedDate.compareTo(b.addedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('友達リスト'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSortedByNewest ? Icons.arrow_downward : Icons.arrow_upward), // 追加：並び替えアイコン
            onPressed: () {
              setState(() {
                _isSortedByNewest = !_isSortedByNewest; // 追加：並び替え順を変更
                _sortFriends(); // 追加：並び替えメソッドを呼び出し
              });
            },
          ),
        ],
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
