import 'dart:async';
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

  late Timer _timeTimer;
  String _greetingText = 'Selamat pagi,';
  String _shiftText = 'Shift Pagi';
  String _dateText = '';

@override
void initState() {
  super.initState();
  
  // 1. Ambil data log perawatan/laporan secara realtime
  _reportsStream = _supabase
      .from('maintenance_logs')
      .stream(primaryKey: ['id']);

  // 2. Ambil data aset secara realtime
  _assetsStream = _supabase
      .from('assets')
      .stream(primaryKey: ['id']);

  // 3. Ambil data profiles yang rolenya 'teknisi' secara realtime
  _techniciansStream = _supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('role', 'teknisi'); // Hanya memfilter pengguna dengan role teknisi

  // Sinkronisasi waktu tetap berjalan seperti biasa
  _updateRealtimeDateTime();
  _timeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
    _updateRealtimeDateTime();
  });
}

  @override
  void dispose() {
    _timeTimer.cancel();
    super.dispose();
  }

void _updateRealtimeDateTime() {
  final now = DateTime.now();
  final hour = now.hour;
  
  print('DEBUG KONSOL - Jam terbaca: $hour:${now.minute}');

  String greeting;
  String shift;

  // Sinkronisasi total antara Sapaan dan Shift berdasarkan jam
  if (hour >= 5 && hour < 11) {
    greeting = 'Selamat pagi,';
    shift = 'Shift Pagi';
  } else if (hour >= 11 && hour < 15) {
    greeting = 'Selamat siang,';
    shift = 'Shift Siang';
  } else if (hour >= 15 && hour < 18) {
    greeting = 'Selamat sore,';
    shift = 'Shift Sore';
  } else {
    greeting = 'Selamat malam,';
    shift = 'Shift Malam'; // Jam 21:29 akan langsung masuk ke sini
  }

  // Format Hari Berdasarkan Indeks Standar ISO
  final constDays = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: 'Jumat',
    6: 'Sabtu',
    7: 'Minggu'
  };
  
  final constMonths = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  String dayName = constDays[now.weekday] ?? 'Sabtu';
  String monthName = constMonths[now.month - 1];
  String formattedDate = '$dayName, ${now.day} $monthName ${now.year}';

  if (mounted) {
    setState(() {
      _greetingText = greeting;
      _shiftText = shift;
      _dateText = formattedDate;
    });
  }
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
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(height: 18),
              const Text(
                'Keluar dari Sistem?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda harus login kembali untuk mengakses konsol admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13, 
                  color: Color(0xFF64748B), 
                  height: 1.4
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Batal', 
                        style: TextStyle(fontFamily: 'Inter', color: Color(0xFF64748B), fontWeight: FontWeight.w600)
                      ),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF1552D2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Keluar', 
                        style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600)
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 275,
            decoration: const BoxDecoration(
              color: Color(0xFF1552D2),
            ),
          ),
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

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TOP NAVIGATION BAR
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.18),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.lock_person_outlined, color: Colors.white, size: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'ASET_KITA',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                Text(
                                                  'SISTEM MANAJEMEN INFRASTRUKTUR',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 8.5, 
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white70,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    //  TOMBOL KELUAR PREMIUM (Gaya minimalis melengkung halus - Glass Action)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _showLogoutConfirmation,
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.14),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.25),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Text(
                                            'Keluar',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // GREETINGS SECTION
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _greetingText,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.75),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Admin Utama',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_dateText • $_shiftText',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // STATS CARD ROW
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0F172A).withOpacity(0.04),
                                        blurRadius: 16,
                                        offset: const Offset(0, 10),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      _buildPillStatColumn('Laporan', reportCount, Icons.assignment_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF), 'Open', const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
                                      _buildVerticalDivider(),
                                      _buildPillStatColumn('Total Aset', assetCount, Icons.dashboard_customize_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5), 'Aktif', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
                                      _buildVerticalDivider(),
                                      _buildPillStatColumn('Staf Aktif', techCount, Icons.badge_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB), 'Idle', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
                                    ],
                                  ),
                                ),
                              ),

                              // MENU UTAMA TITLE
                              const Padding(
                                padding: EdgeInsets.only(left: 24, top: 8, bottom: 16),
                                child: Text(
                                  'MENU UTAMA',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),

                              // OPERATIONAL LIGHT GRID CONSOLE
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.05,
                                  children: [
                                    _buildCorporateMenuCard(
                                      title: 'Daftar Laporan',
                                      // Jika reportCount lebih dari 0, tampilkan jumlah antrean secara dinamis
                                      statusText: reportCount > 0 ? '$reportCount Antrean aktif' : 'Tidak ada antrean',
                                      microDesc: reportCount > 0 ? 'Perlu tindakan segera' : 'Sistem aman & kondusif',
                                      icon: Icons.assignment_rounded, 
                                      iconColor: const Color(0xFF2563EB),
                                      iconBg: const Color(0xFFEFF6FF),
                                      // Mengubah warna indikator bulat kecil menjadi merah jika ada antrean, atau hijau jika kosong
                                      statusColor: reportCount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportListScreen())),
                                    ),
                                    _buildCorporateMenuCard(
                                      title: 'Manajemen Aset',
                                      statusText: '$assetCount Unit terdaftar',
                                      microDesc: 'Sistem optimal 100%',
                                      icon: Icons.dashboard_customize_rounded, 
                                      iconColor: const Color(0xFF10B981),
                                      iconBg: const Color(0xFFECFDF5),
                                      statusColor: const Color(0xFF10B981),
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssetManagementScreen())),
                                    ),
                                    _buildCorporateMenuCard(
                                      title: 'Daftar Teknisi',
                                      statusText: '$techCount Personel aktif',
                                      microDesc: 'Tim siaga lapangan',
                                      icon: Icons.manage_accounts_rounded, 
                                      iconColor: const Color(0xFF6366F1),
                                      iconBg: const Color(0xFFF5F3FF),
                                      statusColor: const Color(0xFFF59E0B),
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicianListScreen())),
                                    ),
                                    _buildCorporateMenuCard(
                                      title: 'Log Aktivitas',
                                      statusText: 'Audit enkripsi',
                                      microDesc: 'Keamanan terjaga',
                                      icon: Icons.security_rounded, 
                                      iconColor: const Color(0xFF0284C7),
                                      iconBg: const Color(0xFFE0F2FE),
                                      statusColor: const Color(0xFF2563EB),
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityLogScreen())),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
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

  Widget _buildVerticalDivider() {
    return Container(
      width: 1.5,
      height: 70,
      color: const Color(0xFFF1F5F9),
    );
  }

  Widget _buildPillStatColumn(
    String label, int value, IconData icon, Color iconColor, Color iconBg,
    String badgeText, Color badgeTextColor, Color badgeBg
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg, 
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
            child: Text(
              badgeText,
              style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.bold, color: badgeTextColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateMenuCard({
    required String title,
    required String statusText,
    required String microDesc,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: iconColor.withOpacity(0.1),
          highlightColor: iconColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 24, color: iconColor),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor, 
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: statusColor.withOpacity(0.4), blurRadius: 4)
                        ]
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        statusText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  microDesc,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}