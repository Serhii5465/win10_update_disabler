$ErrorActionPreference = 'Stop'

Import-Module -Name "$PSScriptRoot\utils\log.psm1"-Force

function ConfigureServicesUpdate {
    <#
    .SYNOPSIS
    Configures Windows services related to Windows Update by adjusting their state, start mode, and logon credentials.
    
    .DESCRIPTION
    Manages the configuration of services Windows Update, Update Orchestrator and Windows Update Medic.
    Uses both WMI objects and values of registry tree to inspect and modify the state, start mode, and logon credential.
    #>

    [string]$User_Name = '.\Guest'
    [string]$Path_Srv_Registry = 'HKLM:\SYSTEM\CurrentControlSet\Services'

    $List_Services = @(
        'wuauserv'      # Windows Update
        'UsoSvc'        # Update Orchestrator Service
        'WaaSMedicSvc'  # Windows Update Medic Service
    )
    
    [string]$Log_Message = ''
    [string]$Cur_Edit_Subtree = ''
    [System.Management.ManagementObject]$Service_Obj = ''

    foreach ($Item in $List_Services) {
        $Service_Obj = Get-WmiObject win32_service | Where-Object {$_.Name -eq $Item}

        if($Service_Obj.State -ne 'Stopped'){
            $Log_Message += "State - " + $Service_Obj.State + "`r`n"
            Get-Service -Name $Item | Stop-Service -Force
        }

        $Cur_Edit_Subtree = $Path_Srv_Registry + '\' + $Item

        if ($Service_Obj.StartMode -ne 'Disabled') {
            $Log_Message += "StartMode - " + $Service_Obj.StartMode + "`r`n"
            Set-ItemProperty -Path $Cur_Edit_Subtree -Name Start -Value 4
        }

        if ($Service_Obj.StartName -ne $User_Name) {
            $Log_Message += "Credential - " + $Service_Obj.StartName + "`r`n"
            Set-ItemProperty -Path $Cur_Edit_Subtree -Name ObjectName -Value $User_Name
        }

        if (-not ([string]::IsNullOrEmpty($Log_Message))){
            WriteInfoToEventLog (-join("Status of ", $Service_Obj.DisplayName, ":`r`n", $Log_Message, "`n`nResetting the presets of service to default"))
            $Log_Message = ''
        }
    }
}

function EditGroupPolicyUpdateViaRegistry {
    <#
    .SYNOPSIS
    Edits Group Policy settings for Windows Update by modifying registry values.
    
    .DESCRIPTION
    Long description
    Modifies on specific properties under the 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\' 
    registry path, creating the registry path if it does not exist. The function sets specific parameters to
    ensure the desired Group Policy configurations. Parameter AUOptions is responsible for download notification and automatic installation of updates.
    Parameter NoAutoUpdate specifies general parameter of auto update activity.
    Setting a value of 1 to these two parameters disables notification and update download activity.
    #>

    [string]$Root_Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\'
    [string]$Log_Message = ''

    $List_Propeties = @(
        'AUOptions'
        'NoAutoUpdate'
    )

    if (!(Test-Path -Path $Root_Path)){
        New-Item -Path $Root_Path -Force
    
        Set-ItemProperty -Path $Root_Path $List_Propeties[0] 1 
        Set-ItemProperty -Path $Root_Path $List_Propeties[1] 1

        $Log_Message = ("Creating new subtree in registry for presets of Group Policy of Windows Updates." + 
                    "Setting new parameters - NoAutoUpdate: 1, AUOptions: 1.")

        WriteInfoToEventLog $Log_Message
    } 

    [string]$Result = ''
    $Log_Message = (" parameter from Group Policy has been changed. Setting default value.")

    foreach ($Item in $List_Propeties) {
        $Result = Get-ItemProperty -Path $Root_Path -Name $Item | Select-Object -ExpandProperty $Item

        if([int]$Result -ne 1){
            Set-ItemProperty -Path $Root_Path $Item 1 
            WriteInfoToEventLog $Item$Log_Message
        }
    }
}

function DisableScheduleTaskUpdate {
    <#
    .SYNOPSIS
    Disables specific scheduled tasks related to Windows Update.
    #>

    $Task_List = @(
        # \Microsoft\Windows\WindowsUpdate
        'Scheduled Start'
        # \Microsoft\Windows\UpdateOrchestrator
        'Report policies'
        'Schedule Scan'
        'Schedule Scan Static Task'
        'Schedule Work'
        'UpdateModelTask'
        'USO_UxBroker'
        # \Microsoft\Windows\WaaSMedic
        'PerformRemediation'
    )

    [string]$Result, [string]$Log_Message = ''
    
    foreach ($Item in $Task_List) {
        $Result = Get-ScheduledTask -TaskName $Item | Where-Object -Property State -eq "Ready" | Select-Object -ExpandProperty TaskPath 
        if($Result){
            $Log_Message += (-join("The task ", $Item, " (Path = ", $Result, ") has a status 'Ready'.", "Changing status to 'Disabled'.`n"))
            Disable-ScheduledTask -TaskPath $Result -TaskName $Item
        }
    }
    
    if (-not ([string]::IsNullOrEmpty($Log_Message))){
        WriteInfoToEventLog $Log_Message
    }
}

function RemoveUpdateDir {
    <#
    .SYNOPSIS
    Removes the contents of the Windows SoftwareDistribution directory, commonly used for Windows updates.
    #>

    [string]$Dir_Updates = 'C:\Windows\SoftwareDistribution'
  
    if((Get-ChildItem -Path $Dir_Updates -Force | Select-Object -First 1 | Measure-Object).Count -ne 0){
        WriteInfoToEventLog "Directory of Win updates is not empty.Removing..."
        Get-ChildItem -Path $Dir_Updates | Remove-Item -Recurse -Force  
    }
}

function main {
    CreateEventLog
    ConfigureServicesUpdate
    EditGroupPolicyUpdateViaRegistry
    DisableScheduleTaskUpdate
    RemoveUpdateDir
}

main