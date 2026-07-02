import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk mengatur kecerahan ikon status bar
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianHistoryScreen extends StatefulWidget {
  const TechnicianHistoryScreen({super.key});

  @override
  State<TechnicianHistoryScreen> createState() => _TechnicianHistoryScreenState();
}

class _TechnicianHistoryScreenState extends State<TechnicianHistoryScreen> {
  final _supabase = Supabase.instance.client;
  
  // Controller & State untuk fitur pencarian lokal secara real-time
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // MENJAGA FUNGSI ASLI: Menyimpan referensi stream di initState agar tidak re-subscribe saat mengetik search
  late final Stream<List<Map<String, dynamic>>> _maintenanceStream;

  @override
  void initState() {
    super.initState();
    _maintenanceStream = _supabase
        .from('maintenance_logs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Mengubah warna teks jam dan sinyal di status bar HP menjadi putih kontras
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Latar belakang abu-abu ultra-soft professional
        body: Column(
          children: [
            // ================= HEADER APPBAR PREMIUM (SERASI DENGAN GRADASI UTAMA) =================
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
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F1E40AF),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              child: Column(
                children: [
                  // Row Tombol Kembali & Judul
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Riwayat Tugas Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // FITUR BARU: Search Bar Terintegrasi Elegan
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari judul, deskripsi, atau catatan...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.7), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = "";
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= SEKSI UTAMA: REALTIME STREAM BUILDER SUPABASE =================
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _maintenanceStream, // Menggunakan referensi stream yang stabil
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1E40AF)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }
                  
                  final completedTasks = snapshot.data ?? [];

                  if (completedTasks.isEmpty) {
                    return const Center(
                      child: Text('Belum ada tugas yang diselesaikan.', style: TextStyle(color: Color(0xFF64748B))),
                    );
                  }

                  // MENJAGA FUNGSI ASLI + FILTER PENCARIAN REAL-TIME
                  final filteredTasks = completedTasks.where((task) {
                    final title = (task['title'] ?? 'Perbaikan Aset').toString().toLowerCase();
                    final description = (task['description'] ?? '-').toString().toLowerCase();
                    final repairNotes = (task['repair_notes'] ?? '').toString().toLowerCase();
                    
                    return title.contains(_searchQuery) || 
                           description.contains(_searchQuery) || 
                           repairNotes.contains(_searchQuery);
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('Hasil pencarian tidak ditemukan', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      // FUNGSI ASLI: Logika penanganan tanggal dipertahankan 100%
                      final dateValue = task['updated_at'] ?? task['created_at'];
                      final dateStr = dateValue != null 
                          ? DateTime.parse(dateValue).toString().substring(0, 16) 
                          : '-';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Baris Atas: Ikon Verified + Judul + Status Badge
                              Row(
                                children: [
                                  const Icon(Icons.verified, color: Color(0xFF10B981), size: 24),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      task['title'] ?? 'Perbaikan Aset',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 15,
                                        color: Color(0xFF1E293B)
                                      ),
                                    ),
                                  ),
                                  // FUNGSI ASLI: Chip warna dipertahankan dengan kecerahan kontras tinggi
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9), 
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Selesai', 
                                      style: TextStyle(
                                        fontSize: 11, 
                                        color: Colors.green, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                              const SizedBox(height: 12),
                              
                              // Seksi Deskripsi Kerusakan (Keterbacaan Ditingkatkan)
                              const Text(
                                'Deskripsi Kerusakan:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task['description'] ?? '-',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.3),
                              ),
                              
                              // Seksi Catatan Perbaikan Teknisi (Kondisional)
                              if (task['repair_notes'] != null && task['repair_notes'].toString().trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF), // Warna Indigo Soft Premium
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE0E7FF), width: 1),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('🛠️ ', style: TextStyle(fontSize: 14)),
                                      Expanded(
                                        child: Text(
                                          'Catatan: ${task['repair_notes']}',
                                          style: const TextStyle(
                                            fontSize: 13, 
                                            color: Color(0xFF312E81),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 14),
                              
                              // Waktu Penyelesaian (Warna dipertegas agar lolos standarisasi UI kontras tinggi)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.access_time_filled_rounded, size: 12, color: const Color(0xFF64748B).withOpacity(0.8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Selesai pada: $dateStr', 
                                    style: const TextStyle(
                                      fontSize: 11, 
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500
                                    ),
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
          ],
        ),
      ),
    );
  }
}