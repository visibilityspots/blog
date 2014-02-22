Cisco HWIC 3G configuration to 2G
#################################
:date: 2012-04-03 14:36
:author: Jan
:tags: 2G, 3G, auto-band, band, cellular, cisco, gsm, gsm-all-bands, Mobile, router
:slug: cisco-3g

In some cisco routing devices you have the possibility to extend the features with a HWIC 3G card so mobile connectivity is added to your network infrastructure. This can be interesting for a mobile fail-over connection.

But as we all now, the mobile reception isn't always that good. To see the signal strength on your cisco device you can use:
::

	show cellular 0/0/0 connection

depending on which slot you plugged the HWIC card into. If the measured value is beneath the -100 dBm then you have sufficient signal to setup a 3G ( CDMA - WCDMA) connection on. 

If that's not the case or the values of different measurements are very different you should consider to downgrade too a 2G connection because else your 3G connection will be very wonky!

The default setup would mostly be auto-band. This means that if there is a little chance to connection over 3G your device will try to connect to this 3G connection. If the 3G signals gets lost it REconnects to 2G and therefore connectivity interruption will take place.
::

	cellular 0/0/0 gsm band auto-band

So if your 3G signals isn't strong enough it's a good idea to force your device to connect only on 2G. This can easily be done by:
::

	cellular 0/0/0 gsm band gsm-all-bands

That way your wonky 3G connection will became a stable 2G connection!
