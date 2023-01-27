pipeline{
        agent any
        tools{
            maven 'Maven-3.8.7'
            nodejs 'NodeJS-19.4.0'
        }
        stages{
            stage('Install Maven & test'){
                steps{

                    checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/bit-of-a-git/last-petclinic/']])
    
                    dir("spring-petclinic-rest") {
                      
                        // sh 'mvn clean install'
                    }
                    
                }
            }
            // stage('Install angular'){
            //     steps{
            //         // checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/bit-of-a-git/spring-petclinic-angular']])
            //         // sh 'sudo apt-get install npm -y'
            //         // sh 'sudo curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -'
            //         // sh 'sudo apt-get install -y nodejs'
            //         // sh 'sudo apt-get install gcc g++ make'
            //         dir("spring-petclinic-rest") {
            //             sh 'npm install -g @angular/cli@11.2.11'
            //             // sh 'sudo npm install'
            //         }
            //     }
            // }

            stage('Build Docker Images'){
                steps{
                    
                    dir("spring-petclinic-rest") {
                        script{
                            sh 'docker build -t cathysimms/spring-petclinic-rest-mysql:latest .'
                        }
                    }

                    dir("spring-petclinic-angular") {
                        script{
                            sh 'docker build -t cathysimms/spring-petclinic-angular:latest .'
                        }
                    }
                
                }
            }
            
            stage('Push images to Hub'){
                steps{
                    script{
                        withCredentials([string(credentialsId: 'DockerHubPwd', variable: 'DockerHubPwd')]) {
                            sh 'docker login -u cathysimms -p ${DockerHubPwd}'
                        }
                        sh 'docker push cathysimms/spring-petclinic-rest-mysql:latest'
                        sh 'docker push cathysimms/spring-petclinic-angular:latest'
                    }
                }
            }
            stage('Remove Local Image'){
                steps{
                    sh 'docker rmi -f cathysimms/spring-petclinic-rest-mysql:latest'
                    sh 'docker rmi -f cathysimms/spring-petclinic-angular:latest'
                }
            }
            stage("Deploy to docker swarm cluster"){
                steps{
                    
                    sshagent(['Docker_Swarm_Manager_SSH']) {
                        withCredentials([string(credentialsId: 'MY_USER', variable: 'USER_NAME'), string(credentialsId: 'MY_PASSWORD', variable: 'USER_PASSWORD')]) {
                            
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 docker service rm petclinic_backend petclinic_frontend petclinic_nginx '
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 export USER_NAME=${USER_NAME} '
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 export USER_PASSWORD=${USER_PASSWORD} '
                            sh 'scp -o StrictHostKeyChecking=no docker-compose.yml ubuntu@3.8.21.159: '
                            sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 docker compose up -d '
                            
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 sudo docker stack rm springboot '
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 sudo docker stack rm petclinic '
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 git clone https://github.com/bit-of-a-git/last-petclinic.git'
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 cd last-petclinic'
                            
                            // sh 'scp -o StrictHostKeyChecking=no ./nginx/nginx.conf ubuntu@3.8.21.159:/home/ubuntu/nginx '
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 ls '
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 ls nginx'
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 sudo docker stack deploy -e USER_NAME=${USER_NAME} USER_PASSWORD=${USER_PASSWORD} --prune --compose-file docker-compose.yml petclinic' 
                            
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 sudo docker stack ls '
                            // sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.8.21.159 sudo docker service ls '
                        }
                    }
                }
                
                    
            }
            
        }
}