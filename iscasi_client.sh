# Install open-iscsi package on the client
apt-get install open-iscsi


# Start the iSCSI service
systemctl start iscsid


# Discover available iSCSI targets on the server (replace with actual server IP)
iscsiadm -m discovery -t sendtargets -p 192.168.82.150:3260


# Login to the discovered iSCSI target
iscsiadm -m discovery -t sendtargets -p 192.168.82.150:3260 --login

# Verify the current iSCSI session
iscsiadm -m session

#########  create partion and filesystem on iscasi

# List available disks (the new iSCSI disk will be visible here)
fdisk -l

# Partition the iSCSI disk (use appropriate device name like /dev/sdx)
fdisk /dev/sdx

# Create a filesystem on the new partition (use ext4 or XFS based on your requirement)
mkfs.ext4 /dev/sdx


######### Mount the iSCSI Disk:
# Create a mount point
mkdir /mnt/iscsi_lv_disk01

# Mount the iSCSI disk to the mount point
mount /dev/sdx /mnt/iscsi_lv_disk01/

##############Check Disk Usage:

# Verify disk usage
df -h

# Logout from the iSCSI target
iscsiadm -m node --logoutall=all

