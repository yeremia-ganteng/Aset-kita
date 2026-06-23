import 'dart:io'; // Penting untuk File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Penting untuk Kamera
import 'package:supabase_flutter/supabase_flutter.dart';

/// 1. DEFINE ENUM UNTUK STATUS LOG (Type-Safe & Profesional)
enum LogStatus { dilaporkan, diproses, selesai }

extension LogStatusX on LogStatus {
  String get toDbString {
    switch (this) {
      case LogStatus.dilaporkan:
        return 'dilaporkan';
      case LogStatus.diproses:
        return 'diproses';
      case LogStatus.selesai:
        return 'selesai';
    }
  }
}

class ReportFormScreen extends StatefulWidget {
  final String assetId;
  const ReportFormScreen({super.key, required this.assetId});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _descriptionController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  File? _selectedImage; // Tambahan untuk menyimpan file foto

  /// Fungsi untuk mengambil foto dari kamera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  /// Memvalidasi format UUID sebelum data dikirim ke Supabase
  bool _isValidUUID(String id) {
    final regExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return regExp.hasMatch(id);
  }

  void _submitLaporan() async {
    // Validasi input deskripsi kosong
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi kerusakan tidak boleh kosong!')),
      );
      return;
    }

    // Validasi defensif terhadap assetId hasil scan QR
    if (!_isValidUUID(widget.assetId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code tidak valid! Gunakan QR Code resmi aset.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      String? imageUrl;

      // --- AWAL FITUR FOTO ---
      // Upload ke Storage jika ada foto yang dipilih
      if (_selectedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage.from('maintenance-photos').upload(fileName, _selectedImage!);
        imageUrl = _supabase.storage.from('maintenance-photos').getPublicUrl(fileName);
      }
      // --- AKHIR FITUR FOTO ---

      // Memasukkan data laporan ke tabel maintenance_logs
      await _supabase.from('maintenance_logs').insert({
        'asset_id': widget.assetId,
        'description': _descriptionController.text.trim(),
        'reporter_id': user?.id,
        'status': LogStatus.dilaporkan.toDbString,
        'image_url': imageUrl, // Menyimpan link foto ke database
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan kerusakan berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke Dashboard
      }
    } on PostgrestException catch (e) {
      debugPrint('Supabase Database Error: ${e.message} (Code: ${e.code})');
      String friendlyMessage = 'Gagal mengirim laporan karena kendala sistem.';
      if (e.code == '23503') {
        friendlyMessage = 'Aset tidak terdaftar di sistem. Silakan hubungi admin.';
      } else if (e.message.contains('log_status')) {
        friendlyMessage = 'Status laporan tidak dikenali oleh database.';
      } else if (e.code == '42501') {
        friendlyMessage = 'Akses ditolak. Anda tidak memiliki izin untuk membuat laporan ini (RLS Policy).';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('Unexpected Error: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koneksi internet terganggu, silakan coba beberapa saat lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Laporan Kerusakan')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Aset yang discan
              Card(
                color: Colors.blue.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_2, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Aset Terdeteksi:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${widget.assetId}',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Input Deskripsi
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Masalah / Kerusakan',
                  hintText: 'Contoh: AC tidak dingin dan mengeluarkan bunyi bising...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              
              // --- TAMBAHAN UI FOTO ---
              _selectedImage != null
                  ? Column(
                      children: [
                        Image.file(_selectedImage!, height: 150),
                        TextButton(
                          onPressed: () => setState(() => _selectedImage = null),
                          child: const Text('Hapus Foto'),
                        ),
                      ],
                    )
                  : OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tambah Foto Kerusakan'),
                    ),
              const SizedBox(height: 32),
              
              // Tombol Kirim
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitLaporan,
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim Laporan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}