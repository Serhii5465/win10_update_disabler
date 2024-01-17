# Win10_Update_Disabler_Script-PS

A small utility written on PowerShell to disable annoying updates in Windows 10.
Can be run as a standalone script manually or through the Task Scheduler.

# Dependencies
Before using the Upd_Disabler.ps1 script, the PsExec utility is required. This utility is used to elevate system privileges, edit certain properties of services, and schedule tasks in Windows.

# What does this tool do exactly?
1. Disables windows update services and their helpers (Windows Update: wuauserv, Update Orchestrator service - UsoSvc, Windows Update Medic service - WaaSMedicSvc).It also sets new values for the parameters Start Type='Disabled' and Log On As='Guest'.
2. Disables all scheduled tasks for updates in the WindowsUpdate, UpdateOrchestrator, and WaaSMedic sections.
3. Edits group policy for Windows updates via the registry (disabling activity notifications about available updates and automatic downloading to the PC).
4. It deletes already downloaded windows update files.

# Warnings!
Before use, make sure you have a system backup. To restore default values, use the upd_enabler.ps1 script, which located in the 'reset' folder.

# Logging
All actions related to making changes to the system are recorded in the Event Log. Parameters for searching log entries:

 - Log Name: Application
 - Source : Disabler Windows 10 Update
 - Event ID : 47990

# How to use?
Clone the repository to your PC. Download the PsExec utility and place the exe file in the root of the repository.

## For disabling updates 

### Manualy mode
Run init_disabler.bat with administrator privileges.

### As scheduled task
Create a scheduled task with the following launch parameters:

Tab 'General':
 - Run with the highest privileges
 - When running the task, use the following user account: System. Run whether user is logged on or not
 - Configure for: Windows 10


Tab 'Triggers':
 - Begin the task: On a schedule
 - One time: set your current time
 - Repeat task every: **20 min** for a duration of **indefinitely**

Tab 'Actions':
 - Action: Start a program
 - Program/Script: Powershell
 - Arguments: -executionpolicy unrestricted -file **{Your path to clonned repo}**\Upd_Disabler.ps1

## For enabling updates
Put PsExec.exe to 'reset' folder and run init_enabler.bat with admin privileges.

# Notes
The utility is still in BETA and undergoing testing. It has been tested and confirmed to work on the Windows 10 LTSC (21H2) operating system, which is used as both the host and guest on Hyper-V.

# License
MIT
