$ErrorActionPreference = 'Stop'

Import-Module -Name "$PSScriptRoot\utils\log.psm1"-Force

function ConfigureServicesUpdate {
    [string]$User_Name = '.\Guest'

    [string]$Path_Srv_Registry = 'HKLM:\SYSTEM\CurrentControlSet\Services'

    $List_Services = @(
        'wuauserv'      # Windows Update
        'UsoSvc'        # Update Orchestrator Service
        'WaaSMedicSvc'  # Windows Update Medic Service
    )
    
    [string]$Log_Message = ''
    [string]$Cur_Edit_Subtree = ''

    foreach ($Item in $List_Services) {
        if(Get-Service -Name $Item | Where-Object {$_.Status -eq "Running"}){
            Get-Service -Name $Item | Stop-Service -Force
            $Log_Message += "Is active; "
        }
        
        $Cur_Edit_Subtree = $Path_Srv_Registry + '\' + $Item
    
        if(Get-ItemProperty -Path $Cur_Edit_Subtree | Where-Object {[int]$_.Start -ne 4}){
            Set-ItemProperty -Path $Cur_Edit_Subtree -Name Start -Value 4
            $Log_Message += "StartMode is not 'Disabled'; "
        }

        if(Get-ItemProperty -Path $Cur_Edit_Subtree | Where-Object {$_.ObjectName -ne $User_Name}){
            Set-ItemProperty -Path $Cur_Edit_Subtree -Name ObjectName -Value $User_Name
            $Log_Message += "Logon credentials has been changed."
        } 

        if (-not ([string]::IsNullOrEmpty($Log_Message))){
            WriteInfoToEventLog "Status of", $Item, ":", $Log_Message, "Setting the presets of service to default"
            $Log_Message = ''
        }
    }
}

function EditGroupPolicyUpdateViaRegistry {
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
    $Task_List = @(
        'Scheduled Start'
        'Schedule Scan'
        'Schedule Scan Static Task'
        'Schedule Work'
        'Report policies'
        'UpdateModelTask'
        'USO_UxBroker'
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
    
    WriteInfoToEventLog $Log_Message
}

function RemoveUpdateDir {
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