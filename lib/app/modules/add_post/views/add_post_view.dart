import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Kontroler lokal reaktif khusus untuk mengatur UI form postingan
class AddPostViewController extends GetxController {
  var selectedType = 'Barter'.obs;
  var selectedCategory = ''.obs;

  void setType(String type) => selectedType.value = type;
  void setCategory(String category) => selectedCategory.value = category;
}

class AddPostView extends StatelessWidget {
  const AddPostView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject kontroler agar Obx di bawah bisa mendeteksi perubahan state
    final uiController = Get.put(AddPostViewController());

    final List<String> categories = [
      'Perabotan',
      'Elektronik',
      'Pakaian',
      'Buku',
      'Lainnya',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // --- APP BAR ---
      appBar: AppBar(
        title: const Text(
          'Post Baru',
          style: TextStyle(
            color: Color(0xFF0F5238),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- UPLOAD FOTO BARANG ---
            const Text(
              'Foto Barang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 10),
            GridValuesArea(),
            const SizedBox(height: 6),
            const Text(
              'Unggah maksimal 5 foto barang Anda.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // --- TIPE POSTINGAN (Segmented Control) ---
            const Text(
              'Tipe Postingan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Obx(
                () => Row(
                  children: ['Barter', 'Dijual', 'Donasi'].map((type) {
                    bool isSelected = uiController.selectedType.value == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => uiController.setType(type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2D6A4F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            type,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF404943),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- INPUT TEXT FIELDS ---
            _buildInputField('Judul Barang', 'Contoh: Kursi Kayu Jati Bekas'),
            const SizedBox(height: 16),

            // --- CHIP KATEGORI ---
            const Text(
              'Kategori',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                return Obx(() {
                  bool isSelected = uiController.selectedCategory.value == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) uiController.setCategory(cat);
                    },
                    selectedColor: const Color(
                      0xFF2D6A4F,
                    ).withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2D6A4F)
                          : const Color(0xFF404943),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2D6A4F)
                            : Colors.grey[300]!,
                      ),
                    ),
                    showCheckmark: false,
                    backgroundColor: Colors.white,
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: 20),

            _buildInputField(
              'Deskripsi',
              'Ceritakan kondisi barang Anda dan alasan melepasnya...',
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // --- INPUT KONDISIONAL BERBASIS STATE ---
            Obx(() {
              if (uiController.selectedType.value == 'Donasi') {
                return const SizedBox(); // Donasi tidak butuh input tambahan harga/wishlist
              }
              bool isDijual = uiController.selectedType.value == 'Dijual';
              return _buildInputField(
                isDijual ? 'Harga (Rp)' : 'Ingin Barter Dengan',
                isDijual
                    ? 'Contoh: 50000'
                    : 'Sebutkan barang yang Anda inginkan...',
                isNumber: isDijual,
              );
            }),
            const SizedBox(height: 32),

            // --- BUTTON SUBMIT ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.snackbar(
                    'Sukses',
                    'Kontribusi sirkular kamu berhasil diposting!',
                    backgroundColor: Colors.white,
                  );
                },
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Posting Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF404943),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget internal untuk layout deretan slot foto paking rapi
class GridValuesArea extends StatelessWidget {
  const GridValuesArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: Color(0xFF2D6A4F),
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                'Tambah',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF2D6A4F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildMiniPlaceholder(),
        const SizedBox(width: 10),
        _buildMiniPlaceholder(),
      ],
    );
  }

  Widget _buildMiniPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Icon(Icons.image_outlined, color: Colors.grey[300], size: 28),
    );
  }
}
