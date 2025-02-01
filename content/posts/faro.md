+++
date = '2025-01-27T21:09:42-05:00'
draft = true
title = 'Faro'
+++

# Faro

> Disclaimer!
> I work at Grafana Labs, but this is not endorsed.
> I'm writing this in my personal time as I explore Faro and see how I can use it with hugo.

I want to monitor traffic to this site, but to do it in a way that has some semblance of privacy.
In the past I've used Google Analytics, but feel this pulls much more data then I'm comfortable with.
It's a powerful tool that I've used personally and professionaly, but for the most part I do not need most of the features.
I want to be able to know the following
- How many users visited my website, broken down by page
- How long does a user stay?
- How much data is transmitted?
- How well does the page perform?

[Grafana Faro](https://grafana.com/oss/faro/) appears to be able to do all of these things.

1. What is Grafana Faro
2. How do I add it to a hugo site?
3. Should this be contributed back?
4. Now that it's instrumented, what can I do with it?

## How do I add Grafana Faro to a Hugo site

Main docs:
https://grafana.com/docs/grafana-cloud/monitor-applications/frontend-observability/instrument/faro/