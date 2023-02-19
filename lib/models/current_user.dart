import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUser with ChangeNotifier {
  User? _currentUser = FirebaseAuth.instance.currentUser;

  void set_user(User? User) {
    _currentUser = User;

    if (_currentUser != null) {
      notifyListeners();
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }

  User? get currentUser => _currentUser;
}
