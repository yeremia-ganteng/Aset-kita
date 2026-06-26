import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({super.key});

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  final _supabase = Supabase.instance.client;
  final _nameController = TextEditingController();

  Future<void> _addAsset() async {
    if (_nameController.text.trim().isEmpty) return;

    try {
      await _supabase.from('assets').insert({
        'name': _nameController.text.trim(),
        // Tambahkan field lain jika ada di skema database Anda (misal: 'status': 'normal')
      });
      _nameController.clear();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah aset: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Aset Baru'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Aset',
            hintText: 'Contoh: AC Split Daikin 2 PK',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    _nameController.dispose();
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
                  subtitle: Text('ID: ${asset['id']}'),
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