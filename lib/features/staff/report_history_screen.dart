import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  void _initFetch() {
    _historyFuture = _fetchReportHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchReportHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User tidak terautentikasi');

    final response = await _supabase
        .from('maintenance_logs')
        .select('*, assets(name, asset_code)') 
        .eq('reporter_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // 🎨 CHIP STATUS PASTEL ULTRA-SOFT (NYAMAN DI MATA)
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'dilaporkan':
        backgroundColor = const Color(0xFFFEF7E0); // Kuning/Oranye Pastel Soft
        textColor = const Color(0xFFB06000);
        break;
      case 'diproses':
        backgroundColor = const Color(0xFFE8F0FE); // Biru Kerja Pastel Soft
        textColor = const Color(0xFF1A73E8);
        break;
      case 'selesai':
        backgroundColor = const Color(0xFFE6F4EA); // Hijau Kalem Pastel Soft
        textColor = const Color(0xFF137333);
        break;
      default:
        backgroundColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor, 
          fontSize: 10, 
          fontWeight: FontWeight.w900, 
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 PALET WARNA DECORATION UTAMA
    const Color bgLight = Color(0xFFF8FAFC);       // Background abu-abu ultra soft
    const Color cardBg = Colors.white;             // Putih bersih untuk kartu
    const Color textDark = Color(0xFF1E293B);      // Slate gelap lembut
    const Color textMuted = Color(0xFF64748B);     // Abu-abu penjelas
    const Color borderColor = Color(0xFFEDF2F7);   // Border super tipis halus

    return Scaffold(
      backgroundColor: bgLight,
      // ─── APPBAR PREMIUM MINIMALIS ───
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Laporan Anda',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w800, 
            color: textDark,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),
      
      body: RefreshIndicator(
        color: const Color(0xFF3B82F6),
        onRefresh: () async {
          setState(() {
            _initFetch();
          });
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Gagal memuat data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            final logs = snapshot.data ?? [];

            if (logs.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 64, color: textMuted.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada riwayat laporan.',
                          style: TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final asset = log['assets'] as Map<String, dynamic>?;

                // Format Waktu yang lebih bersih
                String formattedDate = '-';
                if (log['created_at'] != null) {
                  try {
                    formattedDate = DateTime.parse(log['created_at']).toLocal().toString().substring(0, 16);
                  } catch (_) {}
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ROW HEADER: ICON + NAMA ASET + STATUS CHIP
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.build_circle_outlined, color: Color(0xFF475569), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    asset?['name'] ?? 'Aset Tidak Diketahui',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800, 
                                      fontSize: 15,
                                      color: textDark,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Kode: ${asset?['asset_code'] ?? '-'}',
                                    style: const TextStyle(
                                      color: textMuted, 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(log['status'] ?? 'unknown'),
                          ],
                        ),
                        
                        // SEPARATOR GARIS HALUS INTERNAL KARTU
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Container(height: 1, color: const Color(0xFFF1F5F9)),
                        ),

                        // KONTEN DESKRIPSI
                        const Text(
                          'Deskripsi Kerusakan:',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log['description'] ?? '-',
                          style: const TextStyle(
                            fontSize: 13, 
                            color: textDark, 
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: 14),

                        // FOOTER WAKTU DENGAN ICON MINIMALIS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.access_time_rounded, color: textMuted, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}