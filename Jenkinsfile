@Library('PrepEnvForBuild') _

pipeline{
    agent {
        label 'master'
    }
    
    options { 
        skipDefaultCheckout() 
    }

    parameters {
        choice choices: ['Win10_MSI', 'Win10-VB', 'Win10-Dell'], description: 'Choose an agent for deployment', name: 'AGENT'
        credentials credentialType: 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey', defaultValue: '', name: 'GIT_REPO_CRED', required: true
    }

    stages {
        stage('Check status agent/git cred'){
            steps{
                CheckAgent("${params.AGENT}")
                CheckGitCred("$params.GIT_REPO_CRED")
            }
        }

        stage('Git checkout'){
            steps {
                git branch: 'main', 
                credentialsId: "${params.GIT_REPO_CRED}", 
                poll: false, 
                url: 'git@github.com:Serhii5465/win10_update_disabler_script-ps.git'

                stash includes: 'upd_disabler.ps1', name: 'script'
            }
        }

        stage('Deploy'){
            agent {
                label "${params.AGENT}"
            }

            steps{
                unstash 'script'
                bat returnStatus: true, script: 'robocopy . D:\\system\\Disabler_Win10_Updates upd_disabler.ps1'
            }
        }
    }
}