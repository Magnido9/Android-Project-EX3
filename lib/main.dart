import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'auth_services.dart';
import 'components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return MaterialApp(
                home: Scaffold(
                    body: Center(
                        child: Text(snapshot.error.toString(),
                            textDirection: TextDirection.ltr))));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MyApp();
          }
          return const Center(child: const CircularProgressIndicator());
        });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {'/Login': (context) => Login()},
        title: 'Flutter Demo',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.black,
          ),
        ), // ... to here.
        home: RandomWords()); // And add the const back here.
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<dynamic> getWords() async {
    String? pid = AuthRepository.instance().user?.uid;
    var v =
    (await FirebaseFirestore.instance.collection("words").doc(pid).get());
    var words;
    if(v["words"]==null){
      words=[];
    }
    else {
      words=v["words"];
    }
    var saved=<WordPair>{};
    for(int i=0;i<words.length;i+=2){
      saved.add(WordPair(words[i], words[i+1]));
    }
    return saved;
  }
  bool IsLoading = false;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Enter your login details please',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              )),
          Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(hintText: "Username"),
              )),
          Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(hintText: "Password"),
              )),
          (IsLoading)
              ? CircularProgressIndicator()
              : CoolButton(() async {
                  IsLoading = true;
                  final String email = emailController.text.trim();
                  final String password = passwordController.text.trim();
                  setState(() => IsLoading = true);
                  print(IsLoading);
                  dynamic result = await AuthRepository.instance().signIn(email, password, context);
                  print(result);
                  if (result == null) {
                    setState(() => IsLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('There was an error loging into the app')));
                  }
                  else{
                    setState(() => IsLoading = false);
                    Navigator.pop(context,getWords());
                  }
                })
        ],
      ),
    );
  }
}

class RandomWords extends StatefulWidget {

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  var _saved = <WordPair>{}; // NEW
  Future<void> setWords(Set<WordPair> words) async {
    print(words);
    var words_strings=[];
    for(var pair in words.toList()){
      words_strings.add(pair.first.toString());
      words_strings.add(pair.second.toString());
    }
    print(words);
    print(words_strings);
    String? pid = AuthRepository.instance().user?.uid;
    await FirebaseFirestore.instance
        .collection("words")
        .doc(pid)
        .set({"words":words_strings});
  }
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 14);
  bool IsLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Startup Name Generator'), actions: [
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: _pushSaved,
          tooltip: 'Saved Suggestions',
        ),
        AuthRepository.instance().isAuthenticated?IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            setWords(_saved);
            AuthRepository.instance().signOut();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully logged out')));
            setState(() {
            });
        },
          tooltip: 'Login',
        ):IconButton(
          icon: const Icon(Icons.login),
          onPressed: () async {
            var a=await Navigator.pushNamed(context, '/Login');
            print(a);
            _saved=a as Set<WordPair>;
            print(_saved);
            setState(() {

            });
            },
          tooltip: 'Login',
        ),
      ]),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              String dialogMessage='Are you sure you want to delete '+ pair.toString() +'from your saved suggestions';
              return Dismissible(
                  onDismissed: (direction) {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Delete Suggestion'),
                        content: Text(dialogMessage),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                                setState(() {
                                  _saved.remove(pair);
                                });
                                Navigator.pop(context);
                              },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {Navigator.pop(context);} ,
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                    },
                  background: Container(
                      color: Colors.deepPurple,
                      child: Row(
                          children: [Icon(Icons.delete), Text("Delete Item")])),
                  key: Key(pair.asPascalCase),
                  child: ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    ),
                  ));
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];
          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }


  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border_outlined,
        color: alreadySaved ? Colors.deepPurple : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      }, // ... to here.
    );
  }
}
