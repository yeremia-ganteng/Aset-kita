import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aset_kita/features/staff/report_form_screen.dart'; 

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  BarcodeCapture? barcodeCapture;
  bool _isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code Aset')),
      body: Stack(
        children: [
          // Kamera Scanner
          MobileScanner(
            onDetect: (capture) async {
              if (_isScanCompleted) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _isScanCompleted = true; // Kunci scanner sementara
                
                final String assetId = barcodes.first.rawValue!;
                
                // Tampilkan indikator loading kecil agar user tahu aplikasi sedang mengecek data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memvalidasi kode aset...'),
                    duration: Duration(milliseconds: 800),
                  ),
                );

                try {
                  // 1. Cek ke tabel 'assets' apakah ID tersebut terdaftar
                  final data = await Supabase.instance.client
                      .from('assets') 
                      .select()
                      .eq('id', assetId)
                      .maybeSingle();

                  if (data != null) {
                    // 2. JIKA ASET DITEMUKAN -> Pindah ke form laporan
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportFormScreen(assetId: assetId),
                        ),
                      );
                    }
                  } else {
                    // 3. JIKA ASET TIDAK DITEMUKAN DI DATABASE
                    _isScanCompleted = false; // Buka kembali kunci scan
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Error: Aset tidak terdaftar di sistem!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  // 4. JIKA FORMAT KODE SALAH / BUKAN UUID (Format teks acak biasa)
                  _isScanCompleted = false; // Buka kembali kunci scan
                  if (context.mounted) {
                    String errorMessage = 'Teks QR Code bukan kode aset yang sah!';
                    
                    // Filter pesan error jika database mendeteksi kode error '22P02' (Bukan UUID)
                    if (e.toString().contains('22P02')) {
                      errorMessage = '⚠️ Format QR Code tidak dikenali (Bukan ID Aset)!';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }
            },
          ),
          
          // Overlay Garis Pemandu di Tengah Layar
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Teks Petunjuk di Bawah Layar
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke QR Code pada Aset',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                backgroundColor: Colors.black54,
              ),
            ),
          )
        ],
      ),
    );
  }
}