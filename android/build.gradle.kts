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

    // Pub plugins pin older AGP/Kotlin in their buildscript blocks. Those plugins
    // fail to load on JDK 25, so force the classpath onto the app toolchain.
    buildscript {
        configurations.classpath {
            resolutionStrategy {
                force(
                    "com.android.tools.build:gradle:9.0.1",
                    "org.jetbrains.kotlin:kotlin-gradle-plugin:2.3.20",
                )
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
