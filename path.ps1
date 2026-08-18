# Define the folder we want to add
$newFolder = "C:\Users\muman\OneDrive\Other\Documents\Coding\Jellyfin site"

# Grab your current User PATH variables
$currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

# Check if the folder is already in the PATH
if ($currentPath -split ';' -notcontains $newFolder) {
    # Combine the old PATH with our new folder
    $updatedPath = "$currentPath;$newFolder"
    
    # Save the new PATH back to Windows
    [Environment]::SetEnvironmentVariable("Path", $updatedPath, [EnvironmentVariableTarget]::User)
    
    Write-Host "Boom! Successfully added to your PATH!" -ForegroundColor Green
    Write-Host "Please restart your terminal to use the 'nstatus' command." -ForegroundColor Cyan
} else {
    Write-Host "Hold up! That folder is already in your PATH." -ForegroundColor Yellow
}