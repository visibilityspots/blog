Command line printing & scanning
################################
:date: 2013-08-02 21:00
:author: Jan
:tags: print, scan, command, line, linux, lpr, scanimage
:slug: printing-scanning
:status: published

Since I discovered the joy of using the ratpoison window manager I'm trying to do all tasks I need to perform on my system using the command line.

One of those frequently used tasks is printing out documents or scanning in files. Until today I used the software viewer of my documents to print and simple-scan to scan my files.

Nowadays I use the command line to perform those tasks. To print out documents I use the `lp`_ command:

::

	"Get the status off all printers on your system"
	$ lpc status all

	"Print the desired file to a specific printer"
	$ lpr -P PRINTERNAME FILE/TO/PRINT.XX

	"Show the printing queue"
	$ lpq -P PRINTERNAME

	"Cancel a specific print job using the queue id"
	$ lprm ID

	"Cancel all printing jobs"
	$ lprm -

Those are the commands I regularly use to print my documents.

For scanning I use `scanimage`_ from sane. There are too many options to explain so I just give hereby the one I use to scan A4 formatted files to pdf:

::

	"List your scan devices"
	$ scanimage -L

	"Scan the image to a pdf file"
	$ scanimage -p > fileName.pdf

Off course there are many ways to perform those tasks using the command line. Those are only the ones I use on my fedora machine. I'm always open for suggestions!

.. _lp: http://www.tldp.org/HOWTO/Printing-Usage-HOWTO-1.html
.. _scanimage: http://www.sane-project.org/man/scanimage.1.html
