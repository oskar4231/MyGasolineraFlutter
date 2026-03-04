# ============================================================
# Flutter Core
# ============================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# ============================================================
# flutter_secure_storage - CRITICAL: evita crash al acceder KeyStore
# ============================================================
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.it_nomads.fluttersecurestorage.ciphers.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
# Mantener clases del KeyStore de Android que usa secure_storage
-keep class android.security.keystore.** { *; }
-keep class java.security.KeyStore { *; }
-keep class java.security.KeyStore$* { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ============================================================
# Isar Database - Librerías nativas (NO tocar con R8)
# ============================================================
-keep class dev.isar.** { *; }
-keep class isar.** { *; }
-keep class com.isar.** { *; }
-keepclassmembers class ** {
    @isar.annotations.* *;
}
# Mantener los esquemas Isar generados
-keep class **.IsarSchema { *; }
-keep class **Schema { *; }
-dontwarn dev.isar.**
-dontwarn isar.**

# ============================================================
# Google Maps
# ============================================================
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.**

# ============================================================
# Geolocator
# ============================================================
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# ============================================================
# Image Picker
# ============================================================
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# ============================================================
# Permission Handler
# ============================================================
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ============================================================
# URL Launcher
# ============================================================
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# ============================================================
# Shared Preferences
# ============================================================
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# ============================================================
# Package Info Plus
# ============================================================
-keep class io.flutter.plugins.packageinfo.** { *; }
-dontwarn io.flutter.plugins.packageinfo.**

# ============================================================
# File Picker
# ============================================================
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# ============================================================
# Share Plus
# ============================================================
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# ============================================================
# Cached Network Image
# ============================================================
-keep class com.github.bumptech.glide.** { *; }
-dontwarn com.github.bumptech.glide.**

# ============================================================
# Printing / PDF
# ============================================================
-keep class net.nfet.flutter.printing.** { *; }
-dontwarn net.nfet.flutter.printing.**

# ============================================================
# Google Play Core (para deferred components de Flutter)
# ============================================================
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ============================================================
# Google ML Kit Text Recognition
# ============================================================
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ============================================================
# App classes
# ============================================================
-keep class com.example.my_gasolinera.** { *; }

# ============================================================
# Apache Tika (dependencia transitiva del paquete excel)
# ============================================================
-dontwarn javax.xml.stream.XMLStreamException
-dontwarn org.apache.tika.**

# ============================================================
# Optimizaciones - CUIDADO: no tocar cast ni aritmética nativa
# ============================================================
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-allowaccessmodification
-repackageclasses ''

# ============================================================
# REGLAS CRÍTICAS PARA EVITAR CRASH DEL TECLADO Y FLUTTER ENGINE
# ============================================================
# Mantener atributos de Kotlin (Metadata es vital para reflexiones internas)
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod, Exceptions, RuntimeVisibleAnnotations
-keep class kotlin.Metadata { *; }

# Text Input / Teclado
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.plugin.platform.** { *; }
-keep class android.view.inputmethod.** { *; }

# Mantener métodos llamados desde C++ (JNI) por el motor de Flutter
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}
-keepclassmembers,allowshrinking,includedescriptorclasses class * {
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <methods>;
}

# No advertir sobre clases internas de AndroidX/Kotlin que puedan no estar presentes
-dontwarn kotlin.**
-dontwarn kotlinx.**
-dontwarn androidx.**
-dontwarn android.view.**
