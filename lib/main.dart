import 'package:aset_kita/features/staff/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/auth_services.dart';
import 'package:aset_kita/features/staff/report_history_screen.dart';
import 'package:aset_kita/features/admin/admin_dashboard.dart'; // Menghubungkan file dashboard admin terpisah
import 'package:aset_kita/features/technician/technician_dashboard.dart'; // Dashboard teknisi


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bfqycitfmkgcjghbvthj.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmcXljaXRmbWtnY2pnaGJ2dGhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxODM2OTUsImV4cCI6MjA5Nzc1OTY5NX0.gBrmd95RK2dlL9Z1BLLv1yM7ULDEQ0s0d9NuWMyT9ho',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsetKita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Supabase.instance.client.auth.currentSession == null
          ? const LoginScreen()
          : FutureBuilder<String>(
              future: AuthService().getUserRole(Supabase.instance.client.auth.currentUser!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                return RoleRoutingScreen(role: snapshot.data ?? 'staf');
              },
            ),
      // Mendaftarkan rute login agar fungsi logout di dashboard admin bekerja dengan aman
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class RoleRoutingScreen extends StatelessWidget {
  final String role;
  const RoleRoutingScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'admin') return const AdminDashboard(); 
    if (role == 'teknisi') return const TechnicianDashboard(); 
    return const StaffDashboard();
  }
}

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Staf'),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Laporan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Ada fasilitas atau aset yang rusak?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan pindai QR Code yang tertempel pada aset untuk melaporkannya ke tim teknisi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Mulai Scan QR Aset'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12), 
            
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportHistoryScreen()),
                );
              },
              icon: const Icon(Icons.history_toggle_off),
              label: const Text('Lihat Riwayat Laporan Anda'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                side: BorderSide(color: Colors.blue.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}