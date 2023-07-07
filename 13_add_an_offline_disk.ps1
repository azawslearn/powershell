#################################
####ATTACH A VOLUME TO A VM#####
#################################

# Get a list of all disks
$disks = Get-Disk

# Filter the disks based on specific criteria (e.g., OperationalStatus)
$filteredDisks = $disks | Where-Object { $_.OperationalStatus -like "*offline*" }

# Display the disk number for each filtered disk
$filteredDisks | Select-Object Number, Size, Model

#$diskNumber = ($filteredDisks).Number
$diskNumber = 2

$driveLetter = "E"
$volumeSize = 5GB

# Initialize the disk
Initialize-Disk -Number $diskNumber -PartitionStyle GPT

# Create a new partition and assign a drive letter
New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel "NewVolume" -Confirm:$false

# Create a new volume with the specified size
New-Volume -DriveLetter $driveLetter -FileSystem NTFS -Size $volumeSize -Confirm:$false
