# --- Kotlin Serialization ---
-keep class kotlinx.serialization.** { *; }
-keep class kotlinx.serialization.json.** { *; }
-keep class kotlinx.serialization.internal.** { *; }
-keepattributes *Annotation*

# --- SDK RBM (impedir obfuscación del SDK) ---
-keep class com.redeban.** { *; }
-keep class com.redeban.sdkqrcore.** { *; }
-keep class co.com.rbm.sdkqrcode.** { *; }

# Evitar que se eliminen KSerializer
-keepclassmembers class ** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Ktor
-dontwarn io.ktor.**
-keep class io.ktor.** { *; }

# Coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Arrow
-keep class arrow.core.** { *; }
-dontwarn arrow.core.**
