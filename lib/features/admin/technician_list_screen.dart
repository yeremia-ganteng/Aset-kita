import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianListScreen extends StatefulWidget {
  const TechnicianListScreen({super.key});

  @override
  State<TechnicianListScreen> createState() => _TechnicianListScreenState();
}

class _TechnicianListScreenState extends State<TechnicianListScreen> {
  final _supabase = Supabase.instance.client;
  // Inisialisasi variabel stream
  late final Stream<List<Map<String, dynamic>>> _technicianStream;

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan tabel profiles yang rolenya teknisi secara realtime
    _technicianStream = _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('role', 'teknisi')
        .order('full_name', ascending: true);
  }

  // Helper Pemetaan Warna Status
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'idle':
        return const Color(0xFF10B981); // Emerald Green
      case 'on duty':
        return const Color(0xFFF59E0B); // Amber Yellow
      case 'offline':
      default:
        return const Color(0xFF64748B); // Slate Grey
    }
  }

  Color _getStatusBg(String? status) {
    switch (status?.toLowerCase()) {
      case 'idle':
        return const Color(0xFFD1FAE5);
      case 'on duty':
        return const Color(0xFFFEF3C7);
      case 'offline':
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Teknisi Lapangan',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFF10B981), 
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.engineering_rounded, color: Colors.white),
            ),
          )
        ],
      ),
      // PERBAIKAN: Mengubah FutureBuilder menjadi StreamBuilder agar realtime
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _technicianStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Inter', color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }

          final technicians = snapshot.data;
          if (technicians == null || technicians.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.supervised_user_circle_rounded, size: 72, color: Colors.grey.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada data teknisi.',
                    style: TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final tech = technicians[index];
              
              final String name = tech['full_name'] ?? 'Tanpa Nama';
              final String status = tech['status'] ?? 'offline';
              final String specialty = tech['specialty'] ?? 'Umum / Serbabisa';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5), 
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.person_rounded, color: Color(0xFF059669), size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _getStatusBg(status),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: _getStatusColor(status),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  specialty,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF10B981), size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Menghubungi $name...'),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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