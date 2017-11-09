Title:       Test ansible playbooks with docker
Author:      Jan
Date: 	     2017-11-09 21:00
Slug:	     test ansible playbooks
Tags: 	     ansible, docker, playbook, test
Status:      published
Modified     2017-11-09

recently I started working at a new project where the infra is maintained by ansible. When been asked to write some functionality in a playbook I missed my [vagrant puppet](https://github.com/visibilityspots/vagrant-puppet) setup where I could easily test my puppet code on my local machine.

Due to my previous project I felt like maybe I could use docker for this purpose on the ansible part. So I looked a bit around and stumbled on the [docker-ansible github repository](https://github.com/William-Yeh/docker-ansible) of William Yeh. He already did a great job by creating a docker container with ansible preinstalled for a lot of linux distributions.

I only figured the way he describes wasn't really what I am looking for. By using docker build the test of the playbook creates a docker image every time. I was looking for a solution a docker container will be brought up, the ansible playbook being tested, showing those results and bringing the container back down without too much hassle to set this environment up and running.

So I digged around a bit further in his images and came up with the following command

```
$ docker run -ti --rm -v "$(pwd)":/tmp --workdir="/tmp" williamyeh/ansible:centos7-onbuild ansible-playbook-wrapper
```

This will mount the current directory where a file named playbook.yml is placed to the /tmp directory of the docker container. By changing the container's workdir to this /tmp directory the ansible-playbook-wrapper he wrote will be executed using the mounted playbook.yml and spawning the results.

```
$ docker run -ti --rm -v "$(pwd)":/tmp --workdir="/tmp" williamyeh/ansible:centos7-onbuild ansible-playbook-wrapper
PLAY [Remove upstream repositories when being an offline instance] **************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Check if system is supposed to be offline] *********************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [find] *********************************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [file] *********************************************************************************************************************************************************************************************************************************************************************
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 560, u'isgid': False, u'size': 1664, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Base.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 60, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 561, u'isgid': False, u'size': 1309, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-CR.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 60, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 562, u'isgid': False, u'size': 649, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Debuginfo.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 60, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 563, u'isgid': False, u'size': 630, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Media.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 60, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 564, u'isgid': False, u'size': 1331, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Sources.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 60, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 565, u'isgid': False, u'size': 3830, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Vault.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 60, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
skipping: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 566, u'isgid': False, u'size': 314, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-fasttrack.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 60, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=4    changed=1    unreachable=0    failed=0
```

the playbook will check for a certain file and depending on that file's existence it will remove all repositories except from a predefined list.

```
---
- name: Remove upstream repositories when being an offline instance
  hosts: localhost
  become_user: root
  vars:
    repos_to_keep:
      - /etc/yum.repos.d/CentOS-fasttrack.repo

  tasks:

    - name: Check if system is supposed to be offline
      stat:
        path: /opt/offline
      register: offline

    - find:
        paths: /etc/yum.repos.d/
        patterns: "*.repo"
      register: repos

    - debug:
        var: repos.files

    - file:
        path: "{{ item.path }}"
        state: absent
      with_items: "{{ repos.files }}"
      when:
        - item.path not in repos_to_keep
        - offline.stat.exists


```

during development you want to keep the container online to troubleshoot. This can be done by running the container and instead of executing the ansible-playbook-wrapper just launching bash.

```
$ docker run -ti --rm -v "$(pwd)":/tmp --workdir="/tmp" williamyeh/ansible:centos7-onbuild /bin/bash
[root@5cd5cfe2d7cf tmp]# ls /etc/yum.repos.d/
CentOS-Base.repo  CentOS-CR.repo  CentOS-Debuginfo.repo  CentOS-fasttrack.repo  CentOS-Media.repo  CentOS-Sources.repo  CentOS-Vault.repo
[root@5cd5cfe2d7cf tmp]# ansible-playbook-wrapper

PLAY [Remove upstream repositories when being an offline instance] **************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Check if system is supposed to be offline] *********************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [find] *********************************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [file] *********************************************************************************************************************************************************************************************************************************************************************
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 560, u'isgid': False, u'size': 1664, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Base.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 59, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 561, u'isgid': False, u'size': 1309, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-CR.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 59, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 562, u'isgid': False, u'size': 649, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Debuginfo.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 59, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 563, u'isgid': False, u'size': 630, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Media.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 59, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 564, u'isgid': False, u'size': 1331, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Sources.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 59, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
changed: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 565, u'isgid': False, u'size': 3830, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-Vault.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 59, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})
skipping: [localhost] => (item={u'uid': 0, u'woth': False, u'mtime': 1504108387.0, u'inode': 566, u'isgid': False, u'size': 314, u'roth': True, u'isuid': False, u'isreg': True, u'gid': 0, u'ischr': False, u'wusr': True, u'xoth': False, u'rusr': True, u'nlink': 1, u'issock': False, u'rgrp': True, u'path': u'/etc/yum.repos.d/CentOS-fasttrack.repo', u'xusr': False, u'atime': 1504108387.0, u'isdir': False, u'ctime': 1510218719.8578098, u'wgrp': False, u'xgrp': False, u'dev': 59, u'isblk': False, u'isfifo': False, u'mode': u'0644', u'islnk': False})

PLAY RECAP **********************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=4    changed=1    unreachable=0    failed=0

[root@5cd5cfe2d7cf tmp]# ls /etc/yum.repos.d/
CentOS-fasttrack.repo
[root@5cd5cfe2d7cf tmp]# exit
exit
```

Since the command is rather long to memorize I created an alias for it in my [zsh](https://wiki.archlinux.org/index.php/Zsh) config (~/.zshrc)

```
alias ansible-playbook-test='docker run -ti --rm -v "$(pwd)":/tmp --workdir="/tmp" williamyeh/ansible:centos7-onbuild ansible-playbook-wrapper'
```
