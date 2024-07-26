pipeline {
    agent any
    tools {
        jdk 'jdk11'
        maven 'maven3'
    }
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
    }
    stages {
        stage('GIT CHECKOUT') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/jaiswaladi246/Ekart.git'
            }
        }
        stage('compile') {
            steps {
                sh "maven clean compile"
            }
        }
        stage('sonarqube Analysis') {
            steps {
                sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.url=http://192.168.186.134:9000/ -Dsonar.login=squ_dbd9c849b4acf45659b4029c483a5863283620fe -Dsonar.projectName=shopping-cart \
                -Dsonar.java.binaries=. \
                -Dsonar.projectkey=shopping-cart '''
            }
        }
    }
}
