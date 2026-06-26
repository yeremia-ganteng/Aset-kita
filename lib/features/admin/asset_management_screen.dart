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

  // ==================== 🛠️ TAMBAHAN BARU: FUNGSI UPDATE & DELETE (PROFESIONAL) ====================

  Future<void> _updateAsset(dynamic id, String status) async {
    final assetCode = _assetCodeController.text.trim();
    final assetName = _nameController.text.trim();
    final location = _locationController.text.trim();

    if (assetCode.isEmpty || assetName.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi!'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await _supabase.from('assets').update({
        'asset_code': assetCode,
        'name': assetName,
        'location': location,
        'status': status, // Menyertakan status jika diperlukan 
      }).eq('id', id);

      _assetCodeController.clear();
      _nameController.clear();
      _locationController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data aset berhasil diperbarui!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui aset: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteAsset(dynamic id) async {
    try {
      await _supabase.from('assets').delete().eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aset berhasil dihapus!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus aset: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditAssetDialog(Map<String, dynamic> asset) {
    // Isi data awal ke textfield sebelum dialog tampil
    _assetCodeController.text = asset['asset_code'] ?? '';
    _nameController.text = asset['name'] ?? '';
    _locationController.text = asset['location'] ?? '';

    String selectedStatus = asset['status']?.toString() ?? 'baik'; // Default status jika null  

showDialog(
    context: context,
    builder: (context) => StatefulBuilder( // ✨ Menggunakan StatefulBuilder agar dropdown bisa berubah di dalam dialog
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Edit Data Aset'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _assetCodeController,
                  decoration: const InputDecoration(labelText: 'Kode / ID Aset', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Aset', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Lokasi Penempatan', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                
                // ✨ BARU: DROPDOWN PILIHAN STATUS
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status Aset',
                    border: OutlineInputBorder(),
                  ),
                  // 💡 PENTING: Isian di bawah ini HARUS sama persis (Capital/Kecilnya) dengan tipe ENUM di Supabase Anda
                  items: const [
                    DropdownMenuItem(value: 'baik', child: Text('baik')),
                    DropdownMenuItem(value: 'perlu perbaikan', child: Text('perlu perbaikan')),
                    DropdownMenuItem(value: 'rusak', child: Text('rusak')),
                    DropdownMenuItem(value: 'sedang diservis', child: Text('sedang diservis')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
                  },
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
              // ✨ Mengirimkan ID beserta Status yang dipilih ke fungsi update
              onPressed: () => _updateAsset(asset['id'], selectedStatus),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ),
  );
}

  // ==============================================================================================

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
          // Pencegahan loading terus jika terjadi error stream database
          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }
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
                  // Menggunakan trailing Row untuk menambahkan tombol Edit dan Hapus secara rapi
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditAssetDialog(asset),
                        tooltip: 'Edit Aset',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Hapus Aset',
                        onPressed: () {
                          // Konfirmasi hapus dialog profesional
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Aset'),
                              content: Text('Apakah Anda yakin ingin menghapus "${asset['name']}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteAsset(asset['id']);
                                  },
                                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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