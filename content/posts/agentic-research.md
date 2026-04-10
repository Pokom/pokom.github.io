+++
date = '2026-04-09T06:17:52-04:00'
draft = true
title = 'Agentic Research'
readTime = true
+++

In my previous post about [Effective Agentic Coding]({{< ref "posts/effective-agentic-coding.md" >}}), I listed out five distinct workflows that I find myself falling into.
The first topic is using agents to researching topics.
For many folks, this can be shocking as agentics are exceptionally confident and will tell you what you would like.
They search the web faster and analyzing text and synthesizing it into something usable.

## First must come the problem

I work on the [Synthetic Monitoring](https://grafana.com/docs/grafana-cloud/testing/synthetic-monitoring/) product which started offering browser checks about a year ago(May 2025). 
Browser checks had a healthy adoption rate, and with that has come growing pains.

* [chromium](https://chromium.googlesource.com/chromium/src/+/HEAD/docs/README.md) has extensive documentation can be tough to read
* discovering written posts about scaling chromium on k8s 
* no tools exist to help measure performance

Enter agents!

## Researching with agents

Here was my prompt for Claude:

> This is purely a planning and research session. The end result should be a written document that I can refer to in the next phase. I'm looking to learn more about how to collect metrics on running chromium instances. The context is I run a chromium wrapper in grafana/crocochrome that is invoked from k6 runners, and I run these at scale in kubernetes. I'd like to figure out a way of gathering more runtime diagnostic data on chromium sessions that are spawned and execute k6 browser tests.

What happened from this point is:

* Multiple agents were spawned
* Each agent was tasked with a specific part of the problem:
  * Chrome DevTools Protocols(CDP)
  * OS-level chromium metrics
  * crocochrome architecture
  * chromium monitoring in k8s

As I viewed the agents, what each one was doing was effectively

* [Web search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool) invocations
* piping results to python scripts to extract content
* aggregating content into summaries

At the end, the main agent collected all of the results into a final markdown file with it's [findings](https://gist.github.com/Pokom/ad2031bc8ae234b990118e680a5055c1#file-writeup-md).

## Summary

Of course, agents and LLM's are exceptionally confident and are there to please.
So the first thing I always do is read through the summary as best as I can and try and pressure test it.
The first draft brought together _11_ sections of content plus references.
That's overwhelming as someone who's just trying to dip there toes and learn more.
For me, the most effective sections that were produced were:

* [cdp interface](https://gist.github.com/Pokom/ad2031bc8ae234b990118e680a5055c1#2-cdp-based-metrics-primary-interface)
* [what's missing](https://gist.github.com/Pokom/ad2031bc8ae234b990118e680a5055c1#whats-missing)

From there, I added one more prompt because I was overwhelmed, and asked claude to simplify things as much as possible and provide learning resources.
The result was [learning cdp](https://gist.github.com/Pokom/ad2031bc8ae234b990118e680a5055c1#learning-cdp), which was honestly more effective than anything else.

## Was it useful?

This exercise got me closer to material much faster than I could have without claude.
The prompt I provided was too broad and I ended up with about 500 lines of text that took me another hour or so to read through.
The links it provided were the most valuable aspect as it got me closer to where I wanted to be.
It's _almost_ like I created a wikipedia article on the subject that's complete vibes.
So overall, _yes_ it was useful in getting me material faster.
_No_, I still do not have a confident answer on how to collect better performance metrics from chromium.
What I _do_ have is guided material I can use to spin up experiments to dig deeper!
Which leads well into how I use claude to experiment and learn!

## What's changed

My workflow for researching topics has completely shifted.
For my _whole life_, it's generally been: `Have problem => Search the internet with appropriate query => read through top 5 results => repeat until satisfied`
Early search engines weren't great, but were helpful enough.
Google reshaped the search engine market and had a market share for almost 20 years.
Wikipedia and StackOverflow were my mainstays for anything science + computer science related.
HowStuffWorks was a great surface level resource for learning about general things.
Reddit was a place to find communities around niche topics.
Basically, I learned not just _how_ to find things, but _where_ reliable information could be found.

It now makes more sense how Google took such a big risk placing AI results at the topic of their searches.
ChatGPT was an existential threat, but in hindsight it wasn't the one Google was worried about.
Harnesses like Claude were the things Google was worried about.
I no longer bounce between searching the internet and the terminal for work.

## Where to go from here

So now I'm spending a considerable amount of time reformulating how I research and discover topics.
LLM's and agents aren't perfect, but neither are search engines or the internet.
These are all tools that help you discover, but the onus still is on the human to decide what to do with that information.
What's changed is how _fast_ I can gather information.
My wetware is still the bottleneck, and so I must figure out ways of keeping these two in sync.

What I've found that works for me though is:

* have a problem
* launch a new session in some harness(claude for example)
* stick to planning mode and work to gather as much information as possible
* distill information into some written markdown file
* iterate

The artifact produced from this step is then used as the basis for further work.
It's far from perfect, but that's fine.
Search engines and the internet is far from perfect, but you use the tools the best way you can.
