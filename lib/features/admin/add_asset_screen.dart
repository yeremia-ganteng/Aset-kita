import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Jangan lupa import paket QR

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _codeController = TextEditingController(); // Input kode aset manual dari admin (misal: AC-001)
  bool _isLoading = false;

  // 🌟 LOGIKA DIALOG POP-UP QR CODE PREMIUM SETELAH BERHASIL SIMPAN
  void _showQrDialog(String assetName, String assetCode) {
    showDialog(
      context: context,
      barrierDismissible: false, // Admin harus menekan tombol "Selesai" untuk menutup
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aset Berhasil Terdaftar!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Text(
                'Silakan ambil tangkapan layar atau cetak QR Code di bawah untuk ditempelkan pada fisik $assetName.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 24),
              
              // 🎨 GENERATOR QR DINAMIS - LANGSUNG DARI APK BERDASARKAN KODE ASLI SUPABASE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: QrImageView(
                  data: assetCode, // QR Code akan berisi String kode aset (misal: AC-001)
                  version: QrVersions.auto,
                  size: 180.0,
                  gapless: false,
                ),
              ),
              
              const SizedBox(height: 12),
              Text(
                'KODE ASET: $assetCode',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'monospace', color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 24),
              
              // Tombol Tutup & Kembali
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7), // Biru corporate
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup Dialog
                  Navigator.pop(context); // Kembali ke halaman list aset utama
                },
                child: const Text('Selesai & Kembali', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🚀 LOGIKA KIRIM DATA KE SUPABASE
  Future<void> _insertAsset() async {
    if (_nameController.text.isEmpty || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua form wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String name = _nameController.text;
      final String code = _codeController.text;

      // Memasukkan data langsung ke tabel assets Anda di Supabase
      await _supabase.from('assets').insert({
        'name': name,
        'asset_code': code,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        // Tampilkan pop-up sukses beserta QR Codenya secara dinamis!
        _showQrDialog(name, code);
      }
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sisa visual UI Form input Admin Anda (TextField nama, kode, dan tombol simpan)
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Aset Baru')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Aset (Contoh: AC Split Daikin)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Kode Unik Aset (Contoh: AC-DKN-01)'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _insertAsset,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Daftarkan Aset'),
            )
          ],
        ),
      ),
    );
  }
}