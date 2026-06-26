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
      appBar: AppBar(
        title: const Text('Riwayat Tugas Selesai'),
        backgroundColor: Colors.green.shade100,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Membaca data secara realtime yang statusnya HANYA 'selesai'
        stream: _supabase
            .from('maintenance_logs')
            .stream(primaryKey: ['id'])
            .eq('status', 'selesai')
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada tugas yang diselesaikan.', style: TextStyle(color: Colors.grey)),
            );
          }

          final completedTasks = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.verified, color: Colors.green, size: 32),
                  title: Text(task['title'] ?? 'Perbaikan Aset', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(task['description'] ?? 'Tidak ada deskripsi'),
                  trailing: const Text(
                    'Selesai',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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