import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  // Data awal (bisa diganti dengan data dari SharedPreferences nanti)
  UserProfile _profile = UserProfile(
    name: 'Jonathan Tandeja',
    birthDate: '01/01/1990',
  );

  UserProfile get profile => _profile;

  void updateProfile(String newName, String newBirthDate) {
    _profile = _profile.copyWith(name: newName, birthDate: newBirthDate);
    notifyListeners(); // Memberitahu UI bahwa data berubah
  }
}