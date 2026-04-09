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
    afterEvaluate {
        if (!plugins.hasPlugin("com.android.library")) return@afterEvaluate

        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate
        val getNamespace =
            androidExtension.javaClass.methods.find {
                it.name == "getNamespace" && it.parameterCount == 0
            } ?: return@afterEvaluate
        val setNamespace =
            androidExtension.javaClass.methods.find {
                it.name == "setNamespace" && it.parameterCount == 1
            } ?: return@afterEvaluate

        val currentNamespace = getNamespace.invoke(androidExtension) as? String
        if (currentNamespace.isNullOrBlank()) {
            val safeModuleName =
                project.name
                    .replace(Regex("[^A-Za-z0-9_]"), "_")
                    .trim('_')
                    .ifBlank { "library" }

            setNamespace.invoke(androidExtension, "com.mislecturas.$safeModuleName")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
