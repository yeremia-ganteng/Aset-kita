import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _supabase = Supabase.instance.client;

  // State Manajemen Data Teknisi
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoadingTech = true;
  
  // Variabel penampung Stream untuk Realtime Data Laporan
  late final Stream<List<Map<String, dynamic>>> _reportsStream;

  // Warna Tema Deep Red & Putih
  final Color deepRed = const Color(0xFF991B1B); // Merah Deep / Crimson
  final Color lightRedBg = const Color(0xFFFEF2F2); // Merah sangat muda untuk background penanda
  final Color softGreyBorder = const Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _fetchTechnicians();
    
    // MENGUBAH KE REALTIME STREAM: Otomatis mendengarkan perubahan data laporan
    _reportsStream = _supabase
        .from('maintenance_logs')
        .stream(primaryKey: ['id'])
        .order('reported_at', ascending: false);
  }

  // Mengambil daftar semua teknisi untuk Dropdown Admin
  Future<void> _fetchTechnicians() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, full_name, role')
          .eq('role', 'teknisi');

      setState(() {
        _technicians = List<Map<String, dynamic>>.from(data);
        _isLoadingTech = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat teknisi: $e');
      setState(() => _isLoadingTech = false);
    }
  }

  // Menugaskan teknisi & otomatis memicu TRIGGER database menjadi 'on duty'
  Future<void> _assignTechnician(String reportId, String techId) async {
    try {
      await _supabase
          .from('maintenance_logs')
          .update({
            'technician_id': techId,
            'status': 'diproses', // Otomatis naik status agar trigger database mendeteksi ON DUTY
          })
          .eq('id', reportId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Teknisi berhasil ditugaskan & status diperbarui!'), 
            backgroundColor: deepRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memplot teknisi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Menghadirkan nama teknisi dari ID lokal
  String _getTechName(String? techId) {
    if (techId == null) return 'Belum ditugaskan';
    final tech = _technicians.firstWhere(
      (t) => t['id'].toString() == techId.toString(), 
      orElse: () => {},
    );
    return tech['full_name'] ?? 'Teknisi Tidak Dikenal';
  }

  // Update status manual via Radio Button
// Update status laporan DAN otomatis update status teknisi terkait
Future<void> _updateStatus(String reportId, String newStatus, String? technicianId) async {
  try {
    // 1. Update status laporan di maintenance_logs
    await _supabase
        .from('maintenance_logs')
        .update({'status': newStatus})
        .eq('id', reportId);
    
    // 2. LOGIKA OTOMATIS: Jika status laporan diubah menjadi 'selesai' dan ada teknisi yang ditugaskan
    if (newStatus == 'selesai' && technicianId != null) {
      await _supabase
          .from('profiles')
          .update({'status': 'idle'}) // Otomatis balik ke IDLE
          .eq('id', technicianId);
    } 
    // Jika status diubah kembali ke 'diproses', pastikan teknisi 'on duty'
    else if (newStatus == 'diproses' && technicianId != null) {
      await _supabase
          .from('profiles')
          .update({'status': 'on duty'})
          .eq('id', technicianId);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status laporan diperbarui menjadi $newStatus & status teknisi disinkronkan!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: deepRed,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update status: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

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

  // Tampilan Dialog Management yang Dipercantik dengan Tema Deep Red & Putih
  void _showStatusDialog(Map<String, dynamic> report) {
    String? selectedTechId = report['technician_id']?.toString();
    final String currentStatus = report['status'] ?? 'dilaporkan';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Kelola Laporan Masuk',
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ubah Status Kerja:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  ...['dilaporkan', 'diproses', 'selesai'].map((status) {
                    final bool isSelected = currentStatus == status;
                    return ListTile(
                      title: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? deepRed : Colors.black87
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? deepRed : Colors.grey,
                      ),
                      onTap: () {
                        _updateStatus(report['id'].toString(), status, report['technician_id']?.toString());
                        Navigator.pop(context);
                      },
                    );
                  }),
                  
                  const Divider(height: 32, thickness: 1),
                  
                  const Text('Tugaskan ke Teknisi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  _isLoadingTech
                      ? Center(child: CircularProgressIndicator(color: deepRed))
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            border: Border.all(color: softGreyBorder),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              value: _technicians.any((t) => t['id'].toString() == selectedTechId) ? selectedTechId : null,
                              hint: const Text('Pilih Teknisi Lapangan...', style: TextStyle(fontSize: 14)),
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: deepRed),
                              items: _technicians.map((tech) {
                                return DropdownMenuItem<String>(
                                  value: tech['id'].toString(),
                                  child: Text(tech['full_name'] ?? 'Tanpa Nama', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                );
                              }).toList(),
                              onChanged: (newTechId) {
                                if (newTechId != null) {
                                  setDialogState(() {
                                    selectedTechId = newTechId;
                                  });
                                  _assignTechnician(report['id'].toString(), newTechId);
                                  Navigator.pop(context); 
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
      backgroundColor: const Color(0xFFF8FAFC), // Latar belakang putih abu-abu bersih
      appBar: AppBar(
        title: const Text(
          'Daftar Laporan Masuk',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: deepRed, // Header menggunakan Merah Deep
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _reportsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: deepRed));
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(
              child: Text('Belum ada laporan', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final status = report['status'] ?? 'dilaporkan';
              final imageUrl = report['image_url']; 
              final String? currentTechId = report['technician_id'];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white, // Kartu Putih Bersih
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: softGreyBorder),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ]
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: (imageUrl != null && imageUrl.isNotEmpty)
                      ? GestureDetector(
                          onTap: () => _showFullImage(imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.image_not_supported_rounded, size: 28, color: Colors.grey),
                        ),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      report['asset_name'] ?? 'Aset Lapangan', 
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['description'] ?? 'Tanpa deskripsi',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      // Badge Penanda Plotting Teknisi bertema Merah Lembut / Abu-abu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentTechId != null ? lightRedBg : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.engineering_rounded, 
                              size: 14, 
                              color: currentTechId != null ? deepRed : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getTechName(currentTechId),
                              style: TextStyle(
                                fontSize: 11, 
                                fontWeight: FontWeight.w700,
                                color: currentTechId != null ? deepRed : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
trailing: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status == 'selesai' 
            ? const Color(0xFFD1FAE5) // Hijau Lembut untuk Selesai (Indikasi Sukses)
            : status == 'diproses' 
                ? const Color(0xFFEFF6FF) // Biru Lembut untuk Diproses
                : lightRedBg, // Merah Lembut jika masih 'dilaporkan'
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: status == 'selesai'
              ? const Color(0xFFA7F3D0)
              : status == 'diproses'
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFFEE2E2),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900, // Menggunakan FontWeight.w900 / Bold ekstrem agar terbaca jelas
          color: status == 'selesai' 
              ? const Color(0xFF065F46) // Hijau Gelap kontras
              : status == 'diproses' 
                  ? const Color(0xFF1E40AF) // Biru Gelap kontras
                  : deepRed, // Merah Deep untuk status antrean awal
        ),
      ),
    ),
  ],
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