$Log_Name = 'Application'
$Event_Id = 47990
$Source = 'Disabler Windows 10 Updates'

function CreateEventLog {
    If ([System.Diagnostics.EventLog]::SourceExists($Source) -eq $False) {
        New-EventLog -LogName $Log_Name -Source $Source
    }
}

function WriteInfoToEventLog {
    param (
        [string]$Message
    )
    Write-EventLog -LogName $Log_Name -EventId $Event_Id -EntryType 'Information' -Source $Source -Message $Message
}

Export-ModuleMember -Function CreateEventLog, WriteInfoToEventLog