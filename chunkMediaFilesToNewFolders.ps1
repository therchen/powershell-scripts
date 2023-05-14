$inputFolder = "C:\Users\timhw\OneDrive"
$outputFolder = "E:\Organized Photos"
$folderSizeLimit = 5

<#
This script allows you to define a folder ($inputFolder) to search for media files (as defined in the $items variable below) 
The script will search $inputFolder + sub-folders for media files
It will then put the files in the $outputFolder in chunks, based on the $folderSizeLimit you provide (in GB)
The folder names of the chunked groups are set in sequential order - Padded with 4 characters (ie 0001, 0002, 0003)
#>

param (
    <#The folder where you want to search for media files#>
    [Parameter(Mandatory = $true)][string]$inputFolder,

    <#The folder where you want to save your media files#>
    [Parameter(Mandatory = $true)][string]$outputFolder,

    <#The gigabyte limit per each folder that is created $outputFolder (ie the files found in $inputFolder are chunked in groups of this size)#>
    [Parameter(Mandatory = $true)][int]$folderSizeLimit
) 

$movedFilesCount = 0
if (-not($startingFilesCount -eq 0)){
    $foldersCount = (Get-ChildItem -Directory -Path $outputFolder | Measure-Object).Count
    if ($foldersCount -eq 0) {
        $folderName = "0001"
        $folderPath = $outputFolder + "/" + $folderName        
        New-Item -Path $outputFolder -Name $folderName -ItemType Directory 
    }
    else {
        $foldersCount = [int]$foldersCount + 1
        $foldersCount = '{0:d4}' -f $foldersCount
        $folderName = $foldersCount.ToString();
        $folderPath = $outputFolder + "/" + $folderName
        New-Item -Path $outputFolder -Name $folderName -ItemType Directory  
    }
    $items = Get-ChildItem -Path $inputFolder -Include *.jpg, *.png, *.jpeg, *.mp4, *.mov, *.heic, *.gif -Recurse 
    $items | ForEach-Object {
        if (-not($_.PSIsContainer)) {
            if ( (Test-Path $folderPath) -and (Get-Item $folderPath).PSIsContainer ) {
                $measure = Get-ChildItem $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
                $folderSize = '{0:N2}' -f ($measure.Sum / 1Gb)
                if ($folderSize -lt $folderSizeLimit) {
                    Move-Item -Path $_.FullName -Destination $folderPath -Force -ErrorAction SilentlyContinue
                    $movedFilesCount++
                }
                else {
                    $foldersCount = [int]$foldersCount + 1
                    $foldersCount = '{0:d4}' -f $foldersCount
                    $folderName = $foldersCount.ToString();
                    $folderPath = $outputFolder + "/" + $folderName
                    New-Item -Path $outputFolder -Name $folderName -ItemType Directory  
                    Move-Item -Path $_.FullName -Destination $folderPath -Force -ErrorAction SilentlyContinue
                    Write-Host "movedFilesCount" "$($movedFilesCount)"
                }
            }    
        } 
    }
}
Write-Host Done!