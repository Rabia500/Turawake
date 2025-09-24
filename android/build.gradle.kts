// Top-level build file where you can add configuration options common to all sub-projects/modules.

plugins {
    // ✅ Kotlin 2.1.0 plugin (required for latest Flutter support)
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.android.application") apply false
    id("com.android.library") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Use a common build directory outside each module
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
