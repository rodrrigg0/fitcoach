import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fitcoach/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _estaCargando = false;
  String? _error;
  User? _usuarioActual;

  bool get estaCargando => _estaCargando;
  String? get error => _error;
  User? get usuarioActual => _usuarioActual;

  void init() {
    _authService.authStateChanges.listen((user) {
      _usuarioActual = user;
      notifyListeners();
    });
  }

  Future<bool> registrar(String nombre, String email, String password) async {
    _estaCargando = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.registrar(
          email: email, password: password, nombre: nombre);
      return true;
    } on FirebaseAuthException catch (e) {
      // Solo Firebase Auth puede bloquear el registro
      _error = _mensajeErrorRegistro(e.code);
      return false;
    } catch (_) {
      // Errores de red u otros no deben bloquear si Auth tuvo éxito
      // (auth_service ya maneja internamente Firestore/email)
      _error = 'Error al crear la cuenta';
      return false;
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _estaCargando = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.login(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mensajeErrorLogin(e.code);
      return false;
    } catch (_) {
      _error = 'Error al iniciar sesión';
      return false;
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> recuperarContrasena(String email) async {
    await _authService.recuperarContrasena(email);
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  String _mensajeErrorRegistro(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'Formato de email no válido';
      default:
        return 'Error al crear la cuenta';
    }
  }

  String _mensajeErrorLogin(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email no registrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Email o contraseña incorrectos';
      case 'too-many-requests':
        return 'Demasiados intentos, espera un momento';
      case 'invalid-email':
        return 'Formato de email no válido';
      default:
        return 'Error al iniciar sesión';
    }
  }
}
