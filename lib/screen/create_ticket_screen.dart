import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'ticket_data.dart';

class CreateTicketScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const CreateTicketScreen({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Hardware';
  Uint8List? _imageBytes;
  String? _imageName;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Tambah Lampiran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.photo_library, color: Colors.white)),
              title: const Text('Pilih dari Galeri'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.camera_alt, color: Colors.white)),
              title: const Text('Ambil Foto dari Kamera'),
              subtitle: const Text('Hanya tersedia di perangkat mobile', style: TextStyle(fontSize: 11)),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _submitTicket() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tiket tidak boleh kosong!')),
      );
      return;
    }
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi tidak boleh kosong!')),
      );
      return;
    }

    final newId = TicketData.generateId();
    final newDate = TicketData.getFormattedDate();

    // Tambah ke data global
    TicketData.tickets.insert(0, {
      'id': newId,
      'title': _titleController.text.trim(),
      'status': 'Menunggu',
      'date': newDate,
      'category': _selectedCategory,
      'history': [
        {'action': 'Tiket dibuat', 'time': '$newDate, ${TimeOfDay.now().format(context)}', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '$newDate, ${TimeOfDay.now().format(context)}', 'by': 'Sistem'},
      ],
    });

    _titleController.clear();
    _descController.clear();
    setState(() { _imageBytes = null; _imageName = null; });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Tiket $newId berhasil dibuat!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Buat Tiket Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Judul Tiket', prefixIcon: Icon(Icons.title), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category), border: OutlineInputBorder()),
            items: ['Hardware', 'Software', 'Network', 'Lainnya'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Deskripsi Masalah',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          if (_imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(_imageBytes!, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(_imageName ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: _showImageSourceDialog,
            icon: const Icon(Icons.attach_file),
            label: Text(_imageBytes == null ? 'Upload Lampiran / Foto' : 'Ganti Foto'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Kirim Tiket', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}