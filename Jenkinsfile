@Library(['PrepEnvForBuild', 'DeployWinAgents']) _

node('master') {
    def config = [
        platform: "win32",
        git_repo_url : "git@github.com:Serhii5465/win10_update_disabler_script-ps.git",
        git_branch : "main",
        git_cred_id : "win10_update_disabler_repo_cred",
        stash_includes : "upd_disabler.ps1",
        stash_excludes : "",
        command_deploy : "robocopy . D:\\system\\Disabler_Win10_Updates upd_disabler.ps1",
        func_deploy : ""
    ]

    DeployArtifactsPipelineOnAgents(config)
}