scm-safe-travarse
=================

Script to auto-restore server config if server became unavaliable after first run of scm(Ansible, Puppet, ...). It looks ugly, but it's tested and works fine. Run script, run scm, connect to server and run `/ansible-complete.sh`. If you can't connect to server for 10 minutes since script launch, it will restore `/etc` from backup and reboot server.

Copy it to / and launch befere first run of scm. It will create:
* `/etc/before-ansible` - copy of /etc
* `/ansible-restore.sh` - script to restore old config
* `/ansible-complete.sh` - script to clean all junk, if first scm run was successful.
* `/ANSIBLE-BEFORE` - flag file
* cron job in `/etc/cron.d`

`/etc` is backed up and flag file is created. After that, cron job every minute check age of flag file. If it's older than 10 minutes, `/etc` is restored from backup and server is rebooted. `/etc/failed-ansible` with failed config is created for debug.
