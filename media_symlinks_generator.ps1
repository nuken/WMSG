# media_symlinks_generator.ps1

function Create-Symlinks {
    param(
        [string]$SourceRootPath,         # The root directory containing the original files/folders
        [string]$DestinationSymlinkPath, # The root directory where the symbolic links will be created
        [string]$LinkType                # "Directory" for folder symlinks, "File" for file symlinks
    )

    Write-Host "`n--- Processing '$LinkType' Symlinks ---`n"
    Write-Host "  Source: '$SourceRootPath'"
    Write-Host "  Destination: '$DestinationSymlinkPath'"

    # --- Step 1: Ensure the Destination Root Exists ---
    Write-Host "  -> Verifying Destination Root: '$DestinationSymlinkPath'"
    if (-not (Test-Path $DestinationSymlinkPath)) {
        Write-Host "  -> Destination directory '$DestinationSymlinkPath' does NOT exist. Attempting to create."
        try {
            New-Item -ItemType Directory -Path $DestinationSymlinkPath | Out-Null
            Write-Host "  -> Destination directory '$DestinationSymlinkPath' created successfully."
        } catch {
            Write-Error "Failed to create destination directory '$DestinationSymlinkPath': $($_.Exception.Message)"
            return # Exit the function if destination cannot be created
        }
    } else {
        Write-Host "  -> Destination directory '$DestinationSymlinkPath' already exists."
    }

    # --- Step 2: Process based on Link Type ---
    if ($LinkType -eq "Directory") {
        # Create directory symlinks for each subfolder in the SourceRootPath
        Write-Host "  -> Scanning for subdirectories in '$SourceRootPath'..."
        $sourceItems = Get-ChildItem -Path $SourceRootPath -Directory -ErrorAction SilentlyContinue # Ignore errors if path is invalid

        if ($null -eq $sourceItems -or $sourceItems.Count -eq 0) {
            Write-Warning "  -> No subdirectories found in '$SourceRootPath'. No directory symlinks will be created."
        } else {
            Write-Host "  -> Found $($sourceItems.Count) subdirectories in '$SourceRootPath'."
        }

        $sourceItems | ForEach-Object {
            $folderName = $_.Name
            $targetPath = $_.FullName # Full path to the original directory
            $linkPath = Join-Path $DestinationSymlinkPath $folderName # Full path for the new symlink

            Write-Host "  -> Checking link: '$linkPath' pointing to '$targetPath'"
            if (-not (Test-Path $linkPath)) {
                Write-Host "  -> Attempting to create directory symlink: '$linkPath' -> '$targetPath'"
                try {
                    New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath -ErrorAction Stop
                    Write-Host "  -> Successfully created symlink for directory: '$folderName'"
                } catch {
                    Write-Warning "  -> Error creating symlink for directory '$folderName': $($_.Exception.Message)"
                }
            } else {
                Write-Host "  -> Symlink for directory '$folderName' already exists. Skipping."
            }
        }
    } elseif ($LinkType -eq "File") {
        # Create file symlinks for each file in the SourceRootPath (matching extensions)
        $fileExtensionsInput = Read-Host "  -> Enter file extensions to link (e.g., '.mp4, .mkv, .ts' - comma-separated, no quotes)"
        $fileExtensions = $fileExtensionsInput.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } # Clean and filter empty strings

        if ($fileExtensions.Count -eq 0) {
            Write-Warning "  -> No file extensions entered. No file symlinks will be created."
            return
        }
        Write-Host "  -> Looking for files with extensions: $($fileExtensions -join ', ')"

        Write-Host "  -> Scanning for files in '$SourceRootPath' (including subfolders)..."
        # Using Where-Object for robust filtering after getting all files recursively
        $sourceItems = Get-ChildItem -Path $SourceRootPath -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $fileExtensions -contains $_.Extension }

        if ($null -eq $sourceItems -or $sourceItems.Count -eq 0) {
            Write-Warning "  -> No files with specified extensions found in '$SourceRootPath' or its subfolders. No file symlinks will be created."
        } else {
            Write-Host "  -> Found $($sourceItems.Count) files in '$SourceRootPath' and its subfolders."
        }

        $sourceItems | ForEach-Object {
            $fileName = $_.Name
            $targetPath = $_.FullName # Full path to the original file
            $linkPath = Join-Path $DestinationSymlinkPath $fileName # Full path for the new symlink

            Write-Host "  -> Checking link: '$linkPath' pointing to '$targetPath'"
            if (-not (Test-Path $linkPath)) {
                Write-Host "  -> Attempting to create file symlink: '$linkPath' -> '$targetPath'"
                try {
                    New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath -ErrorAction Stop
                    Write-Host "  -> Successfully created symlink for file: '$fileName'"
                } catch {
                    Write-Warning "  -> Error creating symlink for file '$fileName': $($_.Exception.Message)"
                }
            } else {
                Write-Host "  -> Symlink for file '$fileName' already exists. Skipping."
            }
        }
    } else {
        Write-Error "Invalid LinkType specified. Must be 'Directory' or 'File'."
    }
}

# --- Main Script Interaction ---

Write-Host "--- Generic Media Symlink Generator ---"
Write-Host "This script creates symbolic links on your Windows system."
Write-Host "A symbolic link (symlink) is like an advanced shortcut that makes a file or folder appear to exist in multiple locations."
Write-Host "Please ensure you run this script with Administrator privileges!"
Read-Host "Press Enter to continue..."

do {
    Write-Host "`nWhat type of symlinks would you like to process?"
    Write-Host "1. Directory Symlinks (e.g., for TV show folders)"
    Write-Host "2. File Symlinks (e.g., for movie files)"
    Write-Host "3. Both Directory and File Symlinks"
    Write-Host "4. Exit"

    $choice = Read-Host "Enter your choice (1, 2, 3, or 4)"

    switch ($choice) {
        "1" {
            # --- Directory Symlinks ---
            Write-Host "`n--- Setup for Directory Symlinks ---"
            Write-Host "  Source: This is the folder containing the original subfolders you want to link."
            Write-Host "          Each subfolder within this source will have a symlink created."
            $sourceDir = Read-Host "Enter the FULL path to your SOURCE directory (e.g., D:\MyOriginalContent\TVShows)"
            Write-Host "`n  Destination: This is the folder where the new symlinks (shortcuts to original folders) will appear."
            $destinationSymlinkDir = Read-Host "Enter the FULL path to your DESTINATION folder (e.g., C:\MyMediaLibrary\TVShows)"

            if (-not (Test-Path $sourceDir)) {
                Write-Warning "Source directory '$sourceDir' does not exist. Skipping directory symlink creation."
            } else {
                Create-Symlinks -SourceRootPath $sourceDir -DestinationSymlinkPath $destinationSymlinkDir -LinkType "Directory"
            }
        }
        "2" {
            # --- File Symlinks ---
            Write-Host "`n--- Setup for File Symlinks ---"
            Write-Host "  Source: This is the folder containing the original files you want to link."
            Write-Host "          Each file within this source (matching specified extensions) will have a symlink created."
            $sourceFileDir = Read-Host "Enter the FULL path to your SOURCE directory (e.g., D:\MyOriginalContent\Movies)"
            Write-Host "`n  Destination: This is the folder where the new symlinks (shortcuts to original files) will appear."
            $destinationFileSymlinkDir = Read-Host "Enter the FULL path to your DESTINATION folder (e.g., C:\MyMediaLibrary\Movies)"

            if (-not (Test-Path $sourceFileDir)) {
                Write-Warning "Source directory '$sourceFileDir' does not exist. Skipping file symlink creation."
            } else {
                Create-Symlinks -SourceRootPath $sourceFileDir -DestinationSymlinkPath $destinationFileSymlinkDir -LinkType "File"
            }
        }
        "3" {
            # Process Both (calls the logic for 1 and 2 sequentially)
            Write-Host "`n--- Setup for Directory Symlinks (First Part of Both) ---"
            Write-Host "  Source: This is the folder containing the original subfolders you want to link."
            Write-Host "          Each subfolder within this source will have a symlink created."
            $sourceDir = Read-Host "Enter the FULL path to your SOURCE directory for Directories (e.g., D:\MyOriginalContent\TVShows)"
            Write-Host "`n  Destination: This is the folder where the new symlinks (shortcuts to original folders) will appear."
            $destinationSymlinkDir = Read-Host "Enter the FULL path to your DESTINATION folder for Directories (e.g., C:\MyMediaLibrary\TVShows)"

            if (-not (Test-Path $sourceDir)) {
                Write-Warning "Source directory '$sourceDir' does not exist. Skipping directory symlink creation."
            } else {
                Create-Symlinks -SourceRootPath $sourceDir -DestinationSymlinkPath $destinationSymlinkDir -LinkType "Directory"
            }

            Write-Host "`n--- Setup for File Symlinks (Second Part of Both) ---"
            Write-Host "  Source: This is the folder containing the original files you want to link."
            Write-Host "          Each file within this source (matching specified extensions) will have a symlink created."
            $sourceFileDir = Read-Host "Enter the FULL path to your SOURCE directory for Files (e.g., D:\MyOriginalContent\Movies)"
            Write-Host "`n  Destination: This is the folder where the new symlinks (shortcuts to original files) will appear."
            $destinationFileSymlinkDir = Read-Host "Enter the FULL path to your DESTINATION folder for Files (e.g., C:\MyMediaLibrary\Movies)"

            if (-not (Test-Path $sourceFileDir)) {
                Write-Warning "Source directory '$sourceFileDir' does not exist. Skipping file symlink creation."
            } else {
                Create-Symlinks -SourceRootPath $sourceFileDir -DestinationSymlinkPath $destinationFileSymlinkDir -LinkType "File"
            }
        }
        "4" {
            Write-Host "Exiting script."
        }
        default {
            Write-Warning "Invalid choice. Please enter 1, 2, 3, or 4."
        }
    }
} while ($choice -ne "4") # Loop until user chooses to exit

Write-Host "`n--- Symlink generation process complete. ---"
Write-Host "Any applications configured to scan the DESTINATION folders should now see the linked content."
Read-Host "Press Enter to exit..."
