#!/bin/bash

set -e  # Exit on any error

# Variables for configuration
MASTER_IP="192.168.147.139"
COMPUTE_NODES=("compute1")
HOSTNAME="controller"
USERNAME="ubuntu"
PASSWORD="password"
SLURM_VERSION="21.08.8"
SLURM_BASE_DIR="/home/$USERNAME/slurm-$SLURM_VERSION"


# Step 1: Download and extract Slurm source
wget -q https://download.schedmd.com/slurm/slurm-$SLURM_VERSION.tar.bz2
tar -xjf slurm-$SLURM_VERSION.tar.bz2

# Step 2: Install necessary dependencies
sudo apt update
sudo apt install -y build-essential munge libmunge-dev libmunge2 mariadb-client \
  libssl-dev libpam-dev libnuma-dev perl mailutils mariadb-server slurm-client

# Step 3: Build and install Slurm
cd $SLURM_BASE_DIR
./configure --prefix=$SLURM_BASE_DIR
make -j$(nproc)
sudo make install
cd $SLURM_BASE_DIR/etc  # Return to the SLURM base directory

# Step 4: Set up Munge
sudo create-munge-key
sudo chown munge: /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
sudo systemctl enable --now munge

# Step 5: Configure Slurm
sudo mkdir -p /etc/slurm-llnl
sudo cp $SLURM_BASE_DIR/etc/slurm.conf.example $SLURM_BASE_DIR/etc/slurm.conf

# Update slurm.conf
sudo sed -i \
    -e "s/^ClusterName=.*/ClusterName=cluster/" \
    -e "s/^SlurmctldHost=.*/SlurmctldHost=$HOSTNAME/" \
    -e "s/^AuthType=.*/AuthType=auth\/munge/" \
    -e "s/^ProctrackType=.*/ProctrackType=proctrack\/linuxproc/" \
    -e "s/^AccountingStorageType=.*/AccountingStorageType=accounting_storage\/slurmdbd/" \
    -e "s/^SlurmUser=.*/SlurmUser=$USERNAME/" \
    $SLURM_BASE_DIR/etc/slurm.conf

# Add compute nodes
for node in "${COMPUTE_NODES[@]}"; do
  echo "NodeName=$node CPUs=4 State=UNKNOWN" | sudo tee -a $SLURM_BASE_DIR/etc/slurm.conf
done


sudo bash -c "cat >> $SLURM_BASE_DIR/etc/slurm.conf" <<EOL
PartitionName=newpartition Nodes=ALL Default=YES MaxTime=INFINITE State=UP
MailProg=/usr/bin/mail
EOL

sudo mkdir -p /etc/slurm/
sudo cp -r $SLURM_BASE_DIR/etc/slurm.conf /etc/slurm/
sudo cp -r $SLURM_BASE_DIR/etc/slurm.conf /etc/slurm-llnl/

# Step 6: Configure Slurm Database Daemon (slurmdbd)
sudo cp -r $SLURM_BASE_DIR/etc/slurmdbd.conf.example $SLURM_BASE_DIR/etc/slurmdbd.conf


sudo sed -i \
    -e "s/^DbdAddr=.*/DbdAddr=$MASTER_IP/" \
    -e "s/^SlurmUser=.*/SlurmUser=$USERNAME/" \
    -e "s/^StoragePass=.*/StoragePass=$PASSWORD/" \
    -e "s/^StorageUser=.*/StorageUser=$USERNAME/" \
    $SLURM_BASE_DIR/etc/slurmdbd.conf


sudo chmod 600 $SLURM_BASE_DIR/etc/slurmdbd.conf
sudo chown $USERNAME:$USERNAME $SLURM_BASE_DIR/etc/slurmdbd.conf

sudo cp -r $SLURM_BASE_DIR/etc/slurmdbd.conf /etc/slurm-ll/




# Step 7: Configure MySQL
sudo sed -i "s/^bind-address.*/bind-address = $MASTER_IP/" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb

sudo mysql -u root -e "DROP USER IF EXISTS 'ubuntu'@'%';"
sudo mysql -u root <<EOF
CREATE USER 'ubuntu'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'ubuntu'@'localhost';
FLUSH PRIVILEGES;
EOF



# Step 8: Set up required directories
sudo mkdir -p /var/spool/slurmd /var/log/slurmctld
sudo chown $USERNAME:$USERNAME /var/spool/slurmd /var/log/slurmctld
sudo chmod 700 /var/spool/slurmd /var/log/slurmctld


# Step 9: Export environment variables
if ! grep -q "SLURM_INSTALL_DIR" ~/.bashrc; then
  echo "export LD_LIBRARY_PATH=\"$SLURM_INSTALL_DIR/lib:\$LD_LIBRARY_PATH\"" | sudo tee -a ~/.bashrc
  echo "export PATH=\"$SLURM_INSTALL_DIR/sbin:\$PATH\"" | sudo tee -a ~/.bashrc
  echo "export PATH=\"$SLURM_INSTALL_DIR/bin:\$PATH\"" | sudo tee -a ~/.bashrc
fi
source ~/.bashrc


# Step 10: Deploy configuration files to compute nodes
for node in "${COMPUTE_NODES[@]}"; do
    scp -r $SLURM_BASE_DIR/etc/slurm.conf /etc/munge/munge.key $USERNAME@$node:/tmp/
done

# Step 11: Set up Slurm services
sudo cp $SLURM_BASE_DIR/etc/slurmctld.service /etc/systemd/system/
sudo cp $SLURM_BASE_DIR/etc/slurmd.service /etc/systemd/system/
sudo cp $SLURM_BASE_DIR/etc/slurmdbd.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now munge slurmctld slurmd slurmdbd

# Step 12: Verify services
for service in munge slurmctld slurmd slurmdbd; do
  sudo systemctl is-active --quiet $service && echo "$service is running" || echo "$service failed to start"
done

# Step 13: Check nodes
sinfo
scontrol update nodename=compute1 state=idle
# scontrol update nodename=compute2 state=idle
sinfo
