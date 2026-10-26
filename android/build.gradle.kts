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

// Beberapa plugin masih meng-compile dengan compileSdk 34/35, padahal
// flutter_plugin_android_lifecycle (dan lainnya) mensyaratkan >= 36.
// Samakan semua modul plugin ke compileSdk 37 agar lolos AAR metadata check.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByType(com.android.build.api.dsl.LibraryExtension::class.java)
        if (androidExt != null) {
            val current = androidExt.compileSdk
            if (current == null || current < 37) {
                androidExt.compileSdk = 37
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
