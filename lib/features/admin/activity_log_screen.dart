import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    // 🎨 PALET WARNA TEMA: UNGU ROYAL & PUTIH PREMIUM
    final Color royalPurple = const Color(0xFF6D28D9); 
    final Color lightPurpleBg = const Color(0xFFF5F3FF); 
    final Color softGreyBorder = const Color(0xFFE2E8F0); 
    final Color textDark = const Color(0xFF1E293B); 

    // 🧪 KUSTOMISASI WARNA BADGE STATUS SESUAI DATA SKEMA LOG_STATUS ANDA
    Color getStatusBgColor(String status) {
      switch (status.toLowerCase()) {
        case 'selesai':
          return const Color(0xFFD1FAE5); // Hijau Soft
        case 'diproses':
          return const Color(0xFFDBEAFE); // Biru Soft
        case 'dilaporkan':
        default:
          return const Color(0xFFFEF3C7); // Kuning/Oranye Soft
      }
    }

    Color getStatusTextColor(String status) {
      switch (status.toLowerCase()) {
        case 'selesai':
          return const Color(0xFF065F46);
        case 'diproses':
          return const Color(0xFF1E40AF);
        case 'dilaporkan':
        default:
          return const Color(0xFF92400E);
      }
    }

    // 🕒 PARSING JAM MENGGUNAKAN KOLOM 'reported_at' SEUAI SKEMA DDL
    String formatDateTime(String? timestampStr) {
      if (timestampStr == null) return '-';
      try {
        final DateTime parsedDate = DateTime.parse(timestampStr).toLocal();
        return DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);
      } catch (e) {
        return '-';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: const Text(
          'Log Aktivitas Sistem',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: Colors.white),
        ),
        backgroundColor: royalPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Menggunakan primaryKey 'id' sesuai DDL Anda, diurutkan kronologis berdasarkan reported_at
        stream: supabase
            .from('maintenance_logs')
            .stream(primaryKey: ['id'])
            .order('reported_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: royalPurple));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada log aktivitas.',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            );
          }

          final logs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final status = log['status'] ?? 'dilaporkan';
              
              // Membaca tanggal masuk dari properti 'reported_at'
              final String formattedTime = formatDateTime(log['reported_at']);
              final String reporterId = log['reporter_id'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: softGreyBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: royalPurple.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌟 INDIKATOR IKON STATUS
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: lightPurpleBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          status == 'selesai' ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                          color: status == 'selesai' ? Colors.green : Colors.orange,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      
                      // 📝 KONTEN UTAMA
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: const Text(
                                    'Perbaikan Fasilitas', 
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formattedTime,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              log['description'] ?? 'Tanpa deskripsi',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.3),
                            ),
                            const SizedBox(height: 12),
                            
                            // 👤 BOTTOM SECTION: NAMA STAFF (DARI TABEL PROFILES) & BADGE STATUS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Menarik data nama pelapor asli secara asinkron dari tabel profiles dengan multi-fallback check
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: supabase
                                      .from('profiles')
                                      .select('*') 
                                      .eq('id', reporterId),
                                  builder: (context, profileSnapshot) {
                                    String staffName = 'Memuat nama...';

                                    if (profileSnapshot.hasData && profileSnapshot.data!.isNotEmpty) {
                                      final profile = profileSnapshot.data!.first;
                                      
                                      // Otomatis mendeteksi kolom nama yang tersedia pada tabel profiles Anda
                                      staffName = profile['nama'] ?? 
                                                  profile['full_name'] ?? 
                                                  profile['username'] ?? 
                                                  profile['name'] ?? 
                                                  'Staff Tanpa Nama';
                                    } else if (profileSnapshot.hasError) {
                                      staffName = 'Staff Aktif'; 
                                    }

                                    return Row(
                                      children: [
                                        Icon(Icons.account_circle_outlined, size: 14, color: royalPurple.withOpacity(0.6)),
                                        const SizedBox(width: 4),
                                        Text(
                                          staffName,
                                          style: TextStyle(color: royalPurple, fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                
                                // Badge Status
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: getStatusBgColor(status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10, 
                                      fontWeight: FontWeight.w900,
                                      color: getStatusTextColor(status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}