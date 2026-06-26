import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // 1. Fungsi Login
  Future<User?> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Email atau password salah.');
      }
      return response.user;
    } catch (e) {
      throw Exception('Gagal login: ${e.toString()}');
    }
  }

  // 2. Fungsi Register
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName, // Menyimpan nama ke metadata auth
          'role': role,          // Menyimpan role ke metadata auth
        },
      );

      if (response.user == null) {
        throw Exception('Gagal mendaftar. Silakan coba lagi.');
      }
    } catch (e) {
      throw Exception('Gagal registrasi: ${e.toString()}');
    }
  }

  // 3. Fungsi Get User Role
  Future<String> getUserRole(String userId) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      if (response['role'] == null) {
        throw Exception('Role tidak ditemukan pada profil ini.');
      }

      return response['role'] as String;
    } catch (e) {
      throw Exception('Gagal mengambil role user: ${e.toString()}');
    }
  }

  // 4. Fungsi Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService(); // Inisialisasi service

  @override
  void initState() {
    super.initState();
    _checkAuthAndRole();
  }

  Future<void> _checkAuthAndRole() async {
    final session = _supabase.auth.currentSession;

    // Jika sesi kosong, langsung lempar ke halaman login
    if (session == null) {
      _navigateTo('/login');
      return;
    }

    try {
      // Ambil role user menggunakan fungsi dari AuthService
      final String role = await _authService.getUserRole(session.user.id);

      // Routing disesuaikan dengan nilai string dari database ('teknisi', 'staf', 'admin')
      if (role == 'teknisi') {
        _navigateTo('/technician_dashboard');
      } else if (role == 'staf') {
        _navigateTo('/staff_dashboard');
      } else if (role == 'admin') {
        _navigateTo('/admin_dashboard'); 
      } else {
        // Jika nilai string role tidak terdefinisi
        await _authService.signOut();
        _navigateTo('/login', errorMessage: 'Akses ditolak: Peran pengguna tidak dikenali.');
      }
    } catch (e) {
      // Jika terjadi error saat fetch role, otomatis logout demi keamanan
      await _authService.signOut();
      _navigateTo('/login', errorMessage: 'Gagal memuat profil. Silakan masuk kembali.');
    }
  }

  void _navigateTo(String routeName, {String? errorMessage}) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context, 
      routeName, 
      arguments: errorMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'Memverifikasi Hak Akses...',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}