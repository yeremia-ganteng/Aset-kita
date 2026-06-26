import 'package:flutter/material.dart';
import 'auth_services.dart';
import 'register_screen.dart'; // Akan kita buat di langkah berikutnya
import '../../main.dart'; // Untuk referensi ke halaman dummy dashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // --- TAMBAHAN: Key untuk validasi form ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true; // --- TAMBAHAN: Mengontrol visibilitas password ---

  void _handleLogin() async {
    // --- TAMBAHAN: Validasi input form terlebih dahulu sebelum hit ke Supabase ---
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        // Cek role user dari tabel profiles
        final role = await _authService.getUserRole((user as dynamic).id);
        
        if (mounted) {
          // Arahkan user sesuai role mereka (Fungsi Asli Dipertahankan)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoleRoutingScreen(role: role),
            ),
          );
        }
      }
    } catch (e) {
      // Membersihkan teks 'Exception: ' jika ada agar pesan error lebih rapi
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // --- TAMBAHAN: Mencegah overflow saat keyboard muncul ---
      backgroundColor: Colors.grey.shade50, // --- TAMBAHAN: Background halus ---
      body: Center(
        child: SingleChildScrollView( // --- TAMBAHAN: Mencegah error layout pecah saat keyboard muncul ---
          padding: const EdgeInsets.only(left: 28, right: 28, bottom: 50),
          child: Form(
            key: _formKey, // --- TAMBAHAN: Pasang Form Key ---
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ikon Logo Aplikasi
                Icon(Icons.lock_person_outlined, size: 70, color: Colors.blue.shade700),
                const SizedBox(height: 16),
                
                const Text(
                  'AsetKita',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sistem Manajemen Pemeliharaan Fasilitas', 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 40),
                
                // Input Email (Diperbarui jadi TextFormField + Validator)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email', 
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                    // Cek format email regex
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                
                // Input Password (Diperbarui jadi TextFormField + Obscure Toggle + Validator)
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password', 
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password wajib diisi';
                    if (value.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Tombol Masuk dengan State Loading
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
// Ganti bagian ternary (if else) tombol Anda dengan ini:
:ElevatedButton(
  // Jika sedang loading, set onPressed ke null (tombol otomatis tidak bisa diklik)
  onPressed: _isLoading ? null : _handleLogin, 
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 1,
  ),
  child: _isLoading 
      ? const SizedBox(
          height: 20, 
          width: 20, 
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
      : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
),
                const SizedBox(height: 12),
                
                TextButton(
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const RegisterScreen())
                  ),
                  child: const Text('Belum punya akun? Daftar di sini', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}