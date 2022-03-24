pipeline {
    agent any

    environment {
        APPLICATION_NAME = "jenkins-swarm"

        REPOSITORY_AUTH = "gitlab"
        REPOSITORY_URL = "https://github.com/buxiaomo/dockerfile-jenkins-swarm.git"

        REGISTRY_AUTH = "dockerhub"
        REGISTRY_HOST = "docker.io"
        REGISTRY_REPO = "buxiaomo"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '15'))
    }

    stages {
        stage('checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: "${env.REPOSITORY_AUTH}", url: "${env.REPOSITORY_URL}"]]])
            }
        }

        stage('build image') {
            parallel {
                stage('amd64') {
                    agent { 
                        label "amd64"
                    }
                    steps {
                        sh label: 'build', script: "docker build -t ${env.REGISTRY_HOST}/${env.REGISTRY_REPO}/${env.APPLICATION_NAME}:3.32-amd64 --pull -f Dockerfile --build-arg TARGETARCH=amd64 ."
                        retry(3) {
                            script {
                                if (env.REGISTRY_AUTH) {
                                withDockerRegistry(credentialsId: "${env.REGISTRY_AUTH}", url: "https://${env.REGISTRY_HOST}") {
                                    sh label: 'push', script: "docker push ${env.REGISTRY_HOST}/${env.REGISTRY_REPO}/${env.APPLICATION_NAME}:3.32-amd64"
                                }
                                } else {
                                    sh label: 'push', script: "docker push ${env.REGISTRY_HOST}/${env.REGISTRY_REPO}/${env.APPLICATION_NAME}:3.32-amd64"
                                }
                            }
                        }
                    }
                }
                stage('arm64') {
                    agent { 
                        label "arm64" 
                    }
                    steps {
                        sh label: 'build', script: "docker build -t ${env.REGISTRY_HOST}/${env.REGISTRY_REPO}/${env.APPLICATION_NAME}:3.32-arm64 --pull -f Dockerfile --build-arg TARGETARCH=arm64 ."
                        retry(3) {
                            script {
                                if (env.REGISTRY_AUTH) {
                                withDockerRegistry(credentialsId: "${env.REGISTRY_AUTH}", url: "https://${env.REGISTRY_HOST}") {
                                    sh label: 'push', script: "docker push ${env.REGISTRY_HOST}/${env.REGISTRY_REPO}/${env.APPLICATION_NAME}:3.32-arm64"
                                }
                                } else {
                                    sh label: 'push', script: "docker push ${env.REGISTRY_HOST}/${env.REGISTRY_REPO}/${env.APPLICATION_NAME}:3.32-arm64"
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('manifest') {
            steps {
                


                retry(3) {
                    script {
                        if (env.REGISTRY_AUTH) {
                           withDockerRegistry(credentialsId: "${env.REGISTRY_AUTH}", url: "https://${env.REGISTRY_HOST}") {
                                sh label: 'create', script: "docker manifest create buxiaomo/jenkins-swarm:3.32 buxiaomo/jenkins-swarm:3.32-arm64 buxiaomo/jenkins-swarm:3.32-amd64"
                                sh label: 'push', script: "docker manifest push buxiaomo/jenkins-swarm:3.32"
                           }
                        } else {
                            sh label: 'create', script: "docker manifest create buxiaomo/jenkins-swarm:3.32 buxiaomo/jenkins-swarm:3.32-arm64 buxiaomo/jenkins-swarm:3.32-amd64"
                            sh label: 'push', script: "docker manifest push buxiaomo/jenkins-swarm:3.32"
                        }
                    }
                }
            }
        }
    }
}
