import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/auth_services.dart';
import 'package:aset_kita/features/admin/admin_dashboard.dart'; // Menghubungkan file dashboard admin terpisah
import 'package:aset_kita/features/technician/technician_dashboard.dart'; // Dashboard teknisi
import 'package:aset_kita/features/staff/staff_dashboard.dart';


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
    if (role == 'staf') return const StaffDashboard();
    return const Scaffold(body: Center(child: Text('Role tidak dikenali')));
  }
}
