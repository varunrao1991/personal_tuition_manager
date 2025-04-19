pipeline {
    agent any  // Use any available agent to run the pipeline

    environment {
        // Set other required environment variables, but let Jenkins handle the BUILD_NUMBER automatically
        APP_NAME = "TeacherApp"
        VERSION_NAME = "1.0.${BUILD_NUMBER}"
        ENVIRONMENT = "production"
        BUILD_BASE_DIR = "build"
        DEBUG_INFO_DIR = "debug_info"

        KEY_ALIAS = credentials('KEY_ALIAS')        // Jenkins stored key alias
        KEY_PASSWORD = credentials('KEY_PASSWORD')  // Jenkins stored key password
        STORE_PASSWORD = credentials('STORE_PASSWORD') // Jenkins stored store password
        PLAY_STORE_JSON_KEY = credentials('PLAY_STORE_JSON_KEY')  // The JSON key for Play Store
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
                    // Use the 'build' folder to store the keystore file
                    env.KEYSTORE_FOLDER = "${env.WORKSPACE}/build/keystores"  // Set to the build folder inside workspace

                    // Ensure the keystore folder exists
                    sh "mkdir -p ${env.KEYSTORE_FOLDER}"
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

        stage('Prepare Keystore File') {
            steps {
                withCredentials([file(credentialsId: 'KEYSTORE_FILE', variable: 'KEYSTORE_FILE_PATH')]) {
                    script {
                        // Only create the directory if it doesn't already exist
                        if (!fileExists("${KEYSTORE_FOLDER}")) {
                            sh "mkdir -p ${KEYSTORE_FOLDER}"
                            echo "Keystore folder created at: ${KEYSTORE_FOLDER}"

                            // Copy the keystore file to the folder
                            sh '''
                                cp "$KEYSTORE_FILE_PATH" "${KEYSTORE_FOLDER}/padmayoga_release_key.jks"
                                echo "Keystore file placed at: ${KEYSTORE_FOLDER}/padmayoga_release_key.jks"
                            '''
                        } else {
                            echo "Keystore folder already exists at: ${KEYSTORE_FOLDER}"
                        }
                    }
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('android') {
                    // Run bundle install to install gems from Gemfile
                    sh 'bundle install'
                }
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
        
        stage('Upload to Play Store') {
            steps {
                withCredentials([file(credentialsId: 'PLAY_STORE_JSON_KEY', variable: 'PLAY_STORE_JSON_PATH')]) {
                    dir('android') {
                        // Run fastlane commands using bundle exec, passing the JSON key file as an argument
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
