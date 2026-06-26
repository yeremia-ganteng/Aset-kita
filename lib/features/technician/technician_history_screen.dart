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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('maintenance_logs')
            .stream(primaryKey: ['id'])
            .eq('technician_id', _supabase.auth.currentUser!.id)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada tugas selesai.'));
          }

          final completedTasks = snapshot.data!
              .where((task) => task['status'] == 'selesai')
              .toList();

          if (completedTasks.isEmpty) {
            return const Center(child: Text('Belum ada tugas yang diselesaikan.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              // Mengambil tanggal jika tersedia
              final dateStr = task['updated_at'] != null 
                  ? DateTime.parse(task['updated_at']).toString().substring(0, 16) 
                  : 'N/A';

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
                          const Chip(
                            label: Text('Selesai', style: TextStyle(fontSize: 12, color: Colors.green)),
                            backgroundColor: Colors.green,
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