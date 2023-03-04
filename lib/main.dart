import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:todo_firebase/models/current_user.dart';
import 'package:todo_firebase/new_todo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_color/random_color.dart';

import './models/todo.dart';
import 'todo_card.dart';

// TODO: make logout alert more informatic
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseUIAuth.configureProviders([
    GoogleProvider(clientId: dotenv.env['GOOGLE_CLIENT_ID']!),
    EmailAuthProvider()
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Todos()),
        ChangeNotifierProvider(create: (context) => CurrentUser())
      ],
      builder: (context, child) => MaterialApp(
          initialRoute: '/todo',
          routes: {
            '/todo': (context) => const MyHomePage(),
            '/sign-in': (context) => SignInScreen(
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, state) {
                      Provider.of<CurrentUser>(context, listen: false)
                          .set_user(FirebaseAuth.instance.currentUser);
                      Navigator.pop(context);
                    }),
                    AuthStateChangeAction<UserCreated>((context, state) {
                      Navigator.popAndPushNamed(context, '/sign-in');
                    })
                  ],
                ),
          },
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true)),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Widget _getUserIcon(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context).currentUser;

    // If user is signed out,show icon to sign in
    if (currentUser == null) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/sign-in');
          },
          icon: const Icon(Icons.person_add),
        ),
      );
    }

    String userPhotoUrl = currentUser.photoURL ?? "";

    // If the user is signed in but account has not been made by OAuth, display an icon
    if (userPhotoUrl == "") {
      final userDisplayName = currentUser.displayName ?? "";

      if (userDisplayName == "") {
        return CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: IconButton(
            onPressed: () => showLogOutDialog(context),
            icon: const Icon(Icons.person),
          ),
        );
      }

      return CircleAvatar(
        backgroundColor: RandomColor().randomColor(
            colorBrightness:
                Theme.of(context).brightness == ThemeData().brightness
                    ? ColorBrightness.light
                    : ColorBrightness.dark),
        child: Text(userDisplayName.split(' ').map((s) => s[0]).join(""),
            style: Theme.of(context).textTheme.bodyLarge),
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(userPhotoUrl),
      child: GestureDetector(
        onTap: () => showLogOutDialog(context),
      ),
    );
  }

  String? _getUserName(BuildContext context) {
    return Provider.of<CurrentUser>(context).currentUser?.displayName;
  }

  String? _getUserEmail(BuildContext context) {
    return Provider.of<CurrentUser>(context).currentUser?.email;
  }

  void showLogOutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('hello'),
              actions: [
                TextButton(
                    onPressed: () {
                      Provider.of<CurrentUser>(context, listen: false)
                          .signOut();
                      Navigator.pop(context);
                    },
                    child: Text('Log Out'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(
        children: [
          ListTile(
            leading: _getUserIcon(context),
            title: Text(
              _getUserName(context) ??
                  _getUserEmail(context) ??
                  "Username or Email Not Found",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            minLeadingWidth: 0,
            style: ListTileStyle.drawer,
            leading: Icon(
              Icons.check_circle_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text('Texts'),
          )
        ],
      )),
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var todo in Provider.of<Todos>(context).todos)
                      TodoCard(
                        todo: todo,
                      ),
                    const CompletedTodos(),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(2),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.add,
                    // size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                horizontalTitleGap: 0,
                title: Text(
                  'Add a task',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: const NewTodo(),
                        )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CompletedTodos extends StatelessWidget {
  const CompletedTodos({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      animationDuration: const Duration(milliseconds: 100),
      children: [
        ExpansionPanelRadio(
            canTapOnHeader: true,
            value: 1,
            headerBuilder: (_, isExpanded) => ListTile(
                    title: Text(
                  'Completed',
                  style: Theme.of(context).textTheme.titleLarge,
                )),
            body: Column(
              children: [
                for (var completedTodo
                    in Provider.of<Todos>(context).completedTodos)
                  TodoCard(
                    todo: completedTodo,
                  )
              ],
            ))
      ],
    );
  }
}
