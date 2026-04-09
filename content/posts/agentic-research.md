+++
date = '2026-04-09T06:17:52-04:00'
draft = true
title = 'Agentic Research'
+++

In my previous post about [Effective Agentic Coding](./effective-agentic-coding.md), I listed out five distinct workflows that I find myself falling into.
The first of which was around researching topics with agents such as Claude Code.
For many folks, this many be shocking as agentics are exceptionally confident and will tell you what you would like.
However, they also are exceptional are searching the web and analyzing text and synthetisizing it into something usable.

## First must come the problem

At Grafana Labs, I'm working on our [Synthetic Monitoring](https://grafana.com/docs/grafana-cloud/testing/synthetic-monitoring/) product which has had our browser tests usage growing rapidly.
With any period of rapid growth, we're also experiencing growing pains as we learn to operate browser checks at scale.
So I've been dealing with escalations and learning to operate these myself, and have found it challenging to search to web around this topic.
There's only a handful of companies who are operating large browser farms, and not many of them write publicly about their platform.
So this is now my problem:

* [chromium](https://chromium.googlesource.com/chromium/src/+/HEAD/docs/README.md) docs are rather dense
* little is written about scaling chromium on k8s
* no tools exist to help measure performance

Enter agents!

## Researching with agents

Here was my prompt for Claude:

> This is purely a planning and research session. The end result should be a written document that I can refer to in the next phase. I'm looking to learn more about how to collect metrics on running chromium instances. The context is I run a chromium wrapper in grafana/crocochrome that is invoked from k6 runners, and I run these at scale in kubernetes. I'd like to figure out a way of gathering more runtime diagnostic data on chromium sessions that are spawned and execute k6 browser tests.

What happened from this point is:

* Multiple agents were spawned
* Each agent was tasked with a specific part of the problem
  * Chrome Developer Protocols(CDP)
  * OS-level chromium metrics
  * crocochrome architecture
  * chromium monitoring in k8s
As I viewed the agents, what each one was doing was effectively
* [Web search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool) invocations
* piping results to python scripts to extract content
* aggregating content into summaries

At the end, the main agent collected all of the results into a final markdown file with it's [findings](https://gist.github.com/Pokom/ad2031bc8ae234b990118e680a5055c1#file-writeup-md).

## Quick Summary

Of course, agents and LLM's are exceptionally confident and are there to please.
So the first thing I always do is read through the summary as best as I can and try and pressure test it.
The first draft brought together _11_ sections of content plus references.
That's overwhelming as someone who's just trying to dip there toes and learn more.
For me, the most effective sections that were produced were:

* [cdp interface](https://gist.github.com/Pokom/ad2031bc8ae234b990118e680a5055c1#2-cdp-based-metrics-primary-interface)
* [what's missing](https://gist.github.com/Pokom/ad2031bc8ae234b990118e680a5055c1#whats-missing)

From there, I added one more prompt because I was overwhelmed, and asked claude to simplify things as much as possible and provide learning resources.
The result was [learning cdp](https://gist.github.com/Pokom/ad2031bc8ae234b990118e680a5055c1#learning-cdp), which was honestly more effective then anything else.
So, was it useful?

## Was it useful

This exercise got me closer to material much faster then I could have without claude.
The prompt I provided was too broad and I ended up with about 500 lines of text that took me another hour or so to read through.
The links it provided were the most valuable aspect as it got me closer to where I wanted to be.
It's _almost_ like I created a wikipedia article on the subject that's complete vibes.
So overall, _yes_ it was useful in getting me material faster.
_No_, I still do not have a confident answer on how to collect better performance metrics from chromium.
What I _do_ have is guided material I can use to spin up experiments to dig deeper!
