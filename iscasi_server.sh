# Install the necessary iSCSI target packages
apt-get install lvm2 targetcli-fb

####### Prepare Disk (sdb) for LVM:
#
# List available disks
lsblk

# Create a physical volume on the new disk
pvcreate /dev/sdb

# Create a volume group 'vg_iscsi' using /dev/sdb
vgcreate vg_iscsi /dev/sdb

# Create a logical volume 'lv_iscsi-disk-01' of size 1GB
lvcreate -n lv_iscsi-disk-01 -L 1G vg_iscsi

# Show the created logical volume
lvs

########### Configure iSCSI Target using targetcli:

# Launch targetcli shell
targetcli

# Navigate to the backstores and create a block backstore using the logical volume
/> cd backstores/block
/> create block1 /dev/mapper/vg_iscsi-lv_iscsi--disk--01

# Navigate to iSCSI targets and create a target
/> cd /iscsi
/> create iqn.2024-12.cdac.acts.hpcsa.sbm:disk1

# Set up ACLs for the target
/> cd iqn.2024-12.cdac.acts.hpcsa.sbm:disk1/tpg1/acls
/> create iqn.1993-08.org.debian:01:84104998b5d

# Associate the backstore with a LUN
/> cd ..
/> cd iqn.2024-12.cdac.acts.hpcsa.sbm:disk1/tpg1/luns
/> create /backstores/block/block1

# Exit targetcli
/> exit


#########Restart the iSCSI Target Service:

# Restart the iSCSI target service
systemctl restart rtslib-fb-targetctl

# Verify the service status
systemctl status rtslib-fb-targetctl


######### Additional Commands for CentOS VM:

# If the server is a CentOS VM, use the following commands to restart the target service
systemctl restart target
systemctl status target

