$ErrorActionPreference = 'Stop'

function EditUpdateViaRegistryGroupPolicy {
    $Root_Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\'
    Remove-Item -Path $Root_Path
}

function ConfigureServiceUpdate {
    [string]$User_Name = 'LocalSystem'

    Get-Service -DisplayName 'Windows Update' | Set-Service -StartupType 'Automatic'
    Get-Service -DisplayName 'Update Orchestrator Service' | Set-Service -StartupType 'Automatic'

    # Set credentials for Windows Update service and Update Orchestrator Service
    (Get-WmiObject -Class win32_Service | Where-Object DisplayName -eq 'Windows Update').change($null,$null,$null,$null,$null,$null,$User_Name,$null,$null,$null,$null)
    (Get-WmiObject -Class win32_Service | Where-Object DisplayName -eq 'Update Orchestrator Service').change($null,$null,$null,$null,$null,$null,$User_Name,$null,$null,$null,$null)

    # Set start mode and credentials for Windows Update Medic Service and Delivery Optimization
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\" -Name Start -Value 3 # Manual
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DoSvc\" -Name Start -Value 2 # Automatic

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\" -Name ObjectName -Value $User_Name  
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
    EditUpdateViaRegistryGroupPolicy
    EnableScheduleTaskUpdate
    ConfigureServiceUpdate
}

main