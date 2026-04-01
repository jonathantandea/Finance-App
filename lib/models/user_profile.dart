// lib/models/user_profile.dart

class UserProfile {
  String name;
  String birthDate; 

  UserProfile({required this.name, required this.birthDate});

  // Fungsi copyWith untuk update data tanpa mengubah objek asli
  UserProfile copyWith({String? name, String? birthDate}) {
    return UserProfile(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}