import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile(name: 'Jonathan Tandeja', birthDate: '01/01/1990');
  bool _isLoading = true;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  // Fungsi Load Data saat aplikasi dibuka
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? savedName = prefs.getString('profile_name');
    String? savedBirthDate = prefs.getString('profile_birthdate');

    if (savedName != null) {
      _profile = UserProfile(
        name: savedName,
        birthDate: savedBirthDate ?? '01/01/1990',
      );
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Fungsi Simpan Data (Dipanggil saat tombol Save ditekan)
  Future<void> updateProfile(String newName, String newBirthDate) async {
    final prefs = await SharedPreferences.getInstance();
    
    _profile = UserProfile(name: newName, birthDate: newBirthDate);
    
    await prefs.setString('profile_name', newName);
    await prefs.setString('profile_birthdate', newBirthDate);
    
    notifyListeners();
  }
}