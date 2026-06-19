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

subprojects {
    if (project.name != "app") {
        tasks.configureEach {
            if (name.contains("stripReleaseDebugSymbols")) {
                enabled = false
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    val fixNamespaceAndJvm = Runnable {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                // 1. Fix Namespace if missing
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val namespace = getNamespace.invoke(android) as? String
                    if (namespace.isNullOrEmpty()) {
                        val manifestFile = project.file("src/main/AndroidManifest.xml")
                        if (manifestFile.exists()) {
                            val manifestText = manifestFile.readText()
                            val match = """package=["']([^"']+)["']""".toRegex().find(manifestText)
                            if (match != null) {
                                val pkg = match.groupValues[1]
                                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                                setNamespace.invoke(android, pkg)
                                println("Set namespace to $pkg for subproject ${project.name}")
                            }
                        }
                    }
                } catch (e: Exception) {
                    // Ignore
                }

                // 2. Fix Java target compatibility
                try {
                    val compileOptions = android.javaClass.getMethod("getCompileOptions").invoke(android)
                    val setSourceCompatibility = compileOptions.javaClass.getMethod("setSourceCompatibility", JavaVersion::class.java)
                    val setTargetCompatibility = compileOptions.javaClass.getMethod("setTargetCompatibility", JavaVersion::class.java)
                    setSourceCompatibility.invoke(compileOptions, JavaVersion.VERSION_17)
                    setTargetCompatibility.invoke(compileOptions, JavaVersion.VERSION_17)
                    println("Set compileOptions to Java 17 for subproject ${project.name}")
                } catch (e: Exception) {
                    // Ignore
                }
            }
        }

        // 3. Fix Kotlin compiler target compatibility
        try {
            project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
                compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
            println("Set Kotlin compile target to 17 for subproject ${project.name}")
        } catch (e: Throwable) {
            // Ignore
        }
    }

    if (project.state.executed) {
        fixNamespaceAndJvm.run()
    } else {
        project.afterEvaluate {
            fixNamespaceAndJvm.run()
        }
    }
}

