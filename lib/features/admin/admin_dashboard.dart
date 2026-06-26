import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'report_list_screen.dart'; // Halaman untuk melihat daftar laporan masuk
// --- TAMBAHAN IMPORT UNTUK HALAMAN BARU ---
import 'asset_management_screen.dart';
import 'technician_list_screen.dart';
import 'activity_log_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Fungsi logout untuk kembali ke halaman login
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login'); // Pastikan route /login sesuai di main.dart Anda
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white, // Menjaga kontras teks putih pada AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang, Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kelola data aset, validasi laporan, dan distribusikan tugas perbaikan di sini.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Grid Menu Utama Admin
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Daftar Laporan',
                    icon: Icons.assignment_late,
                    color: Colors.orange,
                    onTap: () {
                      // Halaman list laporan masuk (Sudah Terhubung)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReportListScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Manajemen Aset',
                    icon: Icons.inventory,
                    color: Colors.blue,
                    onTap: () {
                      // --- DIKONEKSIKAN ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AssetManagementScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Daftar Teknisi',
                    icon: Icons.engineering,
                    color: Colors.green,
                    onTap: () {
                      // --- DIKONEKSIKAN ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TechnicianListScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Log Aktivitas',
                    icon: Icons.history,
                    color: Colors.purple,
                    onTap: () {
                      // --- DIKONEKSIKAN ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ActivityLogScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}