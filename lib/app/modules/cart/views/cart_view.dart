import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya', style: TextStyle(color: Color(0xFF191C1D), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Review barang pilihanmu sebelum checkout.', style: TextStyle(color: Color(0xFF404943))),
          const SizedBox(height: 24),
          _buildCartItem("Sepatu Lari Nike", "Rp 150.000", "Pakaian"),
          _buildCartItem("Botol Bambu Organik", "Gratis", "Perabotan"),
          const SizedBox(height: 32),
          _buildShippingDetail(),
        ],
      ),
      bottomNavigationBar: _buildBottomCheckout(),
    );
  }

  Widget _buildCartItem(String title, String price, String category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Row(
        children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(category, style: const TextStyle(color: Color(0xFF0F5238), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(color: Color(0xFF0F5238), fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detail Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(20)),
          child: const Column(
            children: [
              Row(children: [Icon(Icons.location_on, size: 16), Text(" Jakarta Selatan, Indonesia")]),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Metode Transaksi"), Text("COD / Ambil Sendiri", style: TextStyle(color: Color(0xFF0F5238)))],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCheckout() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Pembayaran", style: TextStyle(color: Colors.grey)),
                  Text("Rp 150.000", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F5238))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5238), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () {},
              child: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}