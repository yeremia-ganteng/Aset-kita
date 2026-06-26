import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'report_list_screen.dart';
import 'asset_management_screen.dart';
import 'technician_list_screen.dart';
import 'activity_log_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final SupabaseClient _supabase = Supabase.instance.client;

  late final Stream<List<Map<String, dynamic>>> _reportsStream;
  late final Stream<List<Map<String, dynamic>>> _assetsStream;
  late final Stream<List<Map<String, dynamic>>> _techniciansStream;

  @override
  void initState() {
    super.initState();
    _reportsStream = _supabase.from('reports').stream(primaryKey: ['id']);
    _assetsStream = _supabase.from('assets').stream(primaryKey: ['id']);
    _techniciansStream = _supabase.from('technicians').stream(primaryKey: ['id']);
  }

  Future<void> _logout() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AlertDialog(
            backgroundColor: const Color(0xFF070814).withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.25)),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Color(0xFFFCA5A5), size: 26),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Akhiri Sesi Kontrol?',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sistem akan mengunci akses dashboard sampai Anda memasukkan kembali kredensial login Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8), height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.white.withOpacity(0.12)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Batal', style: TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _logout();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFFE11D48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03030A),
      body: Stack(
        children: [
          // 🌌 1. DEEP MIDNIGHT BLUE DYNAMIC GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF050716), 
                  Color(0xFF0A0D25),
                  Color(0xFF04050F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🟣 2. CINEMATIC LIGHTING: PURPLE AMBIENT GLOW (Center Left)
          Positioned(
            top: 120,
            left: -90,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.22), 
                    const Color(0xFF6366F1).withOpacity(0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 🪐 3. CYAN AMBIENT GLOW (Bottom Right)
          Positioned(
            bottom: 60,
            right: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withOpacity(0.15), 
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 📄 4. MAIN INTERFACE LAYER
          SafeArea(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _reportsStream,
              builder: (context, reportSnapshot) {
                final reportCount = reportSnapshot.hasData ? reportSnapshot.data!.length : 0;

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _assetsStream,
                  builder: (context, assetSnapshot) {
                    final assetCount = assetSnapshot.hasData ? assetSnapshot.data!.length : 0;

                    return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _techniciansStream,
                      builder: (context, techSnapshot) {
                        final techCount = techSnapshot.hasData ? techSnapshot.data!.length : 0;

                        return CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // SCREEN NAVIGATION HEADER
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              sliver: SliverToBoxAdapter(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFA78BFA),
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: Color(0xFF7C3AED), blurRadius: 8, spreadRadius: 2)]
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'CORE INTERACTION',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFA78BFA),
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildMinimalistGlassButton(
                                      icon: Icons.power_settings_new_rounded,
                                      onTap: _showLogoutConfirmation,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 📝 UPDATED TITLE: ADMIN DASHBOARD
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Admin Dashboard',
                                      style: TextStyle(
                                        fontSize: 32, 
                                        fontWeight: FontWeight.w900, 
                                        color: Colors.white, 
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Manajemen infrastruktur beresolusi tinggi dengan pemantauan data realtime.',
                                      style: TextStyle(
                                        fontSize: 13, 
                                        color: Colors.white.withOpacity(0.4), 
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 📊 STATS CARDS WITH GLASSMORPHISM & RICH ICONS
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                              sliver: SliverToBoxAdapter(
                                child: Row(
                                  children: [
                                    _buildRichStatTile('Laporan', reportCount, Icons.assignment_late_rounded, const Color(0xFFF59E0B)),
                                    const SizedBox(width: 12),
                                    _buildRichStatTile('Total Aset', assetCount, Icons.business_center_rounded, const Color(0xFF3B82F6)),
                                    const SizedBox(width: 12),
                                    _buildRichStatTile('Staf Aktif', techCount, Icons.engineering_rounded, const Color(0xFF10B981)),
                                  ],
                                ),
                              ),
                            ),

                            // 🎴 GRID OF FOUR ULTRA-RICH HIGH FIDELITY MENU CARDS
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'KONSOL OPERASIONAL',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.35),
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.95, // Sedikit disesuaikan agar proporsinya pas & padat
                                      children: [
                                        _buildHighFidelityMenuCard(
                                          title: 'Daftar Laporan',
                                          subtitle: reportCount > 0 ? '$reportCount Masuk' : 'Tidak ada antrean',
                                          microDesc: 'Perlu tindakan segera',
                                          icon: Icons.folder_copy_outlined,
                                          accentColor: const Color(0xFFF59E0B),
                                          badgeCount: reportCount,
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportListScreen())),
                                        ),
                                        _buildHighFidelityMenuCard(
                                          title: 'Manajemen Aset',
                                          subtitle: '$assetCount Unit Terdaftar',
                                          microDesc: 'Sistem optimal 100%',
                                          icon: Icons.layers_outlined,
                                          accentColor: const Color(0xFF3B82F6),
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssetManagementScreen())),
                                        ),
                                        _buildHighFidelityMenuCard(
                                          title: 'Daftar Teknisi',
                                          subtitle: '$techCount Personel',
                                          microDesc: 'Tim siaga lapangan',
                                          icon: Icons.face_retouching_natural_outlined,
                                          accentColor: const Color(0xFF10B981),
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicianListScreen())),
                                        ),
                                        _buildHighFidelityMenuCard(
                                          title: 'Log Aktivitas',
                                          subtitle: 'Audit Enkripsi',
                                          microDesc: 'Keamanan terjaga',
                                          icon: Icons.wb_twilight_outlined,
                                          accentColor: const Color(0xFF8B5CF6),
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityLogScreen())),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistGlassButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: IconButton(
            icon: Icon(icon, size: 18, color: const Color(0xFFFDA4AF)),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  // Pengayaan Detail pada Tile Stat Atas agar tidak kosong
  Widget _buildRichStatTile(String label, int value, IconData icon, Color themeColor) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$value',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    Icon(icon, size: 14, color: themeColor.withOpacity(0.5)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.35), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💎 KARTU MENU UTAMA BARU: PREMIUM, REALISTIK, DAN PADAT INFORMASI (HIGH-FIDELITY)
  Widget _buildHighFidelityMenuCard({
    required String title,
    required String subtitle,
    required String microDesc,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            // Glowing Purple/Custom Border Tipis yang presisi di tepian kaca
            border: Border.all(
              color: accentColor.withOpacity(0.25), 
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.03),
                blurRadius: 16,
                spreadRadius: 1,
              )
            ],
          ),
          child: InkWell(
            onTap: onTap,
            splashColor: accentColor.withOpacity(0.12),
            highlightColor: accentColor.withOpacity(0.06),
            child: Stack(
              children: [
                // 🌌 Ornamen Geometris Abstrak di Background Card agar ruang tidak kosong
                Positioned(
                  bottom: -15,
                  right: -15,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withOpacity(0.04), width: 8),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris Atas: Ikon Realistik Bercahaya + Indikator Aksi (Chevron)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Kontainer Ikon dengan Efek Pancaran Cahaya 3D Nyata (Glow Shadows)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: -2,
                                )
                              ],
                            ),
                            child: Icon(icon, size: 22, color: accentColor),
                          ),
                          // Chevron bergaya minimalis elegan modern di pojok kanan
                          Icon(
                            Icons.arrow_forward_ios_rounded, 
                            size: 12, 
                            color: Colors.white.withOpacity(0.25)
                          ),
                        ],
                      ),
                      
                      const Spacer(),

                      // Baris Tengah & Bawah: Tipografi Padat, Berjenjang, & Informatif
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accentColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        microDesc,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                    ],
                  ),
                ),

                // Notifikasi Badge Mengambang jika ada data masuk
                if (badgeCount > 0)
                  Positioned(
                    top: 14,
                    right: 32, // Digeser sedikit agar tidak menabrak Chevron arrow
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFE11D48).withOpacity(0.4), blurRadius: 6)
                        ]
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}