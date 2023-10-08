pipeline{
    agent any
    parameters {
	    string(name: 'ImageTag', description: "Name of the docker build")
    }
	environment {
		registry = 'springboot-ecr:latest'
		registryUrl='https://653308993752.dkr.ecr.us-east-1.amazonaws.com'
		registryCredentials = 'ecr:us-east-1:ecr_user_credentials'
		dockerImage = ''
	}
    stages {
        stage('checkout'){
            steps{
                git 'https://github.com/raviu2500/sre-exercise.git'
            }
        }
        stage ('Build_Artifact') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage("Deploy to Sonar") {
            agent any
            steps{
				withSonarQubeEnv(installationName: 'sonarqube', credentialsId: 'sonar-token') {
					sh "${ tool ("sonar-scanner")}/sonar-scanner -Dsonar.projectKey=hellospringboot -Dsonar.projectName=hellospringboot -Dsonar.sourceEncoding=UTF-8 -Dsonar.sources=src"
                }
            }
        }		
        stage ('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build registry
                }
            }
        }
        stage ('Docker Push') {
            steps {
                script {
                    docker.withRegistry(registryUrl,registryCredentials) {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Deployment'){
			steps{
				withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_Credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
					withCredentials([kubeconfigFile(credentialsId: 'kubernetes_credentials', variable: 'KUBECONFIG')]) {
					sh """
					cat deployement.yml | sed "s/{{ImageTag}}/${ImageTag}/g" | kubectl apply -f -
					kubectl apply -f service.yml
					kubectl apply -f ingress.yaml
					"""
				  }
			   }
			}
        }
	}
}
