+++
date = '2025-01-17T22:36:07-05:00'
draft = false
title = 'Squarespace'
+++

I use squarespace for `markpoko.dev`'s DNS records, though not by choice.
Up until 2024, I had used Google domains to handle my DNS thingy.
At the time it made sense as I was diving deep into learning GCP.
There was a nice integration between Cloud Run and Google Domains, making it trivial to expose services over a DNS entry.
As Google [does](https://killedbygoogle.com/), the [project was shut down and sold](https://9to5google.com/2023/06/15/google-domains-squarespace/) off to Squarespace.


However, I'm resurrecting my website and am having trouble getting it switched over to to GitHub Pages.


## Configuration

I had four A records with the host set to `markpoko.dev`(this was the issue).
The records had been set for ~8 hours and I still couldn't access `markpoko.dev`.
When digging the stuff, I get no response.

```bash
dig markpoko.dev +noall +answer -t A
```

I tried a few other combinations
- finding the nameserves(`dig NS example.com +short`) and digging one of them directly
- digging against **@8.8.8.8** and **@1.1.1.1**
- validating `whois markpoko.dev`

All of these had the same results, and so I decided to double check the configurations.
After reviewing an example config, it was obvious that the host was not set properly.
The host was set to `markpoko.dev` without fully understanding what the propery was.

## DNS Records in 30 seconds

The host refers to the `subdomain` the record will apply for.
A special scenario is the root domain(`markpoko.dev`).
The root domain can be represented as either blank or `@`.
Otherwise, it's the `subdomain` passed in(`api.markpoko.dev`).
A number of records can have multiple entries set.
Usually this means the dns server will round robin requests to the IP addresses set.
CNAMES and ALIAS can only have one entry.

## Back to it

After updating the DNS records host from `markpoko.dev` to `@`, immediately afterwards the records were displaying properly:

```bash
dig markpoko.dev +noall +answer -t A
markpoko.dev.           60      IN      A       185.199.109.153
markpoko.dev.           60      IN      A       185.199.108.153
markpoko.dev.           60      IN      A       185.199.110.153
markpoko.dev.           60      IN      A       185.199.111.153
```

Accessing `https://markpoko.dev` through firefox was showing potential security issues with the following warning:

> Websites prove their identity via certificates. Firefox does not trust this site because it uses a certificate that is not valid for markpoko.dev. The certificate is only valid for the following names: *.github.io, github.io, githubusercontent.com, www.github.com, *.github.com, *.githubusercontent.com, github.com

Curl was showing similar problems:

```shell
curl https://markpoko.dev
curl: (60) SSL: no alternative certificate subject name matches target host name 'markpoko.dev'
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

Time to dig compare current DNS settings to the [docs](https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https#verifying-he-dns-configuration). I had missed
- `AAAA` records for `@`
- `CNAME` record for `www`
- `ALIAS` which I'll come back too

I skipped the alias, and was able to verify the customer domain from GitHub.
After that, [markpoko.dev](https://markpoko.dev) loaded.

## Alias thoughts

GitHub recommends having an [ALIAS or ANAME](https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https#verifying-the-dns-configuration) set, which seems innocuous.
SquareSpace offers the ability to set an `ANAME`, so that's what I tried.
The gotcha was that SquareSpace required disabling `DNSSEC` before an `ANAME` can be set.
Given that there's already a `CNAME`, I made the assumption I could skip this setting.
I don't understand why GitHub would recommend setting one if it meant disabling DNSSEC.
However, I don't quite know DNSSEC well enough to understand the implications of disabling it.
Either way, you can skip setting the `ANAME` and move on.