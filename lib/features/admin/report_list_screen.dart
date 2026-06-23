import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _supabase = Supabase.instance.client;

  // Fungsi untuk update status ke Supabase
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

  // --- TAMBAHAN: Fungsi untuk menampilkan foto ukuran penuh ---
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

  // Dialog untuk pilihan status
  void _showStatusDialog(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status Laporan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['dilaporkan', 'diproses', 'selesai'].map((status) {
            return ListTile(
              title: Text(status),
              leading: Icon(
                report['status'] == status ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Colors.blue,
              ),
              onTap: () {
                _updateStatus(report['id'], status);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
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
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  // --- TAMBAHAN: Thumbnail Foto di sisi kiri ---
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
                  subtitle: Text(report['description'] ?? 'Tanpa deskripsi'),
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