import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_firebase/models/current_user.dart';
import 'package:todo_firebase/models/todo_page_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'views/todo_page_ui.dart';

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
        ChangeNotifierProvider(create: (context) => TodoPageList.test()),
        ChangeNotifierProvider(create: (context) => CurrentUser())
      ],
      builder: (context, child) => MaterialApp(
          initialRoute: '/todo',
          routes: {
            '/todo': (context) => TodoPageUI(
                  todoPage: Provider.of<TodoPageList>(context).currentPage,
                ),
            '/sign-in': (context) => SignInScreen(
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, state) {
                      Provider.of<CurrentUser>(context, listen: false)
                          .setUser(FirebaseAuth.instance.currentUser);
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

