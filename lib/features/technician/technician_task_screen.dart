import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianTaskScreen extends StatefulWidget {
  const TechnicianTaskScreen({super.key});

  @override
  State<TechnicianTaskScreen> createState() => _TechnicianTaskScreenState();
}

class _TechnicianTaskScreenState extends State<TechnicianTaskScreen> {
  final _supabase = Supabase.instance.client;

  // --- TAMBAHAN KODE: Variabel state untuk mengontrol refresh data ---
  late Future<dynamic> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // --- TAMBAHAN KODE: Fungsi khusus penarik data dari Supabase ---
  void _fetchTasks() {
    _tasksFuture = _supabase
        .from('maintenance_logs')
        .select('*, assets(name)')
        .eq('status', 'diproses')
        .order('created_at', ascending: true);
  }

  // Fungsi untuk memperbarui progres tugas dari 'diproses' ke 'selesai'
  Future<void> _updateProgressToFinished(String reportId) async {
    try {
      await _supabase
          .from('maintenance_logs')
          .update({'status': 'selesai'})
          .eq('id', reportId);
      
      // --- PERUBAHAN: Segarkan data future terlebih dahulu baru panggil setState ---
      setState(() {
        _fetchTasks();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status progres berhasil diperbarui ke Selesai!'), 
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

  // Fungsi preview foto kerusakan ukuran penuh dengan fitur cubit/zoom (InteractiveViewer)
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Perbaikan Aktif'),
        backgroundColor: Colors.teal.shade100,
      ),
      body: FutureBuilder(
        // --- PERUBAHAN: Menggunakan variabel state agar pembaruan data bersifat reaktif ---
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final tasks = snapshot.data as List<dynamic>;
          if (tasks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Tidak ada tugas perbaikan aktif saat ini.\nSemua aset berjalan normal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final task = tasks[index];
              final imageUrl = task['image_url'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sisi Kiri: Preview Bukti Foto Kerusakan
                          GestureDetector(
                            onTap: () {
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                _showFullImage(imageUrl);
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: (imageUrl != null && imageUrl.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(imageUrl, fit: BoxFit.cover),
                                    )
                                  : const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Sisi Kanan: Nama Aset & Deskripsi Masalah
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['assets']?['name'] ?? 'Aset Tidak Diketahui',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  task['description'] ?? 'Tidak ada deskripsi dari pelapor.',
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      
                      // Bagian Bawah: Aksi Update Progres Kerusakan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // --- TAMBAHAN KODE: Membungkus elemen kiri dengan Expanded agar flexbox rapi ---
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Diproses',
                                    style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // --- PERUBAHAN: Membungkus teks panjang dengan Expanded agar tidak overflow ---
                                const Expanded(
                                  child: Text(
                                    'Klik foto untuk perbesar alat/suku cadang',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8), // Memberikan jarak aman sebelum tombol
                          ElevatedButton.icon(
                            onPressed: () => _updateProgressToFinished(task['id']),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Selesai'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }
}