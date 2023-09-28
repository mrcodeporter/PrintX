# Load Windows Forms and JSON Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Web.Extensions

# Logging function
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO","WARN","ERROR","DEBUG")]
        [string]$Level = "INFO",

        [Parameter(Mandatory=$false)]
        [string]$FunctionName = $null,

        [Parameter(Mandatory=$false)]
        [string]$Logfile = "PrinterManagement.log"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $computerName = $env:COMPUTERNAME
    $userName = $env:USERNAME
    $functionDetail = if ($FunctionName) { " [$FunctionName]" } else { "" }
    
    $logEntry = "$timestamp [$Level]$functionDetail ($computerName - $userName) $Message"
    
    Add-Content -Path $Logfile -Value $logEntry
}

# Functions to load and save settings
function Load-Settings {
    if (Test-Path "./settings.json") {
        return (Get-Content -Path "./settings.json" | ConvertFrom-Json)
    } else {
        # Default settings if no file found
        return @{
            defaultBackupLocation = "C:\DefaultBackupLocation"
        }
    }
}

function Save-Settings($settings) {
    $settings | ConvertTo-Json | Set-Content -Path "./settings.json"
}

# Functions for printer actions
function Export-PrinterSettings {
    param (
        [string]$OutputFile = (Load-Settings).defaultBackupLocation + "\PrintersBackup.xml"
    )
    try {
        Get-Printer | Export-Clixml -Path $OutputFile
        Write-Log -Message "Exported printer settings to $OutputFile" -Level INFO -FunctionName "Export-PrinterSettings"
    } catch {
        Write-Log -Message "Failed to export printer settings. Error: $($_.Exception.Message)" -Level ERROR -FunctionName "Export-PrinterSettings"
    }
}

function Import-PrinterSettings {
    param (
        [string]$InputFile = (Load-Settings).defaultBackupLocation + "\PrintersBackup.xml"
    )
    $printers = Import-Clixml -Path $InputFile

    foreach ($printer in $printers) {
        try {
            if (-not (Get-Printer -Name $printer.Name -ErrorAction SilentlyContinue)) {
                Add-Printer -Name $printer.Name -DriverName $printer.DriverName -PortName $printer.PortName
                Write-Log -Message "Added printer $($printer.Name)" -Level INFO -FunctionName "Import-PrinterSettings"
            }
        } catch {
            Write-Log -Message "Failed to add printer $($printer.Name). Error: $($_.Exception.Message)" -Level ERROR -FunctionName "Import-PrinterSettings"
        }
    }
}




function Show-Printers {
    $formList = New-Object System.Windows.Forms.Form
    $formList.Text = "List of Printers"
    $formList.Size = New-Object System.Drawing.Size(700,400)
    $formList.StartPosition = "CenterScreen"
    
    $listView = New-Object System.Windows.Forms.ListView
    $listView.View = [System.Windows.Forms.View]::Details
    $listView.Width = 870
    $listView.Height = 500
    $listView.Location = New-Object System.Drawing.Point(10,10)
    
    # Define columns
    $listView.Columns.Add("Printer Name", 200)
    $listView.Columns.Add("Driver Name", 150)
    $listView.Columns.Add("Port Name", 100)
    $listView.Columns.Add("Share Name", 100)

    $printers = Get-Printer
    foreach ($printer in $printers) {
        $item = New-Object System.Windows.Forms.ListViewItem($printer.Name)
        $item.SubItems.Add($printer.DriverName)
        $item.SubItems.Add($printer.PortName)
        if ($printer.Shared) {
            $item.SubItems.Add($printer.ShareName)
        } else {
            $item.SubItems.Add("Not Shared")
        }
        $listView.Items.Add($item)
    }

    $formList.Controls.Add($listView)
    $formList.ShowDialog()
    Write-Log -Message "Displayed list of printers on this machine" -Level INFO -FunctionName "Show-Printers"
}



# Functions to load and save settings
function Load-Settings {
    if (Test-Path "./settings.json") {
        return (Get-Content -Path "./settings.json" | ConvertFrom-Json)
    } else {
        # Default settings if no file found
        return @{
            defaultBackupLocation = "C:\DefaultBackupLocation"
        }
    }
}

function Save-Settings($settings) {
    $settings | ConvertTo-Json | Set-Content -Path "./settings.json"
}
function Show-Settings {
    $settings = Load-Settings

    $settingsForm = New-Object System.Windows.Forms.Form
    $settingsForm.Text = "Settings"
    $settingsForm.Size = New-Object System.Drawing.Size(400,200)
    $settingsForm.StartPosition = "CenterScreen"

    $backupLabel = New-Object System.Windows.Forms.Label
    $backupLabel.Text = "Default Backup Location:"
    $backupLabel.Location = New-Object System.Drawing.Point(10,20)
    $backupLabel.AutoSize = $true
    $settingsForm.Controls.Add($backupLabel)

    $backupTextBox = New-Object System.Windows.Forms.TextBox
    $backupTextBox.Location = New-Object System.Drawing.Point(10,50)
    $backupTextBox.Size = New-Object System.Drawing.Size(360,20)
    $backupTextBox.Text = $settings.defaultBackupLocation
    $settingsForm.Controls.Add($backupTextBox)

    $saveButton = New-Object System.Windows.Forms.Button
    $saveButton.Text = "Save"
    $saveButton.Location = New-Object System.Drawing.Point(290,120)
    $saveButton.Add_Click({
        $settings.defaultBackupLocation = $backupTextBox.Text
        Save-Settings $settings
        $settingsForm.Close()
        [System.Windows.Forms.MessageBox]::Show("Settings saved successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $settingsForm.Controls.Add($saveButton)

    $settingsForm.ShowDialog()
}


# Main GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "Printer Management"
$form.Size = New-Object System.Drawing.Size(300,350) # Adjusted form size to fit all buttons properly
$form.StartPosition = "CenterScreen"

$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Location = New-Object System.Drawing.Point(10,10)
$exportButton.Size = New-Object System.Drawing.Size(260,40)
$exportButton.Text = "Export Printer Settings"
$exportButton.Add_Click({
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "XML files (*.xml)|*.xml"
    $saveFileDialog.Title = "Save printer settings to file"
    if ($saveFileDialog.ShowDialog() -eq "OK") {
        Export-PrinterSettings -OutputFile $saveFileDialog.FileName
        [System.Windows.Forms.MessageBox]::Show("Settings exported successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})
$form.Controls.Add($exportButton)

$importButton = New-Object System.Windows.Forms.Button
$importButton.Location = New-Object System.Drawing.Point(10,60)
$importButton.Size = New-Object System.Drawing.Size(260,40)
$importButton.Text = "Import Printer Settings"
$importButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "XML files (*.xml)|*.xml"
    $openFileDialog.Title = "Open printer settings file"
    if ($openFileDialog.ShowDialog() -eq "OK") {
        Import-PrinterSettings -InputFile $openFileDialog.FileName
        [System.Windows.Forms.MessageBox]::Show("Settings imported successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})
$form.Controls.Add($importButton)

$listButton = New-Object System.Windows.Forms.Button
$listButton.Location = New-Object System.Drawing.Point(10,110)
$listButton.Size = New-Object System.Drawing.Size(260,40)
$listButton.Text = "List Printers"
$listButton.Add_Click({ Show-Printers })
$form.Controls.Add($listButton)

$settingsButton = New-Object System.Windows.Forms.Button
$settingsButton.Location = New-Object System.Drawing.Point(10,160)
$settingsButton.Size = New-Object System.Drawing.Size(260,40)
$settingsButton.Text = "Settings"
$settingsButton.Add_Click({ Show-Settings })
$form.Controls.Add($settingsButton)

$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Location = New-Object System.Drawing.Point(10,210)
$exitButton.Size = New-Object System.Drawing.Size(260,40)
$exitButton.Text = "Exit"
$exitButton.Add_Click({ $form.Close() })
$form.Controls.Add($exitButton)






$form.ShowDialog()
