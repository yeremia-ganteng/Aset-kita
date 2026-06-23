import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. REGISTRASI (Sign Up) + Mengirim Metadata ke Trigger PostgreSQL kita
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'admin', 'teknisi', atau 'staf'
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );
    } catch (e) {
      throw Exception('Gagal mendaftar: ${e.toString()}');
    }
  }

  // 2. MASUK (Sign In)
  Future<User?> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception('Gagal masuk: ${e.toString()}');
    }
  }

  // 3. AMBIL PERAN USER (Get User Role dari Tabel Profiles)
  Future<String> getUserRole(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      
      return data['role'] as String;
    } catch (e) {
      return 'staf'; // Default jika terjadi error
    }
  }

  // 4. KELUAR (Sign Out)
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}