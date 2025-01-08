# Step 1: Install LVM Tools and Prepare Disks
#
# List available block devices
lsblk 

# Create physical volumes on the disks /dev/sdb and /dev/sdc
pvcreate /dev/sdb /dev/sdc

# Install LVM2 package if it's not installed
apt-get install lvm2

# Verify the creation of physical volumes
pvs


####### Step 2: Create Volume Group

# Create a volume group named 'HPCSA' with /dev/sdb and /dev/sdc as physical volumes
vgcreate HPCSA /dev/sdb /dev/sdc

# View details of volume groups
vgs

# Display details of physical volumes
pvdisplay

# Display details of volume groups
vgdisplay



###### Step 3: Create Logical Volumes
#
#
# Create a logical volume named 'hpcsa_lab1' of size 1GB in the 'HPCSA' volume group
lvcreate -n hpcsa_lab1 --size 1G HPCSA

# Verify the logical volumes
lvs

# Verify the volume group status
vgs



########## Step 4: Format the Logical Volume
#
# Format the logical volume /dev/mapper/HPCSA-hpcsa_lab1 with ext4 filesystem
mkfs.ext4 /dev/mapper/HPCSA-hpcsa_lab1

# List available partitions to verify the new filesystem
fdisk -l


######### Step 5: Mount the Logical Volume
#
# Create a mount point
mkdir /mnt/disk-1

# Mount the logical volume to /mnt/disk-1
mount /dev/mapper/HPCSA-hpcsa_lab1 /mnt/disk-1/



###### Step 6: Extend the Logical Volume and Resize Filesystem
#
#
# Extend the logical volume by 2GB
lvextend -L +2G /dev/mapper/HPCSA-hpcsa_lab1

# Verify the logical volume size after extension
lvs

# Resize the filesystem on the logical volume to use the additional space
resize2fs /dev/mapper/HPCSA-hpcsa_lab1

# Verify the new filesystem size
df -h


######### Step 7: Create and Mount Another Logical Volume
#
# Create another logical volume named 'hpcsa_lab_3' of size 1GB
lvcreate -n hpcsa_lab_3 --size 1G HPCSA

# Format the new logical volume with ext4 filesystem
mkfs.ext4 /dev/mapper/HPCSA-hpcsa_lab_3

# Create a mount point for the new logical volume
mkdir /mnt/disk_3

# Mount the new logical volume to /mnt/disk_3
mount /dev/mapper/HPCSA-hpcsa_lab_3 /mnt/disk_3/



####### Step 8: Extend the New Logical Volume and Resize Filesystem
#
#
# Extend the new logical volume by 2GB
lvextend -L +2G /dev/mapper/HPCSA-hpcsa_lab_3

# Verify the logical volume size after extension
lvs

# Resize the filesystem to use the additional space
resize2fs /dev/mapper/HPCSA-hpcsa_lab_3

# Check the filesystem size
df -h


########### Step 9: Remove a Logical Volume (Optional)
#
#
# If needed, remove the logical volume (example: hpcsa_lab1)
lvremove -n hpcsa_lab1

# Verify the removal of the logical volume
lvs



