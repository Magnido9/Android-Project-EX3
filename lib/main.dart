import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
import 'auth_services.dart';
import 'components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class SimpleSnappingSheet extends StatefulWidget {
  @override
  SimpleSnappingSheetState createState() => SimpleSnappingSheetState();
}

class SimpleSnappingSheetState extends State<SimpleSnappingSheet> {
  final SnappingSheetController snappingSheetController =
      new SnappingSheetController();
  pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    print("uploading");
    FirebaseStorage.instance
        .ref('/users/' + FirebaseAuth.instance.currentUser!.uid.toString())
        .putFile(File(image.path))
        .then(
      (p0) async {
        url = await FirebaseStorage.instance
            .ref('/users/' + FirebaseAuth.instance.currentUser!.uid.toString())
            .getDownloadURL();
        print("url HERE IS THIS:" + url.toString());
        setState(() {});
        setState(() {});
      },
    );
  }

  String url = '';
  loadImage() async {
    url = await FirebaseStorage.instance
        .ref('/users/' + FirebaseAuth.instance.currentUser!.uid.toString())
        .getDownloadURL();
    print("url HERE IS THIS:" + url.toString());
    setState(() {});
  }

  @override
  void initState() {
    print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
    loadImage();

    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  void up() {
    snappingSheetController.setSnappingSheetPosition(400);
  }

  void down() {
    snappingSheetController.setSnappingSheetPosition(40);
  }

  @override
  Widget build(BuildContext context) {
    return AuthRepository.instance().isAuthenticated
        ? SnappingSheet(
            child: RandomWords(refresh),
            lockOverflowDrag: true,
            snappingPositions: [
              SnappingPosition.factor(
                positionFactor: 0.0,
                snappingCurve: Curves.easeOutExpo,
                snappingDuration: Duration(seconds: 1),
                grabbingContentOffset: GrabbingContentOffset.top,
              ),
              SnappingPosition.factor(
                snappingCurve: Curves.elasticOut,
                snappingDuration: Duration(milliseconds: 1750),
                positionFactor: 0.5,
              ),
              SnappingPosition.factor(
                grabbingContentOffset: GrabbingContentOffset.bottom,
                snappingCurve: Curves.easeInExpo,
                snappingDuration: Duration(seconds: 1),
                positionFactor: 0.9,
              ),
            ],
            grabbing: GrabbingWidget(up, down),
            grabbingHeight: 75,
            sheetAbove: null,
            controller: snappingSheetController,
            sheetBelow: SnappingSheetContent(
              draggable: true,
              child: Container(
                color: Colors.white,
                child: Container(
                  child: ListView(children: [
                    Column(
                      children: [
                        Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: url != ''
                                        ? NetworkImage(url)
                                        : NetworkImage(
                                            "https://as1.ftcdn.net/v2/jpg/03/53/11/00/1000_F_353110097_nbpmfn9iHlxef4EDIhXB1tdTD0lcWhG9.jpg")))),
                        Container(height: 50),
                        MaterialButton(
                            onPressed: () async {
                              pickImage();
                              setState(() async {});
                            },
                            child: Text(
                              "Change avatar image",
                              style: TextStyle(fontSize: 18),
                            ))
                      ],
                    )
                  ]),
                ),
              ),
            ),
          )
        : RandomWords(refresh);
  }
}

/// Widgets below are just helper widgets for this example

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Placeholder(
        color: Colors.green[200]!,
      ),
    );
  }
}

class GrabbingWidget extends StatefulWidget {
  var up;
  var down;
  GrabbingWidget(upf, downf) {
    up = upf;
    down = downf;
  }
  @override
  GrabbingWidgetState createState() => GrabbingWidgetState(up, down);
}

class GrabbingWidgetState extends State<GrabbingWidget> {
  var up;
  var down;
  bool isUp = false;
  bool notClicked = true;
  GrabbingWidgetState(upf, downf) {
    up = upf;
    down = downf;
  }
  @override
  Widget build(BuildContext context) {
    return notClicked
        ? BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 0.0,
              sigmaY: 0.0,
            ),
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 25, color: Colors.black.withOpacity(0.2)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 10,
                    ),
                    AuthRepository.instance().isAuthenticated
                        ? Text(
                            "Welcome back " +
                                (AuthRepository.instance().user!.email!),
                            style: TextStyle(
                                fontSize: 18, color: Colors.deepPurple),
                          )
                        : Container(),
                    Container(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: 100,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      color: Colors.grey[200],
                      height: 2,
                      margin: EdgeInsets.all(15).copyWith(top: 0, bottom: 0),
                    )
                  ],
                ),
              ),
              onTap: () {
                (!isUp) ? up() : down();
                isUp = !isUp;
                notClicked = !notClicked;
                setState(() {});
                print("a");
              },
            ))
        : BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 25, color: Colors.black.withOpacity(0.2)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 10,
                    ),
                    AuthRepository.instance().isAuthenticated
                        ? Text(
                            "Welcome back " +
                                (AuthRepository.instance().user!.email!),
                            style: TextStyle(
                                fontSize: 18, color: Colors.deepPurple),
                          )
                        : Container(),
                    Container(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: 100,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      color: Colors.grey[200],
                      height: 2,
                      margin: EdgeInsets.all(15).copyWith(top: 0, bottom: 0),
                    )
                  ],
                ),
              ),
              onTap: () {
                (!isUp) ? up() : down();
                isUp = !isUp;
                print("a");
                notClicked = !notClicked;
                setState(() {});
              },
            ));
  }
}

class SnappingSheetExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snapping Sheet Examples',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[700],
          elevation: 0,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        primarySwatch: Colors.grey,
      ),
      home: PageWrapper(),
    );
  }
}

class PageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Example",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return Container();
                }),
              ),
            },
          )
        ],
      ),
      body: SimpleSnappingSheet(),
    );
  }
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
        home: SimpleSnappingSheet()); // And add the const back here.
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<dynamic> getWords() async {
    String? pid = AuthRepository.instance().user?.uid;
    print('aaa');

    var v =
        (await FirebaseFirestore.instance.collection("words").doc(pid).get());
    if (!v.exists) return <WordPair>{};
    var words;
    if (v["words"] == null) {
      words = [];
    } else {
      words = v["words"];
    }
    var saved = <WordPair>{};
    for (int i = 0; i < words.length; i += 2) {
      saved.add(WordPair(words[i], words[i + 1]));
    }
    return saved;
  }

  bool IsLoading = false;
  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController confirmPassController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
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
                  dynamic result = await AuthRepository.instance()
                      .signIn(email, password, context);
                  print(result);
                  if (result == null) {
                    setState(() => IsLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('There was an error loging into the app')));
                  } else {
                    setState(() => IsLoading = false);
                    Navigator.pop(context, getWords());
                    setState(() {});
                  }
                }),
          SignupButton(() async {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 200,
                    color: Colors.amber,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Register',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              )),
                          Container(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              child: TextFormField(
                                controller: signupEmailController,
                                decoration:
                                    InputDecoration(hintText: "Username"),
                              )),
                          Container(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              child: TextFormField(
                                controller: signupPasswordController,
                                decoration:
                                    InputDecoration(hintText: "Password"),
                              )),
                          ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);

                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                          height: 200,
                                          color: Colors.amber,
                                          child: Center(
                                              child: Column(children: [
                                            Text('Confirm password',
                                                style: TextStyle(
                                                  color: Colors.deepPurple,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                )),
                                            Container(
                                                color: Colors.white,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 50),
                                                child: TextFormField(
                                                  controller:
                                                      confirmPassController,
                                                  decoration: InputDecoration(
                                                      hintText: "password"),
                                                )),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  final String semail =
                                                      signupEmailController.text
                                                          .trim();
                                                  final String spassword =
                                                      signupPasswordController
                                                          .text
                                                          .trim();
                                                  final String confirm =
                                                      confirmPassController.text
                                                          .trim();
                                                  if (!(confirm == spassword)) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Passwords dont much')));
                                                    return;
                                                  }
                                                  dynamic result =
                                                      await AuthRepository
                                                              .instance()
                                                          .signUp(
                                                              semail,
                                                              spassword,
                                                              context);
                                                  print(result);
                                                  if (result == null) {
                                                    setState(() =>
                                                        IsLoading = false);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'There was an error signing up into the app')));
                                                  } else {
                                                    setState(() =>
                                                        IsLoading = false);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Text('Confirm'))
                                          ])));
                                    });
                              },
                              child: Text('signup'))
                        ],
                      ),
                    ),
                  );
                });
            IsLoading = true;
            final String email = emailController.text.trim();
            final String password = passwordController.text.trim();
            setState(() => IsLoading = true);
            dynamic result = await AuthRepository.instance()
                .signIn(email, password, context);
            print(result);
            if (result == null) {
              setState(() => IsLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('There was an error loging into the app')));
            } else {
              setState(() => IsLoading = false);
              Navigator.pop(context, getWords());
            }
          })
        ],
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  var notifyParent;
  RandomWords(notifyParent1) {
    notifyParent = notifyParent1;
  }
  @override
  _RandomWordsState createState() => _RandomWordsState(notifyParent);
}

class _RandomWordsState extends State<RandomWords> {
  var notifyParent;
  _RandomWordsState(notifyParent1) {
    notifyParent = notifyParent1;
  }

  var _saved = <WordPair>{}; // NEW
  Future<void> setWords(Set<WordPair> words) async {
    print(words);
    var words_strings = [];
    for (var pair in words.toList()) {
      words_strings.add(pair.first.toString());
      words_strings.add(pair.second.toString());
    }
    print(words);
    print(words_strings);
    String? pid = AuthRepository.instance().user?.uid;
    await FirebaseFirestore.instance
        .collection("words")
        .doc(pid)
        .set({"words": words_strings});
  }

  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(
      fontSize: 18, color: Colors.black, fontWeight: FontWeight.w700);
  bool IsLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Startup Name Generator',
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
            AuthRepository.instance().isAuthenticated
                ? IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      setWords(_saved);
                      AuthRepository.instance().signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Successfully logged out')));
                      setState(() {});
                      widget.notifyParent();
                    },
                    tooltip: 'Login',
                  )
                : IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () async {
                      var a = await Navigator.pushNamed(context, '/Login');
                      print(a);
                      _saved = a as Set<WordPair>;
                      print(_saved);
                      setState(() {});
                      widget.notifyParent();
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
              String dialogMessage = 'Are you sure you want to delete ' +
                  pair.toString() +
                  'from your saved suggestions';
              return Dismissible(
                  confirmDismiss: (direction) {
                    return showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Delete Suggestion'),
                        content: Text(dialogMessage),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _saved.remove(pair);
                    });
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
