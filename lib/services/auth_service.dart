import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> register(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw 'Erro ao fazer login: $e';
    }
  }

  Future<String> userUpdate(String email, String name, String password) async {
    final user = _auth.currentUser;
    try {
      if (user != null) {
        await user.updateDisplayName(name);
        await user.verifyBeforeUpdateEmail(email);
        await user.updatePassword(password);

        return 'Perfil atualizado com sucesso';
      }
    } catch (e) {
      throw 'Erro ao atualizar perfil: $e';
    }
    return 'Erro ao atualizar perfil';
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();
}
