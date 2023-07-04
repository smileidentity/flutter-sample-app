
-keepattributes **
-keepattributes *Annotation*
-keep class com.smileidentity.** { *; }
-keep class !android.support.v7.internal.view.menu.**, ** {
    !private <fields>;
    protected <fields>;
    public <fields>;
    <methods>;
}
-dontwarn
-ignorewarnings
-dontnote
-printconfiguration ~/temp/full-r8-config.txt
-printusage ~/temp/usage.txt