Dropbox
#######
:date: 2012-10-15 18:00
:author: Jan
:tags: accounts, centOS, dropbox, encfs, encryption, multiple, security
:slug: dropbox
:status: published
:modified: 2012-10-15

Reading this article will go through the process I went through configuring multiple dropbox accounts on my centos machine (one personal and one for work) and encrypting them both using encfs.

That way I'm sure dropbox can't read the data stored into it. Because no I don't trust anybody on the cloud!

In the first part I will configure 2 dropbox services using a CentOS 6 Desktop, in the second part I will encrypt those 2 dropbox services using encfs.

The first account you can just install and configure the normal way provided by `dropbox`_ itself. Here I configured my work account on so all work related data will be stored in my home/Dropbox folder later on.

Once this is done we have to install the 2nd service and configure the personal account into it. To do this we have to create 2 new folders into your home directory.
One named .dropbox-personal where the 2nd dropbox service configuration files will be stored in. And another named for example Personal where the actual Dropbox folder for this 2nd account will be written to.

When you created those 2 fresh directories you can open a terminal and run the command

::

	HOME=$HOME/.dropbox-personal /usr/bin/dropbox start -i

so the 2nd dropbox service will be started from this newly .dropbox-personal folder.

Follow the wizard, but make sure you enter a CUSTOM folder (e.g. ~/Personal) where you point to the 2nd new folder you've created ~/Dropbox-personal/!

To start this 2nd instance of dropbox we have to create a script which will start this instance and add it to our Startup programs.

Create an executable (chmod +x file.sh) .sh file with this content:

::

	#!/bin/bash HOME=$HOME/.dropbox-personal /usr/bin/dropbox start

And add a new entry via System -> Preferences -> Startup Applications for this script.

Or you can copy the script.sh file to your /usr/bin/ director without the extension so your script will be available as a command in your terminal.

So right now we have 2 dropbox accounts uploading the folders ~/Dropbox for work related stuff and ~/Personal/Dropbox/ for personal data.

Next step will be encryption for those folders. By encrypting your dropbox folders we make sure our data will not be readable when stored on the dropbox servers and sent over the internet.
To accomplish this encryption I opted for encfs. On a CentOS machine you can install it using yum:

::

	sudo yum install fuse-encfs

Once the package is installed we can configure our encrypted volumes.
The way this encryption will work is quite simple. You have 2 folders, a private folder which is the working directory where you can edit delete and create files and folders to work with.
All content in your private folder will be encrypted to you encrypted folder which will be synchronized to the dropbox online services.

So in our case we have to create 4 folders, 2 for our work account (~/Private & ~/Dropbox/.encrypted) and 2 for our personal account (~/Personal/Private-personal & ~/Personal/Dropbox/.encrypted-personal).

Once those folders are created we can configure the encfs volumes:

::

	encfs ~/Dropbox/.encrypted ~/Private encfs ~/Personal/Dropbox/.encrypted-personal ~/Personal/Private-personal

where you can use the paranoia mode to encrypt your files

::

	enter "p" for pre-configured paranoia mode

with your chosen password. When you created your encrypted volumes you can administer your data in the private folders, this data will be encrypted automatically to your .encrypted\* folders which will be uploaded to dropbox.
When you install dropbox on another computer you also have to install encfs on it to decrypt your files.

In the dropbox folders you can see there is a .encfs6.xml file. To be completely sure dropbox can't do anything with your files you can exclude this file to be synchronized online.
But make some copies of it to a secure place (usb stick or your phone) before you continue. This can be done with the command:

::

	dropbox exclude add ~/Dropbox/.encrypted/.encfs6.xml dropbox exclude list

And remove the .encfs6.xml file from the online dropbox account using the web service.

For the 2nd service you have to use the following commands:

::

	HOME=$HOME/.dropbox-personal /usr/bin/dropbox exclude add ~/Personal/Dropbox/.encrypted-personal/.encfs6.xml HOME=$HOME/.dropbox-personal /usr/bin/dropbox exclude list``

On every computer where you install encfs to decrypt those files you have to copy the proper .encfs6.xml file in the .encrypted\* folders so you can decrypt the encfs volumes.

Be aware you can't use your encrypted files using the dropbox web interface. On your android phone you can install `cryptonite`_ which will decrypt your files so you can use them on your phone.

I created a Startup script which can decrypt and umount the encrypted folders and shared it on `github`_ by adding the script with the preferred parameters to your Startup
programs you have to fill in the passwords each time you log in so your folders are decrypted and you can start using them.
(or add the script to your /usr/bin/ folder named encryption so you can handle it as a command called encryption as you named it in your terminal)

You can also use this setup to share for example your evolution mails via dropbox on an encrypted way so nobody can read your mails except your on your different computers with evolution. (Make sure the
evolution versions match and point your evolution working directory to the private one using symlinks - e.g. ln -s ~/Private/.evolution ~/.evolution)

Feel free to add patches, send remarks about this topic.) by adding the script with the preferred parameters to your Startup programs you have to fill in the passwords each time you log in so your folders are
decrypted and you can start using them.

Resources:

-  `http://maketecheasier.com`_
-  `https://help.ubuntu.com`_
-  `http://janaksingh.com`_

.. _dropbox: https://www.dropbox.com/install
.. _cryptonite: https://code.google.com/p/cryptonite/
.. _github: https://github.com/visibilityspots/scripts
.. _http://maketecheasier.com: http://maketecheasier.com/run-multiple-dropbox-accounts-in-mac-and-linux/2010/05/24
.. _https://help.ubuntu.com: https://help.ubuntu.com/community/EncryptedPrivateDirectory
.. _http://janaksingh.com: http://janaksingh.com/blog/dropbox-encryption-install-encfs-linux-encrypt-decrypt-dropbox-content-realtime-155
