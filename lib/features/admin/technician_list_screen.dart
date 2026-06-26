import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianListScreen extends StatefulWidget {
  const TechnicianListScreen({super.key});

  @override
  State<TechnicianListScreen> createState() => _TechnicianListScreenState();
}

class _TechnicianListScreenState extends State<TechnicianListScreen> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Teknisi Lapangan'),
        backgroundColor: Colors.green, // Menyesuaikan warna tema appBar di screenshot kamu
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // PERBAIKAN: Memanggil 'full_name' dan filter 'role' sesuai ENUM database kamu ('teknisi')
        future: _supabase
            .from('profiles')
            .select('id, full_name, role, created_at')
            .eq('role', 'teknisi')
            .order('full_name', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final technicians = snapshot.data;
          if (technicians == null || technicians.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data teknisi.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final tech = technicians[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.greenAccent,
                    child: Icon(Icons.person, color: Colors.green),
                  ),
                  // PERBAIKAN: Menggunakan properti 'full_name' hasil select database
                  title: Text(
                    tech['full_name'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('Role: ${tech['role'] ?? 'teknisi'}'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // Logika navigasi detail teknisi jika diperlukan di kemudian hari
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}