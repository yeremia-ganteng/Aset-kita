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
  final _locationController = TextEditingController();

  // ✨ STATE MANAJEMEN BARU: PENCARIAN & FILTER
  String _searchQuery = '';
  String _selectedFilter = 'semua'; // semua, baik, rusak, perlu perbaikan, sedang diservis

  // 🎨 PALET WARNA TEMA: BIRU-PUTIH ELEGAN & PREMIUM
  final Color primaryBlue = const Color(0xFF1E40AF); // Sapphire / Electric Blue
  final Color lightBlueBg = const Color(0xFFEFF6FF); // Background Biru Sangat Muda
  final Color softGreyBorder = const Color(0xFFE2E8F0); // Border modern
  final Color textDark = const Color(0xFF1E293B); // Slate gelap untuk teks utama

  // 🧪 KUSTOMISASI WARNA BADGE STATUS DINAMIS
  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'baik':
        return const Color(0xFFD1FAE5); // Hijau Lembut
      case 'perlu perbaikan':
        return const Color(0xFFFEF3C7); // Kuning Lembut
      case 'sedang diservis':
        return const Color(0xFFDBEAFE); // Biru Lembut
      case 'rusak':
        return const Color(0xFFFEE2E2); // Merah Lembut
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'baik':
        return const Color(0xFF065F46);
      case 'perlu perbaikan':
        return const Color(0xFF92400E);
      case 'sedang diservis':
        return const Color(0xFF1E40AF);
      case 'rusak':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF475569);
    }
  }

  Future<void> _addAsset() async {
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
      await _supabase.from('assets').insert({
        'asset_code': assetCode, 
        'name': assetName,
        'location': location, 
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
          SnackBar(content: Text('Gagal menambah aset: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
        'status': status, 
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
    _assetCodeController.text = asset['asset_code'] ?? '';
    _nameController.text = asset['name'] ?? '';
    _locationController.text = asset['location'] ?? '';

    String selectedStatus = asset['status']?.toString() ?? 'baik';  

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( 
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Edit Data Aset', style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  TextField(
                    controller: _assetCodeController,
                    decoration: InputDecoration(labelText: 'Kode / ID Aset', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nama Aset', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Lokasi Penempatan', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Status Aset',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () => _updateAsset(asset['id'], selectedStatus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tambah Aset Baru', style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              TextField(
                controller: _assetCodeController,
                decoration: InputDecoration(
                  labelText: 'Kode / ID Aset',
                  hintText: 'Contoh: AC-001, COMP-02',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Aset',
                  hintText: 'Contoh: AC Split Daikin 2 PK',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Penempatan',
                  hintText: 'Contoh: Ruang Server Lt. 2',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: _addAsset,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan Aset', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Helper Widget Filter Chip Kustom
  Widget _buildFilterChip(String filterType, String label) {
    final bool isSelected = _selectedFilter == filterType;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filterType;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? primaryBlue : softGreyBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Latar belakang abu-putih super bersih
      appBar: AppBar(
        title: const Text(
          'Manajemen Aset',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR COMPONENT (Megah Terintegrasi AppBar)
          Container(
            color: primaryBlue,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16, top: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Cari nama atau kode aset...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 🏷️ FILTER CHIPS ROW COMPONENT
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: softGreyBorder)), 
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip('semua', 'Semua'),
                _buildFilterChip('baik', 'Baik'),
                _buildFilterChip('perlu perbaikan', 'Perlu Perbaikan'),
                _buildFilterChip('sedang diservis', 'Servis'),
                _buildFilterChip('rusak', 'Rusak'),
              ],
            ),
          ),

          // 📦 CONTAINER REALTIME STREAM DATA ASSETS
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase.from('assets').stream(primaryKey: ['id']).order('name'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryBlue));
                }
                
                final allAssets = snapshot.data ?? [];

                // Logic Filter & Pencarian secara Realtime dan Efisien
                final filteredAssets = allAssets.where((asset) {
                  final name = (asset['name'] ?? '').toString().toLowerCase();
                  final code = (asset['asset_code'] ?? '').toString().toLowerCase();
                  final status = (asset['status'] ?? 'baik').toString().toLowerCase();

                  final matchesSearch = name.contains(_searchQuery) || code.contains(_searchQuery);
                  final matchesFilter = _selectedFilter == 'semua' || status == _selectedFilter;

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredAssets.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data atau aset tidak ditemukan.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset = filteredAssets[index];
                    final String assetStatus = asset['status'] ?? 'baik';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: softGreyBorder),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        // Avatar dengan Icon Premium Bertema Biru
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: lightBlueBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.inventory_2_rounded, color: primaryBlue, size: 24),
                        ),
                        title: Text(
                          asset['name'] ?? 'Aset Tanpa Nama',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textDark),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kode: ${asset['asset_code'] ?? '-'}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                              Text('Lokasi: ${asset['location'] ?? '-'}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                              const SizedBox(height: 8),
                              // Badge Status Berwarna yang Indah & Dinamis
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(assetStatus),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  assetStatus.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.w900,
                                    color: _getStatusTextColor(assetStatus),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                        // Kelompok Aksi CRUD Edit & Delete yang Bersih
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                              onPressed: () => _showEditAssetDialog(asset),
                              tooltip: 'Edit Aset',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                              tooltip: 'Hapus Aset',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text('Hapus Aset', style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: Text('Apakah Anda yakin ingin menghapus "${asset['name']}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteAsset(asset['id']);
                                        },
                                        child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
          ),
        ],
      ),
      // FAB Mengikuti Skema Biru Sapphire yang Kontras Tinggi
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssetDialog,
        backgroundColor: primaryBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}