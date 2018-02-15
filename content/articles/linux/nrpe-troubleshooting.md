Title:       NRPE troubleshooting
Author:      Jan
Date: 	     2018-02-15 21:00
Slug:	     nrpe-troubleshooting
Tags: 	     nrpe, troubleshooting, nagios, icinga, selinux, unable, to, connect
Status:	     published
Modified:    2018-02-15

When refactoring a [check_memory](https://github.com/visibilityspots/icinga-scripts/blob/master/check_memory) I wrote a few years ago I bumped into the feared

```
NRPE: Unable to read output
```

error message on our nagios instance.

When looking for a solution I went through most possible debug steps I could think of and which are nicely described by nagios [support](https://support.nagios.com/kb/article/nrpe-nrpe-unable-to-read-output-620.html) but didn't found any solution.

I almost grabbed to some anti depressants when I thought of the thing I always forget about.

**SELINUX**

When crawling through the audit log it became clear I forgot to configure the proper selinux context type for the new script.

```
type=PATH msg=audit(1518702310.763:296695): item=0 name="/usr/lib64/nagios/plugins/check_mem" inode=1126947 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=unconfined_u:object_r:admin_home_t:s0 objtype=NORMAL
type=PROCTITLE msg=audit(1518702310.763:296695): proctitle=7368002D63002F7573722F6C696236342F6E6167696F732F706C7567696E732F636865636B5F6D656D2E7368
type=AVC msg=audit(1518702310.763:296696): avc:  denied  { getattr } for  pid=21213 comm="sh" path="/usr/lib64/nagios/plugins/check_mem" dev="dm-0" ino=1126947 scontext=system_u:system_r:nrpe_t:s0 tcontext=unconfined_u:object_r:admin_home_t:s0 tclass=file
type=SYSCALL msg=audit(1518702310.763:296696): arch=c000003e syscall=4 success=no exit=-13 a0=268ea10 a1=7ffc5f708730 a2=7ffc5f708730 a3=7ffc5f708260 items=1 ppid=21212 pid=21213 auid=4294967295 uid=997 gid=994 euid=997 suid=997 fsuid=997 egid=994 sgid=994 fsgid=994 tty=(none) ses=4294967295 comm="sh" exe="/usr/bin/bash" subj=system_u:system_r:nrpe_t:s0 key=(null)
```

By refreshing my memory about selinux again following this gentoo [tutorial](https://wiki.gentoo.org/wiki/SELinux/Tutorials/Where_to_find_SELinux_permission_denial_details) I could quickly fix the issue by configuring the proper context type;

```
# semanage fcontext -a --type nagios_unconfined_plugin_exec_t /usr/lib64/nagios/plugins/check_mem
# restorecon /usr/lib64/nagios/plugins/check_mem
```

and running the check_nrpe tool from the nagios instance finally worked again as I expected it to be:

```
# /usr/lib64/nagios/plugins/check_nrpe -H host -c check_mem
OK: 63% of memory used, 48% is available
```
