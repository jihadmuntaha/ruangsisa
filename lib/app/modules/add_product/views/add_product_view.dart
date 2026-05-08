import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductView extends StatelessWidget {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk', style: TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildLabel("Foto Barang"),
          _buildImagePicker(),
          const SizedBox(height: 20),
          _buildLabel("Judul Barang"),
          _buildInputField("Contoh: Jam Tangan Analog Putih"),
          const SizedBox(height: 16),
          _buildLabel("Harga (Rp)"),
          _buildInputField("0", prefix: "Rp"),
          const SizedBox(height: 24),
          _buildCriteriaSection(),
          const SizedBox(height: 24),
          _buildImpactBanner(),
          const SizedBox(height: 32),
          _buildActionButton("Jual di Marketplace", const Color(0xFF0F5238)),
          const SizedBox(height: 12),
          _buildActionButton("Donasi Instan", const Color(0xFF7D562D)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF404943))),
    );
  }

  Widget _buildInputField(String hint, {String? prefix}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix != null ? "$prefix " : null,
        prefixStyle: const TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold),
        filled: true,
        fillColor: const Color(0xFFF3F4F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFC9C1), width: 2),
      ),
      child: const Center(child: Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 32)),
    );
  }

  Widget _buildCriteriaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kriteria Kelayakan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F5238))),
          const SizedBox(height: 8),
          _buildCheckItem("Barang Berfungsi Normal"),
          _buildCheckItem("Bersih & Tidak Berbau"),
          _buildCheckItem("Komponen Lengkap"),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, color: Color(0xFFA7F3D0), size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildImpactBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFDCBD), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          Icon(Icons.eco, color: Color(0xFF7D562D)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Menjual/mendonasikan barang ini menghemat ~2.4kg emisi CO2.',
              style: TextStyle(color: Color(0xFF623F18), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: () {},
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}