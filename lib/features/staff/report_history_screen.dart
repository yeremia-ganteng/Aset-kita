import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  void _initFetch() {
    _historyFuture = _fetchReportHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchReportHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User tidak terautentikasi');

    final response = await _supabase
        .from('maintenance_logs')
        .select('*, assets(name, asset_code)') 
        .eq('reporter_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'dilaporkan':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'diproses':
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'selesai':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan Anda'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _initFetch();
          });
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyFuture,
          builder: (context, snapshot) { // FIX 1: Karakter ilegal '季' sudah dihapus
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Gagal memuat data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            final logs = snapshot.data ?? [];

            if (logs.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada riwayat laporan.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final asset = log['assets'] as Map<String, dynamic>?;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12), // FIX 2: Diubah dari EdgeInsets.bottom ke EdgeInsets.only
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // FIX 3: Diubah menjadi spaceBetween
                          children: [
                            Expanded(
                              child: Text(
                                asset?['name'] ?? 'Aset Tidak Diketahui',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(log['status'] ?? 'unknown'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kode: ${asset?['asset_code'] ?? '-'}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontFamily: 'monospace'),
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Deskripsi Kerusakan:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log['description'] ?? '-',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            DateTime.parse(log['created_at']).toLocal().toString().substring(0, 16),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
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
      ),
    );
  }
}