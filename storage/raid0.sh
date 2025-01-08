############### RAID 0 Setup (Striping)


# Create a RAID0 array with two or more devices (e.g., /dev/sdb and /dev/sdc)
mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc

# View the details of the RAID0 array
mdadm --detail /dev/md0

# Save the RAID configuration to the mdadm configuration file
mdadm --detail --scan /dev/md0 >> /etc/mdadm/mdadm.conf

# Update the initramfs to include the RAID0 configuration
update-initramfs -u

# Create a filesystem (ext4) on the RAID0 array
mkfs.ext4 /dev/md0

# Create a mount point for the RAID0 array
mkdir -p /mnt/raid_0

# Mount the RAID0 array to the created mount point
mount /dev/md0 /mnt/raid_0/

# Create a test file to verify the RAID mount
cd /mnt/raid_0/
nano test.txt  # Add some content to the test file

# View the contents of the test file
cat test.txt




######## After Removing a Disk and Reassembling RAID 0

# Stop the RAID0 array (if needed, e.g., for disk replacement)
mdadm --stop /dev/md0

# Reassemble the RAID0 array (if the other disk is still intact and functional)
mdadm --assemble /dev/md0

# Check the details of the RAID0 array after reassembly
mdadm --detail /dev/md0


########### Adding a New Disk to RAID 0
#
# Adding a new disk to RAID 0 would involve creating a new array; it's not a simple "add" operation.
# This would delete all existing data on the array, so backup data first.
mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd

# Create a new filesystem and mount the RAID 0 array
mkfs.ext4 /dev/md0
mkdir -p /mnt/raid_0
mount /dev/md0 /mnt/raid_0/



