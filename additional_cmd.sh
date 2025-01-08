# Show iSCSI sessions
iscsiadm -m session

# Get detailed session info (use -P 1 for detailed output)
iscsiadm -m session -P 1

# Logout from a specific iSCSI target
iscsiadm -m node -T iqn.2024-12.in.cdac.acts.hpcsa.sbm:disk1 -p 192.168.82.191:3260 --logout

# Logout from all iSCSI targets
iscsiadm -m node --logoutall=all

