def getCurrentBranch() {
    return sh (
        script: 'git rev-parse --abbrev-ref HEAD'
        returnStdout: true
    ).trim()
}

def BRANCH_NAME = getCurrentBranch()

def verify_image(filename) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh '''
        #!/usr/env/bin bash
        set +x
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'USER=`whoami` packer validate ''' + filename + "'"
    }
}

def build_image(filename) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        virtualenv venv_${filename}
        . venv_${filename}/bin/activate
        pip install -r requirements.txt
        python generate_metadata.py ${filename}
        deactivate
        rm -rf venv_${filename}

        set +x
        docker run --rm \
        -e BRANCH_NAME \
        -e TARGET_ENV \
        -e ARTIFACT_BUCKET \
        -e ZAIZI_BUCKET \
        -v `pwd`:/home/tools/data \
        mojdigitalstudio/hmpps-packer-builder \
        bash -c 'ansible-galaxy install -r ansible/requirements.yml; \
        env | sort ; \
        PACKER_VERSION=`packer --version` USER=`whoami` packer build ${filename}'
        rm ./meta/${filename}_meta.json
        """
    }
}

pipeline {
    agent { label "python3"}

    options {
        ansiColor('xterm')
    }

    triggers {
        cron(env.BRANCH_NAME=='master'? 'H 2 * * 6': '')
    }

    stages {
    /*    stage ('Notify build started') {
            steps {
                slackSend(message: "Build Started - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")
            }
        } */

        stage('Verify Nextcloud AMI') {
            parallel {
                stage('Verify Nextcloud') { steps { script {verify_image('nextcloud_centos.json')}}}
            }
        }

        stage('Build Nextcloud AMI') {
            parallel {
                stage('Build Nextcloud') { steps { script {build_image('nextcloud_centos.json')}}}
            }
        }
    }

    post {
        always {
            deleteDir()
        }
        /*success {
            slackSend(message: "Build completed - ${env.JOB_NAME} ${env.BUILD_NUMBER}", color: 'good')
        }
        failure {
            slackSend(message: "Build failed - ${env.JOB_NAME} ${env.BUILD_NUMBER}", color: 'danger')
        } */
    }
}
