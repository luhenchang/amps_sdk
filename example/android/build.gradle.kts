allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            name = "myrepo"
            url = uri("file://Users/wangfeiwangfei/wangfei/GitHub/ad_scope_sdk_project/amps_sdk/android/m2repository")
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
