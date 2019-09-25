$fileCount = 0
$incrementer = 1000
$folderNumber = 1000
$ls = ls
$folder = New-Item -Path .\ -Name $folderNumber -ItemType "directory"
foreach($file in $ls) {
    Move-Item -Path $file.FullName -Destination $folder.FullName

    if($fileCount -eq $folderNumber) {
        $folderNumber += $incrementer
        $folder = New-Item -Path .\ -Name $folderNumber -ItemType "directory"
    }
    $fileCount++
}