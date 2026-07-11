# 🟢 JAGA TENSORFLOW LITE BIAR GAK DIHAPUS SAMA R8
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }

# Tambahan pelindung delegasi GPU TensorFlow jika ada dependency yang hilang
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.gpu.** { *; }