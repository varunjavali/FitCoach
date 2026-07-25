allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Some plugins (e.g. the "record" package's native "jni" module) declare
// their own NDK requirement independent of android/app/build.gradle.kts,
// and default to whatever NDK ships with the current Flutter SDK. If that
// exact version isn't installed and can't be auto-downloaded (offline /
// blocked network), the build fails. This forces every sub-project onto
// the NDK version we already have installed locally.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            try {
                androidExt.javaClass
                    .getMethod("setNdkVersion", String::class.java)
                    .invoke(androidExt, "27.0.12077973")
            } catch (e: Exception) {
                // Sub-project has no ndkVersion property (doesn't use
                // native code) — nothing to do.
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
