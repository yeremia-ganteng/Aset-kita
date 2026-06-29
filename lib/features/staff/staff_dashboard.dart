import 'dart:ui'; // Diperlukan untuk efek blur latar belakang
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aset_kita/features/staff/qr_scanner_screen.dart';
import 'package:aset_kita/features/staff/report_history_screen.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  // 🌟 LOGIKA & UI DIALOG KELUAR PREMIUM (WOW EFFECT)
  void _showLogoutConfirmation(BuildContext context, SupabaseClient supabase) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.4), // Overlay gelap halus
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        // Efek animasi scale + fade in yang sangat mulus
        final curvedValue = Curves.easeInOutBack.transform(anim1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -50, 0.0),
          child: Opacity(
            opacity: anim1.value,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // Efek frosted glass latar belakang
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.only(top: 28, left: 24, right: 24, bottom: 20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ikon Peringatan Keluar yang Eye-Catching
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Konfirmasi Keluar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Apakah Anda yakin ingin keluar dari akun ini? Anda harus login kembali untuk mengakses sistem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Tombol Aksi Horizontal
                    Row(
                      children: [
                        // Tombol Batal
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E293B),
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tombol Keluar (Destructive Action)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              Navigator.pop(context); // Tutup dialog
                              await supabase.auth.signOut();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                            child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final String userId = supabase.auth.currentUser?.id ?? '';

    final Color primaryBlue = const Color(0xFF1D4ED8); 
    final Color accentBlue = const Color(0xFF3B82F6);
    final Color lightBg = const Color(0xFFF8FAFC); 
    final Color textDark = const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: lightBg,
      body: Column(
        children: [
          // ─── HEADER CONTAINER WITH GRADIENT ───
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1E3A8A), primaryBlue],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.lock_person_outlined, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ASET_KITA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'SISTEM MANAJEMEN INFRASTRUKTUR STAF',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Tombol Keluar yang memicu Dialog Konfirmasi Premium
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                        onPressed: () => _showLogoutConfirmation(context, supabase),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Halo, Staf Operasional!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pantau dan laporkan kendala fasilitas dengan mudah.',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),

          // ─── BODY CONTENT ───
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                const Text(
                  'Status Laporan Anda',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                
                // StreamBuilder Realtime Grid Status
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: supabase
                      .from('maintenance_logs')
                      .stream(primaryKey: ['id'])
                      .eq('reporter_id', userId),
                  builder: (context, snapshot) {
                    int dilaporkan = 0;
                    int diproses = 0;
                    int selesai = 0;

                    if (snapshot.hasData) {
                      for (var log in snapshot.data!) {
                        String status = (log['status'] ?? '').toString().toLowerCase();
                        if (status == 'dilaporkan') dilaporkan++;
                        if (status == 'diproses') diproses++;
                        if (status == 'selesai') selesai++;
                      }
                    }

                    return Row(
                      children: [
                        _buildMetricCard('Dilaporkan', dilaporkan.toString(), const Color(0xFFFEF3C7), const Color(0xFFD97706), Icons.campaign_rounded),
                        const SizedBox(width: 12),
                        _buildMetricCard('Diproses', diproses.toString(), const Color(0xFFDBEAFE), const Color(0xFF2563EB), Icons.build_circle_rounded),
                        const SizedBox(width: 12),
                        _buildMetricCard('Selesai', selesai.toString(), const Color(0xFFD1FAE5), const Color(0xFF059669), Icons.task_alt_rounded),
                      ],
                    );
                  },
                ),

                // 🌟 PERUBAHAN UTAMA: Jarak diperlebar dari 28 ke 42 agar tata letak seimbang
                const SizedBox(height: 42),

                // AREA MENU SCAN QR CODE
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentBlue.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.qr_code_scanner_rounded, color: accentBlue, size: 42),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ada fasilitas atau aset yang rusak?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pindai QR Code yang tertempel pada aset untuk membuat laporan instan ke tim teknisi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      
                      // Tombol Scan QR Utama
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.center_focus_weak_rounded, size: 20),
                        label: const Text('Mulai Scan QR Aset', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      
                      // Tombol Riwayat Laporan
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E3A8A),
                          minimumSize: const Size(double.infinity, 50),
                          side: BorderSide(color: const Color(0xFF1E3A8A).withOpacity(0.3), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.history_toggle_off_rounded, size: 18),
                        label: const Text('Lihat Semua Riwayat Laporan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReportHistoryScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color bgColor, Color iconColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: iconColor),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}