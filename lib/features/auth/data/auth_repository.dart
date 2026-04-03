import '../domain/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> restoreSession();
  Future<AppUser> signIn({required String name, required String email});
  Future<void> signOut();
}
