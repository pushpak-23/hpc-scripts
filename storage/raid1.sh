########### RAID1 Setup (Mirror)


# Creating RAID1 array with two devices (/dev/sdb and /dev/sdc)
mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sdb /dev/sdc

# View details of the RAID1 array
mdadm --detail /dev/md1

# Save RAID1 configuration to the mdadm configuration file
mdadm --detail --scan /dev/md1 >> /etc/mdadm/mdadm.conf

# Update the initramfs to include the RAID1 configuration
update-initramfs -u

# Create a filesystem (ext4) on the RAID1 array
mkfs.ext4 /dev/md1

# Create a mount point for the RAID1 array
mkdir -p /mnt/raid_1

# Mount the RAID1 array to the created mount point
mount /dev/md1 /mnt/raid_1/

# Create a test file to verify the RAID mount
cd /mnt/raid_1/
nano test.txt  # Add some content to the test file

# View the contents of the test file
cat test.txt


################ After Removing a Disk and Reassembling RAID1

# Stop the RAID1 array if needed (when removing a disk)
mdadm --stop /dev/md1

# Reassemble the RAID1 array (in case of disk replacement)
mdadm --assemble /dev/md1

# Check the details of the RAID1 array after reassembly
mdadm --detail /dev/md1




########################## Adding a New HDD to RAID1
#
# Add a new disk (/dev/sdc) to the existing RAID1 array (/dev/md1)
mdadm --add /dev/md1 /dev/sdc

