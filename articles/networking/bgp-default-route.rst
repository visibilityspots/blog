BGP announcing default route
############################
:date: 2012-03-31 13:07
:author: Jan
:tags: bgp, cisco, default, networking, route
:slug: bgp-default-route

Advertising default route with BGP
==================================

If you want to announce the default route which is statically routed then you have to add following commands to the working BGP configuration:
::

	ip route 0.0.0.0 0.0.0.0 192.168.1.1
        router bgp 65001
	network 0.0.0.0
	default-information originate

when you then clear the ip bgp routing softly (so the current connecting will not be broken)
::
	
	clear ip bgp soft in  
	clear ip bgp soft out

you should see that the default route is will be advertised:
::

	sh ip bgp summary
	sh ip bgp neighbors IP.ADDRESS advertised-routes
