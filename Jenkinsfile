@Library(['PrepEnvForBuild', 'DeployWinAgents']) _

node('master') {
    def config = [
        git_repo_url : "win10_update_disabler_script_ps_repo:Serhii5465/win10_update_disabler_script-ps.git",
        git_branch : "main",
        stash_includes : "upd_disabler.ps1",
        stash_excludes : "",
        command : "robocopy . D:\\system\\Disabler_Win10_Updates upd_disabler.ps1"
    ]

    DeployArtifactsPipelineWinAgents(config)
}