$ErrorActionPreference = 'Stop'

function WriteInfoToEventLog {
    param (
        [string]$Message
    )

    $Log_Name = 'Application'
    $Event_Id = 47991
    $Source = 'Enabler Windows 10 Updates'

    If ([System.Diagnostics.EventLog]::SourceExists($Source) -eq $False) {
        New-EventLog -LogName $Log_Name -Source $Source
    }

    Write-EventLog -LogName $Log_Name -EventId $Event_Id -EntryType 'Information' -Source $Source -Message $Message
}

function EditGroupPolicyUpdateViaRegistry {
    $Root_Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\'
    if(Test-Path -Path $Root_Path){
        WriteInfoToEventLog "Removing group policy settings for Windows updates. Resetting the NoAutoUpdate and AUOptions parameters"
        Remove-Item -Path $Root_Path -Force -Recurse
    }
}

function ShutDownScheduledTaskDisablerUpdate {
    [string]$Name_Task = 'Disable updates'
    [string]$Task_Path = Get-ScheduledTask -TaskName $Name_Task | Where-Object -Property State -eq "Ready" | Select-Object -ExpandProperty TaskPath
    
    Disable-ScheduledTask -TaskPath $Task_Path -TaskName $Name_Task | Out-Null
    WriteInfoToEventLog "Disabling the scheduled task for turning off Windows updates"
}

function EnableScheduledTaskUpdate {
    $Task_List = @(
        # \Microsoft\Windows\WindowsUpdate
        'Scheduled Start'
        # \Microsoft\Windows\UpdateOrchestrator
        'Report policies'
        'Schedule Scan'
        'Schedule Scan Static Task'
        #'Schedule Work'
        'UpdateModelTask'
        'USO_UxBroker'
        # \Microsoft\Windows\WaaSMedic
        'PerformRemediation'
    )

    [string]$Result, [string]$Log_Message = ''
    
    foreach ($Item in $Task_List) {
        $Result = Get-ScheduledTask -TaskName $Item | Where-Object -Property State -eq "Disabled" | Select-Object -ExpandProperty TaskPath 
        if($Result){
            $Log_Message += (-join("The task ", $Item, " (Path = ", $Result, ") has a status 'Disabled'.", "Changing status to 'Ready'.`n"))
            Enable-ScheduledTask -TaskPath $Result -TaskName $Item | Out-Null
        }
    }
    
    if (-not ([string]::IsNullOrEmpty($Log_Message))){
        WriteInfoToEventLog $Log_Message
    }
}

function ConfigureServicesUpdate {
    [string]$User_Name = 'LocalSystem'

    # Update Orchestrator Service
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UsoSvc\" -Name Start -Value 2
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UsoSvc\" -Name ObjectName -Value $User_Name  

    # Windows Update
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\wuauserv\" -Name Start -Value 3
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\wuauserv\" -Name ObjectName -Value $User_Name  

    # Windows Update Medic Service
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\" -Name Start -Value 3
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\" -Name ObjectName -Value $User_Name

    WriteInfoToEventLog "The settings for Windows Update Medic Service, Windows Update, and Update Orchestrator Service have been restored to their default values"
}

function main {
    ShutDownScheduledTaskDisablerUpdate
    EditGroupPolicyUpdateViaRegistry
    EnableScheduledTaskUpdate
    ConfigureServicesUpdate
}

main