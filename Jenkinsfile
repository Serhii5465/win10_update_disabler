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
    }

    stages {
        stage('Check status agent'){
            steps{
                CheckAgent("${params.AGENT}")
            }
        }

        stage('Git checkout'){
            steps {
                checkout scmGit(branches: [[name: 'main']],
                extensions: [], 
                userRemoteConfigs: [[url: 'win10_update_disabler_script_ps_repo:Serhii5465/win10_update_disabler_script-ps.git']])

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