#!/bin/bash
#set -x

# Some checks
which rsync
if [ $? -ne 0 ]; then
	echo "ERROR: rsync not found"
	exit 1
fi
service cron status || /etc/init.d/cron status
if [ $? -ne 0 ]; then
    echo "ERROR: cron service not found"
    exit 2
fi

# Backup /etc
rsync -aAX /etc/ /etc.before-ansible/

# Create scripts
cat > /ansible-restore.sh <<EOF
#!/bin/bash
wait=10
test=\`find /ANSIBLE-BEFORE -mmin +\$wait | wc -l\`
if [ \$test -ne 0 ]; then
	rsync -aAX --delete /etc/ /etc.failed-ansible/
	rsync -aAX --delete /etc.before-ansible/ /etc/
	rm -f /ANSIBLE-BEFORE
	/sbin/reboot
fi
EOF
chmod a+x /ansible-restore.sh
cat > /ansible-complete.sh <<EOF
#!/bin/bash
rm -f /ANSIBLE-BEFORE
rm -f /etc/cron.d/ansible-restore
rm -f /ansible-restore.sh
rm -f /ansible-complete.sh
rm -fr /etc.before-ansible/
rm -fr /etc.failed-ansible/
EOF
chmod a+x /ansible-complete.sh

# Create cron job. Will be installed on next cron restart
echo "* * * * * root /ansible-restore.sh" > /etc/cron.d/ansible-restore
service cron restart || /etc/init.d/cron restart || echo "ERROR: faild to restart cron"

# Create flag file
touch /ANSIBLE-BEFORE

date
echo "WARNING: You have 10 minutes to delete /ANSIBLE-BEFORE. Then /etc will be restoread and host will be rebooted."

