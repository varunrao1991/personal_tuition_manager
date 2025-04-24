pipeline {
    agent any

    parameters {
        booleanParam(name: 'UPLOAD_TO_PLAYSTORE', defaultValue: false, description: 'Enable to upload the build to Play Store')
        choice(name: 'TRACK', choices: ['internal', 'alpha', 'beta', 'production'], description: 'Select Play Store track for deployment')
        choice(name: 'RELEASE_STATUS', choices: ['draft', 'completed', 'inProgress', 'halted'], description: 'Release status for the deployment')
    }

    environment {
        APK_NAME = "TeacherApp"
        ENVIRONMENT = "production"
        BUILD_BASE_DIR = "build"
        DEBUG_INFO_DIR = "debug_info"
        // Use params with a fallback to the original default values
        FASTFILE_TRACK = "${params.TRACK ?: 'internal'}"
        FASTFILE_RELEASE_STATUS = "${params.RELEASE_STATUS ?: 'draft'}"

        KEY_ALIAS = credentials('KEY_ALIAS')
        KEY_PASSWORD = credentials('KEY_PASSWORD')
        STORE_PASSWORD = credentials('STORE_PASSWORD')
        PLAY_STORE_JSON_KEY = credentials('PLAY_STORE_JSON_KEY')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'git@github.com:varunrao1991/padmayoga_offline_app.git', branch: 'main'
            }
        }

        stage('Extract Version from pubspec.yaml') {
            steps {
                script {
                    def pubspec = readFile('pubspec.yaml')
                    def versionLine = pubspec.readLines().find { it.trim().startsWith('version:') }

                    // Split properly and handle default if missing
                    def baseVersion = versionLine?.split(':')?.toList()[1]?.trim()?.split('\\+')?.toList()[0] ?: "1.0.0"

                    env.VERSION_NAME = "${baseVersion}.${BUILD_NUMBER}"
                    echo "VERSION_NAME set to: ${env.VERSION_NAME}"
                }
            }
        }

        stage('Set Up Keystore Folder') {
            steps {
                script {
                    env.KEYSTORE_FOLDER = "${env.WORKSPACE}/build/keystores"
                    sh "mkdir -p ${env.KEYSTORE_FOLDER}"
                    echo "Keystore folder set to: ${env.KEYSTORE_FOLDER}"
                }
            }
        }

        stage('Create Debug Info Directory') {
            steps {
                script {
                    def debugInfoPath = "${env.BUILD_BASE_DIR}/${env.DEBUG_INFO_DIR}"
                    sh "mkdir -p ${debugInfoPath}"
                    echo "Debug info directory created at: ${debugInfoPath}"
                }
            }
        }

        stage('Flutter Version') {
            steps {
                sh 'flutter --version'
            }
        }

        stage('Generate Env File') {
            steps {
                sh '''
                cat > .env.production <<EOF
                DB_NAME=app.db
                APP_NAME="Personal Tuition Manager"
                EOF
                '''
            }
        }

        stage('Verify Env File') {
            steps {
                sh 'cat .env.production'
            }
        }

        stage('Prepare Keystore File') {
            steps {
                script {
                    def keystoreFilePath = "${env.KEYSTORE_FOLDER}/padmayoga_release_key.jks"

                    // Ensure the folder exists
                    if (!fileExists(env.KEYSTORE_FOLDER)) {
                        sh "mkdir -p ${env.KEYSTORE_FOLDER}"
                        echo "Keystore folder created at: ${env.KEYSTORE_FOLDER}"
                    }

                    // Only copy if the keystore file doesn't already exist
                    if (!fileExists(keystoreFilePath)) {
                        withCredentials([file(credentialsId: 'KEYSTORE_FILE', variable: 'KEYSTORE_FILE_PATH')]) {
                            sh """
                                cp "$KEYSTORE_FILE_PATH" "${keystoreFilePath}"
                                echo "Keystore file placed at: ${keystoreFilePath}"
                            """
                        }
                    } else {
                        echo "Keystore file already exists at: ${keystoreFilePath}, skipping copy."
                    }
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('android') {
                    sh '''
                        echo "Ruby version: $(ruby --version)"
                        echo "Gem version: $(gem --version)"
                        bundle config set --local path 'vendor/bundle'
                        bundle check || bundle install --jobs=4
                    '''
                }
            }
        }

        stage('Build App Bundle') {
            steps {
                script {
                    def buildCommand = """
                        flutter build appbundle \
                            --release \
                            --obfuscate \
                            --split-debug-info="${env.BUILD_BASE_DIR}/${env.DEBUG_INFO_DIR}" \
                            --dart-define=ENV=${env.ENVIRONMENT} \
                            --build-name="${env.VERSION_NAME}" \
                            --build-number=${BUILD_NUMBER}
                    """
                    echo "Executing build command: ${buildCommand}"
                    sh buildCommand
                }
            }
        }

        stage('Rename App Bundle') {
            steps {
                script {
                    def outputDir = "build/app/outputs/bundle/release"
                    def originalAab = "${outputDir}/app-release.aab"
                    def renamedAabName = "${env.APK_NAME}-${env.VERSION_NAME}-${env.ENVIRONMENT}.aab"
                    def renamedAab = "${outputDir}/${renamedAabName}"

                    if (fileExists(originalAab)) {
                        sh "mv ${originalAab} ${renamedAab}"
                        echo "App Bundle renamed to: ${renamedAab}"

                        // Set environment variables
                        env.AAB_FILE_PATH = "../${outputDir}/${renamedAabName}"
                        
                        echo "AAB_FILE_PATH set to: ${env.AAB_FILE_PATH}"
                        echo "Using track: ${env.FASTFILE_TRACK}"
                        echo "Using release status: ${env.FASTFILE_RELEASE_STATUS}"
                    } else {
                        echo "WARNING: App Bundle not found at expected location: ${originalAab}"
                    }
                }
            }
        }

        stage('Post Build') {
            steps {
                script {
                    def aabArtifactsPath = "${env.BUILD_BASE_DIR}/app/outputs/bundle/release/*.aab"
                    def debugSymbolsPath = "${env.BUILD_BASE_DIR}/${env.DEBUG_INFO_DIR}/**/*"

                    archiveArtifacts artifacts: aabArtifactsPath, allowEmptyArchive: true
                    archiveArtifacts artifacts: debugSymbolsPath, allowEmptyArchive: true

                    echo "Archived artifacts:"
                    echo "- App Bundles from: ${aabArtifactsPath}"
                    echo "- Debug symbols from: ${debugSymbolsPath}"
                }
            }
        }

        stage('Upload to Play Store') {
            when {
                expression { return params.UPLOAD_TO_PLAYSTORE }
            }
            steps {
                withCredentials([file(credentialsId: 'PLAY_STORE_JSON_KEY', variable: 'PLAY_STORE_JSON_PATH')]) {
                    dir('android') {
                        sh """
                            bundle exec fastlane run validate_play_store_json_key json_key:$PLAY_STORE_JSON_PATH
                            bundle exec fastlane deploy json_key:$PLAY_STORE_JSON_PATH
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}