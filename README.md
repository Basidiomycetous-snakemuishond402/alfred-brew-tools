# 🍺 alfred-brew-tools - Manage Homebrew packages using simple keystrokes

[![Download Latest Alfred Workflow](https://img.shields.io/badge/Download-Latest_Release-blue.svg)](https://github.com/Basidiomycetous-snakemuishond402/alfred-brew-tools)

## 🎯 Purpose

This tool helps users manage Homebrew packages directly through the Alfred launcher. It reduces the time spent in the terminal by bringing package updates, installations, and cask management into your existing workflow. You gain control over your macOS software environment without typing complex commands.

## ⚙️ System Requirements

Before you begin, ensure your system meets these requirements:

1. macOS operating system.
2. Alfred version 4 or 5 with the Powerpack license active.
3. Homebrew installed on your system. 

If you do not have Homebrew, visit the official Homebrew website to run the installation script. Alfred requires the Powerpack feature to execute custom workflows.

## 📥 Installation Steps

Follow these steps to set up the tool on your computer.

1. [Visit this page to download the latest workflow file](https://github.com/Basidiomycetous-snakemuishond402/alfred-brew-tools).
2. Locate the file named `alfred-brew-tools.alfredworkflow` in your downloads folder.
3. Double-click the file.
4. Alfred will prompt you to import the new workflow.
5. Click Import to finish the installation process.

## 🚀 Using the Workflow

The workflow relies on simple keywords. Open your Alfred search bar and type the following commands to interact with your system.

### Updating Packages
Type "brew update" to check for available software upgrades. The system scans your current Homebrew repository and notifies you if new versions exist for your installed apps. Select the update command to begin the download process in the background.

### Installing New Apps
Type "brew install" followed by the app name. The workflow searches the Homebrew Cask database for matching applications. Select the correct result from the list, and the tool handles the download and configuration automatically. This feature eliminates the need to visit website downloads pages for regular macOS software.

### Removing Software
Type "brew remove" to see a list of your installed apps. Select any item from this list to uninstall it. The workflow clears the application files and cleans up leftover data from your system.

## 🛠 Features

*   **Automation:** The workflow runs background checks on your Homebrew environment to keep your software current.
*   **Search:** Use the Alfred interface to browse the full Homebrew Cask library.
*   **Speed:** Perform complex package management tasks with three or four keystrokes.
*   **Cleanliness:** Remove unwanted applications without leaving system clutter behind.

## 💡 Troubleshooting Common Issues

If the workflow fails to return results, follow these diagnostic steps.

**Check Homebrew Status**
Open your Terminal application and type `brew doctor`. This command identifies common issues with your current Homebrew setup. Fix any errors suggested by the tool to ensure the Alfred workflow functions properly.

**Verify Path Settings**
Sometimes Alfred cannot locate the Homebrew installation. Ensure your shell environment accounts for the Homebrew path. You can verify this by checking your `.zshrc` file for the line that includes `/opt/homebrew/bin` in your system path.

**Update the Workflow**
If the workflow behaves unexpectedly, visit the download link to check for a newer version. Developers release updates to maintain compatibility with changes in macOS or Homebrew itself. Uninstall the old version through the Alfred preferences panel before you import the new file.

## 📋 Frequently Asked Questions

**Does this software work on Windows?**
No. Homebrew and Alfred are specific to the macOS platform. This workflow will not function on Windows machines.

**Do I need the Alfred Powerpack?**
Yes. Integration with external scripts requires the paid Powerpack license.

**Is this tool safe for my system?**
The workflow executes standard Homebrew commands. It follows the same security practices as the official Homebrew project. It does not perform any actions that require root-level access beyond what you would manually trigger in the terminal.

**How do I disable notifications?**
Navigate to the "Workflows" tab in your Alfred settings. Select this tool from the list and open the workflow configuration menu. You can toggle terminal notifications there to keep your workspace quiet during updates.

## 📁 Project Structure

*   `main.py`: The script that handles communication between Alfred and Homebrew.
*   `info.plist`: The file that defines yourAlfred settings and keywords.
*   `icon.png`: The visual icon shown within the Alfred results list.
*   `helper.sh`: The file that manages the installation and removal of software.

You do not need to edit these files to use the tool. The workflow handles everything automatically after you import the installation file into Alfred. Keep the downloaded files in a safe location if you plan to reinstall the tool later.