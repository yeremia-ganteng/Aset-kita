import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Mengontrol warna ikon status bar perangkat
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianTaskScreen extends StatefulWidget {
  const TechnicianTaskScreen({super.key});

  @override
  State<TechnicianTaskScreen> createState() => _TechnicianTaskScreenState();
}

// ================= PERBAIKAN: Nama kelas disesuaikan menjadi _TechnicianTaskScreenState =================
class _TechnicianTaskScreenState extends State<TechnicianTaskScreen> {
  final _supabase = Supabase.instance.client;

  // --- FUNGSI ASLI: Dipertahankan 100% ---
  late Future<dynamic> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // --- FUNGSI ASLI: Dipertahankan 100% ---
  void _fetchTasks() {
    _tasksFuture = _supabase
        .from('maintenance_logs')
        .select('*, assets(name)')
        .eq('status', 'diproses')
        .eq('technician_id', Supabase.instance.client.auth.currentUser!.id)
        .order('created_at', ascending: true);
  }

  // --- FUNGSI ASLI: Dipertahankan 100% ---
  Future<void> _updateProgressToFinished(String reportId, String repairNotes) async {
    try {
      await _supabase
          .from('maintenance_logs')
          .update({
            'status': 'selesai',
            'repair_notes': repairNotes,
          })
          .eq('id', reportId);
      
      setState(() {
        _fetchTasks();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status progres berhasil diperbarui ke Selesai! 🎉'), 
            backgroundColor: Colors.green
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui progres: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FUNGSI ASLI: Dipertahankan 100% ---
  void _showRepairNotesDialog(String reportId) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Penyelesaian', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tindakan teknis wajib diisi sebelum menutup tugas ini:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Catatan Perbaikan / Tindakan',
                hintText: 'Contoh: Berhasil mengganti sekring RAM & membersihkan debu...',
                hintStyle: const TextStyle(fontSize: 13),
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E40AF), width: 2),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              if (notesController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catatan perbaikan wajib diisi!'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context);
              _updateProgressToFinished(reportId, notesController.text.trim());
            },
            child: const Text('Simpan & Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI ASLI: Dipertahankan 100% ---
  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), 
        body: Column(
          children: [
            // ================= HEADER APPBAR PREMIUM GRADIENT =================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E40AF), 
                    Color(0xFF3B82F6), 
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(color: Color(0x1F1E40AF), blurRadius: 16, offset: Offset(0, 8))
                ],
              ),
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tugas Perbaikan Aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ================= BODY UTAMA: FUTURE BUILDER =================
            Expanded(
              child: FutureBuilder(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1E40AF)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }

                  final tasks = snapshot.data as List<dynamic>;
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gpp_good_rounded, size: 64, color: Color(0xFF10B981)),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada tugas perbaikan aktif saat ini.\nSemua aset berjalan normal.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final imageUrl = task['image_url'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (imageUrl != null && imageUrl.isNotEmpty) {
                                        _showFullImage(imageUrl);
                                      }
                                    },
                                    child: Container(
                                      width: 76,
                                      height: 76,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: (imageUrl != null && imageUrl.isNotEmpty)
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(imageUrl, fit: BoxFit.cover),
                                            )
                                          : const Icon(Icons.image_not_supported, color: Colors.grey, size: 28),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task['assets']?['name'] ?? 'Aset Tidak Diketahui',
                                          style: const TextStyle(
                                            fontSize: 16, 
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B)
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          task['description'] ?? 'Tidak ada deskripsi dari pelapor.',
                                          style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.3),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (imageUrl != null && imageUrl.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 10.0, bottom: 2.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF3B82F6)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Ketuk foto untuk perbesar alat/suku cadang',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6), fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),

                              const Divider(color: Color(0xFFF1F5F9), height: 24, thickness: 1),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0), 
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Diproses',
                                      style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  
                                  ElevatedButton.icon(
                                    onPressed: () => _showRepairNotesDialog(task['id'].toString()),
                                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                                    label: const Text('Selesai'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981), 
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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