import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'technician_task_screen.dart'; 
import 'technician_history_screen.dart'; 

class TechnicianDashboard extends StatefulWidget {
  const TechnicianDashboard({super.key});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard> {
  final _supabase = Supabase.instance.client;

  // --- FUNGSI ASLI: Dipertahankan 100% tanpa perubahan logika sedikit pun ---
  Future<void> _logout() async {
    try {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Latar belakang abu-abu ultra-soft agar card putih terlihat kontras
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER BANNER GRADIEN BIRU ROYAL (IDENTIK DENGAN OPERASIONAL) =================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E40AF), // Biru Royal Deep
                    Color(0xFF3B82F6), // Biru Terang Dinamis
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F1E40AF),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  )
                ]
              ),
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Row: Logo Aplikasi & Tombol Logout Lingkar Transparan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.lock_person_outlined, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ASET_KITA',
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.w800, 
                                  fontSize: 16,
                                  letterSpacing: 0.5
                                ),
                              ),
                              Text(
                                'SISTEM MANAJEMEN INFRASTRUKTUR',
                                style: TextStyle(
                                  color: Colors.white70, 
                                  fontWeight: FontWeight.w500, 
                                  fontSize: 9,
                                  letterSpacing: 0.3
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Tombol Logout Sesuai Tema
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                          onPressed: _logout, // Memanggil fungsi logout bawaan Anda
                          tooltip: 'Logout',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 36),
                  
                  // Greeting & Deskripsi Instruksi Utama
                  const Text(
                    'Selamat Bekerja! 🛠️',
                    style: TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      letterSpacing: -0.5
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan periksa instruksi, deskripsi, dan visual foto kerusakan aset yang telah divalidasi oleh Admin sebelum menuju ke lapangan.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85), 
                      fontSize: 13, 
                      height: 1.4
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // ================= SEKSI KONTEN MENU UTAMA =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DAFTAR MODUL TUGAS',
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF64748B), // Slate Grey modern
                      letterSpacing: 1.5
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- CARD MENU 1: TUGAS PERBAIKAN ASET ---
                  _buildPremiumMenuCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TechnicianTaskScreen()),
                      );
                    },
                    icon: Icons.build_circle_rounded,
                    iconColor: const Color(0xFF3B82F6), // Aksen Biru Tema Utama
                    bgColor: const Color(0xFFEFF6FF),
                    title: 'Tugas Perbaikan Aset',
                    subtitle: 'Lihat daftar & detail kerusakan aktif',
                  ),
                  
                  const SizedBox(height: 16),

                  // --- CARD MENU 2: RIWAYAT TUGAS SELESAI ---
                  _buildPremiumMenuCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TechnicianHistoryScreen()),
                      );
                    },
                    icon: Icons.check_circle_rounded,
                    iconColor: const Color(0xFF10B981), // Aksen Hijau Sukses
                    bgColor: const Color(0xFFECFDF5),
                    title: 'Riwayat Tugas Selesai',
                    subtitle: 'Semua perbaikan yang telah rampung',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Komponen reusable Helper Widget untuk mencetak Struktur Card Premium
  Widget _buildPremiumMenuCard({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Bulatan Ikon dengan Background Pastel Transparan yang Halus
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
                const SizedBox(width: 16),
                
                // Judul & Subtitle teks menu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF1E293B)
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                
                // Panah Navigasi Minimalis
                const Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}