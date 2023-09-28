# PrintX

## Introduction
PrintX is your premier tool for printer management within a Windows environment. With a seamless GUI, PrintX is designed to export, import, and display printer settings effortlessly. Crafted with dedication by Mr. Code Porter, PrintX is in its initial release stage.

## Table of Contents
- Features
- Getting Started
- Usage
- Settings Configuration
- Troubleshooting
- Feedback & Support
- Credits

## Features
- **Export Printer Settings**: Effortlessly backup your current printer settings into an XML file.
- **Import Printer Settings**: Swiftly restore printer settings from an XML backup.
- **List Printers**: Obtain a comprehensive list of printers configured on your machine, complete with essential details.
- **User-Friendly GUI**: Navigate through PrintX's functionalities with a simple, intuitive interface.

## Getting Started
- **Installation**: Ensure you have PowerShell and the necessary Windows Forms and JSON Assemblies. Download `PrintX.ps1` and `settings.json` to a convenient location.
- **Permissions**: Make certain that the script has the necessary permissions to execute and manage printers. Execution policy modifications in PowerShell might be required using `Set-ExecutionPolicy`.

## Usage
- **Launching the Tool**: Navigate to where `PrintX.ps1` resides and execute it, either by double-clicking or running it from the PowerShell terminal.
- **Interactive Menu**: Upon launch, the tool offers an interactive GUI. Choose the required action and follow any provided prompts.

## Settings Configuration
- **Accessing Settings**: In the main GUI, click on the 'Settings' button.
- **Modifying the Backup Path**: Within the Settings window, modify the default backup location as desired.
- **Saving**: After adjustments, click 'Save' for the changes to take effect.

## Troubleshooting
- **Script Execution Issues**: Confirm that your PowerShell execution policy permits the script's operation.
- **Printer Management Issues**: Ensure you have the appropriate permissions to manage printers and that your configurations are correct.
- **Configuration Problems**: If PrintX behaves unexpectedly, confirm the format and location of `settings.json`.

## Feedback & Support
Your input is invaluable. For questions, feedback, or if any issues arise, please reach out. We're continually aiming to enhance PrintX based on your insights.

## Credits
PrintX is innovatively designed and maintained by Mr. Code Porter. Currently in its debut phase, PrintX is set for continuous evolution. All feedback and contributions are enthusiastically welcomed!
