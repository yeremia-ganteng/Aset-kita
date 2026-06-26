import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _supabase = Supabase.instance.client;

  // --- TAMBAHAN DATA STATE TEKNISI ---
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoadingTech = true;

  @override
  void initState() {
    super.initState();
    _fetchTechnicians(); // Mengambil data nama teknisi saat halaman dibuka
  }

  // --- TAMBAHAN FUNGSI: Mengambil daftar semua teknisi ---
  Future<void> _fetchTechnicians() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, name, role')
          .or('role.eq.teknisi,role.eq.technician'); 

      setState(() {
        _technicians = List<Map<String, dynamic>>.from(data);
        _isLoadingTech = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat teknisi: $e');
      setState(() => _isLoadingTech = false);
    }
  }

  // --- TAMBAHAN FUNGSI: Menugaskan teknisi & otomatis set status ke 'diproses' ---
  Future<void> _assignTechnician(String reportId, String techId) async {
    try {
      await _supabase
          .from('maintenance_logs')
          .update({
            'technician_id': techId,
            'status': 'diproses', // Otomatis naik status agar masuk ke device teknisi
          })
          .eq('id', reportId);
      
      setState(() {}); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teknisi berhasil ditugaskan & status diperbarui!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memplot teknisi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- TAMBAHAN HELPER: Mencari nama teknisi berdasarkan ID secara lokal ---
  String _getTechName(String? techId) {
    if (techId == null) return 'Belum ditugaskan';
    final tech = _technicians.firstWhere(
      (t) => t['id'].toString() == techId.toString(), 
      orElse: () => {},
    );
    return tech['name'] ?? 'Teknisi Tidak Dikenal';
  }

  // Fungsi untuk update status ke Supabase (ASLI)
  Future<void> _updateStatus(String reportId, String newStatus) async {
    try {
      await _supabase
          .from('maintenance_logs')
          .update({'status': newStatus})
          .eq('id', reportId);
      
      setState(() {}); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status diubah menjadi $newStatus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- TAMBAHAN: Fungsi untuk menampilkan foto ukuran penuh (ASLI) ---
  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  // Dialog untuk pilihan status (SEKARANG MENDUKUNG PLOTTING TEKNISI)
  void _showStatusDialog(Map<String, dynamic> report) {
    String? selectedTechId = report['technician_id'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Ditambahkan StatefulBuilder agar Dropdown di dalam dialog responsif
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Kelola Laporan Masuk'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ubah Status Kerja:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  ...['dilaporkan', 'diproses', 'selesai'].map((status) {
                    return ListTile(
                      title: Text(status),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        report['status'] == status ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: Colors.blue,
                      ),
                      onTap: () {
                        _updateStatus(report['id'].toString(), status);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                  
                  const Divider(height: 24),
                  
                  const Text('Tugaskan ke Teknisi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  _isLoadingTech
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedTechId,
                              hint: const Text('Pilih Teknisi Lapangan...'),
                              isExpanded: true,
                              items: _technicians.map((tech) {
                                return DropdownMenuItem<String>(
                                  value: tech['id'].toString(),
                                  child: Text(tech['name'] ?? 'Tanpa Nama'),
                                );
                              }).toList(),
                              onChanged: (newTechId) {
                                if (newTechId != null) {
                                  setDialogState(() {
                                    selectedTechId = newTechId;
                                  });
                                  _assignTechnician(report['id'].toString(), newTechId);
                                  Navigator.pop(context); // Tutup dialog setelah berhasil assign
                                }
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Laporan Masuk')),
      body: FutureBuilder(
        future: _supabase.from('maintenance_logs').select('*, assets(name)').order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          
          final reports = snapshot.data as List<dynamic>;
          if (reports.isEmpty) return const Center(child: Text('Belum ada laporan'));

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final status = report['status'] ?? 'dilaporkan';
              final imageUrl = report['image_url']; // Mengambil URL foto
              final String? currentTechId = report['technician_id'];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  // --- Thumbnail Foto di sisi kiri (ASLI) ---
                  leading: (imageUrl != null && imageUrl.isNotEmpty)
                      ? GestureDetector(
                          onTap: () => _showFullImage(imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  
                  title: Text(report['assets']?['name'] ?? 'Aset Tidak Dikenal'),
                  
                  // --- PEMBARUAN SUBTITLE: Menampilkan deskripsi SEKALIGUS nama teknisi yang bertugas ---
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report['description'] ?? 'Tanpa deskripsi'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.engineering, 
                            size: 14, 
                            color: currentTechId != null ? Colors.teal : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Teknisi: ${_getTechName(currentTechId)}',
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                              color: currentTechId != null ? Colors.teal : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  trailing: Chip(
                    label: Text(status),
                    backgroundColor: status == 'selesai' 
                        ? Colors.green.shade100 
                        : status == 'diproses' ? Colors.blue.shade100 : Colors.orange.shade100,
                  ),
                  onTap: () => _showStatusDialog(report), 
                ),
              );
            },
          );
        },
      ),
    );
  }
}