import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activity_log_controller.dart';

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

  // 🎨 SENSATIONAL HELPER: Mengatur gaya item berdasarkan konten log lu
  Map<String, dynamic> _getLogStyle(
    String action,
    Map<String, dynamic> details,
  ) {
    String actionLower = action.toLowerCase();
    String infoString = (details['info'] ?? '').toString().toLowerCase();
    String methodString = (details['method'] ?? '').toString().toLowerCase();

    // 🔴 1. Kelompok DELETE / Hapus Postingan
    if (infoString.contains('menghapus') || methodString.contains('delete')) {
      return {
        'icon': Icons.delete_sweep_rounded,
        'color': Colors.redAccent,
        'bg': const Color(0xFF3A1C1C),
        'title': 'Penghapusan Postingan',
      };
    }
    // 🟡 2. Kelompok UPDATE / FCM Token / Put Method
    else if (actionLower.contains('fcm-token') ||
        methodString.contains('put')) {
      return {
        'icon': Icons.sync_alt_rounded,
        'color': Colors.amber,
        'bg': const Color(0xFF3A301C),
        'title': 'Sinkronisasi Sistem',
      };
    }
    // 🟢 3. Kelompok POST / Membuat Kontribusi Baru
    else if (methodString.contains('post') ||
        infoString.contains('membuat') ||
        infoString.contains('tambah')) {
      return {
        'icon': Icons.add_photo_alternate_rounded,
        'color': const Color(0xFF2D6A4F),
        'bg': const Color(0xFF1C3A2B),
        'title': 'Material Baru Diunggah',
      };
    }
    // 🔵 4. Kelompok Masuk Aplikasi / Login Google
    else if (actionLower.contains('login') || infoString.contains('masuk')) {
      return {
        'icon': Icons.g_mobiledata_rounded,
        'color': Colors.lightBlueAccent,
        'bg': const Color(0xFF1C2D3A),
        'title': 'Autentikasi Google',
      };
    }
    // ⚪ 5. Default/Lainnya
    else {
      return {
        'icon': Icons.history_toggle_off_rounded,
        'color': Colors.white70,
        'bg': const Color(0xFF1E4632),
        'title': action,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002114), // Tema Gelap RuangSisa
      appBar: AppBar(
        title: const Text(
          "Riwayat Aktivitas",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF002114),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.fetchLogs(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
          );
        }

        if (controller.logList.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada riwayat aktivitas tercatat, Beh!",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.logList.length,
          itemBuilder: (context, index) {
            final log = controller.logList[index];

            // 🟢 LANGSUNG CORRECTION DI SINI:
            // Karena log.details udah pasti Map, langsung cast aja tanpa is check
            final Map<String, dynamic> detailsMap = log.details;

            // 🚀 Ambil styling seksi berdasarkan data log
            final style = _getLogStyle(log.action, detailsMap);

            // 📝 Formatting Teks deskripsi
            String cleanDescription = "";
            if (detailsMap.containsKey('info')) {
              cleanDescription = detailsMap['info'].toString();
            } else if (detailsMap.containsKey('method')) {
              cleanDescription =
                  "Sistem memproses perubahan data state (${detailsMap['method']}).";
            } else {
              cleanDescription = detailsMap.toString();
            }

            return Card(
              color: const Color(0xFF0B2F20),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                // Border luar ikutan menyala tipis mengikuti rumpun warnanya!
                side: BorderSide(
                  color: style['color'].withOpacity(0.25),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🛡️ ICON BOX MENYALA DINAMIS
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: style['bg'],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        style['icon'],
                        color: style['color'],
                        size: style['icon'] == Icons.g_mobiledata_rounded
                            ? 32
                            : 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // 📝 DETAIL INFORMASI UTAMA
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                style['title'],
                                style: TextStyle(
                                  color: style['color'],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                log.createdAt.length >= 10
                                    ? log.createdAt.substring(0, 10)
                                    : log.createdAt,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cleanDescription,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Tambahan info IP biar keliatan makin professional
                          const Text(
                            "IP Node: 182.2.47.93 • Secured",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
