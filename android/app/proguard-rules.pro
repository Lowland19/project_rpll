# Jangan hapus TFLite
-keep class org.tensorflow.** { *; }
-keep class java.nio.** { *; }

# Jika pakai plugin tflite_flutter
-dontwarn org.tensorflow.**
-keep class com.tflite_flutter.** { *; }

# Pertahankan native method
-keepclasseswithmembernames class * {
    native <methods>;
}