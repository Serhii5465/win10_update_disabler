$ErrorActionPreference = 'Stop'

function EditUpdateViaRegistry {
    $Root_Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\'
    Remove-Item -Path $Root_Path
}

function ConfigureServiceUpdate {
    # Get-Service -DisplayName 'Windows Update' | Set-Service -StartupType 'Automatic' | Start-Service -Force
    # Get-Service -DisplayName 'Update Orchestrator Service' | Set-Service -StartupType 'Automatic'

    [string]$User_Name = 'LocalSystem'
    (Get-WmiObject -Class win32_Service | Where-Object DisplayName -eq 'Windows Update').change($null,$null,$null,$null,$null,$null,$User_Name,$null,$null,$null,$null)
    (Get-WmiObject -Class win32_Service | Where-Object DisplayName -eq 'Update Orchestrator Service').change($null,$null,$null,$null,$null,$null,$User_Name,$null,$null,$null,$null)
}

function EnableScheduleTaskUpdate {
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\' -TaskName 'Scheduled Start'
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Scan'
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Scan Static Task'
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Work'
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Report policies'
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'UpdateModelTask'
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'USO_UxBroker'
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\WaaSMedic\' -TaskName 'PerformRemediation'
}

function main {
    #EditUpdateViaRegistry
    #EnableScheduleTaskUpdate
    ConfigureServiceUpdate
}

main