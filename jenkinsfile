pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'YOUR_DOCKERHUB_USERNAME'
        IMAGE_NAME     = "${env.DOCKERHUB_USER}/livekit-client"
        REGISTRY_CREDS = 'dockerhub-credentials'
    }

    stages {
        stage('Validate Config') {
            steps {
                sh '''
                echo "Validating Compose structure..."
                LIVEKIT_API_KEY=ci_key \
                LIVEKIT_API_SECRET=ci_secret \
                LIVEKIT_URL=ws://localhost:7880 \
                docker compose config -q
                '''
            }
        }

        stage('Build Client Image') {
            steps {
                dir('client') {
                    sh """
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest .
                    """
                }
            }
        }

        stage('Vulnerability Scan (Trivy)') {
            steps {
                sh """
                # 1. Print full scan table in build console
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  -v trivy-cache:/root/.cache/ \
                  aquasec/trivy:latest image \
                  --severity HIGH,CRITICAL \
                  --format table \
                  ${IMAGE_NAME}:${BUILD_NUMBER}

                # 2. Enforce quality gate (fails build if unfixed HIGH/CRITICAL CVEs exist)
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  -v trivy-cache:/root/.cache/ \
                  aquasec/trivy:latest image \
                  --exit-code 1 \
                  --severity HIGH,CRITICAL \
                  --ignore-unfixed \
                  ${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${REGISTRY_CREDS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                    docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        }
    }

    post {
        always {
            sh "docker logout || true"
            sh "docker image prune -f"
        }
    }
}