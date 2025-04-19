pipeline {
    agent any  // Use any available agent to run the pipeline

    environment {
        // Set other required environment variables, but let Jenkins handle the BUILD_NUMBER automatically
        FLUTTER_HOME = "/opt/flutter"  // Path to Flutter SDK
        PATH = "${env.PATH}:${env.FLUTTER_HOME}/bin"
        APP_NAME = "TeacherApp"
        VERSION_NAME = "1.0.${BUILD_NUMBER}"
        ENVIRONMENT = "production"
        BUILD_BASE_DIR = "build"
        DEBUG_INFO_DIR = "debug_info"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git url: 'git@github.com:varunrao1991/padmayoga_offline_app.git', 
                branch: 'main'
            }
        }

        stage('Set Up Keystore Folder') {
            steps {
                script {
                    // Ensure the keystore folder exists, or use default path
                    if (env.KEYSTORE_FOLDER) {
                        echo "Using provided KEYSTORE_FOLDER: ${env.KEYSTORE_FOLDER}"
                    } else {
                        env.KEYSTORE_FOLDER = "${env.HOME}/keystores"  // Default Linux path
                    }
                    // Verify the keystore folder exists
                    if (!fileExists(env.KEYSTORE_FOLDER)) {
                        error "ERROR: Keystore folder not found: ${env.KEYSTORE_FOLDER}"
                    }
                    echo "Keystore folder set to: ${env.KEYSTORE_FOLDER}"
                }
            }
        }

        stage('Create Debug Info Directory') {
            steps {
                script {
                    // Create the debug info directory
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
                APP_NAME="Teacher App"
                EOF
                '''
            }
        }

        stage('Verify Env File') {
            steps {
                sh 'cat .env.production'
            }
        }
        
        stage('Build App Bundle') {
            steps {
                script {
                    // Run the Flutter build command
                    def buildCommand = """
                        flutter build appbundle \
                            --release \
                            --obfuscate \
                            --split-debug-info="${env.BUILD_BASE_DIR}/${env.DEBUG_INFO_DIR}" \
                            --dart-define=ENV=${env.ENVIRONMENT} \
                            --dart-define=APP_NAME=${env.APP_NAME} \
                            --build-name="${env.VERSION_NAME}" \
                            --build-number=${BUILD_NUMBER}  // Jenkins build number
                    """
                    echo "Executing build command: ${buildCommand}"
                    sh buildCommand
                }
            }
        }

        stage('Rename App Bundle') {
            steps {
                script {
                    // Rename the app bundle
                    def outputDir = "build/app/outputs/bundle/release"
                    def originalAab = "${outputDir}/app-release.aab"
                    def renamedAab = "${outputDir}/${env.APP_NAME}-${env.VERSION_NAME}-${env.ENVIRONMENT}.aab"

                    if (fileExists(originalAab)) {
                        sh "mv ${originalAab} ${renamedAab}"
                        echo "App Bundle renamed to: ${renamedAab}"
                    } else {
                        echo "WARNING: App Bundle not found at expected location: ${originalAab}"
                    }
                }
            }
        }

        stage('Post Build') {
            steps {
                script {
                    // Archive the generated `.aab` file as an artifact (optional)
                    archiveArtifacts artifacts: '**/build/app/outputs/bundle/release/*.aab', allowEmptyArchive: true
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
