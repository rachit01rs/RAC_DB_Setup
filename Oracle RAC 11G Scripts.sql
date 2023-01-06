----------------------------------------------------------------
-------------Openfiler setup on VM Workstation---------------
----------------------------------------------------------------
--Openfiler  Configuring
[root@openfiler ~]# df -h
/*
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2             7.5G  1.4G  5.8G  20% /
tmpfs                 491M  204K  490M   1% /dev/shm
/dev/sda1             289M   23M  252M   9% /boot
*/
[root@openfiler ~]#vi /etc/hosts
/*
127.0.0.1      openfiler.mydomain openfiler localhost.localdomain localhost
# Public
192.168.87.11   RAC1.mydomain        RAC1
192.168.87.12   RAC2.mydomain        RAC2

# Private
10.0.1.11        RAC1-priv.mydomain   RAC1-priv
10.0.1.12        RAC2-priv.mydomain   RAC2-priv

# Virtual
192.168.87.13   RAC1-vip.mydomain    RAC1-vip
192.168.87.14   RAC2-vip.mydomain    RAC2-vip

# Openfiler (SAN/NAS Storage)
192.168.87.10   openfiler.mydomain   openfiler

# SCAN
192.168.87.15   RAC-scan.mydomain    RAC-scan
192.168.87.16   RAC-scan.mydomain    RAC-scan
192.168.87.17   RAC-scan.mydomain    RAC-scan
*/


[root@openfiler ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0
/*
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.87.10
NETMASK=255.255.255.0
GATEWAY=192.168.87.2
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
*/

-- Step 3 -->> On Openfiler (SAN/NAS Storage)
[root@openfiler ~]# service network restart

-- Step 4 -->> On Openfiler (SAN/NAS Storage)
-- disabling the firewall.
[root@openfiler ~]# chkconfig --list iptables
/*
iptables  0:off    1:off    2:on    3:on    4:on    5:on    6:off
*/
[root@openfiler ~]# service iptables stop
/*
iptables: Setting chains to policy ACCEPT: nat mangle filte[  OK  ]
iptables: Flushing firewall rules:                         [  OK  ]
iptables: Unloading modules:                               [  OK  ]
*/
[root@openfiler ~]# chkconfig iptables off
[root@openfiler ~]# iptables -F
[root@openfiler ~]# service iptables save
/*
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
*/
[root@openfiler ~]# /etc/init.d/iptables stop
/*
iptables: Setting chains to policy ACCEPT: filter          [  OK  ]
iptables: Flushing firewall rules:                         [  OK  ]
iptables: Unloading modules:                               [  OK  ]
*/
[root@openfiler ~]# iptables -L
/*
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
*/

[root@openfiler ~]# chkconfig --list iptables
/*
iptables   0:off    1:off    2:off    3:off    4:off    5:off    6:off
*/ 

-- Step 5 -->> On Openfiler (SAN/NAS Storage)
-- ntpd disable
[root@openfiler ~]# service ntpd stop
/*
Shutting down ntpd:                                        [FAILED]
*/

[root@openfiler ~]# service ntpd status
/*
ntpd is stopped
*/

[root@openfiler ~]# chkconfig ntpd off
[root@openfiler ~]# mv /etc/ntp.conf /etc/ntp.conf.backup
[root@openfiler ~]# rm /etc/ntp.conf
[root@openfiler ~]# rm /var/run/ntpd.pid

-- Step 6 -->> On Openfiler (SAN/NAS Storage)
[root@openfiler ~]# init 6

----------------------------------------------------------------
-------------Two Node Rac Setup on VM Workstation---------------
----------------------------------------------------------------
-- 2 Node Rac on VM -->> On both Nodes
[root@RAC1/RAC2 ~]# df -h
/*
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        50G  1.2G   46G   3% /
tmpfs           872M  211M  661M  25% /dev/shm
/dev/sda1        15G  190M   14G   2% /boot
/dev/sda5        15G   58M   14G   1% /home
/dev/sda3        50G   11G   36G  24% /opt
/dev/sda6        15G  585M   14G   5% /tmp
/dev/sda7        15G  5.3G  8.7G  38% /usr
/dev/sda8        15G  2.3G   12G  17% /var
vmhgfs-fuse     932G  564G  369G  61% /mnt/hgfs
*/
-- Step 1 -->> On both Nodes
[root@RAC1/RAC2 ~]# vi /etc/hosts
/*
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# Public
192.168.87.11   RAC1.mydomain        RAC1
192.168.87.12   RAC2.mydomain        RAC2

# Private
10.0.1.11        RAC1-priv.mydomain   RAC1-priv
10.0.1.12        RAC2-priv.mydomain   RAC2-priv

# Virtual
192.168.87.13   RAC1-vip.mydomain    RAC1-vip
192.168.87.14   RAC2-vip.mydomain    RAC2-vip

# Openfiler (SAN/NAS Storage)
192.168.87.10   openfiler.mydomain   openfiler

# SCAN
192.168.87.15   RAC-scan.mydomain    RAC-scan
192.168.87.16   RAC-scan.mydomain    RAC-scan
192.168.87.17   RAC-scan.mydomain    RAC-scan
*/

-- Step 2 -->> On both Nodes
-- Disable secure linux by editing the "/etc/selinux/config" file, making sure the SELINUX 
[root@RAC1/RAC2 ~]# vi /etc/selinux/config
/*
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
#SELINUX=enforcing
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#     targeted - Targeted processes are protected,
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
*/

-- Step 3 -->> On Nodes 1
[root@RAC1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0
/*
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.87.11
NETMASK=255.255.255.0
GATEWAY=192.168.87.2
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
*/
-- Step 4 -->> On Nodes 1
[root@RAC1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth1
/*
DEVICE=eth1
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=10.0.1.11
NETMASK=255.255.255.0
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
*/

-- Step 5 -->> On Nodes 2
[root@RAC2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0 
/*
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.87.12
NETMASK=255.255.255.0
GATEWAY=192.168.87.2
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no

*/

-- Step 6 -->> On Nodes 2
[root@RAC2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth1
/*
DEVICE=eth1
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=10.0.1.12
NETMASK=255.255.255.0
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
*/

-- Step 7 -->> On both Nodes
[root@RAC1/RAC2 ~]# service network restart

-- Step 8 -->> On both Nodes
-- disabling the firewall.
[root@RAC1/RAC2 ~]# chkconfig --list iptables
/*
iptables  0:off    1:off    2:on    3:on    4:on    5:on    6:off
*/
[root@RAC1/RAC2 ~]# service iptables stop
/*
iptables: Setting chains to policy ACCEPT: nat mangle filte[  OK  ]
iptables: Flushing firewall rules:                         [  OK  ]
iptables: Unloading modules:                               [  OK  ]
*/
[root@RAC1/RAC2 ~]# chkconfig iptables off
[root@RAC1/RAC2 ~]# iptables -F
[root@RAC1/RAC2 ~]# service iptables save
/*
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
*/
[root@RAC1/RAC2 ~]# /etc/init.d/iptables stop
/*
iptables: Setting chains to policy ACCEPT: filter          [  OK  ]
iptables: Flushing firewall rules:                         [  OK  ]
iptables: Unloading modules:                               [  OK  ]
*/
[root@RAC1/RAC2 ~]# iptables -L
/*
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
*/

[root@RAC1/RAC2 ~]# chkconfig --list iptables
/*
iptables   0:off    1:off    2:off    3:off    4:off    5:off    6:off
*/ 

-- Step 9 -->> On both Nodes
-- ntpd disable
[root@RAC1/RAC2 ~]# service ntpd stop
/*
Shutting down ntpd:                                        [FAILED]
*/

[root@RAC1/RAC2 ~]# service ntpd status
/*
ntpd is stopped
*/

[root@RAC1/RAC2 ~]# chkconfig ntpd off
[root@RAC1/RAC2 ~]# mv /etc/ntp.conf /etc/ntp.conf.backup
[root@RAC1/RAC2 ~]# rm /etc/ntp.conf
[root@RAC1/RAC2 ~]# rm /var/run/ntpd.pid

-- Step 10 -->> On both Nodes
[root@RAC1/RAC2 ~]# init 6

-- Step 11 -->> On both Nodes
-- Perform either the Automatic Setup or the Manual Setup to complete the basic prerequisites. 
-- The Additional Setup is required for all installations.
[root@RAC1/RAC2 ~]# cd /media/OL6.4\ x86_64\ Disc\ 1\ 20130225/Server/Packages/
[root@RAC1/RAC2 Packages]# yum install oracle-rdbms-server-11gR2-preinstall
[root@RAC1/RAC2 Packages]# yum update

-- Step 12 -->> On both Nodes
-- Manual tup the relevant RPMS
/*
[root@RAC1/RAC2 Packages]# rpm -iUvh binutils-2*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh glibc-2*x86_64* nss-softokn-freebl-3*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh glibc-2*i686* nss-softokn-freebl-3*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh compat-libstdc++-33*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh glibc-common-2*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh glibc-devel-2*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh glibc-devel-2*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh glibc-headers-2*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh elfutils-libelf-0*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh elfutils-libelf-devel-0*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh gcc-4*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh gcc-c++-4*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh ksh-*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh libaio-0*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh libaio-devel-0*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh libaio-0*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh libaio-devel-0*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh libgcc-4*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh libgcc-4*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh libstdc++-4*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh libstdc++-4*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh libstdc++-devel-4*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh make-3.81*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh numactl-devel-2*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh sysstat-9*x86_64*
[root@RAC1/RAC2 Packages]# rpm -iUvh compat-libstdc++-33*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh compat-libcap*
[root@RAC1/RAC2 Packages]# rpm -iUvh libaio-devel-0.*
[root@RAC1/RAC2 Packages]# rpm -iUvh ksh-2*
[root@RAC1/RAC2 Packages]# rpm -iUvh libstdc++-4.*.i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh elfutils-libelf-0*i686* elfutils-libelf-devel-0*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh libtool-ltdl*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh ncurses*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh readline*i686*
[root@RAC1/RAC2 Packages]# rpm -iUvh unixODBC*
[root@RAC1/RAC2 Packages]# rpm -Uvh oracleasm*.rpm
[root@RAC1/RAC2 Packages]# rpm -q binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static \
[root@RAC1/RAC2 Packages]# rpm -q gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers kernel-headers ksh libaio libaio-devel \
[root@RAC1/RAC2 Packages]# rpm -q libgcc libgomp libstdc++ libstdc++-devel make numactl-devel sysstat unixODBC unixODBC-devel
[root@RAC1/RAC2 Packages]#  yum install iscsi 

*/

-- Step 13 -->> On both Nodes
-- Pre-Installation Steps for ASM
[root@RAC1/RAC2 ~ ]# cd /etc/yum.repos.d
[root@RAC1/RAC2 yum.repos.d]# uname -a
/*
Linux RAC1.mydomain 4.1.12-124.48.6.el6uek.x86_64 #2 SMP Tue Mar 16 15:39:03 PDT 2021 x86_64 x86_64 x86_64 GNU/Linux
Linux RAC2.mydomain 4.1.12-124.48.6.el6uek.x86_64 #2 SMP Tue Mar 16 15:39:03 PDT 2021 x86_64 x86_64 x86_64 GNU/Linux
*/
[root@RAC1/RAC2 yum.repos.d]# cat /etc/os-release 
/*
NAME="Oracle Linux Server"
VERSION="6.10"
ID="ol"
VERSION_ID="6.10"
PRETTY_NAME="Oracle Linux Server 6.10"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:oracle:linux:6:10:server"
HOME_URL="https://linux.oracle.com/"
BUG_REPORT_URL="https://bugzilla.oracle.com/"

ORACLE_BUGZILLA_PRODUCT="Oracle Linux 6"
ORACLE_BUGZILLA_PRODUCT_VERSION=6.10
ORACLE_SUPPORT_PRODUCT="Oracle Linux"
ORACLE_SUPPORT_PRODUCT_VERSION=6.10
*/

[root@RAC1/RAC2 yum.repos.d]# wget https://public-yum.oracle.com/public-yum-ol6.repo
/*
--2023-01-06 11:27:34--  https://public-yum.oracle.com/public-yum-ol6.repo
Resolving public-yum.oracle.com... 184.31.210.77, 2600:140f:b:1a0::2a7d, 2600:140f:b:1a5::2a7d
Connecting to public-yum.oracle.com|184.31.210.77|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 12045 (12K) [text/plain]
Saving to: “public-yum-ol6.repo.2”

100%[==============================================================>] 12,045      --.-K/s   in 0s

2023-01-04 11:27:35 (810 MB/s) - “public-yum-ol6.repo.2” saved [12045/12045]
*/

[root@RAC1/RAC2 yum.repos.d]# yum install kmod-oracleasm
[root@RAC1/RAC2 yum.repos.d]# yum install oracleasm-support
/*
Loaded plugins: aliases, changelog, kabi, presto, refresh-packagekit, security,
              : tmprepo, ulninfo, verify, versionlock
Loading support for kernel ABI
Setting up Install Process
Package oracleasm-support-2.1.11-2.el6.x86_64 already installed and latest version
Nothing to do
*/

-- Step 14 -->> On both Nodes
-- Need to dounload (oracleasmlib-2.0.4-1.el5.i386.rpm : https://oracle-base.com/articles/11g/oracle-db-11gr2-rac-installation-on-oel5-using-virtualbox | http://www.hblsoft.org/hwl/1326.html)
[root@RAC1/RAC2 yum.repos.d]#cd /mnt/hgfs/Oracle Linux/Oracle_Linux_6_Rpm/
[root@RAC1/RAC2 Oracle_Linux_6_Rpm]# ls
/*
dtrace-utils-1.0.0-8.el6.x86_64.rpm
dtrace-utils-devel-1.0.0-8.el6.x86_64.rpm
dtrace-utils-testsuite-1.0.0-8.el6.x86_64.rpm
elfutils-libelf-devel-static-0.164-2.el6.x86_64.rpm
libdtrace-ctf-0.8.0-1.el6.x86_64.rpm
libdtrace-ctf-devel-0.8.0-1.el6.x86_64.rpm
numactl-2.0.9-2.el6.i686.rpm
numactl-devel-2.0.9-2.el6.i686.rpm
oracleasmlib-2.0.4-1.el6.x86_64.rpm
unixODBC-devel-2.2.14-12.el6_3.x86_64.rpm
*/
[root@RAC1/RAC2 Oracle_Linux_6_Rpm]# rpm -iUvh oracleasmlib-2.0.4-1.el6.x86_64.rpm
/*
Preparing...                ########################################### [100%]
    package oracleasmlib-2.0.4-1.el6.x86_64 is already installed
*/
[root@RAC1/RAC2 Oracle_Linux_6_Rpm]# rpm -iUvh elfutils-libelf-devel-static-0.164-2.el6.x86_64.rpm
/*
Preparing...                ########################################### [100%]
   1:elfutils-libelf-devel-s########################################### [100%]
*/
-- Step 15 -->> On both Nodes
-- Orcle ASM Configuration
[root@RAC1/RAC2 ~]# rpm -qa | grep -i oracleasm
/*
kmod-oracleasm-2.0.8-16.1.el6_10.x86_64
oracleasmlib-2.0.4-1.el6.x86_64
oracleasm-support-2.1.11-2.el6.x86_64
*/
[root@RAC1/RAC2 ~]# cd /media/OL6.4\ x86_64\ Disc\ 1\ 20130225/Server/Packages/
[root@RAC1/RAC2 Packages]# yum update

-- Step 16 -->> On both Nodes
-- Add the kernel parameters file "/etc/sysctl.conf" and add oracle recommended kernel parameters
[root@RAC1/RAC2 ~]# vi /etc/sysctl.conf
/*
net.ipv4.ip_forward = 0
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
kernel.msgmnb = 65536
kernel.msgmax = 65536
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 65536
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
*/

-- Run the following command to change the current kernel parameters.
[root@RAC1/RAC2 ~]# /sbin/sysctl -p

-- Step 17 -->> On both Nodes
-- Edit “/etc/security/limits.conf” file to limit user processes
[root@RAC1/RAC2 ~]# vim /etc/security/limits.conf
/*
oracle   soft   nofile  65536
oracle   hard   nofile  65536
oracle   soft   nproc   16384
oracle   hard   nproc   16384
oracle   soft   stack   10240
oracle   hard   stack   32768
oracle   hard   memlock 134217728
oracle   soft   memlock 134217728

grid    soft    nproc    16384
grid    hard    nproc    16384
grid    soft    nofile   65536
grid    hard    nofile   65536
grid    soft    stack    10240
grid    soft    memlock  134217728
grid    hard    memlock  134217728
*/


-- Step 18 -->> On both Nodes
-- Add the following line to the "/etc/pam.d/login" file, if it does not already exist.
[root@RAC1/RAC2 ~]# vi /etc/pam.d/login
/*
#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       include      system-auth
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      system-auth
-session    optional    pam_ck_connector.so
session    required     pam_limits.so
*/


-- Step 19 -->> On both Nodes
-- Create the new groups and users.
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i oinstall
/*
oinstall:x:54321:
*/
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i dba
/*
dba:x:54322:oracle
*/
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i asm

-- 1.Create OS groups using the command below. Enter these commands as the 'root' user:
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 503 oper
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 504 asmadmin
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 506 asmdba
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 507 asmoper
/*
[root@RAC1/RAC2 ~]# /usr/sbin/useradd -g oinstall -G oinstall,dba,asmadmin,asmdba,asmoper,beoper grid
[root@RAC1/RAC2 ~]# /usr/sbin/usermod -g oinstall -G oinstall,dba,asmadmin,asmdba,asmoper,beoper grid
[root@RAC1/RAC2 ~]# /usr/sbin/useradd -g oinstall -G oinstall,dba,oper,asmdba,asmadmin oracle
[root@RAC1/RAC2 ~]# /usr/sbin/usermod -g oinstall -G oinstall,dba,oper,asmdba,asmadmin oracle
*/

[root@RAC1/RAC2 ~]# /usr/sbin/useradd  -g oinstall -G asmadmin,asmdba,asmoper grid
[root@RAC1/RAC2 ~]# /usr/sbin/usermod -g oinstall -G dba,oper,asmdba oracle

[root@RAC1/RAC2 ~]# cat /etc/group | grep -i asm
/*
asmadmin:x:504:grid
asmdba:x:506:grid,oracle
asmoper:x:507:grid
*/
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i oracle
/*
dba:x:54322:oracle
oper:x:503:oracle
asmdba:x:506:grid,oracle
*/
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i grid
/*
asmadmin:x:504:grid
asmdba:x:506:grid,oracle
asmoper:x:507:grid
*/

[root@RAC1/RAC2 ~]# passwd oracle
/*
Changing password for user oracle.
New password: 
BAD PASSWORD: it is based on a dictionary word
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
*/
[root@RAC1/RAC2 ~]# passwd grid
/*
Changing password for user grid.
New password: 
BAD PASSWORD: it is too short
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
*/
[root@RAC1/RAC2 ~]# su - oracle
[oracle@RAC1/RAC2 ~]$ su - grid
/*
Password: 
*/
[grid@RAC1/RAC2 ~]$ su - root
/*
Password: 
*/
-- Step 20 -->> On both Node
--1.Create the Oracle Inventory Director:
[root@RAC1/RAC2 ~]# mkdir -p /opt/app/oraInventory
[root@RAC1/RAC2 ~]# chown -R grid:oinstall /opt/app/oraInventory
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/oraInventory

--2.Creating the Oracle Grid Infrastructure Home Directory:
[root@RAC1/RAC2 ~]# mkdir -p /opt/app/11.2.0.3.0/grid
[root@RAC1/RAC2 ~]# chown -R grid:oinstall /opt/app/11.2.0.3.0/grid
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/11.2.0.3.0/grid

--3.Creating the Oracle Base Directory
[root@RAC1/RAC2 ~]# mkdir -p /opt/app/oracle
[root@RAC1/RAC2 ~]# mkdir -p /opt/app/oracle/cfgtoollogs
[root@RAC1/RAC2 ~]# chown -R oracle:oinstall /opt/app/oracle
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/oracle
[root@RAC1/RAC2 ~]# chown -R grid:oinstall /opt/app/oracle/cfgtoollogs
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/oracle/cfgtoollogs

--4.Creating the Oracle RDBMS Home Directory
[root@RAC1/RAC2 ~]# mkdir -p /opt/app/oracle/product/11.2.0.3.0/db_1
[root@RAC1/RAC2 ~]# chown -R oracle:oinstall /opt/app/oracle/product/11.2.0.3.0/db_1
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/oracle/product/11.2.0.3.0/db_1
[root@RAC1/RAC2 ~]# cd /opt/app/oracle
[root@RAC1/RAC2 ~]# chown -R oracle:oinstall product
[root@RAC1/RAC2 ~]# chmod -R 775 product

-- Step 21 -->> On first node 1
-- Unzip the files and Copy the ASM rpm to another Nodes.
[root@RAC1/RAC2 ~]# cd /root/11.2.0.3.0/
[root@RAC1 11.2.0.3.0]# unzip p10404530_112030_Linux-x86-64_1of7.zip -d /opt/app/oracle/product/11.2.0.3.0/db_1/
[root@RAC1 11.2.0.3.0]# unzip p10404530_112030_Linux-x86-64_2of7.zip -d /opt/app/oracle/product/11.2.0.3.0/db_1/
[root@RAC1 11.2.0.3.0]# unzip p10404530_112030_Linux-x86-64_3of7-Clusterware.zip -d /opt/app/11.2.0.3.0/
[root@RAC2 ~]# mkdir -p /opt/app/11.2.0.3.0/grid/rpm/
[root@RAC1 ~]# cd /opt/app/11.2.0.3.0/grid/rpm/
[root@RAC1 rpm]# scp -r cvuqdisk-1.0.9-1.rpm root@RAC2:/opt/app/11.2.0.3.0/grid/rpm/
/*
The authenticity of host 'RAC2 (172.16.1.76)' can't be established.
RSA key fingerprint is 41:08:36:19:bd:fa:4f:7f:e8:ff:cf:27:e3:8d:61:e5.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'RAC2,172.16.1.76' (RSA) to the list of known hosts.
root@RAC2's password: 
cvuqdisk-1.0.9-1.rpm                                                     100% 8551     8.4KB/s   00:00    
*/

-- Step 22 -->> On both Nodes
[root@RAC1/RAC2 ~]# chown -R grid:oinstall /opt/app/11.2.0.3.0/grid
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/11.2.0.3.0/grid
[root@RAC1/RAC2 ~]# chown -R oracle:oinstall /opt/app/oracle/product/11.2.0.3.0/db_1
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/oracle/product/11.2.0.3.0/db_1

-- Step 23 -->> On both Nodes
[root@RAC1/RAC2 ~]# cd /opt/app/11.2.0.3.0/grid/rpm/
[root@RAC1/RAC2 rpm]# ls -ltr
/*
-rwxrwxr-x 1 grid oinstall 8551 Sep 22  2011 cvuqdisk-1.0.9-1.rpm
*/

[root@RAC1/RAC2 rpm]# CVUQDISK_GRP=oinstall; export CVUQDISK_GRP
[root@RAC1/RAC2 rpm]# rpm -iUvh cvuqdisk-1.0.9-1.rpm 
/*
Preparing...                          ################################# [100%]
   1:cvuqdisk-1.0.9-1                 ################################# [100%]
*/

-- Step 24 -->> On both Nodes
-- To Disable the virbr0/lxcbr0 Linux services 
[root@RAC1/RAC2 ~]# cd /etc/sysconfig/
[root@RAC1/RAC2 sysconfig]# brctl show
/*
bridge name    bridge id        STP enabled    interfaces
virbr0        8000.525400467a72    yes        virbr0-nic
*/
[root@RAC1/RAC2 sysconfig]# virsh net-list
/*
Name                 State      Autostart     Persistent
--------------------------------------------------
default              active     yes           yes
*/

[root@RAC1/RAC2 sysconfig]# service libvirtd stop
/*
Stopping libvirtd daemon:                                  [  OK  ]
*/
[root@RAC1/RAC2 sysconfig]# chkconfig --list | grep libvirtd
/*
libvirtd           0:off    1:off    2:off    3:on    4:on    5:on    6:off
*/

[root@RAC1/RAC2 sysconfig]# chkconfig libvirtd off
[root@RAC1/RAC2 sysconfig]# ip link set lxcbr0 down
[root@RAC1/RAC2 sysconfig]# brctl delbr lxcbr0
[root@RAC1/RAC2 sysconfig]# brctl show
[root@RAC1/RAC2 sysconfig]# init 6

-- Step 25 -->> On both Nodes
[root@RAC1/RAC2 ~]# brctl show
/*
bridge name    bridge id        STP enabled    interfaces
*/
[root@RAC1/RAC2 ~]# chkconfig --list | grep libvirtd
/*
libvirtd           0:off    1:off    2:off    3:off    4:off    5:off    6:off
*/

-- Step 26 -->> On Node 1
-- Login as the oracle user and add the following lines at the end of the ".bash_profile" file.
[root@RAC1 ~]# su - oracle
[oracle@RAC1 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Oracle Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_HOSTNAME=RAC1.mydomain; export ORACLE_HOSTNAME
ORACLE_UNQNAME=racdb; export ORACLE_UNQNAME
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.3.0/db_1; export ORACLE_HOME
ORACLE_SID=racdb1; export ORACLE_SID

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 37 -->> On Node 1
[oracle@RAC1 ~]$ . .bash_profile

-- Step 27 -->> On Node 1
-- Login as the grid user and add the following lines at the end of the ".bash_profile" file.
[root@RAC1 ~]# su - grid
[grid@RAC1 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Grid Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_SID=+ASM1; export ORACLE_SID
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
GRID_HOME=/opt/app/11.2.0.3.0/grid; export GRID_HOME
ORACLE_HOME=$GRID_HOME; export ORACLE_HOME

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 28 -->> On Node 1
[grid@RAC1 ~]$ . .bash_profile

-- Step 29 -->> On Node 2
-- Login as the oracle user and add the following lines at the end of the ".bash_profile" file.
[root@RAC2 ~]# su - oracle
[oracle@RAC2 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Oracle Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_HOSTNAME=RAC2.mydomain; export ORACLE_HOSTNAME
ORACLE_UNQNAME=racdb; export ORACLE_UNQNAME
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.3.0/db_1; export ORACLE_HOME
ORACLE_SID=racdb2; export ORACLE_SID

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 30 -->> On Node 2
[oracle@RAC2 ~]$ . .bash_profile

-- Step 31 -->> On Node 2
-- Login as the grid user and add the following lines at the end of the ".bash_profile" file.
[root@RAC2 iscsi]# su - grid
[grid@RAC2 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Grid Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_SID=+ASM2; export ORACLE_SID
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
GRID_HOME=/opt/app/11.2.0.3.0/grid; export GRID_HOME
ORACLE_HOME=$GRID_HOME; export ORACLE_HOME

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Steps 32 -->> On Node 2
[grid@RAC2 ~]$ . .bash_profile
-- Step 33 -->> On Node 2
-- Login as the grid user and add the following lines at the end of the ".bash_profile" file.
[root@RAC2 iscsi]# su - grid
[grid@RAC2 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Grid Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_SID=+ASM2; export ORACLE_SID
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
GRID_HOME=/opt/app/11.2.0.3.0/grid; export GRID_HOME
ORACLE_HOME=$GRID_HOME; export ORACLE_HOME

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

--Step 34 -->> On Node 2
[grid@RAC2 ~]$ . .bash_profile

--Step 35 -->> On Node 1
--SSH user Equivalency configuration (grid and oracle):
[root@RAC1 ~]# su - oracle
[oracle@RAC1 ~]$ cd /opt/app/oracle/product/11.2.0.3.0/db_1/database/sshsetup/
[oracle@RAC1 sshsetup]$ ./sshUserSetup.sh -user oracle -hosts "RAC1.mydomain RAC2.mydomain" -noPromptPassphrase -confirm -advanced

[oracle@RAC1/RAC2 ~]$ ssh oracle@RAC1 date
[oracle@RAC1/RAC2 ~]$ ssh oracle@RAC2 date
[oracle@RAC1/RAC2 ~]$ ssh oracle@RAC1 date && ssh oracle@RAC2 date
[oracle@RAC1/RAC2 ~]$ ssh oracle@RAC1.mydomain date
[oracle@RAC1/RAC2 ~]$ ssh oracle@RAC2.mydomain date
[oracle@RAC1/RAC2 ~]$ ssh oracle@RAC1.mydomain date && ssh oracle@RAC2.mydomain date

[root@RAC1 ~]# su - grid
[grid@RAC1 ~]$ cd /opt/app/11.2.0.3.0/grid/sshsetup
[grid@RAC1 deinstall]$ ./sshUserSetup.sh -user grid -hosts "RAC1.mydomain RAC2.mydomain" -noPromptPassphrase -confirm -advanced

[grid@RAC1/RAC2 ~]$ ssh grid@RAC1 date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC2 date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC1 date && ssh grid@RAC2 date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC1.mydomain date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC2.mydomain date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC1.mydomain date && ssh grid@RAC2.mydomain date


-->> On openfiler (SAN/NAS Storage)
[oracle@openfiler ~]#service iscsi-target restart

-- Step 36 -->> On all Node
[root@RAC1/RAC2 ~]# which oracleasm
/*
/usr/sbin/oracleasm
*/
-- Step 37 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm configure
/*
ORACLEASM_ENABLED=false
ORACLEASM_UID=
ORACLEASM_GID=
ORACLEASM_SCANBOOT=true
ORACLEASM_SCANORDER=""
ORACLEASM_SCANEXCLUDE=""
ORACLEASM_SCAN_DIRECTORIES=""
ORACLEASM_USE_LOGICAL_BLOCK_SIZE="false"
*/

-- Step 38 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm status
/*
Checking if ASM is loaded: no
Checking if /dev/oracleasm is mounted: no
*/

-- Step39 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm configure -i
/*
Configuring the Oracle ASM library driver.

This will configure the on-boot properties of the Oracle ASM library
driver.  The following questions will determine whether the driver is
loaded on boot and what permissions it will have.  The current values
will be shown in brackets ('[]').  Hitting <ENTER> without typing an
answer will keep that current value.  Ctrl-C will abort.

Default user to own the driver interface []: grid
Default group to own the driver interface []: asmadmin
Start Oracle ASM library driver on boot (y/n) [n]: y
Scan for Oracle ASM disks on boot (y/n) [y]: y
Writing Oracle ASM library driver configuration: done
*/

-- Step 40 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm configure
/*
ORACLEASM_ENABLED=true
ORACLEASM_UID=grid
ORACLEASM_GID=asmadmin
ORACLEASM_SCANBOOT=true
ORACLEASM_SCANORDER=""
ORACLEASM_SCANEXCLUDE=""
ORACLEASM_SCAN_DIRECTORIES=""
ORACLEASM_USE_LOGICAL_BLOCK_SIZE="false"
*/

-- Step 41 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm init
/*
Creating /dev/oracleasm mount point: /dev/oracleasm
Loading module "oracleasm": oracleasm
Configuring "oracleasm" to use device physical block size
Mounting ASMlib driver filesystem: /dev/oracleasm
*/

-- Step 42 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm status
/*
Checking if ASM is loaded: yes
Checking if /dev/oracleasm is mounted: yes
*/

-- Step 43 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
*/

-- Step 44 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm listdisks

-- Step 45 -->> On Node 1
[root@RAC1 ~]# ls -ltr /dev/sd*
/*
brw-rw---- 1 root disk 8,  0 Jan  6 10:15 /dev/sda
brw-rw---- 1 root disk 8,  4 Jan  6 10:15 /dev/sda4
brw-rw---- 1 root disk 8,  9 Jan  6 10:15 /dev/sda9
brw-rw---- 1 root disk 8,  2 Jan  6 10:15 /dev/sda2
brw-rw---- 1 root disk 8,  1 Jan  6 10:15 /dev/sda1
brw-rw---- 1 root disk 8,  5 Jan  6 10:15 /dev/sda5
brw-rw---- 1 root disk 8,  3 Jan  6 10:15 /dev/sda3
brw-rw---- 1 root disk 8,  6 Jan  6 10:15 /dev/sda6
brw-rw---- 1 root disk 8,  7 Jan  6 10:15 /dev/sda7
brw-rw---- 1 root disk 8,  8 Jan  6 10:15 /dev/sda8
brw-rw---- 1 root disk 8, 16 Jan  6 10:16 /dev/sdb
brw-rw---- 1 root disk 8, 32 Jan  6 10:16 /dev/sdc
brw-rw---- 1 root disk 8, 17 Jan  6 10:16 /dev/sdb1
brw-rw---- 1 root disk 8, 48 Jan  6 10:16 /dev/sdd
brw-rw---- 1 root disk 8, 33 Jan  6 10:16 /dev/sdc1
brw-rw---- 1 root disk 8, 49 Jan  6 10:16 /dev/sdd1
*/

-- Step 46 -->> On Node 1
[root@RAC1 ~]# fdisk -ll
/*
  
  Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1        1959    15728640   83  Linux
/dev/sda2            1959        8486    52428800   83  Linux
/dev/sda3            8486       15013    52428800   83  Linux
/dev/sda4           15013       24803    78642176    5  Extended
/dev/sda5           15013       16971    15728640   83  Linux
/dev/sda6           16971       18930    15728640   83  Linux
/dev/sda7           18930       20888    15728640   83  Linux
/dev/sda8           20888       22846    15728640   83  Linux
/dev/sda9           22846       24803    15721472   82  Linux swap / Solaris

 Device Boot      Start         End      Blocks   Id  System
/dev/sr0p1   *           1        3884    15908864   17  Hidden HPFS/NTFS
Partition 1 has different physical/logical endings:
     phys=(1023, 63, 32) logical=(3883, 63, 32)

Disk /dev/sdb: 42.9 GB, 42949672960 bytes
64 heads, 32 sectors/track, 40960 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xcb632456

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1       40960    41943024   83  Linux

Disk /dev/sdd: 26.2 GB, 26239565824 bytes
64 heads, 32 sectors/track, 25024 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x68bf25f2

   Device Boot      Start         End      Blocks   Id  System
/dev/sdd1               1       25024    25624560   83  Linux

Disk /dev/sdc: 21.5 GB, 21474836480 bytes
64 heads, 32 sectors/track, 20480 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x5eef3092

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1               1       20480    20971504   83  Linux
*/

-- Step 47 -->> On Node 1
[root@RAC1 ~]# fdisk /dev/sdb
/*
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x29112920.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): p

Disk /dev/sdb: 10.7 GB, 10737418240 bytes
64 heads, 32 sectors/track, 10240 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x29112920

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-10240, default 1): 
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-10240, default 10240): 
Using default value 10240

Command (m for help): p

Disk /dev/sdb: 10.7 GB, 10737418240 bytes
64 heads, 32 sectors/track, 10240 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x29112920

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1       10240    10485744   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
*/

-- Step 48 -->> On Node 1
[root@RAC1 ~]# fdisk /dev/sdc
/*
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0xbff51c9c.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): p

Disk /dev/sdc: 53.7 GB, 53687091200 bytes
64 heads, 32 sectors/track, 51200 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xbff51c9c

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-51200, default 1): 
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-51200, default 51200): 
Using default value 51200

Command (m for help): p

Disk /dev/sdc: 53.7 GB, 53687091200 bytes
64 heads, 32 sectors/track, 51200 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xbff51c9c

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1               1       51200    52428784   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

*/

-- Step 49 -->> On Node 1
[root@RAC1 ~]# fdisk /dev/sdd
/*
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0xebb9bef6.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): p

Disk /dev/sdd: 53.7 GB, 53687091200 bytes
64 heads, 32 sectors/track, 51200 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xebb9bef6

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-51200, default 1): 
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-51200, default 51200): 
Using default value 51200

Command (m for help): p

Disk /dev/sdd: 53.7 GB, 53687091200 bytes
64 heads, 32 sectors/track, 51200 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xebb9bef6

   Device Boot      Start         End      Blocks   Id  System
/dev/sdd1               1       51200    52428784   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
*/
-- Step 50 -->> On Node 1
[root@RAC1 ~]# ls -ltr /dev/sd*
/*
brw-rw---- 1 root disk 8,  0 Jan  6 10:15 /dev/sda
brw-rw---- 1 root disk 8,  4 Jan  6 10:15 /dev/sda4
brw-rw---- 1 root disk 8,  9 Jan  6 10:15 /dev/sda9
brw-rw---- 1 root disk 8,  2 Jan  6 10:15 /dev/sda2
brw-rw---- 1 root disk 8,  1 Jan  6 10:15 /dev/sda1
brw-rw---- 1 root disk 8,  5 Jan  6 10:15 /dev/sda5
brw-rw---- 1 root disk 8,  3 Jan  6 10:15 /dev/sda3
brw-rw---- 1 root disk 8,  6 Jan  6 10:15 /dev/sda6
brw-rw---- 1 root disk 8,  7 Jan  6 10:15 /dev/sda7
brw-rw---- 1 root disk 8,  8 Jan  6 10:15 /dev/sda8
brw-rw---- 1 root disk 8, 16 Jan  6 10:16 /dev/sdb
brw-rw---- 1 root disk 8, 32 Jan  6 10:16 /dev/sdc
brw-rw---- 1 root disk 8, 17 Jan  6 10:16 /dev/sdb1
brw-rw---- 1 root disk 8, 48 Jan  6 10:16 /dev/sdd
brw-rw---- 1 root disk 8, 33 Jan  6 10:16 /dev/sdc1
brw-rw---- 1 root disk 8, 49 Jan  6 10:16 /dev/sdd1
*/
-- Step 51 -->> On Both Nodes
[root@RAC1/RAC2 ~]# fdisk -ll
/*
Disk /dev/sda: 204.0 GB, 204010946560 bytes
255 heads, 63 sectors/track, 24802 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000f249b

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1        1959    15728640   83  Linux
/dev/sda2            1959        8486    52428800   83  Linux
/dev/sda3            8486       15013    52428800   83  Linux
/dev/sda4           15013       24803    78642176    5  Extended
/dev/sda5           15013       16971    15728640   83  Linux
/dev/sda6           16971       18930    15728640   83  Linux
/dev/sda7           18930       20888    15728640   83  Linux
/dev/sda8           20888       22846    15728640   83  Linux
/dev/sda9           22846       24803    15721472   82  Linux swap / Solaris
Note: sector size is 2048 (not 512)

Disk /dev/sr0: 4072 MB, 4072669184 bytes
64 heads, 32 sectors/track, 971 cylinders
Units = cylinders of 2048 * 2048 = 4194304 bytes
Sector size (logical/physical): 2048 bytes / 2048 bytes
I/O size (minimum/optimal): 2048 bytes / 2048 bytes
Disk identifier: 0x2abfe5f5

    Device Boot      Start         End      Blocks   Id  System
/dev/sr0p1   *           1        3884    15908864   17  Hidden HPFS/NTFS
Partition 1 has different physical/logical endings:
     phys=(1023, 63, 32) logical=(3883, 63, 32)

Disk /dev/sdb: 42.9 GB, 42949672960 bytes
64 heads, 32 sectors/track, 40960 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xcb632456

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1       40960    41943024   83  Linux

Disk /dev/sdd: 26.2 GB, 26239565824 bytes
64 heads, 32 sectors/track, 25024 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x68bf25f2

   Device Boot      Start         End      Blocks   Id  System
/dev/sdd1               1       25024    25624560   83  Linux

Disk /dev/sdc: 21.5 GB, 21474836480 bytes
64 heads, 32 sectors/track, 20480 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x5eef3092

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1               1       20480    20971504   83  Linux
*/

-- Step 52 -->> On Node 1
[root@RAC1 ~]# /etc/init.d/oracleasm createdisk OCR /dev/sdb1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 53 -->> On Node 1
[root@RAC1 ~]# /etc/init.d/oracleasm createdisk DATA /dev/sdc1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 54 -->> On Node 1
[root@RAC1 ~]# /etc/init.d/oracleasm createdisk ARC /dev/sdd1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 55 -->> On Node 1
[root@RAC1 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
*/

-- Step 56 -->> On Node 1
[root@RAC1 ~]# oracleasm listdisks
/*
ARC
DATA
OCR
*/

-- Step 57 -->> On Node 2
[root@RAC2 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
Instantiating disk "OCR"
Instantiating disk "ARC"
Instantiating disk "DATA"
*/

-- Step 58 -->> On Node 2
[root@RAC2 ~]# oracleasm listdisks
/*
ARC
DATA
OCR
*/

-- Step 59 -->> On Node 1
-- Pre-check for RAC Setup
[grid@RAC1 ~]$ cd /opt/app/11.2.0.3.0/grid
[grid@RAC1 grid]$ ./runcluvfy.sh stage -pre crsinst -n RAC1,RAC2 -verbose
-- OR --
[grid@RAC1 grid]$ ./runcluvfy.sh stage -pre crsinst -n RAC1.mydomain,RAC2.mydomain -verbose
[grid@rac1 grid]$ ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -method root
--[grid@rac1 grid]$ ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -fixup -verbose (If Required)

-- Step 60 -->> On Node 1
-- Login as grid user and issu the following command at RAC1

[grid@RAC1 Desktop]$ cd 
[grid@RAC1/RAC2 ~]$ hostname
/*
RAC1.mydomain
*/
[grid@RAC1 ~]$ xhost + RAC1.mydomain
/*
RAC1.mydomain being added to access control list
*/

-- Step 61 -->> On Both Nodes
-- Login as grid user and issue the following command at RAC1 
-- Make sure choose proper groups while installing grid
-- OSDBA  Group => asmdba
-- OSOPER Group => asmoper
-- OSASM  Group => asmadmin
-- oraInventory Group Name => oinstall
[grid@RAC1 ~]$ cd /opt/app/11.2.0.3.0/grid
[grid@RAC1 grid]$  ./runInstaller.sh

-- Step 62 -->> On Both Nodes
-- Run from root user to finalized the setup for both racs
[root@RAC1/RAC2 ~]# /opt/app/oraInventory/orainstRoot.sh
[root@RAC1/RAC2 ~]# /opt/app/11.2.0.3.0/grid/root.sh

-- Step 63 -->> On Both Nodes
[root@RAC1/RAC2 ~]# cd /opt/app/11.2.0.3.0/grid/bin/
[root@RAC1/RAC2 bin]# ./crsctl check cluster
/*
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
*/

-- Step 64 -->> On Both Nodes
[root@RAC1/RAC2 bin]# ./crsctl check cluster -all
/*
**************************************************************
rac1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
rac2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
*/

-- Step 65 -->> On Node 1
[root@RAC1 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       rac1                     Started
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       rac1
ora.crf
      1        ONLINE  ONLINE       rac1
ora.crsd
      1        ONLINE  ONLINE       rac1
ora.cssd
      1        ONLINE  ONLINE       rac1
ora.cssdmonitor
      1        ONLINE  ONLINE       rac1
ora.ctssd
      1        ONLINE  ONLINE       rac1                     ACTIVE:0
ora.diskmon
      1        OFFLINE OFFLINE
ora.evmd
      1        ONLINE  ONLINE       rac1
ora.gipcd
      1        ONLINE  ONLINE       rac1
ora.gpnpd
      1        ONLINE  ONLINE       rac1
ora.mdnsd
      1        ONLINE  ONLINE       rac1
*/

-- Step 66 -->> On Node 2
[root@RAC2 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       rac2                     Started
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       rac2
ora.crf
      1        ONLINE  ONLINE       rac2
ora.crsd
      1        ONLINE  ONLINE       rac2
ora.cssd
      1        ONLINE  ONLINE       rac2
ora.cssdmonitor
      1        ONLINE  ONLINE       rac2
ora.ctssd
      1        ONLINE  ONLINE       rac2                     ACTIVE:0
ora.diskmon
      1        OFFLINE OFFLINE
ora.evmd
      1        ONLINE  ONLINE       rac2
ora.gipcd
      1        ONLINE  ONLINE       rac2
ora.gpnpd
      1        ONLINE  ONLINE       rac2
ora.mdnsd
      1        ONLINE  ONLINE       rac2

*/

-- Step 67 -->> On Both Nodes
[root@RAC1/RAC2 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.DATA.dg
               ONLINE  ONLINE       rac1
               ONLINE  ONLINE       rac2
ora.FRA.dg
               ONLINE  ONLINE       rac1
               ONLINE  ONLINE       rac2
ora.LISTENER.lsnr
               ONLINE  ONLINE       rac1
               ONLINE  ONLINE       rac2
ora.OCR.dg
               ONLINE  ONLINE       rac1
               ONLINE  ONLINE       rac2
ora.asm
               ONLINE  ONLINE       rac1                     Started
               ONLINE  ONLINE       rac2                     Started
ora.gsd
               OFFLINE OFFLINE      rac1
               OFFLINE OFFLINE      rac2
ora.net1.network
               ONLINE  ONLINE       rac1
               ONLINE  ONLINE       rac2
ora.ons
               ONLINE  ONLINE       rac1
               ONLINE  ONLINE       rac2
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       rac2
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       rac1
ora.LISTENER_SCAN3.lsnr
      1        ONLINE  ONLINE       rac1
ora.cvu
      1        ONLINE  ONLINE       rac1
ora.oc4j
      1        ONLINE  ONLINE       rac1
ora.rac1.vip
      1        ONLINE  ONLINE       rac1
ora.rac2.vip
      1        ONLINE  ONLINE       rac2
ora.racdb.db
      1        ONLINE  ONLINE       rac1                     Open
      2        ONLINE  ONLINE       rac2                     Open
ora.scan1.vip
      1        ONLINE  ONLINE       rac2
ora.scan2.vip
      1        ONLINE  ONLINE       rac1
ora.scan3.vip
      1        ONLINE  ONLINE       rac1
*/

-- Step 68 -->> On Node 1
/*
Click on OK to complete the installations
*/

-- Step 69 -->> On Node 1
[grid@RAC1 ~]$ asmcmd
ASMCMD> lsdg
/*
State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  1048576     30719    30323                0           30323              0             Y  OCR/
*/
ASMCMD> exit

-- Step 70 -->> On Node 2
[grid@RAC2 ~]$ asmcmd
ASMCMD> lsdg
/*
State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  1048576     30719    30323                0           30323              0             Y  OCR/
*/
ASMCMD> exit

-- Step 71-->> On Node 1
-- Login as oracle user and issu the following command at RAC1 
[oracle@RAC1 ~]$ hostname
/*
RAC1.mydomain
*/
[oracle@RAC1 ~]$ xhost + RAC1.mydomain
/*
RAC1.mydomain being added to access control list
*/

-- Step 72 -->> On Node 1
-- Install database software only => Real Application Cluster database installation
-- Make sure choose proper groups while installing oracle
-- OSDBA  Group => dba
-- OSOPER Group => oper
[oracle@SDB-RAC1 ~]$ cd /opt/app/oracle/product/11.2.0.3.0/db_1/database/
[oracle@RAC1 oracle]$ sh ./runInstaller 

-- Step 73 -->> On Both Nodes
-- Run from root user to finalized the setup for both racs
[root@RAC1/RAC2 ~]# /opt/app/oracle/product/11.2.0.3.0/db_1/root.sh


-- Step 74 -->> On Node 1
--To add DATA and FRA storage
[grid@RAC1 ~]# cd /opt/app/11.2.0.3.0/grid/bin
[grid@RAC1 bin]# ./asmca

-- Step 75 -->> On Node 1
-- To create database 
[oracle@RAC1 ~]# cd /opt/app/oracle/product/11.2.0.3.0/db_1/bin
[oracle@RAC1 bin]# ./dbca

-- Step 76 -->> On Node 1
[root@RAC1 ~]# vi /etc/oratab
/*
+ASM1:/opt/app/11.2.0.3.0/grid:N        # line added by Agent
racdb1:/opt/app/oracle/product/11.2.0.3.0/db_1:N        # line added by Agent
*/

-- Step 77 -->> On Node 2
[root@RAC2 ~]# vi /etc/oratab 
/*
+ASM2:/opt/app/11.2.0.3.0/grid:N        # line added by Agent
racdb2:/opt/app/oracle/product/11.2.0.3.0/db_1:N        # line added by Agent
*/

-- Step 78 -->> On Both Nodes
-- Reboot the Oracle Cluster
[root@RAC1/RAC2 ~]# cd /opt/app/11.2.0.3.0/grid/bin
[root@RAC1/RAC2 ~]# ./crsctl stop crs
[root@RAC1/RAC2 ~]# ./crsctl start crs
[root@RAC1/RAC2 ~]# ./crsctl stat res -t -init
[root@RAC1/RAC2 ~]# ./crsctl stat res -t
[root@RAC1/RAC2 ~]# ./crsctl check cluster -all
/*
**************************************************************
rac1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
rac2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
*/

-- Step 79 -->> On Both Nodes
[root@RAC1/RAC2 ~]# su - grid
[grid@RAC1/RAC2 ~]$ asmcmd
ASMCMD> lsdg
/*
State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  1048576     51199    51104                0           51104              0             N  ARC/
MOUNTED  EXTERN  N         512   4096  1048576     51199    49317                0           49317              0             N  DATA/
MOUNTED  EXTERN  N         512   4096  1048576     10239     9843                0            9843              0             Y  OCR/
ASMCMD> exit
*/

-- Step 80 -->> On Both Nodes
[root@RAC1/RAC2 ~]# su - oracle
[oracle@RAC1/RAC2 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/

-- Step 81 -->> On Both Nodes
[oracle@RAC1/RAC2 ~]$ srvctl status listener -l listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): rac1,rac2
*/

-- Step 82 -->> On Both Nodes
[oracle@RAC1/RAC2 ~]$ srvctl config database -d racdb
/*
Database unique name: racdb
Database name: racdb
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile: +DATA/racdb/spfileracdb.ora
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances: racdb1,racdb2
Disk Groups: DATA,FRA
Mount point paths:
Services:
Type: RAC
Database is administrator managed
*/
-- Step 83 -->> On Node 1
[oracle@RAC1 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 06-JAN-2023 12:53:24

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                06-JAN-2023 10:22:42
Uptime                    0 days 2 hr. 30 min. 43 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3.0/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/RAC1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.87.11)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.87.13)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
The command completed successfully
*/


-- Step 84 -->> On Node 2
[oracle@RAC2 ~]$ lsnrctl status

/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 06-JAN-2023 12:55:01

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                06-JAN-2023 11:23:15
Uptime                    0 days 1 hr. 31 min. 48 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3.0/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/RAC2/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.87.12)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.87.14)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

-- Step 85-->> On both Node Check Database instance name and status.
[oracle@RAC2 ~]$ sqlplus / as sysdba
/*
[oracle@RAC1 ~]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.3.0 Production on Fri Jan 6 12:56:45 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

SQL> select instance_name,status from gv$instance;

INSTANCE_NAME    STATUS
---------------- ------------
racdb1           OPEN
racdb2           OPEN

or for node 2

INSTANCE_NAME    STATUS
---------------- ------------
racdb2           OPEN
racdb1           OPEN

*/

--steps 83 


[oracle@RAC1 ~]$ adrci
/*
ADRCI: Release 11.2.0.3.0 - Production on Fri Jan 6 12:55:48 2023

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

ADR base = "/opt/app/oracle"
adrci> show home
ADR Homes:
diag/rdbms/racdb/racdb1
diag/tnslsnr/RAC1/listener
diag/asm/+asm/+ASM1
adrci> set home diag/rdbms/racdb/racdb1
adrci> show alert -tail -f
2023-01-06 11:23:53.948000 +05:45
 1 2 (myinst: 1)
 Global Resource Directory frozen
 Communication channels reestablished
 Master broadcasted resource hash value bitmaps
 Non-local Process blocks cleaned out
 LMS 0: 0 GCS shadows cancelled, 0 closed, 0 Xw survived
 Set master node info
 Submitted all remote-enqueue requests
 Dwn-cvts replayed, VALBLKs dubious
 All grantable enqueues granted
minact-scn: Master returning as live inst:2 has inc# mismatch instinc:0 cur:8 errcnt:0
2023-01-06 11:23:56.814000 +05:45
 Submitted all GCS remote-cache requests
 Fix write in gcs resources
Reconfiguration complete
2023-01-06 11:25:33.463000 +05:45
db_recovery_file_dest_size of 4347 MB is 5.15% used. This is a
user-specified limit on the amount of space that will be used by this
database for recovery-related files, and does not reflect the amount of
space available in the underlying filesystem or ASM diskgroup.
2023-01-06 11:28:28.449000 +05:45
Time drift detected. Please check VKTM trace file for more details.
2023-01-06 12:58:03.610000 +05:45
Time drift detected. Please check VKTM trace file for more details.
2023-01-06 13:02:02.465000 +05:45
Thread 1 advanced to log sequence 10 (LGWR switch)
  Current log# 2 seq# 10 mem# 0: +DATA/racdb/onlinelog/group_2.262.1125332727
  Current log# 2 seq# 10 mem# 1: +FRA/racdb/onlinelog/group_2.258.1125332729
2023-01-06 13:03:09.472000 +05:45
Thread 1 cannot allocate new log, sequence 11
Checkpoint not complete
  Current log# 2 seq# 10 mem# 0: +DATA/racdb/onlinelog/group_2.262.1125332727
  Current log# 2 seq# 10 mem# 1: +FRA/racdb/onlinelog/group_2.258.1125332729
2023-01-06 13:03:11.255000 +05:45
Thread 1 advanced to log sequence 11 (LGWR switch)
  Current log# 1 seq# 11 mem# 0: +DATA/racdb/onlinelog/group_1.261.1125332725
  Current log# 1 seq# 11 mem# 1: +FRA/racdb/onlinelog/group_1.257.1125332727
 */
 

