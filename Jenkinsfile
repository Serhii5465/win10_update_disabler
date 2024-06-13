@Library(['PrepEnvForBuild', 'DeployWinAgents']) _

node('master') {
    def raw = libraryResource 'configs/win10_update_disabler_repo.json'
    def config = readJSON text: raw
    DeployArtifactsPipelineWinAgents(config)
}