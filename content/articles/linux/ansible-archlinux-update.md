Title:       Ansible-playbook archlinux upgrade
Author:      Jan
Date:        2018-08-06 19:00
Slug:        ansible-archlinux-upgrade
Tags:        ansible, playbook, ansible-playbook, archlinux, aur, aurman, update, upgrade, ansible-aur, pacman
Status:      published
Modified:    2018-10-30

Since a few years now I'm a happy [Archlinux](https://www.archlinux.org/) user. I like their [philosophy](https://wiki.archlinux.org/index.php/Arch_Linux) which was one of the major points why I made the switch back in the days.

I'm not only using it on my laptop, but do have some devices running at home which are configured with it. From a thin client which I use as a docker node through some raspberry pies running [ArchlinuxARM](https://archlinuxarm.org/).

Since Arch is a rolling update distro there are several updates available throughout the day. To keep on top of them I had to log in on all those devices at least once a day to perform the updates. Experience learned me that let them drifting could lead to some major troubles when only updating after a few weeks.

But it became a time consuming task to keep them all in line. Since [ansible](https://www.ansible.com/) is used at the project I'm currently working at it seemed a good idea to write a playbook to update all those devices with only one command. And without having to configure some additional software on all the devices but based on good old SSH.

Ansible already has a default [pacman](https://docs.ansible.com/ansible/latest/modules/pacman_module.html) module which can be used for the official repositories. But since a lot of packages I installed are coming from the [AUR](https://aur.archlinux.org) I first went with a command execution for [aurman](https://github.com/polygamma/aurman). After some research I found out about [ansible-aur](https://github.com/kewlfft/ansible-aur) a bit later so I installed the module and rewrote my playbook so it used the aurman helper.

But only after a few weeks I found out that the developer wasn't really born with an open-source mind as can be seen by his commits [dcb50aa](https://github.com/polygamma/aurman/commit/dcb50aa1bf5296dfadbffbe867d3e7e807442397) & [c409fee](https://github.com/polygamma/aurman/commit/c409feef4c93137c2f0917d8ecdede2d51e06ea9) so I went for the [yay](https://github.com/Jguer/yay) implementation instead.

In the initial phase I used to push my passwords as hashes into the playbook. But when I was about to push the playbook in [github](https://github.com/visibilityspots/ansible-playbook-archlinux-update) I figured it wouldn't be a good idea to share that with the public. So I stumbled on [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vault.html).

That way I could refer to passwords in an encrypted file in the playbook so I could safely push the playbook to the public. In combination with the parameter [--vault-password-file](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html#cmdoption-ansible-playbook-vault-password-file) I can now run the playbook without interaction for passwords.

And it works great, keeping them all up to date and having a clear output about which packages are updated on which machine. Yet another step closer to that ultimate dream of drinking cocktails on the beach while everything is running automatically in the back!
