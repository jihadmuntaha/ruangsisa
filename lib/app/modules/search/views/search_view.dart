import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import '../controllers/search_controller.dart'; // Sesuaikan dengan path folder controller lu

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController controller = Get.put(SearchController());
    final List<String> hashtags = ['ZeroWaste', 'Preloved', 'Donasi', 'Barter'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 1. Search Bar Utama
              TextField(
                controller: controller.searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) =>
                    controller.triggerSearch(query: value.trim()),
                decoration: InputDecoration(
                  hintText: 'Cari furnitur, kain sisa, atau kontributor...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  suffixIcon: Obx(() {
                    if (controller.currentSearchQuery.value.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: () => controller.clearSearch(),
                      );
                    }
                    // Tombol filter advanced hanya muncul kalau tab Material aktif
                    return controller.activeTab.value == 'Material'
                        ? Container(
                            margin: const EdgeInsets.all(6),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA1F4C8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  _showFilterBottomSheet(context, controller),
                              child: const Text(
                                'Filter',
                                style: TextStyle(
                                  color: Color(0xFF1B724F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  }),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🟢 2. SWITCHER TAB GABUNGAN (MATERIAL V.S KONTRIBUTOR)
              Obx(
                () => Row(
                  children: ['Material', 'Kontributor'].map((tab) {
                    final bool isSelected = controller.activeTab.value == tab;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: tab == 'Material' ? 8 : 0,
                        ),
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFF2D6A4F)
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey[300]!,
                              ),
                            ),
                          ),
                          onPressed: () => controller.switchTab(tab),
                          child: Text(
                            tab == 'Material'
                                ? '📦 Cari Material'
                                : '👤 Cari Kontributor',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 🟢 3. CONDITIONAL FILTER AREA (Hanya muncul jika tab Material aktif & tidak sedang mencari spesifik)
              Obx(() {
                final bool isMaterialTab =
                    controller.activeTab.value == 'Material';
                final bool isSearching =
                    controller.currentSearchQuery.value.isNotEmpty;

                if (!isMaterialTab || isSearching) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Kapsul Kategori Horisontal
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categoriesList.length,
                        itemBuilder: (context, index) {
                          final cat = controller.categoriesList[index];
                          final int catId = cat['id'];
                          return Obx(() {
                            final bool isSelected =
                                controller.selectedCategoryId.value == catId;
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                showCheckmark: false,
                                avatar: Icon(
                                  cat['icon'],
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF2D6A4F),
                                ),
                                label: Text(
                                  cat['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF002114),
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF2D6A4F),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                onSelected: (_) =>
                                    controller.toggleCategory(catId),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Hashtag Tren
                    const Text(
                      'Sedang Tren',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002114),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: hashtags.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () =>
                              controller.searchByHashtag(hashtags[index]),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '#',
                                  style: TextStyle(
                                    color: Color(0xFF2D6A4F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    hashtags[index],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),

              // 🟢 4. SEKTOR RENDER HASIL DATA (BERCABANG SESUAI TAB YANG AKTIF)
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF2D6A4F),
                      ),
                    ),
                  );
                }

                // 🅰️ LOGIKA RENDER JIKA USER BERADA DI TAB MATERIAL
                if (controller.activeTab.value == 'Material') {
                  if (controller.searchResults.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentSearchQuery.value.isNotEmpty
                            ? 'Hasil Pencarian Spesifik'
                            : 'Item Populer di Sekitarmu',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002114),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: controller.searchResults.length,
                        itemBuilder: (context, index) {
                          final post = controller.searchResults[index];
                          String title = post['title'] ?? 'Material RuangSisa';
                          String postType = post['post_type'] ?? 'Gratis';
                          String imageUrl = post['images'] ?? '';

                          String labelPrice = postType;
                          Color labelColor = const Color(0xFF2D6A4F);
                          if (postType == "Dijual" && post['price'] != null) {
                            labelPrice = "Rp ${post['price']}";
                            labelColor = Colors.orange;
                          } else if (postType == "Barter") {
                            labelColor = Colors.blue;
                          } else if (postType == "Donasi") {
                            labelColor = Colors.purple;
                          }

                          return _buildGridItem(
                            title: title,
                            label: labelPrice,
                            labelColor: labelColor,
                            imageUrl: imageUrl,
                            baseUrl: controller.baseUrl,
                            authorName:
                                post['author']?['name'] ??
                                'Kontributor RuangSisa',
                            authorId: post['user_id'] ?? 0,
                            onTap: () => Get.toNamed(
                              '/post-detail',
                              arguments: {'post_id': post['id']},
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
                // 🆃️ LOGIKA RENDER JIKA USER BERADA DI TAB KONTRIBUTOR
                else {
                  if (controller.userResults.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daftar Kontributor RuangSisa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002114),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.userResults.length,
                        itemBuilder: (context, index) {
                          final user = controller.userResults[index];
                          String avatarUrl = user['avatar'] ?? '';

                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                backgroundImage: avatarUrl.isNotEmpty
                                    ? NetworkImage(
                                        avatarUrl.startsWith('http')
                                            ? avatarUrl
                                            : '${controller.baseUrl}$avatarUrl',
                                      )
                                    : null,
                                child: avatarUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              title: Text(
                                user['name'] ?? 'Kontributor',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                user['email'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF2D6A4F),
                              ),
                              onTap: () {
                                Get.toNamed(
                                  '/contributor-profile',
                                  arguments: {'user_id': user['id']},
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.layers_clear_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            const Text(
              "Data tidak ditemukan, Beh!",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // BottomSheet Filter Advanced dengan 4 Pilihan Jenis
  void _showFilterBottomSheet(
    BuildContext context,
    SearchController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Material 🎛️',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002114),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.resetAdvancedFilters();
                      Get.back();
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Tipe Postingan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Semua', 'Dijual', 'Barter', 'Donasi'].map((type) {
                  return Obx(() {
                    final bool isSelected =
                        controller.selectedPostType.value == type;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2D6A4F),
                        backgroundColor: Colors.grey[100],
                        onSelected: (_) =>
                            controller.selectedPostType.value = type,
                      ),
                    );
                  });
                }).toList(),
              ),
              const SizedBox(height: 20),
              Obx(() {
                final String currentType = controller.selectedPostType.value;
                if (currentType == 'Barter' || currentType == 'Donasi') {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rentang Harga (Rp)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.minPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Harga Min',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('—'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller.maxPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Harga Max',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    controller.triggerSearch(
                      query: controller.searchController.text.trim(),
                    );
                    Get.back();
                  },
                  child: const Text(
                    'Terapkan Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// Widget bento grid terpisah dengan parameter authorName & authorId
Widget _buildGridItem({
  required String title,
  required String label,
  required Color labelColor,
  required String imageUrl,
  required String baseUrl,
  required String authorName,
  required int authorId,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl.startsWith('http')
                                  ? imageUrl
                                  : '$baseUrl$imageUrl',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: labelColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Sektor klik nama author instan di bento grid
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      '/contributor-profile',
                      arguments: {'user_id': authorId},
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_circle_outlined,
                        size: 14,
                        color: Color(0xFF2D6A4F),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2D6A4F),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
