Title:       Traefik SSL grading
Author:      Jan
Date:        2022-08-20 12:00
Slug:        traefik-ssl-grading
Tags:        traefik, ssl, https, grading, testssl, qualys, ssllabs, labs, a, b
Modified:    2022-08-20
Status:      published

Recently I discovered that many of the services I deployed upon my [nomad cluster]({filename}./nomad-arm-cluster.md)  didn't had the SSL A grading I expected them to have. Somehow I asumed the [traefik letsencrypt]({filename}./traefik.md) implementation got the A rating by default.

After running the [testssl.sh](https://github.com/drwetter/testssl.sh) container it turns out they don't;

```
$ docker run --rm -ti drwetter/testssl.sh domain.org
 Rating specs (not complete)  SSL Labs's 'SSL Server Rating Guide' (version 2009q from 2020-01-30)
 Specification documentation  https://github.com/ssllabs/research/wiki/SSL-Server-Rating-Guide
 Protocol Support (weighted)  95 (28)
 Key Exchange     (weighted)  100 (30)
 Cipher Strength  (weighted)  90 (36)
 Final Score                  94
 Overall Grade                B
 Grade cap reasons            Grade capped to B. TLS 1.1 offered
                              Grade capped to B. TLS 1.0 offered
                              Grade capped to A. HSTS is not offered
```

Turns out traefik by default offers TLS 1.0 and 1.1 which are deprecated since 2018. So those needs to be disabled and TLS 1.3 needs to be supported.

So I started looking into the matter to get that A+ rating and found out traefik has some [tls options](https://doc.traefik.io/traefik/https/tls/#tls-options) which can be configured to get there. So I configured traefik with those extra configuration parameters.

```
traefik.toml:

        [tls.options]
            [tls.options.default]
                sniStrict = true
                minVersion = "VersionTLS12"
                curvePreferences = ["CurveP521", "CurveP384"]
                cipherSuites = [
                    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
                    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
                    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
                    "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
                    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
                ]
            [tls.options.mintls13]
                minVersion = "VersionTLS13"
```

This already got me towards an A rating. Obviously it  was already a big step towards the aim of the A+ rating hence still not there yet so I digged deeper into the matter and tried to get the missing HSTS headers fixed to get that + rating!

And thanks to the [internet](https://www.simplecto.com/improve-traefik-https-encryption-qualys-ssl-labs-testssl-sh/) I found out adding an extra middleware to fix those headers could bring me that extra + rating;

```
traefik.toml:
        [entryPoints.https.http]
            middlewares = ["securedheaders"]
            tls = "true"
```

By configuring this middleware through the https entrypoint and since all http traffic is redirected towards the https entrypoint now all the traffic which reaches the traefik proxy instance will get those headers by default;

```
nomad traefik job tags;
        "traefik.http.middlewares.securedheaders.headers.forceSTSHeader=true",
        "traefik.http.middlewares.securedheaders.headers.STSPreload=true",
        "traefik.http.middlewares.securedheaders.headers.ContentTypeNosniff=true",
        "traefik.http.middlewares.securedheaders.headers.browserXssFilter=true",
        "traefik.http.middlewares.securedheaders.headers.STSIncludeSubdomains=true",
        "traefik.http.middlewares.securedheaders.headers.STSSeconds=315360000",
```

This means that all my traefik configured services get that A+ rating by default from now on!!

```
$ docker run --rm -ti drwetter/testssl.sh domain.org
Rating specs (not complete)  SSL Labs's 'SSL Server Rating Guide' (version 2009q from 2020-01-30)
 Specification documentation  https://github.com/ssllabs/research/wiki/SSL-Server-Rating-Guide
 Protocol Support (weighted)  100 (30)
 Key Exchange     (weighted)  100 (30)
 Cipher Strength  (weighted)  90 (36)
 Final Score                  96
 Overall Grade                A+
```


