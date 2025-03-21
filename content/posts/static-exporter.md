+++
date = '2025-02-25T21:13:48-05:00'
draft = true
title = 'Static Exporter'
+++

If the term static exporter doesn't immediately come to mind, you're not alone.
A quick Google search for "what is a static exporter" yields some pretty sad results:

![Google search for "what is a static exporter"](static-exporter-google-search.png)

It helps to know that I'm more concerned about prometheus exporters then a nextjs static website.
So let's scope down the results by adding "prometheus" to the search:

![Google search for "what is a static exporter prometheus"](static-exporter-google-search-prometheus.png)

Funny enough, AI gets us closer to the answer I was looking for, but the results are still not what I consider a static exporter.
So to me, that means that this is a somewhat new concept and I'm excited to share what I've learned from working with static exporters directly.

## What is a static exporter?

So before we define what a static exporter is, let's look at some examples of some of the data that can be exported.
Think of things like:

- Astronauts in space
- Cost of a cloud resource(*)
- k8s namespace to team mappings
- S3 bucket to team mappings

(*) I'm not sure if this is a great example, since technically the cost of a cloud resource does change, but it's still a good example.
I was first exposed to this concept at work via Grafana's [static-exporter](https://github.com/grafana/jsonnet-libs/tree/master/static-exporter).
One of the cooler use cases for Grafana Labs is mapping all of our k8s namespaces to the team.
The neat part of this is that it's automated so that when ownership changes, the static-exporter will pick it up and be rebuilt and deployed.
Other teams had other use cases that grew organically overtime.

## How does it work?

In prometheus world, the simplest form of an exporter is a text-based format that can be scraped by Prometheus.
Scraping means that some process submits an http request to a web server that responds with text that looks like this:

```
# HELP some_metric Some helpful description of the metric
# TYPE some_metric gauge
some_metric 1.0
```

The `# HELP` line is optional, but it's a good idea to include it.
The `# TYPE` line is required as it defines the name and type of the metric.
The `some_metric 1.0` line is the value of the metric.

So how does static-exporter work?
It defines a deployment that runs an httpd server and a configmap that defines the metrics.
The configmap is mounted into the httpd server and the server serves the metrics when scraped.

This is very simple but incredibly powerful. 

At Grafana Labs, our core platform is defined with jsonnet.

## Problems

I've been working on upgrading the static-exporter in [grafana/jsonnet-libs](https://github.com/grafana/jsonnet-libs) to have a header set that allows the metrics to be scraped by Prometheus 3.0.0.
Prior to working at Grafana Labs, I don't believe I had ever used a static-exporter.
Searching Google "what is a static exporter" yielding some pretty bad results.
Here's a screenshot of the first result:


I was exposed to this concept at work and I'm not sure if it's a common concept in the wild.

## Future of the exporter

The current static-exporter is clever and has proven to be useful.
However, it is a bit of a hack and has some limitations.
The most obvious limitation is that it's based upon apached, which is not as widely known anymore.
The over limitation is that we're limited on the type of metrics the library can support.
It would be more useful to pass data into the exporter from the jsonnet code.