@Library(['PrepEnvForBuild', 'DeployWinAgents']) _

node('master') {
    def config = [
        platform: "win32",
        git_repo_url : "git@github.com:Serhii5465/win10_update_disabler.git",
        git_branch : "main",
        git_cred_id : "win10_update_disabler_repo_cred",
        stash_includes : "upd_disabler.ps1, turn_on_disabler.bat, reset/turn_off_disabler.bat, reset/upd_enabler.ps1",
        stash_excludes : "",
        command_deploy : "robocopy /s . D:\\system\\Disabler_Win10_Updates",
        func_deploy : ""
    ]

    DeployArtifactsPipelineOnAgents(config)
}