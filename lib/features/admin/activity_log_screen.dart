import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Aktivitas Sistem'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('maintenance_logs')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada log aktivitas.', style: TextStyle(color: Colors.grey)));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final status = log['status'] ?? 'dilaporkan';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(
                    status == 'selesai' ? Icons.check_circle : Icons.pending_actions,
                    color: status == 'selesai' ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    log['title'] ?? 'Perbaikan Fasilitas',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['description'] ?? 'Tanpa deskripsi'),
                      const SizedBox(height: 4),
                      Text(
                        'Status terakhir: ${status.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12, 
                          color: status == 'selesai' ? Colors.green.shade700 : Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
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