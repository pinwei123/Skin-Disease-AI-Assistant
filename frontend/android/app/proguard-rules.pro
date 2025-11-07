# Suppress warnings for missing GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
# Keep the GpuDelegateFactory$Options class
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
