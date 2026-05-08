import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DonationView extends StatelessWidget {
  const DonationView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0F5238), // Background hijau tua di peta
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // 1. Map Placeholder Section
          _buildMapPlaceholder(),

          // 2. Search & Filter Bar (Floating)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: _buildFloatingSearchBar(),
          ),

          // 3. Draggable Scrollable Sheet (Panel Panti Terdekat)
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const Icon(Icons.menu, color: Color(0xFF2D6A4F)),
      title: const Text('RuangSisa', 
        style: TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.w900)),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          onPressed: () => Get.toNamed('/cart'),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF143F2E), // Hijau lebih gelap untuk kesan peta
      ),
      child: Center(
        child: Icon(Icons.map_rounded, size: 200, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(child: Text('Tegal', style: TextStyle(color: Colors.black87))),
          Icon(Icons.tune, color: Color(0xFF2D6A4F)),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Panti Terdekat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('3 Lokasi', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              _buildPantiCard(
                'Panti Asuhan Harapan Bangsa',
                'Kec. Tegal Barat, Tegal',
                '2.5km',
                'Mendesak: Pakaian Anak',
                Colors.red[50]!,
              ),
              const SizedBox(height: 16),
              _buildPantiCard(
                'Yayasan Kasih Ibu',
                'Kec. Tegal Timur, Tegal',
                '4.1km',
                'Butuh: Sembako',
                Colors.orange[50]!,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPantiCard(String name, String loc, String dist, String alert, Color alertColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/80x80"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                          child: Text(dist, style: const TextStyle(fontSize: 10, color: Colors.green)),
                        )
                      ],
                    ),
                    Text(loc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: alertColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Text(alert, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
              child: const Text('Donasi di Sini', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}