# Windows Media Symlink Generator (PowerShell)

## Table of Contents

* [Introduction](#introduction)
* [Features](#features)
* [Prerequisites](#prerequisites)
* [How to Use](#how-to-use)
    * [1. Save the Script](#1-save-the-script)
    * [2. Run as Administrator](#2-run-as-administrator)
    * [3. Follow the Prompts](#3-follow-the-prompts)
* [Important Considerations](#important-considerations)
* [Example Use Case](#example-use-case)
* [License](#license)

## Introduction

This PowerShell script is a versatile tool designed to create **symbolic links** (symlinks) on your Windows system. A symbolic link is an advanced type of shortcut that makes a file or folder appear to exist in multiple locations without actually duplicating the data. This is particularly useful for media libraries where you might have original files in one location (e.g., recorded by a DVR) but want them to appear in another location for a media server (e.g., Jellyfin, Plex, Emby) to scan, without consuming double the disk space.

This script is intentionally generalized, using "Source" and "Destination" terminology, so it can be adapted to various data organization needs, not just specific media applications.

## Features

* **Interactive Prompts:** Guides you through the process by asking for necessary paths and choices.
* **Choice of Link Type:** Allows you to create:
    * **Directory Symlinks:** Links to entire folders (e.g., for TV show seasons).
    * **File Symlinks:** Links to individual files (e.g., for movies).
    * **Both:** Process both types in one go.
* **Path Validation:** Basic checks to ensure the source directories exist.
* **Prevents Duplicates:** Skips creating symlinks if one already exists at the destination.
* **User-Friendly Output:** Provides clear messages about what the script is doing.

## Prerequisites

* **Operating System:** Windows 10 or newer (PowerShell is pre-installed).
* **PowerShell:** The script is written in PowerShell.
* **Administrator Privileges:** **Crucially, the script must be run with Administrator privileges** to create symbolic links.

## How to Use

### 1. Save the Script

Copy the entire PowerShell script content (from the previous response) and save it to a file named `media_symlinks_generator.ps1` (or any `.ps1` name you prefer) on your Windows machine (e.g., in `C:\Scripts\`).

### 2. Run as Administrator

Symbolic links can only be created with elevated permissions.

* **Recommended Method:** Open File Explorer, navigate to where you saved `media_symlinks_generator.ps1`, **right-click** the file, and select **"Run with PowerShell"**. If prompted by User Account Control (UAC), click "Yes".
* **Alternative Method:**
    1.  Search for "PowerShell" in the Start Menu.
    2.  Right-click "Windows PowerShell" and select **"Run as administrator"**.
    3.  In the Administrator PowerShell window, navigate to the directory where you saved the script using `cd`. For example:
        ```powershell
        cd C:\Scripts\
        ```
    4.  Then, execute the script:
        ```powershell
        .\media_symlinks_generator.ps1
        ```

### 3. Follow the Prompts

The script is interactive and will guide you through the process:

* It will first remind you to run as Administrator and ask you to press Enter to continue.
* **Main Menu:** You will then be presented with a menu to choose what type of symlinks you want to create:
    * `1. Directory Symlinks`: For linking folders (e.g., TV show folders).
    * `2. File Symlinks`: For linking individual files (e.g., movie files).
    * `3. Both Directory and File Symlinks`: To process both types sequentially.
    * `4. Exit`: To quit the script.
* **Source Path:** For each type, you'll be asked for the "Source" path. This is the **full path to the directory containing the original files or folders** you want to link.
    * *Example:* `D:\MyDVRRecordings\TV Shows` or `E:\MyArchives\Movies`
* **Destination Path:** You'll then be asked for the "Destination" path. This is the **full path to the directory where the new symbolic links will be created**. This is the folder your media server or other application will scan.
    * *Example:* `C:\MediaServer\Library\TV Shows` or `C:\MediaServer\Library\Movies`
* **File Extensions (for File Symlinks):** If you choose to create file symlinks, you'll be prompted to enter a comma-separated list of file extensions (e.g., `.mp4, .mkv, .ts`).

The script will then process the directories and files, creating symlinks as needed, and provide feedback on its progress.

## Important Considerations

* **Administrator Privileges are Essential:** The `New-Item -ItemType SymbolicLink` command **will fail without Administrator rights**.
* **Original Files Untouched:** This script only creates symbolic links; it does **not** move, copy, or rename your original source files or folders. Your original data remains exactly where it is.
* **Windows Specific:** This script uses Windows-specific commands and PowerShell cmdlets and will not work on Linux or macOS without significant modification (where `ln -s` is used for symlinks).
* **Automation (Task Scheduler):** For regularly updating your symlinks, you can configure a [Windows Task Scheduler](https://learn.microsoft.com/en-us/windows/win32/tasksch/about-the-task-scheduler) task to run this script periodically with "highest privileges."
* **Renaming Media:** This script **does not rename** your media files. If your media server requires specific naming conventions for proper metadata scraping, consider using a dedicated media renaming tool like [FileBot](https://www.filebot.net/) or a media management system like [Sonarr](https://sonarr.tv/) (for TV) / [Radarr](https://radarr.video/) (for movies). These tools are designed to handle complex renaming based on fetched metadata.

## Example Use Case

Let's say you have:
* Original TV recordings in: `D:\DVR Recordings\Shows\`
* Original Movie files in: `D:\DVR Recordings\Movies\`

And you want your media server (like Jellyfin) to scan:
* `C:\Jellyfin Library\TV\`
* `C:\Jellyfin Library\Movies\`

You would:
1.  Run the script as Administrator.
2.  Choose option `3` (Both Directory and File Symlinks).
3.  When prompted for **Directory Symlinks**:
    * Source: `D:\DVR Recordings\Shows`
    * Destination: `C:\Jellyfin Library\TV`
4.  When prompted for **File Symlinks**:
    * Source: `D:\DVR Recordings\Movies`
    * Destination: `C:\Jellyfin Library\Movies`
    * File Extensions: `.mp4, .mkv, .ts` (or whatever your movie files are)

After the script runs, `C:\Jellyfin Library\TV` will contain symlinks to your TV show folders from `D:\DVR Recordings\Shows`, and `C:\Jellyfin Library\Movies` will contain symlinks to your movie files from `D:\DVR Recordings\Movies`. Your media server can then scan `C:\Jellyfin Library\` and find all your content!

## License

This script is provided "as-is" under the MIT License. You are free to use, modify, and distribute it.