pipeline {
    agent none
    
    parameters {
        choice choices: ['Win10_MSI', 'Win10-VB'], description: 'Choose an agent for deployment', name: 'AGENT'
        credentials credentialType: 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey', defaultValue: '', name: 'GIT_REPO_CRED', required: true
    }

    stages {
        stage('Chekout'){

            agent {
                node {
                    label 'master'
                }
            }

            steps {
                git branch: 'main', 
                credentialsId: "${params.GIT_REPO_CRED}", 
                poll: false, 
                url: 'git@github.com:Serhii5465/win10_update_disabler_script-ps.git'

                stash includes: 'upd_disabler.ps1', name: 'src'
            }
        }
    }
}
