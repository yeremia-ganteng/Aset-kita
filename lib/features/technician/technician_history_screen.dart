import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianHistoryScreen extends StatefulWidget {
  const TechnicianHistoryScreen({super.key});

  @override
  State<TechnicianHistoryScreen> createState() => _TechnicianHistoryScreenState();
}

class _TechnicianHistoryScreenState extends State<TechnicianHistoryScreen> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Riwayat Tugas Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade100,
        elevation: 0,
      ),
      body: 
StreamBuilder<List<Map<String, dynamic>>>(
  stream: _supabase
      .from('maintenance_logs')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    
    // Karena sudah difilter di atas, kita bisa langsung cek snapshot.data
    final completedTasks = snapshot.data ?? [];

    if (completedTasks.isEmpty) {
      return const Center(
        child: Text('Belum ada tugas yang diselesaikan.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedTasks.length,
itemBuilder: (context, index) {
  final task = completedTasks[index];

  // 1. Perbaikan Tanggal: Coba ambil updated_at, jika null ambil created_at
  final dateValue = task['updated_at'] ?? task['created_at'];
  final dateStr = dateValue != null 
      ? DateTime.parse(dateValue).toString().substring(0, 16) 
      : '-';

  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task['title'] ?? 'Perbaikan Aset',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              // 2. Perbaikan Chip: Ubah background ke warna lebih muda agar teks terlihat
              const Chip(
                label: Text('Selesai', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                backgroundColor: Color(0xFFE8F5E9), // Hijau sangat muda
              ),
            ],
          ),
          const Divider(height: 24),
          Text('Deskripsi: ${task['description'] ?? '-'}'),
          
          if (task['repair_notes'] != null && task['repair_notes'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🛠️ Catatan: ${task['repair_notes']}',
                style: TextStyle(fontSize: 13, color: Colors.indigo.shade900),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text('Selesai pada: $dateStr', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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