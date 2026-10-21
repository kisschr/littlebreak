# shared_preferences_android and path_provider_android call their Kotlin
# code from Dart through JNI (by class and method name) but ship no keep
# rules. Without these, R8 strips or renames that code in release builds
# and the app fails at start (NoSuchMethodError on
# SharedPreferencesApiRegistrar.getAll), leaving a black screen.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class kotlin.Unit { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.enums.EnumEntries { *; }
-keep class kotlin.jvm.internal.DefaultConstructorMarker { *; }
