pipeline {
    agent any

    parameters {
        booleanParam(name: 'UPLOAD_TO_PLAYSTORE', defaultValue: false, description: 'Enable to upload the build to Play Store')
    }

    environment {
        APP_NAME = "TeacherApp"
        ENVIRONMENT = "production"
        BUILD_BASE_DIR = "build"
        DEBUG_INFO_DIR = "debug_info"

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
                    def baseVersion = versionLine?.split(':')?.getAt(1)?.trim()?.split('\\+')?.getAt(0) ?: "1.0.0"
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
                        if (!fileExists("${KEYSTORE_FOLDER}")) {
                            sh "mkdir -p ${KEYSTORE_FOLDER}"
                            echo "Keystore folder created at: ${KEYSTORE_FOLDER}"
                        }
                        sh '''
                            cp "$KEYSTORE_FILE_PATH" "${KEYSTORE_FOLDER}/padmayoga_release_key.jks"
                            echo "Keystore file placed at: ${KEYSTORE_FOLDER}/padmayoga_release_key.jks"
                        '''
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
                    archiveArtifacts artifacts: '**/build/app/outputs/bundle/release/*.aab', allowEmptyArchive: true
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
