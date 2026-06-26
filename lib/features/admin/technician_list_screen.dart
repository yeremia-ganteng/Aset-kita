import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianListScreen extends StatelessWidget {
  const TechnicianListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Teknisi Lapangan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('profiles')
            .select('id, name, role')
            .or('role.eq.teknisi,role.eq.technician'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final technicians = snapshot.data ?? [];
          if (technicians.isEmpty) {
            return const Center(child: Text('Tidak ada teknisi terpantau.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final tech = technicians[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.engineering, color: Colors.green),
                  ),
                  title: Text(
                    tech['name'] ?? 'Nama Tidak Terisi',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Role: ${(tech['role'] ?? 'teknisi').toUpperCase()}'),
                  trailing: const Icon(Icons.circle, color: Colors.green, size: 12), // Indikator Aktif
                ),
              );
            },
          );
        },
      ),
    );
  }
}