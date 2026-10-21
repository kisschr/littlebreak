# shared_preferences_android and path_provider_android call their Kotlin code
# from Dart through JNI. R8 cannot see those calls and strips the classes, so
# the app fails before its first frame. Keep the plugins, the JNI bridge and
# the Kotlin runtime they reach into.
-keep class io.flutter.plugins.** { *; }
-keep class com.github.dart_lang.jni.** { *; }
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**
