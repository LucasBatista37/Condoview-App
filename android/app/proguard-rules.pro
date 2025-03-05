# Mantenha as classes anotadas pelo Google ErrorProne
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**

# Mantenha as anotações javax.annotation
-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

# Mantenha as classes do Google Crypto Tink
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Evita a remoção de métodos e classes utilizadas em runtime
-keepattributes *Annotation*

# Opcionalmente, desative a otimização para evitar erros
-dontoptimize