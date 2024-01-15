$ErrorActionPreference = 'Stop'

function EditGroupPolicyUpdateViaRegistry {
    $Root_Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\'
    if(Test-Path -Path $Root_Path){
        Remove-Item -Path $Root_Path -Force -Recurse
    }
}

function EnableScheduleTaskUpdate {
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\' -TaskName 'Scheduled Start' | Out-Null
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Scan' | Out-Null
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Scan Static Task' | Out-Null
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Schedule Work' | Out-Null
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'Report policies' | Out-Null
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'UpdateModelTask' | Out-Null
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -TaskName 'USO_UxBroker' | Out-Null
    Enable-ScheduledTask -TaskPath '\Microsoft\Windows\WaaSMedic\' -TaskName 'PerformRemediation' | Out-Null
}

function ConfigureServicesUpdate {
    [string]$User_Name = 'LocalSystem'

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UsoSvc\" -Name Start -Value 2
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UsoSvc\" -Name ObjectName -Value $User_Name  

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\wuauserv\" -Name Start -Value 2
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\wuauserv\" -Name ObjectName -Value $User_Name  

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\" -Name Start -Value 3
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\" -Name ObjectName -Value $User_Name  
}

function main {
    EditGroupPolicyUpdateViaRegistry
    EnableScheduleTaskUpdate
    ConfigureServicesUpdate
}

main