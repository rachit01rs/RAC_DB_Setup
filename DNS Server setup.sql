[root@mydns ~]# df -h
/*
Filesystem              Type      Size  Used Avail Use% Mounted on
devtmpfs                devtmpfs  898M     0  898M   0% /dev
tmpfs                   tmpfs     910M     0  910M   0% /dev/shm
tmpfs                   tmpfs     910M  9.6M  901M   2% /run
tmpfs                   tmpfs     910M     0  910M   0% /sys/fs/cgroup
/dev/mapper/centos-root xfs       8.0G  1.9G  6.2G  23% /
/dev/sda1               xfs      1014M  195M  820M  20% /boot
tmpfs                   tmpfs     182M     0  182M   0% /run/user/0
*/

---- Step 1 -->> Configure the network
[root@mydns ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens33
/*

DEVICE="ens33"
TYPE="Ethernet"
BOOTPROTO="none"
NM_CONTROLLED=yes
DEFROUTE="yes"
NAME="ens33"
UUID="a2446459-ca4e-4b4d-b458-f9a7116e87be"
ONBOOT="yes"
IPADDR="192.168.120.100"
PREFIX="24"
GATEWAY="192.168.120.254"
DNS1="8.8.8.8"
DNS2="8.8.4.4"


*/ 
-- Step 2 -->> configure host 
[root@mydns ~]# vi /etc/hosts
/*
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1               openfiler.mydomain openfiler localhost.localdomain localhost openfiler
::1             localhost6.localdomain6 localhost6
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.120.100  mydns.racdomain.com mydns

*/
-- Step 3 -->> restart network

[root@mydns ~]# service network restart
/*
Restarting network (via systemctl):                        [  OK  ]

*/

-- Step 4 -->> On DNS Server
-- disabling the firewall.


[root@mydns ~]# service iptables stop
/*
Redirecting to /bin/systemctl stop iptables.service
*/
[root@mydns ~]# chkconfig iptables off
/*
Note: Forwarding request to 'systemctl disable iptables.service'.
Removed symlink /etc/systemd/system/basic.target.wants/iptables.service.
*/

[root@mydns ~]# iptables -F
[root@mydns ~]# service iptables save
/*
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
*/

[root@mydns ~]# iptables -L
/*
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination     
*/


--Step 5 --Configureing DNS Server
 --Install required PACKAGE
[root@mydns ~]# yum -y install bind
[root@mydns ~]# yum install bind-utils
/*
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: centos.mirror.net.in
 * extras: centos.mirror.net.in
 * updates: centos.mirror.net.in
base                                                                                                                               | 3.6 kB  00:00:00
extras                                                                                                                             | 2.9 kB  00:00:00
updates                                                                                                                            | 2.9 kB  00:00:00
Resolving Dependencies
--> Running transaction check
---> Package bind-utils.x86_64 32:9.11.4-26.P2.el7_9.15 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==========================================================================================================================================================
 Package                            Arch                           Version                                          Repository                       Size
==========================================================================================================================================================
Installing:
 bind-utils                         x86_64                         32:9.11.4-26.P2.el7_9.15                         updates                         262 k

Transaction Summary
==========================================================================================================================================================
Install  1 Package

Total download size: 262 k
Installed size: 584 k
Is this ok [y/d/N]: y
Downloading packages:
Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
bind-utils-9.11.4-26.P2.el7_9.15.x86_64.rpm                                                                                        | 262 kB  00:00:03
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : 32:bind-utils-9.11.4-26.P2.el7_9.15.x86_64                                                                                             1/1
  Verifying  : 32:bind-utils-9.11.4-26.P2.el7_9.15.x86_64                                                                                             1/1

Installed:
  bind-utils.x86_64 32:9.11.4-26.P2.el7_9.15

Complete!
*/
[root@mydns ~]# systemctl start named
[root@mydns ~]# systemctl enable named

--Step 6: Register domain
[root@mydns ~]#cp /etc/named.rfc1912.zones /etc/named.rfc1912.zones.bkp

[root@mydns ~]#vi /etc/named.rfc1912.zones

ZONE	"racdomain.com" IN {
		 type    master;
		 file    "racdomain.com.zone";
							 };
							 
							 
 ZONE	"120.168.192.in-addr.arpa" IN {
		 type    master;
		 file    "reverse.racdomain.com";
							 };
							 
							 
--step 7: Configure dns
							 
[root@mydns ~]# vi /etc/named.conf
/*
options{
	    listen-on port 53 {127.0.0.1; 192.168.120.100; };
		allow-query   {any; };
change : 
*/
--step 8: check for the syntax error in the above files
[root@mydns ~]# named-checkconf /etc/named.conf


--step 8 Create Database file for each zones.

[root@mydns ~]# cd /var/named/
[root@mydns named]# ll
/*
total 16
drwxrwx---. 2 named named    6 Oct 16  2023 data
drwxrwx---. 2 named named    6 Oct 16  2023 dynamic
-rw-r-----. 1 root  named 2253 Apr  5  2018 named.ca
-rw-r-----. 1 root  named  152 Dec 15  2009 named.empty
-rw-r-----. 1 root  named  152 Jun 21  2007 named.localhost
-rw-r-----. 1 root  named  168 Dec 15  2009 named.loopback
drwxrwx---. 2 named named    6 Oct 16  2023 slaves

*/
[root@mydns named]# vi racdomain.com.zone
/*
$TTL 2D
@                       				IN      SOA             mydns.racdomain.com.            root.racdomain.com. (
																												2024052100; Serial
																												3600; Refresh
																												1800; Retry
																												604800; Expire
																												86400; Minimum TTL
																														)
										
										
@                       				IN              NS      mydns.racdomain.com.
										
mydns.racdomain.com.    				IN              A       192.168.120.100
										
oracle19c1.racdomain.com.				IN 				A 		192.168.120.61
oracle19c2.racdomain.com.				IN 				A 		192.168.120.62

	
oracle19c1-priv.racdomain.com.			IN 				A 		10.0.1.61
oracle19c2-priv.racdomain.com.			IN 				A 		10.0.1.62
		
oracle19c1-vip.racdomain.com.			IN 				A 		192.168.120.63
oracle19c2-vip.racdomain.com.			IN 				A 		192.168.120.64

sanstorage.racdomain.com.				IN              A		192.168.120.60

oracle19c-scan.racdomain.com.			IN 				A 		192.168.120.65
oracle19c-scan.racdomain.com.			IN 				A 		192.168.120.66
oracle19c-scan.racdomain.com.			IN 				A 		192.168.120.67

*/

[root@mydns named]# vi reverse.racdomain.com
/*
$TTL 2D
@                       				IN      SOA             mydns.racdomain.com.            root.racdomain.com. (
																												2024052100; Serial
																												3600; Refresh
																												1800; Retry
																												604800; Expire
																												86400; Minimum TTL
																														)
										
										
@                       				IN              NS      mydns.racdomain.com.									

61.120.168.192.in-addr.arpa.  			IN 				PTR		oracle19c1.racdomain.com.    				       
62.120.168.192.in-addr.arpa.  			IN 				PTR		oracle19c2.racdomain.com.										
   				       

63.120.168.192.in-addr.arpa.  			IN 				PTR		oracle19c1-vip.racdomain.com.   				       
64.120.168.192.in-addr.arpa.  			IN 				PTR		oracle19c2-vip.racdomain.com.
			

60.120.168.192.in-addr.arpa.  			IN 				PTR		sanstorage.racdomain.com.



65.120.168.192.in-addr.arpa.  			IN 				PTR		oracle19c-scan.racdomain.com.  				       
66.120.168.192.in-addr.arpa.  			IN 				PTR		oracle19c-scan.racdomain.com.
67.120.168.192.in-addr.arpa.  			IN 				PTR		oracle19c-scan.racdomain.com.

 */                                                     

--Step 9: Start the DNS service
[root@mydns named]# systemctl restart named

[root@mydns named]# named-checkzone racdomain.com racdomain.com.zone
/*
zone racdomain.com/IN: loaded serial 2024052100
OK
*/

[root@mydns named]# named-checkzone 120.168.192.in-addr.arpa /var/named/reverse.racdomain.com
zone 120.168.192.in-addr.arpa/IN: loaded serial 2024052100
OK

[root@mydns ~]# systemctl enable named
/*
Created symlink from /etc/systemd/system/multi-user.target.wants/named.service to /usr/lib/systemd/system/named.service.
*/

--Step 10: To allow DNS requests through the firewall
[root@mydns ~]# firewall-cmd --permanent --add-service=dns
/*
success
*/

[root@mydns ~]# firewall-cmd --reload

/*
success
*/
[root@mydns ~]# firewall-cmd --list-all
/*
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens33
  sources:
  services: dhcpv6-client dns ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
*/
[root@mydns named]# firewall-cmd --permanent --add-port=53/tcp
success
[root@mydns named]# firewall-cmd --reload
success


[root@mydns ~]# cat /etc/resolv.conf
/*
# Generated by NetworkManager
search racdomain.com
nameserver 192.168.120.100

*/






