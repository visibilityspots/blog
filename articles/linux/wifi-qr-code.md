Title:       Wifi QR code
Author:      Jan
Date: 	     2014-08-28 22:00
Slug:	     wifi-qr-code
Tags: 	     wifi, qr, code, generator, qrencode, linux, archlinux
Status:      published

To make the process of connecting to our local wifi at home a bit less complex I decided to create a qr code for it. That way people can easily use their camera of their smartphone to connect to our network without typing in the WPA key.

So I looked on the net for a qr generator and started by typing in our SSID, when realizing it can't be secure to fill in our wpa key too.. It may be a bit paranoia but well I don't trust anything on the interweb most of the time.

Doing some further research I found out about [qrencode](http://fukuchi.org/works/qrencode/) a command line tool which can be used to generate many different QR codes.

For installation in archlinux you can use pacman:

```bash
  $ pkgfile qrencode
  extra/qrencode

  $ sudo pacman -Syu qrencode
```

Once installed you can generate a qr code consisting of your wifi data base on some standardized [barcode contents](https://github.com/zxing/zxing/wiki/Barcode-Contents).

When figured out what that content had to be I generated an svg file of our QR code:

```bash
  $ qrencode -t SVG -o wifi-code.svg "WIFI:S:SSID-OF-YOUR-WLAN;T:WPA2;P:YOUR-WPA2-KEY;;"
```

You now should be able to print that svg file with your SSID connection information you could use to connect to your network by simple scanning the code from your smartphone using a [barcode scanner](https://play.google.com/store/search?q=barcode) of your choice.

And by not using the internet but your local machine there is no chance anyone is storing that data in some dark database ;)
