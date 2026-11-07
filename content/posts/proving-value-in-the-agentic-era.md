+++
date = '2026-05-01'
draft = true
title = 'Proving Value in the Agentic Era'
readTime = true
+++

A recent article came out from Uber where they burned through a years worth of budget in the first four months of the year.
The associated hackernews thread on is quite worthwhile to read through.
Agents, and agentic coding, has proven to be more divisive in 6 months than k8s has in almost a decade of it's existence.
Proponents of it think the value is self explanatory and requires no further proof.
Nay sayers claim not only is the spend on tokens shameful, the resulting work requires 10x the time to clean up.
Like most things, the truth is somewhere between the two.
But there's something really important that's worthwhile considering: Could you prove today that agents have provided value in your day to day life?

## 10x programmers

Probably my favorite divisive phrases is the mythical 10x programmer.
Those that are so well endowed in the craft or programming, they can produce 10x more then their peers.
Now, the more interesting and subtle question is "10x" what?
10x more code? That's probably a bad measure if you're trying to write simple/dry/reusable code.
10x more features? Also a bad measure if you care about UX and adoption rates.
10x more revenue? That doesn't quite make sense if you're doing SRE/Platform work.
Turns out that it's quite hard to define what exactly a 10x programmer is, and if they even exist. 

An inflection point for me around this topic was at Grafana's platform team offsite a few years back and our CTO joined us.
I forgot exactly how it came up, but the way he had phrased it was roughly "Whatever you work on should provide 10x your salary in value to the company".
At the time, I was working on things like cloudcost-exporter which helped our development teams measure cost of their workloads.
So anything I shipped should have enough leverage to potentially save us 10x my salary in a year.
At the time, this was quite easy for me to prioritize:
* cpu/memory 
* object storage
* networking

For the better part of 18 months, most of my focus was figuring out how to better provide these metrics to engineers so they could know where to optimize their workloads. 
If I wasn't focusing on things like this, then it was very likely what I was doing didn't provide 10x my salary in value to the company.
Reading through the article and hackernews thread brought back this memory and made me think pretty deeply what this means in today's terms. 

## 10x in the agentic era

With that rough heuristic, I started to ask myself what this looks like with agents.
Let's say right now, I spend $500/month on tokens.
Could I reasonably say my usage of llm's generated $5k worth of value?
It's very easy to use LLM's to generate 10x the code I was doing before, meaning if I was a "10x engineer" before, I'm now a "100x engineer".
But measure of code is known to be a pretty poor metric to track value to an organization.
Similar story with features.
Revenue is a bit more interesting, as this is usually a lagging indicator that is tough to trace back to one specific feature you released.

So it made me really think, what have I done where I can be confident that what I've spent on tokens can be directly tied to a 10x in value.
A clear one for me was recent work I had done to improve spinning up a new region for my product at Grafana.

The work basically boiled down to translating shell scripts and README runbooks to go/terraform.
It would've taken days/weeks to do with a low degree of confidence in the resulting output.
So I started small with an LLM and carefully provided as much context as I could, generated a plan, and then let it loose.
Each step of the way I had a clear way of testing the output: 
* point the output towards a development environment
* execute the generated code
* validate the output matched an existing environment

In the end, I migrated 1000's of lines of shell scripting and README runbooks into code and cut down the time to bootstrap a new region for my product from a week to hours.
The cost was $100's in tokens and a few weeks of my time.
Now every time we need to bootstrap a new region, it takes hours instead of days.
Over the course of three years, this will pay back many multiples of the time and tokens spent.
Even if all the LLM saved me was a weeks worth of time, it paid for itself in the time I saved on my salary.

## LLM's meet "No free lunch"

We're very quickly heading towards the llm's equivalent of learning there is [no such thing as free lunch](https://en.wikipedia.org/wiki/No_such_thing_as_a_free_lunch).
It's not the first time this has happened in the software world.
Software got free performance improvements for decades as long as they could compile on the latest cpu architectures.

