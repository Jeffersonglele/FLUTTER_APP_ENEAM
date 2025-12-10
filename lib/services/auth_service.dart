import 'package:flutter/foundation.dart';
import 'package:eneam_projet/models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  
  // Méthode pour définir l'utilisateur connecté
  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
  
  // Méthode pour se déconnecter
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
  
  // Vérifier si un utilisateur est connecté
  bool get isLoggedIn => _currentUser != null;
}
