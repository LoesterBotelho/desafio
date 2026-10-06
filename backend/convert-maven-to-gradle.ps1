$ErrorActionPreference = "Stop"

Clear-Host

# ==========================================================
# Environment
# ==========================================================

$ProjectPath = "C:\dev\eclipse-workspace\desafio\backend"

$JavaHome = "C:\dev\jdk-25.0.4.1"
$MavenHome = "C:\dev\maven-3.10.0"
$GradleHome = "C:\dev\gradle-9.8.0"
$NodeHome = "C:\dev\node-v24.21.0-win-x64"

$env:JAVA_HOME = $JavaHome
$env:MAVEN_HOME = $MavenHome
$env:GRADLE_HOME = $GradleHome
$env:NODE_HOME = $NodeHome

$env:Path = "$JavaHome\bin;$MavenHome\bin;$GradleHome\bin;$NodeHome;$env:Path"

# ==========================================================
# Header
# ==========================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "             MAVEN TO GRADLE CONVERTER" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Project:"
Write-Host "    $ProjectPath"
Write-Host ""

# ==========================================================
# Functions
# ==========================================================

function Write-Section {
    param (
        [string]$Number,
        [string]$Title
    )

    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "[$Number] $Title" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Stop-WithError {
    param (
        [string]$Message
    )

    Write-Host ""
    Write-Host "ERROR: $Message" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# ==========================================================
# Validate environment
# ==========================================================

Write-Host "Environment:"
Write-Host "    JAVA_HOME   : $env:JAVA_HOME"
Write-Host "    MAVEN_HOME  : $env:MAVEN_HOME"
Write-Host "    GRADLE_HOME : $env:GRADLE_HOME"
Write-Host "    NODE_HOME   : $env:NODE_HOME"
Write-Host ""

if (-not (Test-Path -LiteralPath $JavaHome -PathType Container)) {
    Stop-WithError "Java directory not found: $JavaHome"
}

if (-not (Test-Path -LiteralPath $MavenHome -PathType Container)) {
    Stop-WithError "Maven directory not found: $MavenHome"
}

if (-not (Test-Path -LiteralPath $GradleHome -PathType Container)) {
    Stop-WithError "Gradle directory not found: $GradleHome"
}

# ==========================================================
# Validate project
# ==========================================================

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    Stop-WithError "Project directory not found: $ProjectPath"
}

Set-Location -LiteralPath $ProjectPath

# ==========================================================
# [1/8] Checking Maven project
# ==========================================================

Write-Section "1/8" "Checking Maven project"

if (-not (Test-Path -LiteralPath "pom.xml" -PathType Leaf)) {
    Stop-WithError "pom.xml not found."
}

Write-Host "OK: pom.xml found." -ForegroundColor Green

Write-Host ""
Write-Host "Reading Maven configuration..."

try {
    [xml]$Pom = Get-Content -LiteralPath "pom.xml" -Raw
}
catch {
    Stop-WithError "Could not read pom.xml."
}

$ProjectGroupId = $Pom.project.groupId

if (-not $ProjectGroupId) {
    $ProjectGroupId = $Pom.project.parent.groupId
}

$ProjectArtifactId = $Pom.project.artifactId
$ProjectVersion = $Pom.project.version

$SpringBootVersion = $Pom.project.parent.version
$JavaVersion = $Pom.project.properties."java.version"

$JunitVersion = $Pom.project.properties."junit.version"
$MockitoVersion = $Pom.project.properties."mockito.version"
$JjwtVersion = $Pom.project.properties."jjwt.version"
$MapstructVersion = $Pom.project.properties."mapstruct.version"
$SpringdocVersion = $Pom.project.properties."springdoc.version"

if (-not $ProjectGroupId) {
    Stop-WithError "Could not determine Maven groupId."
}

if (-not $ProjectArtifactId) {
    Stop-WithError "Could not determine Maven artifactId."
}

if (-not $ProjectVersion) {
    Stop-WithError "Could not determine Maven project version."
}

if (-not $SpringBootVersion) {
    Stop-WithError "Could not determine Spring Boot version."
}

if (-not $JavaVersion) {
    Stop-WithError "Could not determine Java version."
}

if (-not $JunitVersion) {
    Stop-WithError "Could not determine JUnit version."
}

if (-not $MockitoVersion) {
    Stop-WithError "Could not determine Mockito version."
}

if (-not $JjwtVersion) {
    Stop-WithError "Could not determine JJWT version."
}

if (-not $MapstructVersion) {
    Stop-WithError "Could not determine MapStruct version."
}

if (-not $SpringdocVersion) {
    Stop-WithError "Could not determine SpringDoc version."
}

Write-Host ""
Write-Host "Maven configuration detected:"
Write-Host "    Group       : $ProjectGroupId"
Write-Host "    Artifact    : $ProjectArtifactId"
Write-Host "    Version     : $ProjectVersion"
Write-Host "    Java        : $JavaVersion"
Write-Host "    Spring Boot : $SpringBootVersion"
Write-Host "    JUnit       : $JunitVersion"
Write-Host "    Mockito     : $MockitoVersion"
Write-Host "    JJWT        : $JjwtVersion"
Write-Host "    MapStruct   : $MapstructVersion"
Write-Host "    SpringDoc   : $SpringdocVersion"

# ==========================================================
# [2/8] Checking Java
# ==========================================================

Write-Section "2/8" "Checking Java"

$JavaExecutable = Join-Path $JavaHome "bin\java.exe"

if (-not (Test-Path -LiteralPath $JavaExecutable -PathType Leaf)) {
    Stop-WithError "Java executable not found: $JavaExecutable"
}

Write-Host "Java executable:"
Write-Host "    $JavaExecutable"
Write-Host ""

& $JavaExecutable -version

if ([int]$JavaVersion -ne 25) {
    Stop-WithError "This converter expects Java 25. pom.xml contains Java $JavaVersion."
}

Write-Host ""
Write-Host "OK: Java 25 detected." -ForegroundColor Green

# ==========================================================
# [3/8] Checking Gradle
# ==========================================================

Write-Section "3/8" "Checking Gradle"

$GradleExecutable = Join-Path $GradleHome "bin\gradle.bat"

if (-not (Test-Path -LiteralPath $GradleExecutable -PathType Leaf)) {
    Stop-WithError "Gradle executable not found: $GradleExecutable"
}

Write-Host "Gradle executable:"
Write-Host "    $GradleExecutable"
Write-Host ""

& $GradleExecutable --version

if ($LASTEXITCODE -ne 0) {
    Stop-WithError "Could not execute Gradle."
}

Write-Host ""
Write-Host "OK: Gradle detected." -ForegroundColor Green

# ==========================================================
# [4/8] Creating Maven backup
# ==========================================================

Write-Section "4/8" "Creating Maven backup"

$BackupPath = Join-Path $ProjectPath "pom.xml.backup"

if (Test-Path -LiteralPath $BackupPath -PathType Leaf) {
    Write-Host "Backup already exists:"
    Write-Host "    pom.xml.backup"
}
else {
    try {
        Copy-Item -LiteralPath "pom.xml" -Destination "pom.xml.backup"
    }
    catch {
        Stop-WithError "Could not create pom.xml.backup."
    }

    Write-Host "Backup created:"
    Write-Host "    pom.xml.backup" -ForegroundColor Green
}

# ==========================================================
# [5/8] Converting Maven project to Gradle
# ==========================================================

Write-Section "5/8" "Converting Maven project to Gradle"

Write-Host "Gradle configuration:"
Write-Host "    DSL          : Kotlin"
Write-Host "    Java         : $JavaVersion"
Write-Host "    Spring Boot  : $SpringBootVersion"
Write-Host ""

Write-Host "Cleaning previous generated Gradle files..."

$FilesToRemove = @(
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts"
)

foreach ($File in $FilesToRemove) {
    if (Test-Path -LiteralPath $File) {
        Remove-Item -LiteralPath $File -Force
    }
}

Write-Host "Previous Gradle build files removed."
Write-Host ""

Write-Host "Running:"
Write-Host "    gradle init --type pom --dsl kotlin"
Write-Host ""

$InitOutput = & cmd.exe /c "echo no|`"$GradleExecutable`" init --type pom --dsl kotlin" 2>&1
$InitExitCode = $LASTEXITCODE

$InitOutput | ForEach-Object {
    Write-Host $_
}

if ($InitExitCode -ne 0) {
    Stop-WithError "Gradle Maven conversion failed."
}

Write-Host ""
Write-Host "Gradle migration command completed successfully." -ForegroundColor Green

$GeneratedVersionCatalog = Join-Path $ProjectPath "gradle\libs.versions.toml"

if (Test-Path -LiteralPath $GeneratedVersionCatalog -PathType Leaf) {
    Remove-Item -LiteralPath $GeneratedVersionCatalog -Force
    Write-Host "Removed generated version catalog."
}

# ==========================================================
# [6/8] Generating professional Gradle configuration
# ==========================================================

Write-Section "6/8" "Generating professional Gradle configuration"

$BuildGradleContent = @'
plugins {
    java
    id("org.springframework.boot") version "__SPRING_BOOT_VERSION__"
    id("io.spring.dependency-management") version "1.1.7"
}

group = "__GROUP_ID__"
version = "__PROJECT_VERSION__"
description = "REST API with JWT Authentication, Spring Security, PostgreSQL and OpenAPI."

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(__JAVA_VERSION__)
    }
}

repositories {
    mavenCentral()
}

val junitVersion = "__JUNIT_VERSION__"
val mockitoVersion = "__MOCKITO_VERSION__"
val jjwtVersion = "__JJWT_VERSION__"
val mapstructVersion = "__MAPSTRUCT_VERSION__"
val springdocVersion = "__SPRINGDOC_VERSION__"

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:$springdocVersion")

    implementation("org.mapstruct:mapstruct:$mapstructVersion")
    annotationProcessor("org.mapstruct:mapstruct-processor:$mapstructVersion")

    runtimeOnly("org.postgresql:postgresql")

    testImplementation("com.h2database:h2")

    implementation("org.springframework.boot:spring-boot-starter-flyway")
    implementation("org.flywaydb:flyway-database-postgresql")

    implementation("io.jsonwebtoken:jjwt-api:$jjwtVersion")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:$jjwtVersion")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:$jjwtVersion")

    developmentOnly("org.springframework.boot:spring-boot-devtools")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
    testImplementation("org.junit.jupiter:junit-jupiter:$junitVersion")
    testImplementation("org.mockito:mockito-core:$mockitoVersion")
    testImplementation("org.mockito:mockito-junit-jupiter:$mockitoVersion")
}

tasks.withType<JavaCompile>().configureEach {
    options.encoding = "UTF-8"
    options.compilerArgs.add("-parameters")
}

tasks.withType<Javadoc>().configureEach {
    options.encoding = "UTF-8"
}

tasks.test {
    useJUnitPlatform()
}
'@

$BuildGradleContent = $BuildGradleContent.Replace("__SPRING_BOOT_VERSION__", $SpringBootVersion)
$BuildGradleContent = $BuildGradleContent.Replace("__GROUP_ID__", $ProjectGroupId)
$BuildGradleContent = $BuildGradleContent.Replace("__PROJECT_VERSION__", $ProjectVersion)
$BuildGradleContent = $BuildGradleContent.Replace("__JAVA_VERSION__", $JavaVersion)
$BuildGradleContent = $BuildGradleContent.Replace("__JUNIT_VERSION__", $JunitVersion)
$BuildGradleContent = $BuildGradleContent.Replace("__MOCKITO_VERSION__", $MockitoVersion)
$BuildGradleContent = $BuildGradleContent.Replace("__JJWT_VERSION__", $JjwtVersion)
$BuildGradleContent = $BuildGradleContent.Replace("__MAPSTRUCT_VERSION__", $MapstructVersion)
$BuildGradleContent = $BuildGradleContent.Replace("__SPRINGDOC_VERSION__", $SpringdocVersion)

try {
    Set-Content -LiteralPath "build.gradle.kts" -Value $BuildGradleContent -Encoding UTF8
}
catch {
    Stop-WithError "Could not generate build.gradle.kts."
}

Write-Host "OK: build.gradle.kts generated." -ForegroundColor Green

$SettingsGradleContent = @'
rootProject.name = "__ARTIFACT_ID__"
'@

$SettingsGradleContent = $SettingsGradleContent.Replace(
    "__ARTIFACT_ID__",
    $ProjectArtifactId
)

try {
    Set-Content -LiteralPath "settings.gradle.kts" -Value $SettingsGradleContent -Encoding UTF8
}
catch {
    Stop-WithError "Could not generate settings.gradle.kts."
}

Write-Host "OK: settings.gradle.kts generated." -ForegroundColor Green

# ==========================================================
# [7/8] Validating Gradle configuration
# ==========================================================

Write-Section "7/8" "Validating Gradle configuration"

if (-not (Test-Path -LiteralPath "build.gradle.kts" -PathType Leaf)) {
    Stop-WithError "build.gradle.kts was not generated."
}

if (-not (Test-Path -LiteralPath "settings.gradle.kts" -PathType Leaf)) {
    Stop-WithError "settings.gradle.kts was not generated."
}

Write-Host "OK: build.gradle.kts found." -ForegroundColor Green
Write-Host "OK: settings.gradle.kts found." -ForegroundColor Green

$BuildText = Get-Content -LiteralPath "build.gradle.kts" -Raw

$RequiredPatterns = @(
    'id("org.springframework.boot")'
    'id("io.spring.dependency-management")'
    'JavaLanguageVersion.of(25)'
    'annotationProcessor("org.mapstruct:mapstruct-processor'
    'useJUnitPlatform()'
    'options.compilerArgs.add("-parameters")'
    'developmentOnly("org.springframework.boot:spring-boot-devtools")'
    'mavenCentral()'
)

foreach ($Pattern in $RequiredPatterns) {
    if ($BuildText -notlike "*$Pattern*") {
        Stop-WithError "Generated build.gradle.kts is missing required configuration: $Pattern"
    }
}

Write-Host ""
Write-Host "Required Gradle configuration detected:" -ForegroundColor Green
Write-Host "    Spring Boot plugin"
Write-Host "    Dependency Management plugin"
Write-Host "    Java 25 toolchain"
Write-Host "    MapStruct annotation processor"
Write-Host "    JUnit Platform"
Write-Host "    Java -parameters"
Write-Host "    Spring Boot DevTools"
Write-Host "    Maven Central"
Write-Host ""

Write-Host "Running:"
Write-Host "    gradle tasks"
Write-Host ""

& $GradleExecutable tasks

if ($LASTEXITCODE -ne 0) {
    Stop-WithError "gradle tasks failed."
}

# ==========================================================
# [8/8] Building project
# ==========================================================

Write-Section "8/8" "Building project"

Write-Host "Running:"
Write-Host "    gradle clean build"
Write-Host ""

& $GradleExecutable clean build

if ($LASTEXITCODE -ne 0) {
    Stop-WithError "Gradle build failed."
}

# ==========================================================
# Final result
# ==========================================================

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "             MIGRATION SUCCESSFUL" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Project:"
Write-Host "    $ProjectArtifactId"

Write-Host ""
Write-Host "Group:"
Write-Host "    $ProjectGroupId"

Write-Host ""
Write-Host "Version:"
Write-Host "    $ProjectVersion"

Write-Host ""
Write-Host "Java:"
Write-Host "    $JavaVersion"

Write-Host ""
Write-Host "Spring Boot:"
Write-Host "    $SpringBootVersion"

Write-Host ""
Write-Host "Gradle:"
& $GradleExecutable --version | Select-String "Gradle"

Write-Host ""
Write-Host "Generated files:"
Write-Host "    build.gradle.kts"
Write-Host "    settings.gradle.kts"

Write-Host ""
Write-Host "Maven backup:"
Write-Host "    pom.xml.backup"

Write-Host ""
Write-Host "Build:"
Write-Host "    gradle clean build"

Write-Host ""
Write-Host "The Maven project was successfully migrated to Gradle." -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"