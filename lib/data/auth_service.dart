import 'package:supabase_flutter/supabase_flutter.dart';

/// Kontrak auth agar UI bisa diuji tanpa jaringan.
/// Produksi: [SupabaseAuthService]. Tes/widget: [FakeAuthService].
abstract class AuthService {
  Future<void> signUp(
      {required String name, required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

void validateRegister(
    {required String name, required String email, required String password}) {
  if (name.trim().isEmpty) {
    throw ArgumentError('Nama perlu diisi.');
  }
  if (!email.contains('@')) {
    throw ArgumentError('Masukkan alamat email yang valid.');
  }
  if (password.length < 6) {
    throw ArgumentError('Password minimal 6 karakter.');
  }
}

String friendlyAuthError(Object e) {
  final msg = e.toString();
  if (msg.contains('User already registered') ||
      msg.contains('already been registered')) {
    return 'Email sudah terdaftar. Silakan masuk.';
  }
  if (msg.contains('Invalid login credentials')) {
    return 'Email atau password salah.';
  }
  if (msg.contains('Email not confirmed')) {
    return 'Email belum dikonfirmasi. Cek inbox lalu masuk.';
  }
  return 'Gagal autentikasi. Coba lagi.';
}

/// Implementasi asli Supabase. Trigger SQL `handle_new_user()` membuat `profiles`.
class SupabaseAuthService implements AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<void> signUp(
      {required String name,
      required String email,
      required String password}) async {
    validateRegister(name: name, email: email, password: password);
    try {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );
    } catch (e) {
      throw Exception(friendlyAuthError(e));
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth
          .signInWithPassword(email: email.trim(), password: password);
    } catch (e) {
      throw Exception(friendlyAuthError(e));
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: null,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      throw Exception(friendlyAuthError(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception(friendlyAuthError(e));
    }
  }
}

/// Double untuk widget test / mode tanpa Supabase: cek kredensial di memori.
/// Akun dummy `alea@skinsight.id` / `skinsight123` bawaan agar alur widget
/// test tetap jalan; akun baru ikut terdaftar lewat [signUp].
class FakeAuthService implements AuthService {
  final Map<String, String> _passwords = {'alea@skinsight.id': 'skinsight123'};

  @override
  Future<void> signUp(
      {required String name,
      required String email,
      required String password}) async {
    validateRegister(name: name, email: email, password: password);
    final key = email.trim();
    if (_passwords.containsKey(key)) {
      throw Exception('Email sudah terdaftar. Silakan masuk.');
    }
    _passwords[key] = password;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (_passwords[email.trim()] != password) {
      throw Exception('Email atau password salah.');
    }
  }

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}
