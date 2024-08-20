# Define the destination folder
$destinationFolder = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath '..\..\..\_retail_\Interface\AddOns'

# Create the destination folder if it does not exist
if (-not (Test-Path -Path $destinationFolder)) {
    try {
        New-Item -Path $destinationFolder -ItemType Directory | Out-Null
    } catch {
        Write-Output "Error creating the folder '$destinationFolder'. Error: $_"
        exit 1
    }
}

# Retrieve all folders starting with SVUI in the current directory
$sourcePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$foldersToCopy = Get-ChildItem -Path $sourcePath -Directory -Filter 'SVUI*'

# Count all items to copy for the progress bar
$totalItems = 0
foreach ($folder in $foldersToCopy) {
    $totalItems += (Get-ChildItem -Path $folder.FullName -Recurse -File).Count + 1 # +1 for the folder itself
}

# Copy each folder to the destination folder
$currentItem = 0
foreach ($folder in $foldersToCopy) {
    $sourceFolder = $folder.FullName
    $destinationPath = Join-Path -Path $destinationFolder -ChildPath $folder.Name

    if (-not (Test-Path -Path $destinationPath)) {
        try {
            Copy-Item -Path $sourceFolder -Destination $destinationPath -Recurse -Force
        } catch {
            Write-Output "Error copying the folder '$sourceFolder' to '$destinationPath'. Error: $_"
        }
    } else {
        # Synchronize files and folders
        $sourceItems = Get-ChildItem -Path $sourceFolder -Recurse
        foreach ($item in $sourceItems) {
            $relativePath = $item.FullName.Substring($sourceFolder.Length).TrimStart('\')
            $destinationItem = Join-Path -Path $destinationPath -ChildPath $relativePath

            if ($item.PSIsContainer) {
                if (-not (Test-Path -Path $destinationItem)) {
                    try {
                        New-Item -Path $destinationItem -ItemType Directory | Out-Null
                    } catch {
                        Write-Output "Error creating the folder '$destinationItem'. Error: $_"
                    }
                }
            } else {
                try {
                    if (-not (Test-Path -Path $destinationItem) -or (Get-Item -Path $item.FullName).LastWriteTime -gt (Get-Item -Path $destinationItem).LastWriteTime) {
                        Copy-Item -Path $item.FullName -Destination $destinationItem -Force
                    }
                } catch {
                    Write-Output "Error copying the file '$($item.FullName)'. Error: $_"
                }
            }

            # Update the progress bar
            $currentItem++
            $percentComplete = [math]::Round(($currentItem / $totalItems) * 100, 0)
            if ($percentComplete -gt 100) {
                $percentComplete = 100
            }
            Write-Progress -PercentComplete $percentComplete -Status "Copying in progress" -CurrentOperation "Processing item '$($item.FullName)'" -Activity "Copying items"
        }
    }

    # Update the progress bar for the copied folder
    $currentItem++
    $percentComplete = [math]::Round(($currentItem / $totalItems) * 100, 0)
    if ($percentComplete -gt 100) {
        $percentComplete = 100
    }
    Write-Progress -PercentComplete $percentComplete -Status "Copying in progress" -CurrentOperation "Copying folder '$sourceFolder'" -Activity "Copying folders"
}

# Optionally: Remove files or folders in the destination that are no longer present in the source
$destinationFolders = Get-ChildItem -Path $destinationFolder -Directory -Filter 'SVUI*'
foreach ($folder in $destinationFolders) {
    $destinationFolderPath = $folder.FullName
    $sourceFolderPath = Join-Path -Path $sourcePath -ChildPath $folder.Name

    if (-not (Test-Path -Path $sourceFolderPath)) {
        try {
            Remove-Item -Path $destinationFolderPath -Recurse -Force
        } catch {
            Write-Output "Error removing the folder '$destinationFolderPath'. Error: $_"
        }
    }
}

# Complete the progress bar
Write-Progress -PercentComplete 100 -Status "Copying complete" -CurrentOperation "End of process" -Activity "Copying items"
