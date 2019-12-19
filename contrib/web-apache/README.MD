# Apache Web Server with ARPA2 service add-ons

> *This is a web server rootfs, based on Apache.  It is
> a contribition for now, but may grow into a standard
> rootfs during our ServiceHub phase.*

Static files are available through
`https://$HOSTNAME/...` and served from
`/var/www/$HOSTNAME/...`.

User-published documents are available through
`https://$USERNAME@$HOSTNAME/...` and served from
`/home/$USERNAME/public_html/...`.

Dynamic plugin services are TODO.  They will be configured
as part of the service setup.

This rootfs will gradually incorporate aspects of the
ARPA2 infrastructure to demonstrate how services can be
structured:

  * Serving any number of domains `$DOMAIN`, each with
    their own set of `$HOSTNAME.$DOMAIN` and user-published
    `$USERNAME@$HOSTNAME.$DOMAIN` locations.  These are
    automatically configured in the Apache configuration files.

  * Use of an automatically provisioned
    [TLS Pool](https://gitlab.com/arpa2/tlspool)
    with certificates.  External identity infrastructure
    registers such certificates under a root and in DNSSEC/DANE,
    with cautious rollover procedures for automated renewal.
    The TLS Pool incorporates
    new mechanisms that make TLS a
    [Quantum Proof](http://www.internetwide.org/blog/2019/07/14/quantum-crypto-3.html)
    security protocol, meaning that current-day storage of
    sessions cannot lead to future reversal of encryption.

  * The incorporation of
    [HTTP SASL](http://internetwide.org/blog/2018/11/15/somethings-cooking-4.html)
    as a generic and user-controllable authentication mechanism
    with realm crossover options implementing our favourite
    [Bring Your Own IDentity](TODO)
    so your home-grown identity can work.

  * Automatically populating access control databases with
    user credentials, both for domain-local users and for
    foreign users that happen to have authenticated through
    BYOID facilitation.

