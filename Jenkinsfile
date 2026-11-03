pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'rahulbastia'
        IMAGE_NAME     = "${env.DOCKERHUB_USER}/livekit-client"
        REGISTRY_CREDS = 'dockerhub-credentials'
    }

    stages {

        stage('Validate Config') {
            steps {
                sh '''
                    set -e

                    echo "Generating temporary CI environment..."

                    CI_SECRET=$(openssl rand -hex 32)

                    cat > .env <<EOF
LIVEKIT_API_KEY=ci_key
LIVEKIT_API_SECRET=${CI_SECRET}
LIVEKIT_URL=ws://localhost:7880
NEXT_PUBLIC_SHOW_SETTINGS_MENU=true
EOF

                    echo "Validating Docker Compose configuration..."
                    docker compose config -q

                    rm -f .env

                    echo "Docker Compose validation successful."
                '''
            }
        }

        stage('Build Client Image') {
            steps {
                dir('client') {
                    sh """
                        set -e

                        echo "Building Docker image..."

                        docker build \
                            -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                            -t ${IMAGE_NAME}:latest \
                            .

                        echo "Docker image built successfully."
                    """
                }
            }
        }

        stage('Vulnerability Scan (Trivy)') {
            steps {
                sh """
                    set -e

                    echo "Scanning Docker image for HIGH and CRITICAL vulnerabilities..."

                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v trivy-cache:/root/.cache/ \
                        aquasec/trivy:latest image \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        --exit-code 1 \
                        --format table \
                        ${IMAGE_NAME}:${BUILD_NUMBER}

                    echo "Security scan passed."
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${REGISTRY_CREDS}",
                        passwordVariable: 'DOCKER_PASS',
                        usernameVariable: 'DOCKER_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin

                        docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${IMAGE_NAME}:latest

                        echo "Docker images pushed successfully."
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''
                docker logout || true
                docker image prune -f || true
            '''
        }

        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs above.'
        }
    }
}