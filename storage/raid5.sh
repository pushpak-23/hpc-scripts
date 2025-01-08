##### RAID5 Setup (Parity Array)



# Create a RAID5 array with three devices (/dev/sdb, /dev/sdc, /dev/sdd)
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd

# View details of the RAID5 array
mdadm --detail /dev/md0

# Save RAID5 configuration to the mdadm configuration file
mdadm --detail --scan /dev/md0 >> /etc/mdadm/mdadm.conf

# Update the initramfs to include the RAID5 configuration
update-initramfs -u

# Create a filesystem (ext4) on the RAID5 array
mkfs.ext4 /dev/md0

# Create a mount point for the RAID5 array
mkdir -p /mnt/raid_5

# Mount the RAID5 array to the created mount point
mount /dev/md0 /mnt/raid_5/

# Navigate to the mount point and create a test file
cd /mnt/raid_5/
nano test.txt  # Add some content to the test file

# View the contents of the test file
cat test.txt




########## After Stopping and Reassembling RAID5
#
# Stop the RAID5 array (in case of disk removal or other maintenance)
mdadm --stop /dev/md0

# Reassemble the RAID5 array
mdadm --assemble /dev/md0

# Mount the RAID5 array again
mount /dev/md0 /mnt/raid_5/

# Navigate to the mount point and verify the test file
cd /mnt/raid_5/
ls  # List files in the directory
cat test.txt  # View the content of the test file

