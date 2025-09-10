allprojects {
    repositories {
        google()
        mavenCentral()
        // ChannelTalk Android SDK repository
        // Note: ChannelTalk recommends dependencyResolutionManagement, but allprojects
        // approach is more compatible with Flutter projects
        maven { url = uri("https://maven.channel.io/maven2") }
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
