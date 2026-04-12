import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitcoach/core/utils/preferences_helper.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get usuarioActual => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> emailVerificado() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<UserCredential> registrar({
    required String email,
    required String password,
    required String nombre,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'nombre': nombre,
      'email': email,
      'fechaRegistro': FieldValue.serverTimestamp(),
      'onboardingCompletado': false,
    });
    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
    await PreferencesHelper.limpiarTodo();
  }

  Future<void> recuperarContrasena(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
