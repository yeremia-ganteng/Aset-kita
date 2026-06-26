import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../technician/technician_dashboard.dart';
// import 'staff/staff_dashboard.dart'; // Sesuaikan dengan lokasi dashboard staff kamu

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRole();
  }

  Future<void> _checkAuthAndRole() async {
    final session = _supabase.auth.currentSession;

    // 1. Jika sesi tidak ada, arahkan ke Login
    if (session == null) {
      _navigateTo('/login');
      return;
    }

    try {
      // 2. Ambil data role dari tabel profiles berdasarkan UID yang sedang login
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .single();

      final String? role = response['role'];

      // 3. Routing Berdasarkan Role
      if (role == 'technician') {
        _navigateTo('/technician_dashboard');
      } else if (role == 'staff') {
        _navigateTo('/staff_dashboard');
      } else {
        // Jika role tidak dikenali atau kosong
        await _supabase.auth.signOut();
        _navigateTo('/login', errorMessage: 'Akses ditolak: Akun tidak memiliki hak akses valid.');
      }
    } catch (e) {
      // Jika gagal mengambil profile (masalah jaringan atau data corrupt)
      await _supabase.auth.signOut();
      _navigateTo('/login', errorMessage: 'Gagal memuat profil pengguna. Silakan login kembali.');
    }
  }

  void _navigateTo(String routeName, {String? errorMessage}) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context, 
      routeName, 
      arguments: errorMessage
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menampilkan splash indicator sementara sistem menentukan rute
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'Mengecek Sesi & Hak Akses...',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}