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
192.168.120.11   RAC1.mydomain        RAC1
192.168.120.12   RAC2.mydomain        RAC2

# Private
10.0.1.11        RAC1-priv.mydomain   RAC1-priv
10.0.1.12        RAC2-priv.mydomain   RAC2-priv

# Virtual
192.168.120.13   RAC1-vip.mydomain    RAC1-vip
192.168.120.14   RAC2-vip.mydomain    RAC2-vip

# Openfiler (SAN/NAS Storage)
192.168.120.10   openfiler.mydomain   openfiler

# SCAN
192.168.120.15   RAC-scan.mydomain    RAC-scan
192.168.120.16   RAC-scan.mydomain    RAC-scan
192.168.120.17   RAC-scan.mydomain    RAC-scan
*/


[root@openfiler ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0
/*
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.120.10
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
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
[root@openfiler ~]# rm -rf /etc/ntp.conf
[root@openfiler ~]# rm -rf /var/run/ntpd.pid

-- Step 6 -->> On Openfiler (SAN/NAS Storage)
[root@openfiler ~]# init 6

----------------------------------------------------------------
-------------Two Node Rac Setup on VM Workstation---------------
----------------------------------------------------------------
-- 2 Node Rac on VM -->> On both Nodes

[root@RAC1DR/RAC2DR ~]# df -Th ~]# df -Th
/*
Filesystem     Type     Size  Used Avail Use% Mounted on
/dev/sda2      ext4      50G  813M   46G   2% /
tmpfs          tmpfs    1.9G   80K  1.9G   1% /dev/shm
/dev/sda1      ext4      15G  114M   14G   1% /boot
/dev/sda6      ext4      15G   38M   14G   1% /home
/dev/sda3      ext4      50G   52M   47G   1% /opt
/dev/sda9      ext4      15G   38M   14G   1% /tmp
/dev/sda7      ext4      15G  5.3G  8.7G  38% /usr
/dev/sda8      ext4      15G  2.0G   12G  15% /var
/dev/sr0       iso9660  3.8G  3.8G     0 100% /media/OL6.10 x86_64 Disc 1 20180625

*/
-- Step 1 -->> On both Node
[root@RAC1/RAC2 ~]vi /etc/hosts
/*
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# Public
192.168.120.11   RAC1.mydomain        RAC1
192.168.120.12   RAC2.mydomain        RAC2

# Private
10.0.1.11        RAC1-priv.mydomain   RAC1-priv
10.0.1.12        RAC2-priv.mydomain   RAC2-priv

# Virtual
192.168.120.13   RAC1-vip.mydomain    RAC1-vip
192.168.120.14   RAC2-vip.mydomain    RAC2-vip

# Openfiler (SAN/NAS Storage)
192.168.120.10   openfiler.mydomain   openfiler

# SCAN
192.168.120.15   RAC-scan.mydomain    RAC-scan
192.168.120.16   RAC-scan.mydomain    RAC-scan
192.168.120.17   RAC-scan.mydomain    RAC-scan

*/

-- Step 2 -->> On both Node
-- Disable secure linux by editing the "/etc/selinux/config" file, making sure the SELINUX flag is set
[root@RAC1DR/RAC2DR ~]# vi /etc/selinux/config
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
-- Step 3 -->> On Node 1
[root@RAC1 network-scripts ~]# vi /etc/sysconfig/network
/*
NETWORKING=yes
HOSTNAME=RAC1.mydomain
*/

-- Step 3 -->> On Node 1
[root@RAC2 network-scripts ~]# vi /etc/sysconfig/network
/*
NETWORKING=yes
HOSTNAME=RAC2.mydomain
*/
-- Step 5 -->> On Node 1
[root@RAC1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.120.11
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no

*/

-- Step 6 -->> On Node 1
[root@RAC1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth1
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=eth1
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=10.0.1.11
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
*/

-- Step 7 -->> On Node 2
[root@RAC2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth0
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.120.12
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no

*/

-- Step 8 -->> On Node 2
[root@RAC2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-eth1
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=eth1
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=10.0.1.12
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
*/


[root@localhost ~]# service network restart
/*
Shutting down loopback interface:                          [  OK  ]
Bringing up loopback interface:                            [  OK  ]
Bringing up interface eth0:  Error: Connection activation failed: The connection is not for this device.
	[FAILED]
Bringing up interface eth1:  Error: Connection activation failed: The connection is not for this device.
	[FAILED]
*/
--How we fix the error Device eth0 does not seem to be present?
Method 1: Removing 70-persistent-net.rules file
/*
[root@localhost rules.d]#cd /etc/udev/rules.d/70-persistent-net.rules[

[root@localhost rules.d]# rm -rf 70-persistent-net.rules
*/

-- Step 9 -->> On both Nodes
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
[root@RAC1/RAC2 ~]# iptables -F
[root@RAC1/RAC2 ~]# chkconfig iptables off
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

-- Step 10 -->> On both Nodes
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
[root@RAC1/RAC2 ~]# rm -rf /etc/ntp.conf
[root@RAC1/RAC2 ~]# rm -rf /var/run/ntpd.pid

-- Step 11 -->> On both Nodes
[root@rac1/rac2 ~]# init 6

-- Step 12 -->> On both Nodes
-- Perform either the Automatic Setup or the Manual Setup to complete the basic prerequisites. 
-- The Additional Setup is required for all installations.
[root@RAC1/RAC2 ~]# cd /media/OL6.4\ x86_64\ Disc\ 1\ 20130225/Server/Packages/
[root@RAC1/RAC2]# yum install oracle-rdbms-server-11gR2-preinstall
[root@RAC1/RAC2]# yum update
[root@RAC1/RAC2 Packages]# yum erase copy-jdk-configs
[root@RAC1/RAC2 Packages]# yum install java-1.7.0

-- Step 13 -->> On both Nodes
-- Manual tup the relevant RPMS

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
[root@RAC1/RAC2 Packages]# yum install lsscsi
*/
/*
yum install -y binutils-2.20.51.0.2-5.48.0.3.el6_10.1.x86_64
yum install -y compat-libstdc++-33-3.2.3-69.el6.x86_64
yum install -y compat-libstdc++-33-3.2.3-69.el6.i686
yum install -y elfutils-libelf-0.164-2.el6.x86_64
yum install -y elfutils-libelf-0.164-2.el6.i686
yum install -y elfutils-libelf-devel-0.164-2.el6.x86_64
yum install -y elfutils-libelf-devel-0.164-2.el6.i686
yum install -y package elfutils-libelf-devel-static is not installed
yum install -y rpm-4.8.0-59.el6.x86_64
yum install -y gcc-4.4.7-23.0.1.el6.x86_64
yum install -y gcc-c++-4.4.7-23.0.1.el6.x86_64
yum install -y glibc-2.12-1.212.0.3.el6_10.3.x86_64
yum install -y glibc-2.12-1.212.0.3.el6_10.3.i686
yum install -y glibc-common-2.12-1.212.0.3.el6_10.3.x86_64
yum install -y glibc-devel-2.12-1.212.0.3.el6_10.3.x86_64
yum install -y glibc-headers-2.12-1.212.0.3.el6_10.3.x86_64
yum install -y kernel-headers-2.6.32-754.35.1.el6.x86_64
yum install -y ksh-20120801-38.el6_10.x86_64
yum install -y libaio-0.3.107-10.el6.x86_64
yum install -y libaio-0.3.107-10.el6.i686
yum install -y libaio-devel-0.3.107-10.el6.x86_64
yum install -y libaio-devel-0.3.107-10.el6.i686
yum install -y rpm-4.8.0-59.el6.x86_64
yum install -y libgcc-4.4.7-23.0.1.el6.x86_64
yum install -y libgcc-4.4.7-23.0.1.el6.i686
yum install -y libgomp-4.4.7-23.0.1.el6.x86_64
yum install -y libstdc++-4.4.7-23.0.1.el6.x86_64
yum install -y libstdc++-4.4.7-23.0.1.el6.i686
yum install -y libstdc++-devel-4.4.7-23.0.1.el6.x86_64
yum install -y make-3.81-23.el6.x86_64
yum install -y numactl-devel-2.0.9-2.el6.x86_64
yum install -y sysstat-9.0.4-33.0.1.el6_9.1.x86_64
yum install -y unixODBC-2.2.14-14.el6.x86_64
*/
-- Step 14 -->> On both Nodes
-- Pre-Installation Steps for ASM
[root@RAC1/RAC2 ~ ]# cd /etc/yum.repos.d
[root@RAC1/RAC2 yum.repos.d]# uname -a
/*
Linux rac1/rac2.mydomain 2.6.39-400.313.1.el6uek.x86_64 #1 SMP Thu Aug 8 15:49:52 PDT 2019 x86_64 x86_64 x86_64 GNU/Linux
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
--2019-09-02 13:50:54--  https://public-yum.oracle.com/public-yum-ol6.repo
Resolving public-yum.oracle.com... 104.84.157.171
Connecting to public-yum.oracle.com|104.84.157.171|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 12045 (12K) [text/plain]
Saving to: “public-yum-ol6.repo.2”

100%[======================================>] 12,045      --.-K/s   in 0s      

2019-09-02 13:50:55 (95.3 MB/s) - “public-yum-ol6.repo” saved [12045/12045]
*/
[root@RAC1/RAC2 yum.repos.d]# ls
/*
oracle-linux-ol6.repo.disabled  public-yum-ol6.repo    public-yum-ol6.repo.2
packagekit-media.repo           public-yum-ol6.repo.1  uek-ol6.repo.disabled
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

-- Step 15 -->> On both Nodes
Need to download (oracleasmlib-2.0.4-1.el5.i386.rpm : https://oracle-base.com/articles/11g/oracle-db-11gr2-rac-installation-on-oel5-using-virtualbox | http://www.hblsoft.org/hwl/1326.html)
[root@RAC1/RAC2 yum.repos.d]# cd /mnt/hgfs/Oracle_Linux_6_Rpm/
[root@RAC1/RAC2 Oracle_Linux_6_Rpm]# ls
/*
dtrace-utils-1.0.0-8.el6.x86_64.rpm                  
libdtrace-ctf-0.8.0-1.el6.x86_64.rpm        
oracleasmlib-2.0.4-1.el6.x86_64.rpm
dtrace-utils-devel-1.0.0-8.el6.x86_64.rpm            
libdtrace-ctf-devel-0.8.0-1.el6.x86_64.rpm  
unixODBC-devel-2.2.14-12.el6_3.x86_64.rpm
dtrace-utils-testsuite-1.0.0-8.el6.x86_64.rpm        
numactl-2.0.9-2.el6.i686.rpm
elfutils-libelf-devel-static-0.164-2.el6.x86_64.rpm  
numactl-devel-2.0.9-2.el6.i686.rpm

*/

[root@RAC1/RAC2 OracleASM_Package]# rpm -iUvh oracleasmlib-2.0.4-1.el6.x86_64.rpm
/*
Preparing...                ########################################### [100%]
    package oracleasmlib-2.0.4-1.el6.x86_64 is already installed
*/
[root@RAC1/RAC2 OracleASM_Package]# rpm -iUvh elfutils-libelf-devel-static-0.164-2.el6.x86_64.rpm
/*
Preparing...                ########################################### [100%]
   1:elfutils-libelf-devel-s########################################### [100%]
*/

-- Step 16 -->> On both Nodes
-- Orcle ASM Configuration
[root@RAC1/RAC2 ~]# rpm -qa | grep -i oracleasm
/*
kmod-oracleasm-2.0.8-16.1.el6_10.x86_64
oracleasmlib-2.0.4-1.el6.x86_64
oracleasm-support-2.1.11-2.el6.x86_64

-- Step 17 -->> On both Nodes
-- Add the kernel parameters file "/etc/sysctl.conf" and add oracle recommended kernel parameters
[root@rac1/rac2 ~]# vi /etc/sysctl.conf
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
/*


-- Step 18 -->> On both Nodes
-- Edit "/etc/security/limits.conf" file to limit user processes
[root@RAC1/RAC2 ~]# vi /etc/security/limits.conf

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

-- Step 19 -->> On both Nodes
-- Add the following line to the "/etc/pam.d/login" file, if it does not already exist.
[root@RAC1/RAC2~]# vi /etc/pam.d/login
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

-- Step 20 -->> On both Node
-- Create the new groups and users.
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i oinstall
/*
oinstall:x:54321:
*/
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i dba
/*
dba:x:54322:
*/

[root@RAC1/RAC2 ]# cat /etc/group | grep -i asm

-- 1.Create OS groups using the command below. Enter these commands as the 'root' user:
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 503 oper
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 504 asmadmin
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 506 asmdba
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 507 asmoper
[root@RAC1/RAC2 ~]# /usr/sbin/groupadd -g 508 beoper

-- 2.Create the users that will own the Oracle software using the commands:
[root@RAC1/RAC2 ~]# /usr/sbin/useradd -g oinstall -G oinstall,dba,asmadmin,asmdba,asmoper,beoper grid	
[root@RAC1/RAC2 ~]# /usr/sbin/usermod -g oinstall -G oinstall,dba,oper,asmadmin,asmdba oracle

[root@RAC1/RAC2 ~]# cat /etc/group | grep -i oinstall
/*
oinstall:x:54321:grid,oracle
*/
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i asm
/*
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
asmoper:x:507:grid
*/
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i oracle
/*
oracle:x:500:
oinstall:x:54321:grid,oracle
dba:x:54322:grid,oracle
oper:x:503:oracle
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
*/
[root@RAC1/RAC2 ~]# cat /etc/group | grep -i grid
/*
oinstall:x:54321:grid,oracle
dba:x:54322:grid,oracle
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
asmoper:x:507:grid
beoper:x:508:grid
*/

[root@RAC1/RAC2 ~]# cat /etc/group | grep -i oper
/*
oper:x:503:oracle
asmoper:x:507:grid
beoper:x:508:grid
*/

-- Step 21 -->> On both Node
[root@RAC1/RAC2 ~]# passwd oracle
/*
Changing password for user oracle.
New password: 
BAD PASSWORD: it is based on a dictionary word
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
*/

-- Step 22 -->> On both Node
[root@RAC1/RAC2 ~]# passwd grid
/*
Changing password for user grid.
New password: 
BAD PASSWORD: it is too short
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
*/

-- Step 23 -->> On both Node
[root@RAC1/RAC2 ~]# su - oracle
[oracle@RAC1/RAC2 ~]$ su - grid
[grid@RAC1/RAC2 ~]$ su - root

-- Step 24 -->> On both Node
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
[root@RAC1/RAC2 ~]# mkdir /opt/app/oracle/cfgtoollogs
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

--on Both Nodes
--Make the following changes to the default shell startup file, add the following lines to the /etc/profile file:
[root@RAC1/RAC2 ~]# vi /etc/profile
/*
if [ $USER = "oracle" ]; then
           if [ $SHELL = "/bin/ksh" ]; then
              ulimit -p 16384
              ulimit -n 65536
           else
              ulimit -u 16384 -n 65536
           fi
fi
if [ $USER = "grid" ]; then
           if [ $SHELL = "/bin/ksh" ]; then
              ulimit -p 16384
              ulimit -n 65536
           else
              ulimit -u 16384 -n 65536
           fi
fi
*/


-- For the C shell (csh or tcsh), add the following lines to the /etc/csh.login file:
[root@RAC1/RAC2 ~]# vi /etc/csh.login
/*
if ( $USER == "oracle" ) then
          limit maxproc 16384
          limit descriptors 65536
endif
if ( $USER == "grid" ) then
          limit maxproc 16384
          limit descriptors 65536
endif
*/

-- Step 25 -->> On both Nodes
-- Unzip the files and Copy the ASM rpm to another Nodes.
[root@RAC1/RAC2 ~]# cd /root/11.2.0.3.0/
[root@RAC1 11.2.0.3.0]# unzip p10404530_112030_Linux-x86-64_1of7.zip -d /opt/app/oracle/product/11.2.0.3.0/db_1/
[root@RAC1 11.2.0.3.0]# unzip p10404530_112030_Linux-x86-64_2of7.zip -d /opt/app/oracle/product/11.2.0.3.0/db_1/
[root@RAC1 11.2.0.3.0]# unzip p10404530_112030_Linux-x86-64_3of7-Clusterware.zip -d /opt/app/11.2.0.3.0/
[root@RAC2 ~]# mkdir -p /opt/app/11.2.0.3.0/grid/rpm/
[root@RAC1 ~]# cd /opt/app/11.2.0.3.0/grid/rpm/
[root@RAC1 rpm]# scp -r cvuqdisk-1.0.9-1.rpm root@RAC2:/opt/app/11.2.0.3.0/grid/rpm/
/*
The authenticity of host 'RAC2 (192.168.120.22)' can't be established.
RSA key fingerprint is db:b7:69:ca:58:cd:9e:31:c7:d8:ac:81:b3:20:6f:fd.
Are you sure you want to continue connecting (yes/no)? YES
Warning: Permanently added 'RAC2,192.168.120.22' (RSA) to the list of known hosts.
root@RAC2's password:
cvuqdisk-1.0.9-1.rpm                                     100% 8551     8.4KB/s   00:00
*/



-- Step 26 -->> On both Nodes
[root@RAC1/RAC2 ~]# chown -R grid:oinstall /opt/app/11.2.0.3.0/grid
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/11.2.0.3.0/grid
[root@RAC1/RAC2 ~]# chown -R oracle:oinstall /opt/app/oracle/product/11.2.0.3.0/db_1
[root@RAC1/RAC2 ~]# chmod -R 775 /opt/app/oracle/product/11.2.0.3.0/db_1

[root@RAC1/RAC2 rpm]# CVUQDISK_GRP=oinstall; export CVUQDISK_GRP
[root@RAC1/RAC2 rpm]# rpm -iUvh cvuqdisk-1.0.9-1.rpm 
/*
Preparing...                          ################################# [100%]
   1:cvuqdisk-1.0.9-1                 ################################# [100%]
*/
-- Step 27 -->> On both Nodes
-- To Disable the virbr0/lxcbr0 Linux services 

[root@RAC1/RAC2 ~]# cd /etc/sysconfig/
[root@RAC1/RAC2]# sysconfig]# brctl show
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

-- Step 28 -->> On both Nodes
[root@RAC1/RAC2 ~]# brctl show
/*
bridge name    bridge id        STP enabled    interfaces
*/
[root@RAC1/RAC2 ~]# chkconfig --list | grep libvirtd
/*
libvirtd           0:off    1:off    2:off    3:off    4:off    5:off    6:off
*/


-- Step 29 -->> On Node 1
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

-- Step 30 -->> On Node 1
[oracle@RAC1 ~]$ . .bash_profile

-- Step 31 -->> On Node 1
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

-- Step 32 -->> On Node 1
[grid@RAC1 ~]$ . .bash_profile

-- Step 33 -->> On Node 1
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

-- Step 34 -->> On Node 2
[oracle@RAC2 ~]$ . .bash_profile
root@RAC2 ]# su - grid
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
-- Steps 35 -->> On Node 2
[grid@RAC2 ~]$ . .bash_profile


--Step 36 -->> On Node 1
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
[grid@RAC1 grid]$ ./sshUserSetup.sh -user grid -hosts "RAC1.mydomain RAC2.mydomain" -noPromptPassphrase -confirm -advanced

[grid@RAC1/RAC2 ~]$ ssh grid@RAC1 date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC2 date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC1 date && ssh grid@RAC2 date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC1.mydomain date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC2.mydomain date
[grid@RAC1/RAC2 ~]$ ssh grid@RAC1.mydomain date && ssh grid@RAC2.mydomain date


-->> On openfiler (SAN/NAS Storage)
[oracle@openfiler ~]#service iscsi-target restart

-- Step 37 -->> On all Node
[root@RAC1/RAC2 ~]# which oracleasm


/*
/usr/sbin/oracleasm
*/
-- Step 38 -->> On all Node
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

-- Step 39 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm status
/*
Checking if ASM is loaded: no
Checking if /dev/oracleasm is mounted: no
*/

-- Step 40 -->> On all Node
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


-- Step 41 -->> On all Node
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

-- Step 42 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm init
/*
Creating /dev/oracleasm mount point: /dev/oracleasm
Loading module "oracleasm": oracleasm
Configuring "oracleasm" to use device physical block size
Mounting ASMlib driver filesystem: /dev/oracleasm
*/

-- Step 43 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm status
/*
Checking if ASM is loaded: yes
Checking if /dev/oracleasm is mounted: yes
*/

-- Step 44 -->> On all Node
[root@RAC1/RAC2 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
*/

-- Step 45 -->> On all Nodes
[root@RAC1/RAC2 ~]# oracleasm listdisks
[root@RAC1/RAC2 ~]# rpm -qa | grep -i iscsi
/*
iscsi-initiator-utils-6.2.0.873-27.0.10.el6_10.x86_64
*/

-- Step 46 -->> On all Nodes
[root@RAC1/RAC2 ~]# service iscsi stop
/*
Stopping iscsi:                                            [  OK  ]
*/

-- Step 47 -->> On all Nodes
[root@RAC1/RAC2 ~]# service iscsi status
/*
iscsi is stopped
*/

-- Step 48 -->> On all Nodes
[root@RAC1/RAC2 ~]# cd /etc/iscsi/
[root@RAC1/RAC2 iscsi]# ls
/*
initiatorname.iscsi  iscsid.conf
*/

-- Step 49 -->> On all Nodes
[root@RAC1 iscsi]# vi initiatorname.iscsi 
/*
InitiatorName=iqn.RAC1:oracle
*/

[root@RAC2 iscsi]# vim initiatorname.iscsi 
/*
InitiatorName=iqn.RAC2:oracle
*/

-- Step 50 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# service iscsi start
[root@RAC1/RAC2 iscsi]# chkconfig iscsi on
[root@RAC1/RAC2 iscsi]# chkconfig iscsid on

-- Step 51 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0 
[2:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda 
*/

-- Step 52 -->> On all Nodes 
[root@RAC1 /RAC2 iscsi]# iscsiadm -m discovery -t sendtargets -p openfiler
/*


192.168.120.10:3260,1 iqn.openfiler:fra1
192.168.120.10:3260,1 iqn.openfiler:data1
192.168.120.10:3260,1 iqn.openfiler:ocr
*/

-- Step 53 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0 
[2:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda 
*/

-- Step 54 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# ls /var/lib/iscsi/send_targets/
/*
openfiler,3260
*/

-- Step 55 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# ls /var/lib/iscsi/nodes/
/*
iqn.openfiler:data1  iqn.openfiler:fra1  iqn.openfiler:ocr
*/

-- Step 56 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# service iscsi restart
/*
Stopping iscsi:                                            [  OK  ]
Starting iscsi:                                            [  OK  ]
*/

-- Step 57 -->> On all Nodes 


[root@RAC1/RAC2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0 
[2:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda 
[4:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdb 
[6:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdc 
[8:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdd 
*/

-- Step 58 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# iscsiadm -m session
/*
tcp: [2] 192.168.129.104:3260,1 iqn.openfiler:data1 (non-flash)
tcp: [4] 192.168.129.104:3260,1 iqn.openfiler:fra1 (non-flash)
tcp: [6] 192.168.129.104:3260,1 iqn.openfiler:ocr (non-flash)
*/

-- Step 59 -->> On Node 1
[root@RAC1 iscsi]# iscsiadm -m node -T iqn.openfiler:ocr -p 192.168.120.10 --op update -n node.startup -v automatic
[root@RAC1 iscsi]# iscsiadm -m node -T iqn.openfiler:data1 -p 192.168.120.10 --op update -n node.startup -v automatic
[root@RAC1 iscsi]# iscsiadm -m node -T iqn.openfiler:fra1 -p 192.168.120.10 --op update -n node.startup -v automatic

-- Step 60 -->> On Node 1
[root@RAC1 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0 
[2:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda 
[4:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdb 
[6:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdc 
[8:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdd 
*/

-- Step 61 -->> On Node 1
[root@RAC1 iscsi]# ls /dev/sd*
/*
/dev/sda   /dev/sda2  /dev/sda4  /dev/sda6  /dev/sda8  /dev/sdb  /dev/sdd
/dev/sda1  /dev/sda3  /dev/sda5  /dev/sda7  /dev/sda9  /dev/sdc
*/

-- Step 62 -->> On Node 1
[root@RAC1/RAC2 iscsi]# iscsiadm -m session -P 3 > scsi_drives.txt
[root@RAC1/RAC2 iscsi]# vi scsi_drives.txt 
[root@RAC1/RAC2  iscsi]# cat scsi_drives.txt 
/*
# iscsiadm -m session -P 3

Target: iqn.openfiler:fra1dr (non-flash)
                        Attached scsi disk sdb          State: running
Target: iqn.openfiler:data1dr (non-flash)
                        Attached scsi disk sdc          State: running
Target: iqn.openfiler:ocrdr (non-flash)
                        Attached scsi disk sdd          State: running
*/
-- Step 63 -->> On Node 1
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

-- Step 64 -->> On Node 1
[root@RAC1 ~]# fdisk -ll
/*
Disk /dev/sda: 204.0 GB, 204010946560 bytes
255 heads, 63 sectors/track, 24802 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0008e6c0

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1        1959    15728640   83  Linux
/dev/sda2            1959        8486    52428800   83  Linux
/dev/sda3            8486       15013    52428800   83  Linux
/dev/sda4           15013       24803    78642176    5  Extended
/dev/sda5           15013       16971    15728640   82  Linux swap / Solaris
/dev/sda6           16971       18930    15728640   83  Linux
/dev/sda7           18930       20888    15728640   83  Linux
/dev/sda8           20888       22846    15728640   83  Linux
/dev/sda9           22846       24803    15721472   83  Linux

Disk /dev/sdb: 26.2 GB, 26239565824 bytes
64 heads, 32 sectors/track, 25024 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/sdc: 42.9 GB, 42949672960 bytes
64 heads, 32 sectors/track, 40960 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


Disk /dev/sdd: 21.5 GB, 21474836480 bytes
64 heads, 32 sectors/track, 20480 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

*/



-- Step 65 -->> On Node 1
[root@RAC1 ~]# fdisk /dev/sdb
/*
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x2f9a2e80.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): p

Disk /dev/sdb: 26.2 GB, 26239565824 bytes
64 heads, 32 sectors/track, 25024 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x2f9a2e80

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-25024, default 1):
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-25024, default 25024):
Using default value 25024

Command (m for help): p

Disk /dev/sdb: 26.2 GB, 26239565824 bytes
64 heads, 32 sectors/track, 25024 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x2f9a2e80

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1       25024    25624560   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
 
 */
 
 -- Step 66 -->> On Node 1
[root@RAC1 ~]# fdisk /dev/sdc
/*
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x0d8bf62e.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): p

Disk /dev/sdc: 42.9 GB, 42949672960 bytes
64 heads, 32 sectors/track, 40960 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0d8bf62e

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-40960, default 1):
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-40960, default 40960):
Using default value 40960

Command (m for help): p

Disk /dev/sdc: 42.9 GB, 42949672960 bytes
64 heads, 32 sectors/track, 40960 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0d8bf62e

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1               1       40960    41943024   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

 */

-- Step 67 -->> On Node 1

[root@RAC1 ~]# fdisk /dev/sdd
/*
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0x790b12b4.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').

Command (m for help): p

Disk /dev/sdd: 21.5 GB, 21474836480 bytes
64 heads, 32 sectors/track, 20480 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x790b12b4

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-20480, default 1):
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-20480, default 20480):
Using default value 20480

Command (m for help): p

Disk /dev/sdd: 21.5 GB, 21474836480 bytes
64 heads, 32 sectors/track, 20480 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x790b12b4

   Device Boot      Start         End      Blocks   Id  System
/dev/sdd1               1       20480    20971504   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
  
*/

-- Step 68 -->> On Node 1
[root@RAC1 ~]# ls -ltr /dev/sd*
/*
brw-rw---- 1 root disk 8,  0 Jan 19 10:16 /dev/sda
brw-rw---- 1 root disk 8,  4 Jan 19 10:16 /dev/sda4
brw-rw---- 1 root disk 8,  5 Jan 19 10:16 /dev/sda5
brw-rw---- 1 root disk 8,  2 Jan 19 10:17 /dev/sda2
brw-rw---- 1 root disk 8,  1 Jan 19 10:17 /dev/sda1
brw-rw---- 1 root disk 8,  6 Jan 19 10:17 /dev/sda6
brw-rw---- 1 root disk 8,  3 Jan 19 10:17 /dev/sda3
brw-rw---- 1 root disk 8,  9 Jan 19 10:17 /dev/sda9
brw-rw---- 1 root disk 8,  7 Jan 19 10:17 /dev/sda7
brw-rw---- 1 root disk 8,  8 Jan 19 10:17 /dev/sda8
brw-rw---- 1 root disk 8, 16 Jan 19 13:46 /dev/sdb
brw-rw---- 1 root disk 8, 17 Jan 19 13:46 /dev/sdb1
brw-rw---- 1 root disk 8, 32 Jan 19 13:48 /dev/sdc
brw-rw---- 1 root disk 8, 33 Jan 19 13:48 /dev/sdc1
brw-rw---- 1 root disk 8, 48 Jan 19 13:49 /dev/sdd
brw-rw---- 1 root disk 8, 49 Jan 19 13:49 /dev/sdd1

*/
-- Step 69 -->> On Both Nodes
[root@RAC1/RAC2 ~]# fdisk -ll
/*
Disk /dev/sda: 204.0 GB, 204010946560 bytes
255 heads, 63 sectors/track, 24802 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0008e6c0

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1        1959    15728640   83  Linux
/dev/sda2            1959        8486    52428800   83  Linux
/dev/sda3            8486       15013    52428800   83  Linux
/dev/sda4           15013       24803    78642176    5  Extended
/dev/sda5           15013       16971    15728640   82  Linux swap / Solaris
/dev/sda6           16971       18930    15728640   83  Linux
/dev/sda7           18930       20888    15728640   83  Linux
/dev/sda8           20888       22846    15728640   83  Linux
/dev/sda9           22846       24803    15721472   83  Linux

Disk /dev/sdb: 26.2 GB, 26239565824 bytes
64 heads, 32 sectors/track, 25024 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x2f9a2e80

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1       25024    25624560   83  Linux

Disk /dev/sdc: 42.9 GB, 42949672960 bytes
64 heads, 32 sectors/track, 40960 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0d8bf62e

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1               1       40960    41943024   83  Linux

Disk /dev/sdd: 21.5 GB, 21474836480 bytes
64 heads, 32 sectors/track, 20480 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x790b12b4

   Device Boot      Start         End      Blocks   Id  System
/dev/sdd1               1       20480    20971504   83  Linux

*/

-- Step 70 -->> On Node 1
[root@RAC1 ~]# /etc/init.d/oracleasm createdisk OCR /dev/sdc1
/*
Marking disk "OCR" as an ASM disk:                       [  OK  ]
*/


[root@RAC1 ~]# /etc/init.d/oracleasm createdisk DATA /dev/sdb1
/*
Marking disk "DATA" as an ASM disk:                       [  OK  ]
*/
-- Step 71-->> On Node 1



-- Step 72 -->> On Node 1
[root@RAC1 ~]# /etc/init.d/oracleasm createdisk FRA /dev/sdd1

/*
Marking disk "FRA" as an ASM disk:                       [  OK  ]
*/

-- Step 73 -->> On Node 1
[root@RAC1 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
*/

-- Step 74 -->> On Node 1
[root@RAC1 ~]# oracleasm listdisks
/*
DATA
FRA
OCR
*/

-- Step 75 -->> On Node 2
[root@RAC2 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
Instantiating disk "DATA"
Instantiating disk "OCR"
Instantiating disk "FRA"
*/
-- Step 75 -->> On Node 2
[root@RAC2 ~]# oracleasm listdisks
/*
DATA
FRA
OCR
*/

-- Step 76 -->> On Node 1
-- Pre-check for RAC Setup
[grid@RAC1 ~]$ cd /opt/app/11.2.0.3.0/grid
[grid@RAC1 grid]$ ./runcluvfy.sh stage -pre crsinst -n RAC1,RAC2 -verbose
-- OR --
[grid@RAC1 grid]$ ./runcluvfy.sh stage -pre crsinst -n RAC1.mydomain,RAC2.mydomain -verbose
[grid@RAC1 grid]$ ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -method root
[grid@rac1 grid]$ ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -fixup -verbose (If Required)



-- Step 77 -->> On Node 1
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

-- Step 59 -->> On Both Nodes
-- Login as grid user and issue the following command at RAC1 
-- Make sure choose proper groups while installing grid
-- OSDBA  Group => asmdba
-- OSOPER Group => asmoper
-- OSASM  Group => asmadmin
-- oraInventory Group Name => oinstall

[grid@RAC1 ~]$ cd /opt/app/11.2.0.3.0/grid
[grid@RAC1 grid]$  ./runInstaller.sh
-- Unable to retrieve local node. The following error occured: PRCR-1001 : Resource ora.asm does not exist

/opt/app/11.2.0.3.0/grid/root.sh

grid database +ASM  password :Adminrabin1
oracle database racdb password :Adminrabin1

[grid@RAC1 ~]$ srvctl add asm
[grid@RAC1 ~]$ crsctl stat res -t


-- Step 78 -->> On Both Nodes
-- Run from root user to finalized the setup for both racs
[grid@RAC1 grid]$ su - root
Password:
[root@RAC1 ~]# /opt/app/oraInventory/orainstRoot.sh
/*
Changing permissions of /opt/app/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.
Changing groupname of /opt/app/oraInventory to oinstall.
The execution of the script is complete.

*/

[root@RAC1 ~]# /opt/app/11.2.0.3.0/grid/root.sh
/*
Performing root user operation for Oracle 11g

The following environment variables are set as:
    ORACLE_OWNER= grid
    ORACLE_HOME=  /opt/app/11.2.0.3.0/grid

Enter the full pathname of the local bin directory: [/usr/local/bin]:
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Using configuration parameter file: /opt/app/11.2.0.3.0/grid/crs/install/crsconfig_params
Creating trace directory
User ignored Prerequisites during installation
OLR initialization - successful
  root wallet
  root wallet cert
  root cert export
  peer wallet
  profile reader wallet
  pa wallet
  peer wallet keys
  pa wallet keys
  peer cert request
  pa cert request
  peer cert
  pa cert
  peer root cert TP
  profile reader root cert TP
  pa root cert TP
  peer pa cert TP
  pa peer cert TP
  profile reader pa cert TP
  profile reader peer cert TP
  peer user cert
  pa user cert
Adding Clusterware entries to upstart
CRS-2672: Attempting to start 'ora.mdnsd' on 'RAC1'
CRS-2676: Start of 'ora.mdnsd' on 'RAC1' succeeded
CRS-2672: Attempting to start 'ora.gpnpd' on 'RAC1'
CRS-2676: Start of 'ora.gpnpd' on 'RAC1' succeeded
CRS-2672: Attempting to start 'ora.cssdmonitor' on 'RAC1'
CRS-2672: Attempting to start 'ora.gipcd' on 'RAC1'
CRS-2676: Start of 'ora.cssdmonitor' on 'RAC1' succeeded
CRS-2676: Start of 'ora.gipcd' on 'RAC1' succeeded
CRS-2672: Attempting to start 'ora.cssd' on 'RAC1'
CRS-2672: Attempting to start 'ora.diskmon' on 'RAC1'
CRS-2676: Start of 'ora.diskmon' on 'RAC1' succeeded
CRS-2676: Start of 'ora.cssd' on 'RAC1' succeeded

ASM created and started successfully.

Disk Group OCRDR created successfully.

clscfg: -install mode specified
Successfully accumulated necessary OCR keys.
Creating OCR keys for user 'root', privgrp 'root'..
Operation successful.
CRS-4256: Updating the profile
Successful addition of voting disk 444dc55337774f06bf2f123f6730dd8a.
Successfully replaced voting disk group with +OCRDR.
CRS-4256: Updating the profile
CRS-4266: Voting file(s) successfully replaced
##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   444dc55337774f06bf2f123f6730dd8a (ORCL:OCRDR) [OCRDR]
Located 1 voting disk(s).
Configure Oracle Grid Infrastructure for a Cluster ... succeeded
*/


[root@RAC2 ~]# /opt/app/11.2.0.3.0/grid/root.sh
/*
Performing root user operation for Oracle 11g

The following environment variables are set as:
    ORACLE_OWNER= grid
    ORACLE_HOME=  /opt/app/11.2.0.3.0/grid

Enter the full pathname of the local bin directory: [/usr/local/bin]:
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Using configuration parameter file: /opt/app/11.2.0.3.0/grid/crs/install/crsconfig_params
Creating trace directory
User ignored Prerequisites during installation
OLR initialization - successful
Adding Clusterware entries to upstart
CRS-4402: The CSS daemon was started in exclusive mode but found an active CSS daemon on node RAC1, number 1, and is terminating
An active cluster was found during exclusive startup, restarting to join the cluster
Configure Oracle Grid Infrastructure for a Cluster ... succeeded
*/

 Unable to retrieve local node. The following error occured: PRCR-1001 : Resource ora.asm does not exist
 
[grid@RAC1 ~]$ srvctl add asm
[grid@RAC1 ~]$ crsctl stat res -t

-- Step 79 -->> On Both Nodes
[grid@RAC1 bin]$ ./crsctl check cluster
/*
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
*/
-- Step 80 -->> On Both Nodes
[grid@RAC1 bin]$ ./crsctl check cluster -all
/*
**************************************************************
RAC1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
RAC2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
*/

[grid@RAC1 bin]$ ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       RAC1                   Started
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       RAC1
ora.crf
      1        ONLINE  ONLINE       RAC1
ora.crsd
      1        ONLINE  ONLINE       RAC1
ora.cssd
      1        ONLINE  ONLINE       RAC1
ora.cssdmonitor
      1        ONLINE  ONLINE       RAC1
ora.ctssd
      1        ONLINE  ONLINE       RAC1                   OBSERVER
ora.diskmon
      1        OFFLINE OFFLINE
ora.evmd
      1        ONLINE  ONLINE       RAC1
ora.gipcd
      1        ONLINE  ONLINE       RAC1
ora.gpnpd
      1        ONLINE  ONLINE       RAC1
ora.mdnsd
      1        ONLINE  ONLINE       RAC1


*/
-- On Both Nodes
[grid@RAC1 bin]$ su - root
Password:
[root@RAC1/RAC2 ~]# cd /etc
[root@RAC1/RAC2 etc]# rm -rf ntp.conf

-- On both Nodes

[grid@RAC1 bin]$ su - root
Password:
[root@RAC1/RAC2 ~]# cd /opt/app/11.2.0.3.0/grid/bin/
[root@RAC1/RAC2 bin]# ./crsctl stop crs
/*
CRS-2791: Starting shutdown of Oracle High Availability Services-managed resources on 'RAC1'
CRS-2673: Attempting to stop 'ora.crsd' on 'RAC1'
CRS-2790: Starting shutdown of Cluster Ready Services-managed resources on 'RAC1'
CRS-2673: Attempting to stop 'ora.RAC1.vip' on 'RAC1'
CRS-2677: Stop of 'ora.RAC1.vip' on 'RAC1' succeeded
CRS-2672: Attempting to start 'ora.RAC1.vip' on 'RAC2'
CRS-2676: Start of 'ora.RAC1.vip' on 'RAC2' succeeded
CRS-2673: Attempting to stop 'ora.ons' on 'RAC1'
CRS-2677: Stop of 'ora.ons' on 'RAC1' succeeded
CRS-2673: Attempting to stop 'ora.net1.network' on 'RAC1'
CRS-2677: Stop of 'ora.net1.network' on 'RAC1' succeeded
CRS-2792: Shutdown of Cluster Ready Services-managed resources on 'RAC1' has completed
CRS-2677: Stop of 'ora.crsd' on 'RAC1' succeeded
CRS-2673: Attempting to stop 'ora.ctssd' on 'RAC1'
CRS-2673: Attempting to stop 'ora.evmd' on 'RAC1'
CRS-2673: Attempting to stop 'ora.asm' on 'RAC1'
CRS-2673: Attempting to stop 'ora.mdnsd' on 'RAC1'
CRS-2677: Stop of 'ora.evmd' on 'RAC1' succeeded
CRS-2677: Stop of 'ora.mdnsd' on 'RAC1' succeeded
CRS-2677: Stop of 'ora.ctssd' on 'RAC1' succeeded
CRS-2677: Stop of 'ora.asm' on 'RAC1' succeeded
CRS-2673: Attempting to stop 'ora.cluster_interconnect.haip' on 'RAC1'
CRS-2677: Stop of 'ora.cluster_interconnect.haip' on 'RAC1' succeeded
CRS-2673: Attempting to stop 'ora.cssd' on 'RAC1'
CRS-2677: Stop of 'ora.cssd' on 'RAC1' succeeded
CRS-2673: Attempting to stop 'ora.crf' on 'RAC1'
CRS-2677: Stop of 'ora.crf' on 'RAC1' succeeded
CRS-2673: Attempting to stop 'ora.gipcd' on 'RAC1'
CRS-2677: Stop of 'ora.gipcd' on 'RAC1' succeeded
CRS-2673: Attempting to stop 'ora.gpnpd' on 'RAC1'
CRS-2677: Stop of 'ora.gpnpd' on 'RAC1' succeeded
CRS-2793: Shutdown of Oracle High Availability Services-managed resources on 'RAC1' has completed
CRS-4133: Oracle High Availability Services has been stopped.

*/

[root@RAC2 bin]# ./crsctl stop crs
/*
CRS-2791: Starting shutdown of Oracle High Availability Services-managed resources on 'RAC2'
CRS-2673: Attempting to stop 'ora.crsd' on 'RAC2'
CRS-2790: Starting shutdown of Cluster Ready Services-managed resources on 'RAC2'
CRS-2673: Attempting to stop 'ora.RAC2.vip' on 'RAC2'
CRS-2673: Attempting to stop 'ora.RAC1.vip' on 'RAC2'
CRS-2677: Stop of 'ora.RAC2.vip' on 'RAC2' succeeded
CRS-2677: Stop of 'ora.RAC1.vip' on 'RAC2' succeeded
CRS-2673: Attempting to stop 'ora.ons' on 'RAC2'
CRS-2677: Stop of 'ora.ons' on 'RAC2' succeeded
CRS-2673: Attempting to stop 'ora.net1.network' on 'RAC2'
CRS-2677: Stop of 'ora.net1.network' on 'RAC2' succeeded
CRS-2792: Shutdown of Cluster Ready Services-managed resources on 'RAC2' has completed
CRS-2677: Stop of 'ora.crsd' on 'RAC2' succeeded
CRS-2673: Attempting to stop 'ora.mdnsd' on 'RAC2'
CRS-2673: Attempting to stop 'ora.crf' on 'RAC2'
CRS-2673: Attempting to stop 'ora.ctssd' on 'RAC2'
CRS-2673: Attempting to stop 'ora.evmd' on 'RAC2'
CRS-2673: Attempting to stop 'ora.asm' on 'RAC2'
CRS-2677: Stop of 'ora.mdnsd' on 'RAC2' succeeded
CRS-2677: Stop of 'ora.crf' on 'RAC2' succeeded
CRS-2677: Stop of 'ora.evmd' on 'RAC2' succeeded
CRS-2677: Stop of 'ora.asm' on 'RAC2' succeeded
CRS-2673: Attempting to stop 'ora.cluster_interconnect.haip' on 'RAC2'
CRS-2677: Stop of 'ora.cluster_interconnect.haip' on 'RAC2' succeeded
CRS-2677: Stop of 'ora.ctssd' on 'RAC2' succeeded
CRS-2673: Attempting to stop 'ora.cssd' on 'RAC2'
CRS-2677: Stop of 'ora.cssd' on 'RAC2' succeeded
CRS-2673: Attempting to stop 'ora.gipcd' on 'RAC2'
CRS-2677: Stop of 'ora.gipcd' on 'RAC2' succeeded
CRS-2673: Attempting to stop 'ora.gpnpd' on 'RAC2'
CRS-2677: Stop of 'ora.gpnpd' on 'RAC2' succeeded
CRS-2793: Shutdown of Oracle High Availability Services-managed resources on 'RAC2' has completed
CRS-4133: Oracle High Availability Services has been stopped.
*/

-- On both nodes

[root@RAC1/RAC2 bin]# ./crsctl start crs
/*
CRS-4123: Oracle High Availability Services has been started.

*/
--On Node 1
[root@RAC1 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       RAC1                   Started
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       RAC1
ora.crf
      1        ONLINE  ONLINE       RAC1
ora.crsd
      1        ONLINE  ONLINE       RAC1
ora.cssd
      1        ONLINE  ONLINE       RAC1
ora.cssdmonitor
      1        ONLINE  ONLINE       RAC1
ora.ctssd
      1        ONLINE  ONLINE       RAC1                   ACTIVE:0
ora.diskmon
      1        OFFLINE OFFLINE
ora.evmd
      1        ONLINE  ONLINE       RAC1
ora.gipcd
      1        ONLINE  ONLINE       RAC1
ora.gpnpd
      1        ONLINE  ONLINE       RAC1
ora.mdnsd
      1        ONLINE  ONLINE       RAC1
*/

--On Node 2
[root@RAC1 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.LISTENER.lsnr
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
ora.OCRDR.dg
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
ora.asm
               ONLINE  ONLINE       RAC1                   Started
               ONLINE  ONLINE       RAC2                   Started
ora.gsd
               OFFLINE OFFLINE      RAC1
               OFFLINE OFFLINE      RAC2
ora.net1.network
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
ora.ons
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       RAC2
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       RAC1
ora.cvu
      1        ONLINE  ONLINE       RAC1
ora.oc4j
      1        ONLINE  ONLINE       RAC1
ora.RAC1.vip
      1        ONLINE  ONLINE       RAC1
ora.RAC2.vip
      1        ONLINE  ONLINE       RAC2
ora.scan1.vip
      1        ONLINE  ONLINE       RAC2
ora.scan2.vip
      1        ONLINE  ONLINE       RAC1
*/

[root@RAC1 bin]# ./ocrcheck
/*
Status of Oracle Cluster Registry is as follows :
         Version                  :          3
         Total space (kbytes)     :     262120
         Used space (kbytes)      :       2552
         Available space (kbytes) :     259568
         ID                       : 1320561932
         Device/File Name         :     +OCR
                                    Device/File integrity check succeeded

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

         Cluster registry integrity check succeeded

         Logical corruption check succeeded
		 
*/

--On both nodes 
[root@RAC1/RAC2 bin]# ./crsctl query css votedisk
/*
##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   264c7ee485ff4f4cbf3e97a6265eb3ed (ORCL:OCRDR) [OCR ]
Located 1 voting disk(s).
*/
-- Step 84 -->> On Node 1
[grid@RAC1 ~]$ asmcmd
ASMCMD> lsdg
/*
State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  4194304     20476    20044                0           20044              0             Y  OCR/


*/
ASMCMD> exit

-- Step 85 -->> On Node 2
[grid@RAC2 ~]$ asmcmd
ASMCMD> lsdg
/*

State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  4194304     20476    20044                0           20044              0             Y  OCR/

*/
ASMCMD> exit


-- Step 86-->> On Node 1
-- Login as oracle user and issu the following command at RAC1 
[oracle@RAC1 ~]$ hostname
/*
RAC1.mydomain
*/
[oracle@RAC1 ~]$ xhost + RAC1.mydomain
/*
RAC1.mydomain being added to access control list
*/

-- Step 87 -->> On Node 1
-- Install database software only => Real Application Cluster database installation
-- Make sure choose proper groups while installing oracle
-- OSDBA  Group => dba
-- OSOPER Group => oper
[oracle@SDB-RAC1 ~]$ cd /opt/app/oracle/product/11.2.0.3.0/db_1/database/
[oracle@RAC1 oracle]$ sh ./runInstaller 

-- Step 88 -->> On Both Nodes
-- Run from root user to finalized the setup for both racs
[root@RAC1/RAC2 ~]# /opt/app/oracle/product/11.2.0.3.0/db_1/root.sh

-- Step 89 -->> On Node 1
--To add DATADR and FRADR storage
[grid@RAC1 ~]# cd /opt/app/11.2.0.3.0/grid/bin
[grid@RAC1 bin]# ./asmca


-- Step 94 -->> On Both Nodes
[root@RAC1/RAC2 ~]# su - grid
[grid@RAC1/RAC2 ~]$ asmcmd
ASMCMD> lsdg
/*
State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  1048576     40959    40864                0           40864              0             N  DATA/
MOUNTED  EXTERN  N         512   4096  1048576     25023    24928                0           24928              0             N  FRA/
MOUNTED  EXTERN  N         512   4096  4194304     20476    20044                0           20044              0             Y  OCRDR/
ASMCMD>
*/
-- Verify from /etc/oratab configuration level
[root@RAC1~]# vi /etc/oratab
/*
+ASM1:/opt/app/11.2.0.3.0/grid:N                # line added by Agent
*/

-- Verify from /etc/oratab configuration level
[root@RAC2 ~]# vi /etc/oratab
/*
+ASM2:/opt/app/11.2.0.3.0/grid:N                # line added by Agent
*/

-- Step 95-->> On Standby (DR) Database Servers
[oracle@rac_sdb ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 20-JAN-2023 10:27:30

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                20-JAN-2023 09:45:09
Uptime                    0 days 0 hr. 42 min. 21 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3.0/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/RAC1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.21)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.23)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

-- Step 96 -->> On Primary (DC) Database Servers
[oracle@RAC1 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 20-JAN-2023 12:49:55

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                20-JAN-2023 12:26:00
Uptime                    0 days 0 hr. 23 min. 54 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3.0/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/RAC1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.11)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.13)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
The command completed successfully

*/

-- Step 97 -->> On Primary (DC) Database Servers
[oracle@RAC1 ~]$ sqlplus sys/sys as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jan 20 12:52:40 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

SQL>  SELECT status, instance_name FROM gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
OPEN         racdb1
OPEN         racdb2



SQL> select file_name from dba_data_files;

FILE_NAME
--------------------------------------------------------------------------------
+DATA/racdb/datafile/users.272.1124715969
+DATA/racdb/datafile/undotbs1.271.1124715969
+DATA/racdb/datafile/sysaux.270.1124715969
+DATA/racdb/datafile/system.269.1124715967
+DATA/racdb/datafile/example.277.1124716053
+DATA/racdb/datafile/undotbs2.278.1124716135
exit
*/

-- Step 98 -->> On Primary (DC) Database Servers
[oracle@RAC1 ~]$ which srvctl
/*
/opt/app/oracle/product/11.2.0.3.0/db_1/bin/srvctl
*/
[oracle@RAC1 ~]$ srvctl stop database -d racdb
[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is not running on node rac1
Instance racdb2 is not running on node rac2
*/
[oracle@RAC1 ~]$ srvctl start database -d racdb -o mount
[oracle@RAC1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jan 20 13:03:19 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options
SQL> select status, instance_name from gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
MOUNTED      racdb1
MOUNTED      racdb2

SQL> alter database archivelog;

Database altered.
SQL> exit

*/
[oracle@RAC1 ~]$ srvctl stop database -d racdb
[oracle@RAC1 ~]$ srvctl start database -d racdb
[oracle@RAC1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jan 20 13:08:02 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

SQL> select status, instance_name from gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
OPEN         racdb1
OPEN         racdb2

SQL> archive log list;
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     24
Next log sequence to archive   25
Current log sequence           25

SQL> alter system switch logfile;

System altered.

SQL>
SQL> /

System altered.

SQL> archive log list;
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     26
Next log sequence to archive   27
Current log sequence           27

*/

-- For disabling archive mode also steps are same (If you want)
/*
srvctl stop database -d racdb
srvctl start database -d racdb -o mount
alter database noarchivelog;
srvctl stop database -d racdb
srvctl start database -d racdb
*/

-- Step 99 -->> On Primary (DC) Database Servers
[oracle@RAC1 ~]$ cd /opt/app/11.2.0.3.0/grid/bin/
[oracle@RAC1 bin]$
[oracle@RAC1 bin]$ ./crsctl check cluster -all
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

[oracle@RAC1 bin]$ ./crsctl check crs
/*
CRS-4638: Oracle High Availability Services is online
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
*/

[oracle@RAC1 bin]$ ./crsctl stat res -t -init
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

[oracle@RAC1 bin]$ ./crsctl stat res -t
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
*/

[oracle@RAC1 bin]$ which srvctl
/*
/opt/app/oracle/product/11.2.0.3.0/db_1/bin/srvctl
*/

[oracle@RAC1 bin]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/
-- Step 100 -->> On Standby (DR) Database Servers
/*
[grid@RAC1 bin]$ ./crsctl check cluster -all
**************************************************************
RAC1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
RAC2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
*/
[grid@RAC1 bin]$ ./crsctl check crs
/*
CRS-4638: Oracle High Availability Services is online
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online

*/
[grid@RAC1 bin]$ ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       RAC1                   Started
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       RAC1
ora.crf
      1        ONLINE  ONLINE       RAC1
ora.crsd
      1        ONLINE  ONLINE       RAC1
ora.cssd
      1        ONLINE  ONLINE       RAC1
ora.cssdmonitor
      1        ONLINE  ONLINE       RAC1
ora.ctssd
      1        ONLINE  ONLINE       RAC1                   ACTIVE:0
ora.diskmon
      1        OFFLINE OFFLINE
ora.evmd
      1        ONLINE  ONLINE       RAC1
ora.gipcd
      1        ONLINE  ONLINE       RAC1
ora.gpnpd
      1        ONLINE  ONLINE       RAC1
ora.mdnsd
      1        ONLINE  ONLINE       RAC1

*/

[grid@RAC1 bin]$ ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.DATADR.dg
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
ora.FRADR.dg
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
ora.LISTENER.lsnr
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
ora.OCRDR.dg
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
ora.asm
               ONLINE  ONLINE       RAC1                   Started
               ONLINE  ONLINE       RAC2                   Started
ora.gsd
               OFFLINE OFFLINE      RAC1
               OFFLINE OFFLINE      RAC2
ora.net1.network
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
ora.ons
               ONLINE  ONLINE       RAC1
               ONLINE  ONLINE       RAC2
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       RAC2
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       RAC1
ora.cvu
      1        ONLINE  ONLINE       RAC1
ora.oc4j
      1        ONLINE  ONLINE       RAC1
ora.RAC1.vip
      1        ONLINE  ONLINE       RAC1
ora.RAC2.vip
      1        ONLINE  ONLINE       RAC2
ora.scan1.vip
      1        ONLINE  ONLINE       RAC2
ora.scan2.vip
      1        ONLINE  ONLINE       RAC1
*/

[oracle@RAC1 bin]$ which srvctl
/*
/opt/app/11.2.0.3.0/grid/bin/srvctl

*/

[oracle@RAC1 bin]$ srvctl status database -d racdr
/*
PRCD-1120 : The resource for database racdr could not be found.
PRCR-1001 : Resource ora.racdr.db does not exist
*/

--Step 101 -->> On Primary (DC) Database Servers
-- Enable Force Logging.
[oracle@RAC1 ~]$ which srvctl
/*
/opt/app/oracle/product/11.2.0.3.0/db_1/bin/srvctl
*/
[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2

SQL> SELECT name, open_mode,force_logging FROM gv$database;

NAME      OPEN_MODE            FOR
--------- -------------------- ---
RACDB     READ WRITE           NO
RACDB     READ WRITE           NO

SQL> ALTER DATABASE FORCE LOGGING;

Database altered.

SQL> SELECT name, open_mode,force_logging FROM gv$database;

NAME      OPEN_MODE            FOR
--------- -------------------- ---
RACDB     READ WRITE           YES
RACDB     READ WRITE           YES
*/

--Step 102 -->> On Primary (DC) Database Servers
-- Configure a Standby Redo Log on Primary
[oracle@RAC1 admin]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jan 20 14:57:09 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options


SQL> SELECT group#,thread#,bytes FROM gv$log;

    GROUP#    THREAD#      BYTES
---------- ---------- ----------
         1          1   52428800
         2          1   52428800
         3          2   52428800
         4          2   52428800
         1          1   52428800
         2          1   52428800
         3          2   52428800
         4          2   52428800
		 
		 
SQL> SELECT b.thread#, a.group#,a.type, a.member, b.bytes FROM gv$logfile a, gv$log b WHERE a.group# = b.group# order by 2;

   THREAD#     GROUP# TYPE    MEMBER                                                    BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         1          1 ONLINE  +FRA/racdb/onlinelog/group_1.264.1124716043                    52428800
         1          1 ONLINE  +DATA/racdb/onlinelog/group_1.274.1124716043                   52428800
         1          1 ONLINE  +FRA/racdb/onlinelog/group_1.264.1124716043                    52428800
         1          1 ONLINE  +DATA/racdb/onlinelog/group_1.274.1124716043                   52428800
         1          1 ONLINE  +FRA/racdb/onlinelog/group_1.264.1124716043                    52428800
         1          1 ONLINE  +DATA/racdb/onlinelog/group_1.274.1124716043                   52428800
         1          1 ONLINE  +FRA/racdb/onlinelog/group_1.264.1124716043                    52428800
         1          1 ONLINE  +DATA/racdb/onlinelog/group_1.274.1124716043                   52428800
         1          2 ONLINE  +DATA/racdb/onlinelog/group_2.275.1124716043                   52428800
         1          2 ONLINE  +FRA/racdb/onlinelog/group_2.265.1124716045                    52428800
         1          2 ONLINE  +DATA/racdb/onlinelog/group_2.275.1124716043                   52428800

   THREAD#     GROUP# TYPE    MEMBER                                                    BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         1          2 ONLINE  +FRA/racdb/onlinelog/group_2.265.1124716045                    52428800
         1          2 ONLINE  +DATA/racdb/onlinelog/group_2.275.1124716043                   52428800
         1          2 ONLINE  +FRA/racdb/onlinelog/group_2.265.1124716045                    52428800
         1          2 ONLINE  +DATA/racdb/onlinelog/group_2.275.1124716043                   52428800
         1          2 ONLINE  +FRA/racdb/onlinelog/group_2.265.1124716045                    52428800
         2          3 ONLINE  +FRA/racdb/onlinelog/group_3.266.1124716165                    52428800
         2          3 ONLINE  +DATA/racdb/onlinelog/group_3.279.1124716165                   52428800
         2          3 ONLINE  +FRA/racdb/onlinelog/group_3.266.1124716165                    52428800
         2          3 ONLINE  +DATA/racdb/onlinelog/group_3.279.1124716165                   52428800
         2          3 ONLINE  +FRA/racdb/onlinelog/group_3.266.1124716165                    52428800
         2          3 ONLINE  +DATA/racdb/onlinelog/group_3.279.1124716165                   52428800

   THREAD#     GROUP# TYPE    MEMBER                                                    BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         2          3 ONLINE  +FRA/racdb/onlinelog/group_3.266.1124716165                    52428800
         2          3 ONLINE  +DATA/racdb/onlinelog/group_3.279.1124716165                   52428800
         2          4 ONLINE  +FRA/racdb/onlinelog/group_4.267.1124716165                    52428800
         2          4 ONLINE  +DATA/racdb/onlinelog/group_4.280.1124716165                   52428800
         2          4 ONLINE  +FRA/racdb/onlinelog/group_4.267.1124716165                    52428800
         2          4 ONLINE  +DATA/racdb/onlinelog/group_4.280.1124716165                   52428800
         2          4 ONLINE  +FRA/racdb/onlinelog/group_4.267.1124716165                    52428800
         2          4 ONLINE  +DATA/racdb/onlinelog/group_4.280.1124716165                   52428800
         2          4 ONLINE  +FRA/racdb/onlinelog/group_4.267.1124716165                    52428800
         2          4 ONLINE  +DATA/racdb/onlinelog/group_4.280.1124716165                   52428800



SQL> SELECT group#, archived, status FROM v$log;

    GROUP# ARC STATUS
---------- --- ----------------
         1 NO  CURRENT
         2 YES INACTIVE
         3 YES INACTIVE
         4 NO  CURRENT


*/
--Step 103
--if you don’t find any standby redologs then add the standby redo logs with 1 extra redo logs group on each thread.
[oracle@RAC1 ~]$ sqlplus / as sysdba
/*

SQL*Plus: Release 11.2.0.3.0 Production on Mon Jan 23 15:39:31 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

SQL> SELECT t.INSTANCE, l.THREAD#, l.GROUP#,  l.SEQUENCE#, l.bytes, l.archived, l.status, lf.MEMBER FROM v$log l, v$logfile lf, v$thread t WHERE t.THREAD# = l.THREAD# AND l.GROUP# = lf.GROUP# ORDER BY l.THREAD#, GROUP#;

INSTANCE    THREAD#     GROUP#  SEQUENCE#      BYTES ARC STATUS           MEMBER
-------- ---------- ---------- ---------- ---------- --- ---------------- --------------------------------------------------
racdb1            1          1         31   52428800 NO  CURRENT          +FRA/racdb/onlinelog/group_1.264.1124716043
racdb1            1          1         31   52428800 NO  CURRENT          +DATA/racdb/onlinelog/group_1.274.1124716043
racdb1            1          2         30   52428800 YES INACTIVE         +FRA/racdb/onlinelog/group_2.265.1124716045
racdb1            1          2         30   52428800 YES INACTIVE         +DATA/racdb/onlinelog/group_2.275.1124716043
racdb2            2          3         21   52428800 NO  CURRENT          +DATA/racdb/onlinelog/group_3.279.1124716165
racdb2            2          3         21   52428800 NO  CURRENT          +FRA/racdb/onlinelog/group_3.266.1124716165
racdb2            2          4         20   52428800 YES INACTIVE         +DATA/racdb/onlinelog/group_4.280.1124716165
racdb2            2          4         20   52428800 YES INACTIVE         +FRA/racdb/onlinelog/group_4.267.1124716165

SQL> col member format a50
SQL> select GROUP#,THREAD#,SEQUENCE#,bytes/1024/1024,MEMBERS,STATUS from v$log;

    GROUP#    THREAD#  SEQUENCE# BYTES/1024/1024    MEMBERS STATUS
---------- ---------- ---------- --------------- ---------- ----------------
         1          1         31              50          2 CURRENT
         2          1         30              50          2 INACTIVE
         3          2         21              50          2 CURRENT
         4          2         20              50          2 INACTIVE


SQL>alter database add standby logfile thread 1 group 5 ('+DATA', '+FRA') SIZE 50M;
SQL>alter database add standby logfile thread 1 group 6 ('+DATA', '+FRA') SIZE 50M;
SQL>alter database add standby logfile thread 1 group 7 ('+DATA', '+FRA') SIZE 50M;
SQL>alter database add standby logfile thread 1 group 8 ('+DATA', '+FRA') SIZE 50M;
SQL>alter database add standby logfile thread 1 group 9 ('+DATA', '+FRA') SIZE 50M;

SQL>alter database add standby logfile thread 2  ('+DATA', '+FRA') SIZE 50M;
SQL>alter database add standby logfile thread 2  ('+DATA', '+FRA') SIZE 50M;
SQL>alter database add standby logfile thread 2  ('+DATA', '+FRA') SIZE 50M;
SQL>alter database add standby logfile thread 2  ('+DATA', '+FRA') SIZE 50M;
SQL>alter database add standby logfile thread 2  ('+DATA', '+FRA') SIZE 50M;

SQL> SELECT b.thread#,a.group#, a.type, a.member, b.bytes FROM gv$logfile a, gv$standby_log b WHERE a.group# = b.group#;

   THREAD#     GROUP# TYPE    MEMBER                                               BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         1          5 STANDBY +FRA/racdb/onlinelog/group_5.288.1126952563               52428800
         1          5 STANDBY +DATA/racdb/onlinelog/group_5.281.1126952561              52428800
         1          5 STANDBY +FRA/racdb/onlinelog/group_5.288.1126952563               52428800
         1          5 STANDBY +DATA/racdb/onlinelog/group_5.281.1126952561              52428800
         1          6 STANDBY +FRA/racdb/onlinelog/group_6.289.1126952563               52428800
         1          6 STANDBY +DATA/racdb/onlinelog/group_6.282.1126952563              52428800
         1          6 STANDBY +FRA/racdb/onlinelog/group_6.289.1126952563               52428800
         1          6 STANDBY +DATA/racdb/onlinelog/group_6.282.1126952563              52428800
         1          7 STANDBY +FRA/racdb/onlinelog/group_7.290.1126952563               52428800
         1          7 STANDBY +DATA/racdb/onlinelog/group_7.283.1126952563              52428800
         1          7 STANDBY +FRA/racdb/onlinelog/group_7.290.1126952563               52428800

   THREAD#     GROUP# TYPE    MEMBER                                               BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         1          7 STANDBY +DATA/racdb/onlinelog/group_7.283.1126952563              52428800
         1          8 STANDBY +FRA/racdb/onlinelog/group_8.291.1126952565               52428800
         1          8 STANDBY +DATA/racdb/onlinelog/group_8.284.1126952565              52428800
         1          8 STANDBY +FRA/racdb/onlinelog/group_8.291.1126952565               52428800
         1          8 STANDBY +DATA/racdb/onlinelog/group_8.284.1126952565              52428800
         1          9 STANDBY +FRA/racdb/onlinelog/group_9.292.1126952565               52428800
         1          9 STANDBY +DATA/racdb/onlinelog/group_9.285.1126952565              52428800
         1          9 STANDBY +FRA/racdb/onlinelog/group_9.292.1126952565               52428800
         1          9 STANDBY +DATA/racdb/onlinelog/group_9.285.1126952565              52428800
         2         10 STANDBY +FRA/racdb/onlinelog/group_10.293.1126952769              52428800
         2         10 STANDBY +DATA/racdb/onlinelog/group_10.286.1126952769             52428800

   THREAD#     GROUP# TYPE    MEMBER                                               BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         2         10 STANDBY +FRA/racdb/onlinelog/group_10.293.1126952769              52428800
         2         10 STANDBY +DATA/racdb/onlinelog/group_10.286.1126952769             52428800
         2         11 STANDBY +FRA/racdb/onlinelog/group_11.294.1126952769              52428800
         2         11 STANDBY +DATA/racdb/onlinelog/group_11.287.1126952769             52428800
         2         11 STANDBY +FRA/racdb/onlinelog/group_11.294.1126952769              52428800
         2         11 STANDBY +DATA/racdb/onlinelog/group_11.287.1126952769             52428800
         2         12 STANDBY +FRA/racdb/onlinelog/group_12.295.1126952771              52428800
         2         12 STANDBY +DATA/racdb/onlinelog/group_12.288.1126952771             52428800
         2         12 STANDBY +FRA/racdb/onlinelog/group_12.295.1126952771              52428800
         2         12 STANDBY +DATA/racdb/onlinelog/group_12.288.1126952771             52428800
         2         13 STANDBY +FRA/racdb/onlinelog/group_13.296.1126952771              52428800

   THREAD#     GROUP# TYPE    MEMBER                                               BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         2         13 STANDBY +DATA/racdb/onlinelog/group_13.289.1126952771             52428800
         2         13 STANDBY +FRA/racdb/onlinelog/group_13.296.1126952771              52428800
         2         13 STANDBY +DATA/racdb/onlinelog/group_13.289.1126952771             52428800
         2         14 STANDBY +FRA/racdb/onlinelog/group_14.297.1126952771              52428800
         2         14 STANDBY +DATA/racdb/onlinelog/group_14.290.1126952771             52428800
         2         14 STANDBY +FRA/racdb/onlinelog/group_14.297.1126952771              52428800
         2         14 STANDBY +DATA/racdb/onlinelog/group_14.290.1126952771             52428800
         1          5 STANDBY +FRA/racdb/onlinelog/group_5.288.1126952563               52428800
         1          5 STANDBY +DATA/racdb/onlinelog/group_5.281.1126952561              52428800
         1          5 STANDBY +FRA/racdb/onlinelog/group_5.288.1126952563               52428800
         1          5 STANDBY +DATA/racdb/onlinelog/group_5.281.1126952561              52428800

   THREAD#     GROUP# TYPE    MEMBER                                               BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         1          6 STANDBY +FRA/racdb/onlinelog/group_6.289.1126952563               52428800
         1          6 STANDBY +DATA/racdb/onlinelog/group_6.282.1126952563              52428800
         1          6 STANDBY +FRA/racdb/onlinelog/group_6.289.1126952563               52428800
         1          6 STANDBY +DATA/racdb/onlinelog/group_6.282.1126952563              52428800
         1          7 STANDBY +FRA/racdb/onlinelog/group_7.290.1126952563               52428800
         1          7 STANDBY +DATA/racdb/onlinelog/group_7.283.1126952563              52428800
         1          7 STANDBY +FRA/racdb/onlinelog/group_7.290.1126952563               52428800
         1          7 STANDBY +DATA/racdb/onlinelog/group_7.283.1126952563              52428800
         1          8 STANDBY +FRA/racdb/onlinelog/group_8.291.1126952565               52428800
         1          8 STANDBY +DATA/racdb/onlinelog/group_8.284.1126952565              52428800
         1          8 STANDBY +FRA/racdb/onlinelog/group_8.291.1126952565               52428800

   THREAD#     GROUP# TYPE    MEMBER                                               BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         1          8 STANDBY +DATA/racdb/onlinelog/group_8.284.1126952565              52428800
         1          9 STANDBY +FRA/racdb/onlinelog/group_9.292.1126952565               52428800
         1          9 STANDBY +DATA/racdb/onlinelog/group_9.285.1126952565              52428800
         1          9 STANDBY +FRA/racdb/onlinelog/group_9.292.1126952565               52428800
         1          9 STANDBY +DATA/racdb/onlinelog/group_9.285.1126952565              52428800
         2         10 STANDBY +FRA/racdb/onlinelog/group_10.293.1126952769              52428800
         2         10 STANDBY +DATA/racdb/onlinelog/group_10.286.1126952769             52428800
         2         10 STANDBY +FRA/racdb/onlinelog/group_10.293.1126952769              52428800
         2         10 STANDBY +DATA/racdb/onlinelog/group_10.286.1126952769             52428800
         2         11 STANDBY +FRA/racdb/onlinelog/group_11.294.1126952769              52428800
         2         11 STANDBY +DATA/racdb/onlinelog/group_11.287.1126952769             52428800

   THREAD#     GROUP# TYPE    MEMBER                                               BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         2         11 STANDBY +FRA/racdb/onlinelog/group_11.294.1126952769              52428800
         2         11 STANDBY +DATA/racdb/onlinelog/group_11.287.1126952769             52428800
         2         12 STANDBY +FRA/racdb/onlinelog/group_12.295.1126952771              52428800
         2         12 STANDBY +DATA/racdb/onlinelog/group_12.288.1126952771             52428800
         2         12 STANDBY +FRA/racdb/onlinelog/group_12.295.1126952771              52428800
         2         12 STANDBY +DATA/racdb/onlinelog/group_12.288.1126952771             52428800
         2         13 STANDBY +FRA/racdb/onlinelog/group_13.296.1126952771              52428800
         2         13 STANDBY +DATA/racdb/onlinelog/group_13.289.1126952771             52428800
         2         13 STANDBY +FRA/racdb/onlinelog/group_13.296.1126952771              52428800
         2         13 STANDBY +DATA/racdb/onlinelog/group_13.289.1126952771             52428800
         2         14 STANDBY +FRA/racdb/onlinelog/group_14.297.1126952771              52428800

   THREAD#     GROUP# TYPE    MEMBER                                               BYTES
---------- ---------- ------- ------------------------------------------------------------ ----------
         2         14 STANDBY +DATA/racdb/onlinelog/group_14.290.1126952771             52428800
         2         14 STANDBY +FRA/racdb/onlinelog/group_14.297.1126952771              52428800
         2         14 STANDBY +DATA/racdb/onlinelog/group_14.290.1126952771             52428800

80 rows selected.

*/
-- Run the below query in both the nodes of primary to find the newly added standby redlog files:

/*SQL> set lines 999 pages 999
col inst_id for 9999
col group# for 9999
col member for a60
col archived for a7SQL> SQL> SQL> SQL>
SQL>
SQL>
SQL> SELECT
     a.*
        FROM (SELECT
           '[ ONLINE REDO LOG ]'  redolog_file_type,
                a.inst_id  inst_id,
                   a.group#,
                b.thread#,
                b.sequence#,
               a.member,
            b.status,
                  b.archived,
               (b.BYTES/1024/1024) AS size_mb
      FROM gv$logfile a, gv$log b
            WHERE a.group#=b.group#
         and a.inst_id=b.inst_id
         and b.thread#=(SELECT value FROM v$parameter WHERE name = 'thread')
      and a.inst_id=( SELECT instance_number FROM v$instance)
            UNION
        SELECT
           '[ STANDBY REDO LOG ]' redolog_file_type,
                 a.inst_id,
              a.group#,
              b.thread#,
           b.sequence#,
                a.member,
           b.status,
                 b.archived,
           (b.bytes/1024/1024) size_mb
            FROM gv$logfile a, gv$standby_log b
        WHERE a.group#=b.group#
      and a.inst_id=b.inst_id
           and b.thread#=(SELECT value FROM v$parameter WHERE name = 'thread')
         and a.inst_id=( SELECT instance_number FROM v$instance)
    ) a
     ORDER BY 2,3;

REDOLOG_FILE_TYPE    INST_ID GROUP#    THREAD#  SEQUENCE# MEMBER                          STATUS            ARCHIVE    SIZE_MB
-------------------- ------- ------ ---------- ---------- ------------------------------------------------------------ ---------------- ------- ----------
[ ONLINE REDO LOG ]        1      1          1         33 +DATA/racdb/onlinelog/group_1.274.1124716043                     INACTIVE         YES             50
[ ONLINE REDO LOG ]        1      1          1         33 +FRA/racdb/onlinelog/group_1.264.1124716043                      INACTIVE         YES             50
[ ONLINE REDO LOG ]        1      2          1         34 +DATA/racdb/onlinelog/group_2.275.1124716043                     CURRENT          NO              50
[ ONLINE REDO LOG ]        1      2          1         34 +FRA/racdb/onlinelog/group_2.265.1124716045                      CURRENT          NO              50
[ STANDBY REDO LOG ]       1      5          1          0 +DATA/racdb/onlinelog/group_5.281.1126952561                     UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      5          1          0 +FRA/racdb/onlinelog/group_5.288.1126952563                      UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      6          1          0 +DATA/racdb/onlinelog/group_6.282.1126952563                     UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      6          1          0 +FRA/racdb/onlinelog/group_6.289.1126952563                      UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      7          1          0 +DATA/racdb/onlinelog/group_7.283.1126952563                     UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      7          1          0 +FRA/racdb/onlinelog/group_7.290.1126952563                      UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      8          1          0 +DATA/racdb/onlinelog/group_8.284.1126952565                     UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      8          1          0 +FRA/racdb/onlinelog/group_8.291.1126952565                      UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      9          1          0 +DATA/racdb/onlinelog/group_9.285.1126952565                     UNASSIGNED       YES             50
[ STANDBY REDO LOG ]       1      9          1          0 +FRA/racdb/onlinelog/group_9.292.1126952565                      UNASSIGNED       YES             50

14 rows selected.

*/

--Step 104 -->> On Primary (DC) Database Servers
-- SET Primary Database Initialization Parameters
-- Now, verify all the required values have the appropriate values.
[oracle@RAC1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Tue Jan 24 10:17:15 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Real Application Clusters and Automatic Storage Management options

SQL> set lines 999 pages 999
SQL> col name for a40
SQL> col value for a50
SQL> SELECT
         name,value
         FROM v$parameter
         WHERE name IN ('db_name','db_unique_name','log_archive_config', 'log_archive_dest_1','log_archive_dest_2','log_archive_dest_state_1','log_archive_dest_state_2',
         'remote_login_passwordfile','log_archive_format','log_archive_max_processes','fal_server','fal_client','standby_file_management',
         'db_file_name_convert','log_file_name_convert','audit_file_dest');

NAME                                     VALUE
---------------------------------------- --------------------------------------------------
db_file_name_convert
log_file_name_convert
log_archive_dest_1
log_archive_dest_2
log_archive_dest_state_1                 enable
log_archive_dest_state_2                 enable
fal_client
fal_server
log_archive_config
log_archive_format                       %t_%s_%r.dbf
log_archive_max_processes                4
standby_file_management                  MANUAL
remote_login_passwordfile                EXCLUSIVE
audit_file_dest                          /opt/app/oracle/admin/racdb/adump
db_name                                  racdb
db_unique_name                           racdb

SQL> ALTER system SET db_unique_name='racdb' scope=spfile sid='*';

System altered.
SQL> ALTER system SET log_archive_config='DG_CONFIG=(racdb,racdr)' scope=both sid='*';
System altered.

SQL> ALTER system SET log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=racdb' scope=both sid='*';
System altered.
SQL> ALTER system SET LOG_ARCHIVE_DEST_2='SERVICE=racdr VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=racdr' scope=both sid='*';
System altered.

SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_1=ENABLE scope=both sid='*';
System altered.

SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=ENABLE scope=both sid='*';
System altered.

SQL> ALTER system SET log_archive_format='racdb_%t_%s_%r.arc' scope=spfile sid='*';
System altered.

SQL> ALTER system SET LOG_ARCHIVE_MAX_PROCESSES=8 scope=both sid='*';
System altered.

SQL> ALTER system SET REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE scope=spfile sid='*';
System altered.

SQL> ALTER SYSTEM SET fal_client='racdb' scope=both;
System altered.

SQL> ALTER system SET fal_server = 'racdr' sid='*';
System altered.

SQL> ALTER system SET STANDBY_FILE_MANAGEMENT=AUTO scope=spfile sid='*';
System altered.

SQL> ALTER system SET db_file_name_convert='+DATA/racdb/','+DATADR/racdr/', '+FRA/racdb/','+FRADR/racdr/' scope=spfile sid='*';
System altered.

SQL> ALTER system SET log_file_name_convert='+DATA/racdb/','+DATADR/racdr/', '+FRA/racdb/','+FRADR/racdr/' scope=spfile sid='*';

SQL> exit
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options
System altered.
*/

--Step 105 -->> On Primary (DC) Database Servers
-- Reboot the Server to set Intial parameter
[oracle@RAC1 ~]$ which srvctl
/opt/app/oracle/product/11.2.0.3.0/db_1/bin/srvctl
[oracle@RAC1 ~]$ srvctl stop database -d racdb
srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/

--Step 106 -->> On Primary (DC) Database Servers
-- Verify the Intial parameter
/*
SQL*Plus: Release 11.2.0.3.0 Production on Tue Jan 24 12:01:37 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

SQL> set lines 999 pages 999
SQL> col name for a40
SQL> col value for a100

SQL> SELECT
          name,
          value
     FROM v$parameter
     WHERE name IN ('db_name','db_unique_name','log_archive_config', 'log_archive_dest_1','log_archive_dest_2','log_archive_dest_state_1','log_archive_dest_state_2',
     'remote_login_passwordfile','log_archive_format','log_archive_max_processes','fal_server','fal_client','standby_file_management',
     'db_file_name_convert','log_file_name_convert','audit_file_dest');
	 NAME                                     VALUE
---------------------------------------- ----------------------------------------------------------------------------------------------------
db_file_name_convert                     +DATA/racdb/, +DATADR/racdr/, +FRA/racdb/, +FRADR/racdr/
log_file_name_convert                    +DATA/racdb/, +DATADR/racdr/, +FRA/racdb/, +FRADR/racdr/
log_archive_dest_1                       LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=racdb
log_archive_dest_2                       SERVICE=racdr VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=racdr
log_archive_dest_state_1                 ENABLE
log_archive_dest_state_2                 ENABLE
fal_client                               racdb
fal_server                               racdr
log_archive_config                       DG_CONFIG=(racdb,racdr)
log_archive_format                       racdb_%t_%s_%r.arc
log_archive_max_processes                8
standby_file_management                  AUTO
remote_login_passwordfile                EXCLUSIVE
audit_file_dest                          /opt/app/oracle/admin/racdb/adump
db_name                                  racdb
db_unique_name                           racdb

SQL> CREATE PFILE='/home/oracle/backup/spfileracdb.ora' FROM SPFILE;
SQL> exit
*/

--Step 107 -->> On Primary (DC) Database Servers
-- Verfy the parameter file
[oracle@RAC1 backup]$ ls
spfileracdb.ora  spfileracdb.ora.bkp
[oracle@RAC1 backup]$ cat spfileracdb.ora
/*
racdb1.__db_cache_size=536870912
racdb2.__db_cache_size=570425344
racdb1.__java_pool_size=16777216
racdb2.__java_pool_size=16777216
racdb1.__large_pool_size=16777216
racdb2.__large_pool_size=16777216
racdb1.__oracle_base='/opt/app/oracle'#ORACLE_BASE set from environment
racdb2.__oracle_base='/opt/app/oracle'#ORACLE_BASE set from environment
racdb1.__pga_aggregate_target=637534208
racdb2.__pga_aggregate_target=637534208
racdb1.__sga_target=922746880
racdb2.__sga_target=922746880
racdb1.__shared_io_pool_size=0
racdb2.__shared_io_pool_size=0
racdb1.__shared_pool_size=335544320
racdb2.__shared_pool_size=301989888
racdb1.__streams_pool_size=0
racdb2.__streams_pool_size=0
*.audit_file_dest='/opt/app/oracle/admin/racdb/adump'
*.audit_trail='db'
*.cluster_database=true
*.compatible='11.2.0.0.0'
*.control_files='+DATA/racdb/controlfile/current.273.1124716041','+FRA/racdb/controlfile/current.263.1124716041'
*.db_block_size=8192
*.db_create_file_dest='+DATA'
*.db_domain=''
*.db_file_name_convert='+DATA/racdb/','+DATADR/racdr/','+FRA/racdb/','+FRADR/racdr/'
*.db_name='racdb'
*.db_recovery_file_dest='+FRA'
*.db_recovery_file_dest_size=4558159872
*.db_unique_name='racdb'
*.diagnostic_dest='/opt/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=racdbXDB)'
*.fal_client='racdb'
*.fal_server='racdr'
racdb2.instance_number=2
racdb1.instance_number=1
*.job_queue_processes=1000
*.log_archive_config='DG_CONFIG=(racdb,racdr)'
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=racdb'
*.log_archive_dest_2='SERVICE=racdr VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=racdr'
*.log_archive_dest_state_1='ENABLE'
*.log_archive_dest_state_2='ENABLE'
*.log_archive_format='racdb_%t_%s_%r.arc'
*.log_archive_max_processes=8
*.log_file_name_convert='+DATA/racdb/','+DATADR/racdr/','+FRA/racdb/','+FRADR/racdr/'
*.memory_target=1547698176
*.open_cursors=300
*.processes=150
*.remote_listener='RAC-scan.mydomain:1521'
*.remote_login_passwordfile='exclusive'
*.standby_file_management='AUTO'
racdb2.thread=2
racdb1.thread=1
racdb2.undo_tablespace='UNDOTBS2'
racdb1.undo_tablespace='UNDOTBS1'
*/


--Step 108-->> On Primary (DC) Database Servers
-- Backup the primary database that includes backup of datafiles, archivelogs and controlfile for standby
[oracle@RAC1 backup]$ rman target /
/*
Recovery Manager: Release 11.2.0.3.0 - Production on Tue Jan 24 12:30:56 2023

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: RACDB (DBID=1122332808)

RMAN> run
{
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK MAXPIECESIZE 10G;
  ALLOCATE CHANNEL c2 DEVICE TYPE DISK MAXPIECESIZE 10G;
  ALLOCATE CHANNEL c3 DEVICE TYPE DISK MAXPIECESIZE 10G;
  ALLOCATE CHANNEL c4 DEVICE TYPE DISK MAXPIECESIZE 10G;
  SQL "ALTER SYSTEM SWITCH LOGFILE";
  BACKUP DATABASE FORMAT '/home/oracle/backup/database_%d_%u_%s';
  SQL "ALTER SYSTEM ARCHIVE LOG CURRENT";
  BACKUP ARCHIVELOG ALL FORMAT '/home/oracle/backup/arch_%d_%u_%s';
  BACKUP CURRENT CONTROLFILE FOR STANDBY FORMAT '/home/oracle/backup/Control_%d_%u_%s';
  release channel c1;
  release channel c2;
  release channel c3;
  release channel c4;
}

*/

--Step 109 -->> On Primary (DC) Database Servers
-- Transfer PASSWORD FILE TO STANDBY SIDE
[oracle@RAC1/RAC2 ~]$ cd /opt/app/oracle/product/11.2.0.3.0/db_1/dbs/
[oracle@RAC1 dbs]$ ls -lrt
/*
total 18112
-rw-r--r-- 1 oracle oinstall     2851 May 15  2009 init.ora
-rw-r----- 1 oracle oinstall       37 Dec 29 13:09 initracdb1.ora
-rw-r----- 1 oracle oinstall     1536 Dec 29 15:12 orapwracdb1
-rw-rw---- 1 oracle asmadmin     1544 Jan 24 12:00 hc_racdb1.dat
-rw-r----- 1 oracle asmadmin 18530304 Jan 24 12:34 snapcf_racdb1.f
*/

[oracle@RAC1 dbs]$ scp orapwracdb1 oracle@192.168.120.21:/opt/app/oracle/product/11.2.0.3.0/db_1/dbs/

/* The authenticity of host '192.168.120.21 (192.168.120.21)' can't be established.
RSA key fingerprint is db:b7:69:ca:58:cd:9e:31:c7:d8:ac:81:b3:20:6f:fd.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.120.21' (RSA) to the list of known hosts.
oracle@192.168.120.21's password:
orapwracdb1

*/
[oracle@RAC2 dbs]$ scp orapwracdb2 oracle@192.168.120.22:/opt/app/oracle/product/11.2.0.3.0/db_1/dbs/
/*
The authenticity of host '192.168.120.22 (192.168.120.22)' can't be established.
RSA key fingerprint is db:b7:69:ca:58:cd:9e:31:c7:d8:ac:81:b3:20:6f:fd.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.120.22' (RSA) to the list of known hosts.
oracle@192.168.120.22's password:
orapwracdb2                               100% 1536     1.5KB/s   00:00
*/

--Step 110 -->> On Primary (DC) Database Servers
-- Transfer Backup FROM Primary to Standby

[oracle@RAC1 backup]$ scp -p /home/oracle/backup/* oracle@192.168.120.21:/home/oracle/backup/
/*
oracle@192.168.120.21's password:
arch_RACDB_061io39k_6                             100%   50MB  49.9MB/s   00:01
arch_RACDB_071io39k_7                             100%   40MB  40.0MB/s   00:01
arch_RACDB_081io39l_8                             100% 3944KB   3.9MB/s   00:00
arch_RACDB_091io39m_9                             100%   12MB  12.0MB/s   00:00
arch_RACDB_0a1io39m_10                            100% 4096     4.0KB/s   00:00
Control_RACDB_0b1io39o_11                         100%   18MB  17.7MB/s   00:01
database_RACDB_021io38s_2                         100%  613MB  51.1MB/s   00:12
database_RACDB_031io38s_3                         100%   71MB  35.7MB/s   00:02
database_RACDB_041io38t_4                         100%  449MB  49.9MB/s   00:09
spfileracdb.ora                                   100% 2150     2.1KB/s   00:00
spfileracdb.ora.bkp                               100% 2150     2.1KB/s   00:00

*/

--Step 111 -->> On Primary (DC) Database Servers
-- Configure TNS for Primary
-- Now we need to modify/update $ORACLE_HOME/network/admin/tnsnames.ora file on primary node 1 as shown an example below

[oracle@RAC1 admin]$ cat tnsnames.ora
/*
# tnsnames.ora Network Configuration File: /opt/app/oracle/product/11.2.0.3.0/db_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

RACDB =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = RAC-scan.mydomain)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACDR =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = RACDR-scan.mydomain)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdr)
    )
  )
 
 */
  
[oracle@RAC1 admin]$ scp tnsnames.ora oracle@192.168.120.21:/opt/app/oracle/product/11.2.0.3.0/db_1/network/admin/

/*
oracle@192.168.120.21's password:
tnsnames.ora                                      100%  580     0.6KB/s   00:00
[oracle@RAC1 admin]$ scp tnsnames.ora oracle@192.168.120.22:/opt/app/oracle/product/11.2.0.3.0/db_1/network/admin/
The authenticity of host '192.168.120.22 (192.168.120.22)' can't be established.
RSA key fingerprint is db:b7:69:ca:58:cd:9e:31:c7:d8:ac:81:b3:20:6f:fd.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.120.22' (RSA) to the list of known hosts.
oracle@192.168.120.22's password:
tnsnames.ora                                      100%  580     0.6KB/s   00:00
[oracle@RAC1 admin]$ scp tnsnames.ora oracle@192.168.120.12:/opt/app/oracle/product/11.2.0.3.0/db_1/network/admin/
tnsnames.ora                                      100%  580     0.6KB/s   00:00

*/

--Step 112 -->> On Secondary (DR) Database Servers
-- Verify the TNS
[oracle@RAC1 ~]$ tnsping RACDR
/*
TNS Ping Utility for Linux: Version 11.2.0.3.0 - Production on 24-JAN-2023 14:43:02

Copyright (c) 1997, 2011, Oracle.  All rights reserved.

Used parameter files:


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = RACDR-scan.mydomain)(PORT = 1521))) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = racdr)))
OK (0 msec)
*/
[oracle@RAC1 ~]$ tnsping RACDB
/*
TNS Ping Utility for Linux: Version 11.2.0.3.0 - Production on 24-JAN-2023 14:43:38

Copyright (c) 1997, 2011, Oracle.  All rights reserved.

Used parameter files:


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = RAC-scan.mydomain)(PORT = 1521))) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = racdb)))
OK (0 msec)
*/

--Step 113 -->> On Secondary (DR) Database Servers
-- Data Guard Configuration - Standby Site
-- Login to racdb_dr using oracle user and perform the following tasks to prepare Standby site data guard configuration.


[oracle@RAC1 ~]$ mkdir -p /opt/app/oracle/admin/racdb/hdump
[oracle@RAC1 ~]$ mkdir -p /opt/app/oracle/admin/racdb/dpdump
[oracle@RAC1 ~]$ mkdir -p /opt/app/oracle/admin/racdb/pfile
[oracle@RAC1 ~]$ mkdir -p /opt/app/oracle/admin/racdb/adump

--Step 114 -->> On Secondary (DR) Database Servers
-- Modified in our paramter file initracdb_dr.ora for standby database creation in a dataguard environment.
[oracle@RAC1 backup]$ vi spfileracdb.ora
/*
racdb1.__db_cache_size=536870912
racdb2.__db_cache_size=570425344
racdb1.__java_pool_size=16777216
racdb2.__java_pool_size=16777216
racdb1.__large_pool_size=16777216
racdb2.__large_pool_size=16777216
racdb1.__oracle_base='/opt/app/oracle'#ORACLE_BASE set from environment
racdb2.__oracle_base='/opt/app/oracle'#ORACLE_BASE set from environment
racdb1.__pga_aggregate_target=637534208
racdb2.__pga_aggregate_target=637534208
racdb1.__sga_target=922746880
racdb2.__sga_target=922746880
racdb1.__shared_io_pool_size=0
racdb2.__shared_io_pool_size=0
racdb1.__shared_pool_size=335544320
racdb2.__shared_pool_size=301989888
racdb1.__streams_pool_size=0
racdb2.__streams_pool_size=0
*.audit_file_dest='/opt/app/oracle/admin/racdb/adump'
*.audit_trail='db'
*.cluster_database=true
*.compatible='11.2.0.0.0'
*.control_files='+DATADR/racdb/controlfile/current.273.1124716041','+FRADR/racdb/controlfile/current.263.1124716041'
*.db_block_size=8192
*.db_create_file_dest='+DATADR'
*.db_domain=''
*.db_file_name_convert='+DATA/RACDB/','+DATADR/racdr/','+FRA/RACDB/','+FRADR/racdr/'
*.db_name='racdb'
*.db_recovery_file_dest='+FRADR'
*.db_recovery_file_dest_size=4558159872
*.db_unique_name='racdr'
*.diagnostic_dest='/opt/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=racdbXDB)'
*.fal_client='racdr'
*.fal_server='racdb'
racdb2.instance_number=2
racdb1.instance_number=1
*.job_queue_processes=1000
*.log_archive_config='DG_CONFIG=(racdb,racdr)'
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=racdr'
*.log_archive_dest_2='SERVICE=racdb VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=racdb'
*.log_archive_dest_state_1='ENABLE'
*.log_archive_dest_state_2='ENABLE'
*.log_archive_format='racdb_%t_%s_%r.arc'
*.log_archive_max_processes=8
*.log_file_name_convert='+DATA/RACDB/','+DATADR/racdr/','+FRA/RACDB/','+FRADR/racdr/'
*.memory_target=1547698176
*.open_cursors=300
*.processes=150
*.remote_listener='RAC-scan.mydomain:1521'
*.remote_login_passwordfile='exclusive'
*.standby_file_management='AUTO'
racdb2.thread=2
racdb1.thread=1
racdb2.undo_tablespace='UNDOTBS2'
racdb1.undo_tablespace='UNDOTBS1'

*/
--Step 115 -->> On Secondary (DR) Database Servers
-- Add oratab entry
[oracle@RAC1 backup]$ vi /etc/oratab
/*
# Multiple entries with the same $ORACLE_SID are not allowed.
#
#
+ASM1:/opt/app/11.2.0.3.0/grid:N                # line added by Agent
racdb1:/opt/app/oracle/product/11.2.0.3.0/db_1:N                # line added by Agent
racdb:/opt/app/oracle/product/11.2.0.3.0/db_1:N         # line added by Agent
*/

[root@RAC2 ~]# cat /etc/oratab
/*
+ASM2:/opt/app/11.2.0.3.0/grid:N                # line added by Agent
racdb2:/opt/app/oracle/product/11.2.0.3.0/db_1:N                # line added by Agent
racdb:/opt/app/oracle/product/11.2.0.3.0/db_1:N         # line added by Agent
*/
--Step 116 -->> On Secondary (DR) Database Servers
-- Modify the initracdb1 file

[oracle@RAC1/RAC2 dbs]$ vi initracdb1.ora
/*
SPFILE='+DATADR/racdr/spfileracdb.ora'
*/
--Step 117 -->> On Secondary (DR) Database Servers
-- Creating physical standby database
/*
[oracle@RAC1 ~]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.3.0 Production on Wed Jan 25 11:21:44 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup nomount pfile='/home/oracle/backup/spfileracdb.ora';
ORACLE instance started.

Total System Global Area 1553305600 bytes
Fixed Size                  2228664 bytes
Variable Size            1006636616 bytes
Database Buffers          536870912 bytes
Redo Buffers                7569408 bytes
SQL> SELECT status,instance_name FROM gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
STARTED      racdb1

SQL> show parameter db_unique_name;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_unique_name                       string      racdr

SQL> CREATE SPFILE ='+DATADR/racdr/spfileracdb.ora' FROM PFILE ='/home/oracle/backup/spfileracdb.ora';

File created.

SQL> shut immediate;
ORA-01507: database not mounted


ORACLE instance shut down.
SQL> startup nomount;
ORACLE instance started.

Total System Global Area 1553305600 bytes
Fixed Size                  2228664 bytes
Variable Size            1006636616 bytes
Database Buffers          536870912 bytes
Redo Buffers                7569408 bytes

*/

--Step 118 -->> On Secondary (DR) Database Servers
-- To Restore the backup
[oracle@RAC1 ~]$ ls -ltr /home/oracle/backup/
/*
-rw-r--r-- 1 oracle oinstall      2150 Jan 24 12:06 spfileracdb.ora.bkp
-rw-r--r-- 1 oracle oinstall      2150 Jan 25 10:10 spfileracdb.ora
-rw-r----- 1 oracle oinstall  52266496 Jan 25 12:11 arch_RACDB_0h1iqkrd_17
-rw-r----- 1 oracle oinstall  41975296 Jan 25 12:11 arch_RACDB_0i1iqkrd_18
-rw-r----- 1 oracle oinstall  16536576 Jan 25 12:11 arch_RACDB_0j1iqkre_19
-rw-r----- 1 oracle oinstall  51379200 Jan 25 12:11 arch_RACDB_0k1iqkrf_20
-rw-r----- 1 oracle oinstall   9478144 Jan 25 12:11 arch_RACDB_0l1iqkrf_21
-rw-r----- 1 oracle oinstall 642703360 Jan 25 12:11 database_RACDB_0d1iqkq2_13
-rw-r----- 1 oracle oinstall  74874880 Jan 25 12:11 database_RACDB_0e1iqkq3_14
-rw-r----- 1 oracle oinstall 476561408 Jan 25 12:11 database_RACDB_0f1iqkq3_15
-rw-r----- 1 oracle oinstall  18579456 Jan 25 12:11 Control_RACDB_0m1iqkrj_22

*/

[oracle@RAC1 backup]$ rman target /
/*
Recovery Manager: Release 11.2.0.3.0 - Production on Wed Jan 25 12:13:38 2023

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: RACDB (not mounted)

RMAN> RESTORE STANDBY CONTROLFILE FROM '/home/oracle/backup/Control_RACDB_0m1iqkrj_22';

Starting restore at 25-JAN-23
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=16 instance=racdb1 device type=DISK

channel ORA_DISK_1: restoring control file
channel ORA_DISK_1: restore complete, elapsed time: 00:00:03
output file name=+DATADR/racdr/controlfile/current.257.1127046457
output file name=+FRADR/racdr/controlfile/current.256.1127046457
Finished restore at 25-JAN-23

RMAN> SQL 'ALTER DATABASE MOUNT STANDBY DATABASE';

sql statement: ALTER DATABASE MOUNT STANDBY DATABASE
released channel: ORA_DISK_1
RMAN> exit
*/
--Step 119 -->> On Secondary (DR) Database Servers
-- Chage the permission and ownership
/*
[oracle@RAC1 backup]$ ls -lrt
total 1351932
-rw-r--r-- 1 oracle oinstall      2150 Jan 24 12:06 spfileracdb.ora.bkp
-rw-r----- 1 oracle oinstall  52266496 Jan 25 12:11 arch_RACDB_0h1iqkrd_17
-rw-r----- 1 oracle oinstall  41975296 Jan 25 12:11 arch_RACDB_0i1iqkrd_18
-rw-r----- 1 oracle oinstall  16536576 Jan 25 12:11 arch_RACDB_0j1iqkre_19
-rw-r----- 1 oracle oinstall  51379200 Jan 25 12:11 arch_RACDB_0k1iqkrf_20
-rw-r----- 1 oracle oinstall   9478144 Jan 25 12:11 arch_RACDB_0l1iqkrf_21
-rw-r----- 1 oracle oinstall 642703360 Jan 25 12:11 database_RACDB_0d1iqkq2_13
-rw-r----- 1 oracle oinstall  74874880 Jan 25 12:11 database_RACDB_0e1iqkq3_14
-rw-r----- 1 oracle oinstall 476561408 Jan 25 12:11 database_RACDB_0f1iqkq3_15
-rw-r----- 1 oracle oinstall  18579456 Jan 25 12:11 Control_RACDB_0m1iqkrj_22
-rw-r--r-- 1 oracle oinstall      2154 Jan 25 12:21 spfileracdb.ora

*/

[oracle@RAC1 backup]$ rm -rf spfileracdb.ora
[oracle@RAC1 backup]$ rm -rf spfileracdb.ora.bkp
[oracle@RAC1 backup]$ chmod -R 775 *
[oracle@RAC1 backup]$ ls -lrt
/*
total 1351924
-rwxrwxr-x 1 oracle oinstall  52266496 Jan 25 12:11 arch_RACDB_0h1iqkrd_17
-rwxrwxr-x 1 oracle oinstall  41975296 Jan 25 12:11 arch_RACDB_0i1iqkrd_18
-rwxrwxr-x 1 oracle oinstall  16536576 Jan 25 12:11 arch_RACDB_0j1iqkre_19
-rwxrwxr-x 1 oracle oinstall  51379200 Jan 25 12:11 arch_RACDB_0k1iqkrf_20
-rwxrwxr-x 1 oracle oinstall   9478144 Jan 25 12:11 arch_RACDB_0l1iqkrf_21
-rwxrwxr-x 1 oracle oinstall 642703360 Jan 25 12:11 database_RACDB_0d1iqkq2_13
-rwxrwxr-x 1 oracle oinstall  74874880 Jan 25 12:11 database_RACDB_0e1iqkq3_14
-rwxrwxr-x 1 oracle oinstall 476561408 Jan 25 12:11 database_RACDB_0f1iqkq3_15
-rwxrwxr-x 1 oracle oinstall  18579456 Jan 25 12:11 Control_RACDB_0m1iqkrj_22
*/
--Step 120 -->> On Secondary (DR) Database Servers
-- Restor the Database on Phiysiscal Statandby Database
[oracle@RAC1 backup]$ rman target /
/*
Recovery Manager: Release 11.2.0.3.0 - Production on Wed Jan 25 12:36:13 2023

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: RACDB (DBID=1122332808, not open)

RMAN> CATALOG START WITH '/home/oracle/backup/';

Starting implicit crosscheck backup at 25-JAN-23
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
allocated channel: ORA_DISK_2
allocated channel: ORA_DISK_3
allocated channel: ORA_DISK_4
Crosschecked 8 objects
Crosschecked 4 objects
Finished implicit crosscheck backup at 25-JAN-23

Starting implicit crosscheck copy at 25-JAN-23
using channel ORA_DISK_1
using channel ORA_DISK_2
using channel ORA_DISK_3
using channel ORA_DISK_4
Finished implicit crosscheck copy at 25-JAN-23

searching for all files in the recovery area
cataloging files...
no files cataloged

searching for all files that match the pattern /home/oracle/backup/

List of Files Unknown to the Database
=====================================
File Name: /home/oracle/backup/Control_RACDB_0m1iqkrj_22

Do you really want to catalog the above files (enter YES or NO)? yes
cataloging files...
cataloging done

List of Cataloged Files
=======================
File Name: /home/oracle/backup/Control_RACDB_0m1iqkrj_22

RMAN> LIST BACKUP OF ARCHIVELOG ALL;


List of Backup Sets
===================


BS Key  Size       Device Type Elapsed Time Completion Time
------- ---------- ----------- ------------ ---------------
17      49.84M     DISK        00:00:01     25-JAN-23
        BP Key: 17   Status: AVAILABLE  Compressed: NO  Tag: TAG20230125T114547
        Piece Name: /home/oracle/backup/arch_RACDB_0h1iqkrd_17

  List of Archived Logs in backup set 17
  Thrd Seq     Low SCN    Low Time  Next SCN   Next Time
  ---- ------- ---------- --------- ---------- ---------
  1    25      1746160    20-JAN-23 1755270    20-JAN-23
  1    26      1755270    20-JAN-23 1755329    20-JAN-23
  1    27      1755329    20-JAN-23 1788855    20-JAN-23
  1    28      1788855    20-JAN-23 1808927    22-JAN-23
  1    29      1808927    22-JAN-23 1846296    23-JAN-23
  2    15      1726142    20-JAN-23 1755333    20-JAN-23
  2    16      1755333    20-JAN-23 1788836    20-JAN-23
  2    17      1788836    20-JAN-23 1788838    20-JAN-23

BS Key  Size       Device Type Elapsed Time Completion Time
------- ---------- ----------- ------------ ---------------
18      40.03M     DISK        00:00:02     25-JAN-23
        BP Key: 18   Status: AVAILABLE  Compressed: NO  Tag: TAG20230125T114547
        Piece Name: /home/oracle/backup/arch_RACDB_0i1iqkrd_18

  List of Archived Logs in backup set 18
  Thrd Seq     Low SCN    Low Time  Next SCN   Next Time
  ---- ------- ---------- --------- ---------- ---------
  1    30      1846296    23-JAN-23 1866299    23-JAN-23
  1    31      1866299    23-JAN-23 1938982    23-JAN-23
  1    32      1938982    23-JAN-23 1939007    23-JAN-23
  1    33      1959025    24-JAN-23 1959344    24-JAN-23
  2    18      1814242    22-JAN-23 1819659    22-JAN-23
  2    19      1820289    23-JAN-23 1846270    23-JAN-23
  2    20      1846270    23-JAN-23 1846272    23-JAN-23
  2    21      1866375    23-JAN-23 1959024    24-JAN-23
  2    22      1959024    24-JAN-23 1959028    24-JAN-23
  2    23      1959028    24-JAN-23 1959030    24-JAN-23
  2    24      1959030    24-JAN-23 1959103    24-JAN-23

BS Key  Size       Device Type Elapsed Time Completion Time
------- ---------- ----------- ------------ ---------------
19      15.77M     DISK        00:00:01     25-JAN-23
        BP Key: 19   Status: AVAILABLE  Compressed: NO  Tag: TAG20230125T114547
        Piece Name: /home/oracle/backup/arch_RACDB_0j1iqkre_19

  List of Archived Logs in backup set 19
  Thrd Seq     Low SCN    Low Time  Next SCN   Next Time
  ---- ------- ---------- --------- ---------- ---------
  1    34      1959344    24-JAN-23 1967668    24-JAN-23
  1    35      1967668    24-JAN-23 1967918    24-JAN-23
  1    36      1967918    24-JAN-23 1978864    24-JAN-23
  1    37      1978864    24-JAN-23 1979155    24-JAN-23
  1    38      1979155    24-JAN-23 1985195    24-JAN-23
  2    25      1959407    24-JAN-23 1962197    24-JAN-23
  2    26      1962197    24-JAN-23 1967665    24-JAN-23
  2    27      1967665    24-JAN-23 1967948    24-JAN-23
  2    28      1967948    24-JAN-23 1978869    24-JAN-23
  2    29      1978869    24-JAN-23 1979684    24-JAN-23
  2    30      1979684    24-JAN-23 1985310    24-JAN-23

BS Key  Size       Device Type Elapsed Time Completion Time
------- ---------- ----------- ------------ ---------------
20      49.00M     DISK        00:00:01     25-JAN-23
        BP Key: 20   Status: AVAILABLE  Compressed: NO  Tag: TAG20230125T114547
        Piece Name: /home/oracle/backup/arch_RACDB_0k1iqkrf_20

  List of Archived Logs in backup set 20
  Thrd Seq     Low SCN    Low Time  Next SCN   Next Time
  ---- ------- ---------- --------- ---------- ---------
  1    39      1985195    24-JAN-23 1985305    24-JAN-23
  1    40      1985305    24-JAN-23 1985334    24-JAN-23
  1    41      1985334    24-JAN-23 2072396    25-JAN-23
  1    42      2072396    25-JAN-23 2072422    25-JAN-23
  1    43      2072422    25-JAN-23 2096100    25-JAN-23
  2    31      1985310    24-JAN-23 1985324    24-JAN-23
  2    32      1985324    24-JAN-23 2052371    24-JAN-23
  2    33      2052371    24-JAN-23 2052373    24-JAN-23
  2    34      2072418    25-JAN-23 2072458    25-JAN-23

BS Key  Size       Device Type Elapsed Time Completion Time
------- ---------- ----------- ------------ ---------------
21      9.04M      DISK        00:00:01     25-JAN-23
        BP Key: 21   Status: AVAILABLE  Compressed: NO  Tag: TAG20230125T114547
        Piece Name: /home/oracle/backup/arch_RACDB_0l1iqkrf_21

  List of Archived Logs in backup set 21
  Thrd Seq     Low SCN    Low Time  Next SCN   Next Time
  ---- ------- ---------- --------- ---------- ---------
  1    44      2096100    25-JAN-23 2096240    25-JAN-23
  1    45      2096240    25-JAN-23 2097434    25-JAN-23
  2    35      2072458    25-JAN-23 2072811    25-JAN-23
  2    36      2072811    25-JAN-23 2096244    25-JAN-23
  2    37      2096244    25-JAN-23 2096823    25-JAN-23
  
run
{
 ALLOCATE CHANNEL t1 TYPE DISK;
 ALLOCATE CHANNEL t2 TYPE DISK;
 ALLOCATE CHANNEL t3 TYPE DISK;
 ALLOCATE CHANNEL t4 TYPE DISK;
 RESTORE DATABASE;
 RECOVER DATABASE UNTIL SEQUENCE 45;
 RELEASE CHANNEL t1;
 RELEASE CHANNEL t2;
 RELEASE CHANNEL t3;
 RELEASE CHANNEL t4;
}
*/

--Step 121 -->> On Secondary (DR) Database Servers
-- Add init parameters for Instance
/*
[oracle@RAC1 backup]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.3.0 Production on Wed Jan 25 15:03:13 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options
SQL> startup mount;
ORACLE instance started.

Total System Global Area 1553305600 bytes
Fixed Size                  2228664 bytes
Variable Size            1006636616 bytes
Database Buffers          536870912 bytes
Redo Buffers                7569408 bytes
Database mounted.
SQL> exit
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

*/
--Step 121 -->> On Secondary (DR) Database Servers
-- On either node of the standby cluster, register the standby database and the database instances with the Oracle Cluster Registry (OCR) using the Server Control (SRVCTL) utility.
[oracle@RAC1 ~]$ which srvctl
/*
/opt/app/oracle/product/11.2.0.3.0/db_1/bin/srvctl
*/
[oracle@RAC1 ~]$ srvctl add database -d racdr -o /opt/app/oracle/product/11.2.0.3.0/db_1 -r physical_standby -s mount
[oracle@RAC1 ~]$ srvctl config database -d racdr
/*
Database unique name: racdr
Database name:
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile:
Domain:
Start options: mount
Stop options: immediate
Database role: PHYSICAL_STANDBY
Management policy: AUTOMATIC
Server pools: racdr
Database instances:
Disk Groups:
Mount point paths:
Services:
Type: RAC
Database is administrator managed
*/
[oracle@RAC1 ~]$ srvctl add instance -d racdr -i racdb1 -n RAC1
[oracle@RAC2 ~]$ srvctl add instance -d racdr -i racdb2 -n RAC2

/*
The -d option specifies the database unique name (DB_UNIQUE_NAME) of the database.
The -i option specifies the database insance name.
The -n option specifies the node on which the instance is running.
The -o option specifies the Oracle home of the database.
*/

[oracle@RAC1 ~]$ srvctl config database -d racdr
/*
Database unique name: racdr
Database name:
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile:
Domain:
Start options: mount
Stop options: immediate
Database role: PHYSICAL_STANDBY
Management policy: AUTOMATIC
Server pools: racdr
Database instances: racdb1,racdb2
Disk Groups: DATADR,FRADR
Mount point paths:
Services:
Type: RAC
Database is administrator managed
*/
[oracle@RAC1 ~]$ srvctl status database -d racdr

/*
Instance racdb1 is running on node RAC1
Instance racdb2 is running on node RAC2
*/

--Step 122 -->> On Secondary (DR) Database Servers
-- Verify Standby redo logs and Apply MRP

[oracle@RAC1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Thu Jan 26 12:22:02 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

SQL> select status, instance_name from gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
MOUNTED      racdb1
MOUNTED      racdb2


SQL> set lines 999 pages 999
SQL> col name for a20
SQL> col open_mode for a10
SQL> col db_unique_name for a15

SQL> SELECT name,open_mode,db_unique_name,database_role,protection_mode FROM gv$database;

NAME                 OPEN_MODE  DB_UNIQUE_NAME  DATABASE_ROLE    PROTECTION_MODE
-------------------- ---------- --------------- ---------------- --------------------
RACDB                MOUNTED    racdr           PHYSICAL STANDBY MAXIMUM PERFORMANCE
RACDB                MOUNTED    racdr           PHYSICAL STANDBY MAXIMUM PERFORMANCE
