import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加: 友達リストを保存・読み込むためのパッケージ
import 'dart:convert'; // 追加: JSON形式でデータをエンコード・デコードするためのパッケージ

// アプリのエントリーポイント
void main() {
  runApp(FriendListApp()); // FriendListAppウィジェットを最初に表示する
}

// Friendクラス: 友達の情報を管理するクラス
class Friend {
  String name; // 友達の名前
  String university; // 友達が通っている大学名
  String faculty; // 友達の学部名
  String year; // 友達の学年
  String email; // 友達のメールアドレス

  Friend(this.name, this.university, this.faculty, this.year, this.email);
// コンストラクタ: 友達情報を初期化する
}

// FriendListAppクラス: アプリ全体の構成を定義するウィジェット
class FriendListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FriendListPage(), // アプリのホーム画面としてFriendListPageウィジェットを指定
      theme: ThemeData(
        primaryColor: Colors.white, // アプリの主要なカラーを白に設定
        hintColor: Colors.blue, // ヒントテキストのカラーを青に設定
        visualDensity: VisualDensity.adaptivePlatformDensity, // プラットフォームに応じた視覚密度を適用
      ),
    );
  }
}

// FriendListPageクラス: 友達リストの表示や操作を行うページ
class FriendListPage extends StatefulWidget {
  @override
  _FriendListPageState createState() => _FriendListPageState();
// FriendListPageの状態を管理するクラスを作成
}

// _FriendListPageStateクラス: FriendListPageの状態を管理するクラス
class _FriendListPageState extends State<FriendListPage> {
  List<Friend> friends = []; // 友達リストを格納するリスト

  @override
  void initState() {
    super.initState();
    _loadFriends(); // アプリ起動時に友達リストを読み込むメソッドを呼び出す
  }

  // 友達を追加するためのメソッド
  void _addFriend() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = ''; // 新しい友達の名前を一時的に保持
        String university = ''; // 新しい友達の大学名を一時的に保持
        String faculty = ''; // 新しい友達の学部名を一時的に保持
        String year = ''; // 新しい友達の学年を一時的に保持
        String email = ''; // 新しい友達のメールアドレスを一時的に保持

        return AlertDialog(
          title: Text('友達を追加'), // ダイアログのタイトル
          content: Column(
            mainAxisSize: MainAxisSize.min, // ダイアログの内容のサイズを最小限に抑える
            children: <Widget>[
              _buildTextField('名前', (value) => name = value), // 名前入力フィールド
              _buildTextField('大学名', (value) => university = value), // 大学名入力フィールド
              _buildTextField('学部', (value) => faculty = value), // 学部入力フィールド
              _buildTextField('学年', (value) => year = value), // 学年入力フィールド
              _buildTextField('メールアドレス', (value) => email = value), // メールアドレス入力フィールド
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  // 入力された情報で新しいFriendオブジェクトを作成し、friendsリストに追加
                  friends.add(Friend(name, university, faculty, year, email));
                  _saveFriends(); // 友達リストを保存する
                });
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('追加'), // 追加ボタンのテキスト
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // キャンセルボタンを押したときにダイアログを閉じる
              },
              child: Text('キャンセル'), // キャンセルボタンのテキスト
            ),
          ],
        );
      },
    );
  }

  // 友達を編集するためのメソッド
  void _editFriend(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 編集する友達の現在の情報を取得
        String name = friends[index].name;
        String university = friends[index].university;
        String faculty = friends[index].faculty;
        String year = friends[index].year;
        String email = friends[index].email;

        return AlertDialog(
          title: Text('友達を編集'), // ダイアログのタイトル
          content: Column(
            mainAxisSize: MainAxisSize.min, // ダイアログの内容のサイズを最小限に抑える
            children: <Widget>[
              // 各入力フィールドに初期値を設定して、編集可能にする
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
                  // 編集された情報で友達リストを更新
                  friends[index] = Friend(name, university, faculty, year, email);
                  _saveFriends(); // 友達リストを保存する
                });
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('保存'), // 保存ボタンのテキスト
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // キャンセルボタンを押したときにダイアログを閉じる
              },
              child: Text('キャンセル'), // キャンセルボタンのテキスト
            ),
          ],
        );
      },
    );
  }

  // 友達を削除するためのメソッド
  void _deleteFriend(int index) {
    setState(() {
      friends.removeAt(index); // 指定されたインデックスの友達をリストから削除
      _saveFriends(); // 削除後に友達リストを保存
    });
  }

  // 入力フィールドを生成するためのメソッド
  TextField _buildTextField(String label, Function(String) onChanged, {String initialValue = ''}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label, // 入力フィールドのラベル
        border: OutlineInputBorder(), // 入力フィールドの境界線
      ),
      onChanged: onChanged, // 入力されたテキストが変更されたときに呼び出されるコールバック
      controller: TextEditingController(text: initialValue), // 初期値を設定
    );
  }

  // 友達リストを保存するためのメソッド
  void _saveFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // SharedPreferencesインスタンスを取得（非同期処理）

    List<String> friendList = friends.map((friend) => json.encode({
      // friendsリストの各FriendオブジェクトをJSON形式に変換して、Stringのリストにする
      'name': friend.name,
      'university': friend.university,
      'faculty': friend.faculty,
      'year': friend.year,
      'email': friend.email,
    })).toList();

    await prefs.setStringList('friendList', friendList);
    // 変換したリストをSharedPreferencesに保存
  }

  // 友達リストを読み込むためのメソッド
  void _loadFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // SharedPreferencesインスタンスを取得（非同期処理）

    List<String>? friendList = prefs.getStringList('friendList');
    // 保存されている友達リストを取得

    if (friendList != null) {
      setState(() {
        // 取得したリストをFriendオブジェクトにデコードしてfriendsリストに設定
        friends = friendList.map((item) {
          Map<String, dynamic> friendData = json.decode(item);
          return Friend(
            friendData['name'],
            friendData['university'],
            friendData['faculty'],
            friendData['year'],
            friendData['email'],
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('友達リスト'), // アプリのタイトルを表示
        backgroundColor: Colors.white, // アプリバーの背景色を白に設定
      ),
      body: ListView.builder(
        itemCount: friends.length, // 友達リストの項目数を設定
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(friends[index].name), // 友達の名前をリストに表示
            onTap: () => _editFriend(index), // リストタイルをタップしたときに編集画面を表示
            trailing: IconButton(
              icon: Icon(Icons.delete), // ゴミ箱アイコンを表示
              onPressed: () => _deleteFriend(index), // ゴミ箱アイコンをタップしたときに友達を削除
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _addFriend, // 追加ボタンを押したときに友達追加ダイアログを表示
            child: Icon(Icons.add), // プラスアイコンを表示
            backgroundColor: Colors.blue, // ボタンの背景色を青に設定
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // ボタンを角丸にする
            ),
          ),
        ],
      ),
    );
  }
}
