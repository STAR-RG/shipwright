from	ubuntu:12.04

# Configure apt
run	echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
run	apt-get -y update
run	apt-get -y install python-software-properties
run	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
run	add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/5.5/ubuntu precise main'
run     apt-key adv --recv-keys --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

# Make apt and MariaDB happy with the docker environment
run	echo "#!/bin/sh\nexit 101" >/usr/sbin/policy-rc.d
run	chmod +x /usr/sbin/policy-rc.d
run	cat /proc/mounts >/etc/mtab

# Install MariaDB
run	apt-get -y update
run	apt-get -y install 
run	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y iproute mariadb-galera-server galera rsync netcat-openbsd socat pv

# this is for testing - can be commented out later
run	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y iputils-ping net-tools

run	add-apt-repository 'deb http://repo.percona.com/apt precise main'
run	apt-get -y update
run	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y percona-xtrabackup

# add in extra wsrep scripts
add     wsrep_sst_common /usr/bin/wsrep_sst_common
add     wsrep_sst_xtrabackup-v2 /usr/bin/wsrep_sst_xtrabackup-v2

# Clean up
run	rm /usr/sbin/policy-rc.d
run	rm -r /var/lib/mysql

# Add config(s) - standalong and cluster mode
add	./my-cluster.cnf /etc/mysql/my-cluster.cnf
add     ./my-init.cnf /etc/mysql/my-init.cnf

expose	3306 4567 4444

add	./mariadb-setrootpassword /usr/bin/mariadb-setrootpassword
add	./mariadb-start /usr/bin/mariadb-start
cmd	["/usr/bin/mariadb-start"]

# vim:ts=8:noet:
