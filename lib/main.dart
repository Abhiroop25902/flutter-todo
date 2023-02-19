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
  await SystemTheme.accentColor.load();

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
          '/todo': (context) =>
              const MyHomePage(title: 'Flutter Demo Home Page'),
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
        title: 'Flutter Demo',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark().copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: SystemTheme.accentColor.accent,
                secondary: SystemTheme.fallbackColor)),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

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
      appBar: AppBar(
        actions: [_getUserIcon(context)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Tasks',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: Provider.of<Todos>(context).todos.length,
                  itemBuilder: (context, idx) => TodoCard(
                        todo: Provider.of<Todos>(context).todos[idx],
                      )),
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
