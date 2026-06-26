import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({super.key});

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  final _supabase = Supabase.instance.client;
  
  final _assetCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController(); // TAMBAHAN: Controller Lokasi

  Future<void> _addAsset() async {
    final assetCode = _assetCodeController.text.trim();
    final assetName = _nameController.text.trim();
    final location = _locationController.text.trim();

    // Validasi input agar tidak ada yang kosong
    if (assetCode.isEmpty || assetName.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi!'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      // Menyesuaikan dengan struktur tabel 'assets' kamu
      await _supabase.from('assets').insert({
        'asset_code': assetCode, 
        'name': assetName,
        'location': location, // Mengisi kolom lokasi (NOT NULL)
      });

      _assetCodeController.clear();
      _nameController.clear();
      _locationController.clear();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aset baru berhasil disimpan!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah aset: $e'), 
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Aset Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _assetCodeController,
                decoration: const InputDecoration(
                  labelText: 'Kode / ID Aset',
                  hintText: 'Contoh: AC-001, COMP-02',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Aset',
                  hintText: 'Contoh: AC Split Daikin 2 PK',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // TAMBAHAN FIELD INPUT LOKASI
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Penempatan',
                  hintText: 'Contoh: Ruang Server Lt. 2',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _assetCodeController.clear();
              _nameController.clear();
              _locationController.clear();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _addAsset,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _assetCodeController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Aset'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase.from('assets').stream(primaryKey: ['id']).order('name'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data aset.', style: TextStyle(color: Colors.grey)));
          }

          final assets = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.inventory, color: Colors.white),
                  ),
                  title: Text(
                    asset['name'] ?? 'Aset Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Menampilkan Kode, Lokasi, dan Status bawaan 'baik' dari database kamu
                  subtitle: Text(
                    'Kode: ${asset['asset_code'] ?? '-'} | Status: ${asset['status']}\nLokasi: ${asset['location'] ?? '-'}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssetDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}