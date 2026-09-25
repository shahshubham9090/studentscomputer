# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

# Google Play Services & Firebase Rules
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.libraries.identity.googleid.** { *; }

# Prevent obfuscation of serializable / model classes if needed
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Flutter's deferred components support references Play Core split-install
# APIs that aren't included since this app doesn't use dynamic feature delivery.
-dontwarn com.google.android.play.core.**
