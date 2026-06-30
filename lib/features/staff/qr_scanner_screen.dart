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
      setState(() {
        _isScanCompleted = true; // Kunci scanner pertama kali
      });
      
      final String assetId = barcodes.first.rawValue!;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memvalidasi kode aset...'),
          duration: Duration(milliseconds: 500),
        ),
      );

      try {
        // Ganti 'id' dengan 'asset_code' jika QR Anda berisi teks kode kustom (misal: AST-001)
        final data = await Supabase.instance.client
            .from('assets') 
            .select()
            .eq('asset_code', assetId) 
            .maybeSingle();

        if (data != null) {
          final String trueUuidValue = data['id']; 
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ReportFormScreen(assetId: trueUuidValue),
              ),
            );
          }
        } else {
          // JIKA ASET TIDAK DITEMUKAN DI DATABASE
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Error: Aset tidak terdaftar di sistem!'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
          
          // ✨ Beri jeda 2 detik sebelum user bisa men-scan ulang agar tidak kena loop
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _isScanCompleted = false;
          });
        }
      } catch (e) {
        // JIKA FORMAT KODE SALAH / BUKAN UUID / KESALAHAN QUERY
        if (context.mounted) {
          String errorMessage = '⚠️ Teks QR Code bukan kode aset yang sah!';
          
          if (e.toString().contains('22P02')) {
            errorMessage = '⚠️ Format QR Code tidak dikenali (Bukan ID Aset)!';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2), // Batasi durasi snackbar
            ),
          );
        }

        // ✨ JANGAN langsung dibuka. Beri jeda 2.5 detik agar user punya waktu 
        // untuk menjauhkan kamera dari QR Code yang salah tersebut.
        await Future.delayed(const Duration(milliseconds: 2500));
        setState(() {
          _isScanCompleted = false; // Buka kunci setelah jeda selesai
        });
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