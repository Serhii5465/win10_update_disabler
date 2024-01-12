$ErrorActionPreference = 'Stop'

function ConfigureServiceUpdate {
    [string]$User_Name = '.\Guest'

    Get-Service -DisplayName 'Windows Update' | Set-Service -StartupType 'Disabled'  | Stop-Service -Force
    Get-Service -DisplayName 'Update Orchestrator Service' | Set-Service -StartupType 'Disabled' | Stop-Service -Force

    # Set credentials for Windows Update service and Update Orchestrator Service
    (Get-WmiObject -Class win32_Service | Where-Object DisplayName -eq 'Windows Update').change($null,$null,$null,$null,$null,$null,$User_Name,$null,$null,$null,$null)
    (Get-WmiObject -Class win32_Service | Where-Object DisplayName -eq 'Update Orchestrator Service').change($null,$null,$null,$null,$null,$null,$User_Name,$null,$null,$null,$null)

    Get-Service -DisplayName 'Delivery Optimization' | Stop-Service -Force
    Get-Service -DisplayName 'Windows Update Medic Service' | Stop-Service -Force

    # Change start mode and credentials for Windows Update Medic Service and Delivery Optimization
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\" -Name Start -Value 4 
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DoSvc\" -Name Start -Value 4

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\" -Name ObjectName -Value $User_Name
}

function EditUpdateViaRegistryGroupPolicy {
    $Root_Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\'

    if (!(Test-Path -Path $Root_Path)){
        New-Item -Path $Root_Path -Force
    } 

    
    Set-ItemProperty -Path $Root_Path 'NoAutoUpdate' 1 
    Set-ItemProperty -Path $Root_Path 'AUOptions' 1
}

function DisableScheduleTaskUpdate {
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\' -TaskName 'Scheduled Start'
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Scan'
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Scan Static Task'
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Work'
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Report policies'
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'UpdateModelTask'
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'USO_UxBroker'
    Disable-ScheduledTask -TaskPath '\Microsoft\Windows\WaaSMedic\' -TaskName 'PerformRemediation'
}

function RemoveUpdateDir {
    Get-ChildItem -Path $env:windir'\SoftwareDistribution' | Remove-Item -Recurse -Force    
}

function main {
    ConfigureServiceUpdate
    #EditUpdateViaRegistryGroupPolicy
    #DisableScheduleTaskUpdate
    #RemoveUpdateDir
}

main