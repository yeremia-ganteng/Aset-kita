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

  // Helper Widget untuk membuat Step Indicator di bagian atas form
  Widget _buildStepItem(String title, bool isDone, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFDCFCE7) : (isActive ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_circle_rounded : Icons.lens,
            size: isActive ? 16 : 12,
            color: isDone ? const Color(0xFF16A34A) : (isActive ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive || isDone ? FontWeight.w800 : FontWeight.w500,
            color: isActive || isDone ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 PALET WARNA DECORATION PREMIUM
    const Color bgLight = Color(0xFFF8FAFC);       // Background canvas bersih
    const Color cardBg = Colors.white;             // Putih murni untuk komponen utama
    const Color textDark = Color(0xFF0F172A);      // Midnight slate teks utama
    const Color textMuted = Color(0xFF64748B);     // Abu penjelas teks sekunder
    const Color primaryBlue = Color(0xFF2563EB);   // Aksentuasi biru modern

    return Scaffold(
      backgroundColor: bgLight,
      // ─── APPBAR PREMIUM MINIMALIS ───
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 14),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Form Laporan Kerusakan',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w800, 
            color: textDark,
            letterSpacing: -0.4,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
        ),
      ),
      
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── STEPPER INDICATOR SEBAGAI PEMANIS UX (WAH EFFECT) ───
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStepItem('Scan Aset', true, false),
                    Container(width: 40, height: 2, color: const Color(0xFF16A34A)),
                    _buildStepItem('Isi Detail', false, true),
                    Container(width: 40, height: 2, color: const Color(0xFFE2E8F0)),
                    _buildStepItem('Kirim', false, false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── SLEEK ASSET DETECTED CARD ───
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: textDark.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Aset Terdeteksi',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textDark, letterSpacing: -0.2),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.verified_rounded, size: 10, color: Color(0xFF16A34A)),
                                      SizedBox(width: 2),
                                      Text('OK', style: TextStyle(color: Color(0xFF16A34A), fontSize: 9, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.assetId,
                              style: const TextStyle(
                                fontFamily: 'monospace', 
                                fontSize: 12, 
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── DESKRIPSI INPUT BLOCK ───
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'DETAIL KERUSAKAN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textMuted, letterSpacing: 0.6),
                ),
              ),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Contoh: AC tidak dingin, berbunyi bising, atau indikator lampu berkedip terus-menerus...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  filled: true,
                  fillColor: cardBg,
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // ─── INTERACTIVE FOTO ATTACHMENT CARD ───
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'LAMPIRAN BUKTI FISIK',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textMuted, letterSpacing: 0.6),
                ),
              ),
              _selectedImage != null
                  ? Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _selectedImage!, 
                                  height: 180, 
                                  width: double.infinity, 
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() => _selectedImage = null),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                            label: const Text('Hapus & Ambil Ulang', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    )
                  : InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.add_a_photo_rounded, color: primaryBlue, size: 32),
                            SizedBox(height: 10),
                            Text(
                              'Ambil Foto Kerusakan Aset',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gunakan kamera untuk bukti visual yang valid',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 36),
              
              // ─── PREMIUM ACTION SUBMIT BUTTON ───
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryBlue,
                        strokeWidth: 3,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _submitLaporan,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Kirim Laporan Resmi'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}