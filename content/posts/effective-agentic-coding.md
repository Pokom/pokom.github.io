+++
date = '2026-03-16T03:29:59-04:00'
draft = false
title = 'Effective Agentic Coding'
+++

I want to start capturing different ways of using agentic tools effectively.
Most of the discourse I see online around agentic tools such as Claude/Codex/Gemini focus around how to generate code.
However, my personal experience has been that writing code is likely the last thing I end up using the tooling for.
After ~4 months of using agentic tools, I've started to recognize distinct workflows:

1. research and investigate
1. data gathering
1. learn and experiment
1. explore implementation details
1. Finally, coding

Let me explain each of these areas in a detail.

## Research and investigate

This is likely controversial, but I've found agentic tools to be effective at research.
What I _mean_ by research is very narrowly focused towards searching the web in mass and collecting sources.
I find this to be no different then if I were to manually search Google and find things, except it can be done 100's times faster then I could.

With the right prompts, you can instruct your agent to always provide sources that you _should_ verify yourself.
Used effectively, you can cut gathering sources from hours to minutes and then spend the time digging deeper into what was discovered.

## Data Gathering

Agentic tools are also effective at discovering an API and working with it.
Take for example GitHub: `gh` cli provides a mechanism to craft queries against the rest API or the GraphQL endpoint.
If you've ever written tooling against GitHub's api's, I imagine the last thing you would say is the documentation is user friendly.
Turns out agentic tools do not care about that!

Here's a real example: I wanted to pull data for a subset of repositories my team is responsible for and write it out to json.
I can guarantee that an agent will do it faster then you could, even with experience.
I'll dive deeper into how you can basically turn a non-deterministic system and have it gather data and provide a mechanism to perform the actions again in a deterministic fashion.

## Learn and experiment

This is the area I struggle the most with.
Learning is (in my opinion) the most important skill someone needs to have a long career as a software engineer.
Agentic tools make it _seem_ like we no longer need to learn, as they can do all the writing for you.
Long term, I think this is the wrong approach, and I need to come to terms with how to learn effectively with LLM's.

The good news is, with proper prompting, you can use LLM's to speed up your learning.
And with a bit of ingenuity with skills, llm's can help reinforce learning.

## Exploring implementation details

The entire premise is that you treat a context window as a whiteboard where you're only goal is to scope and refine.
You instruct the LLM to enter some form of planning mode, and you go back and forth with an idea until you're comfortable with it.
It's very similar to doing a white boarding exercise for systems design problem.
How effective these sessions are will be entirely bound by your knowledge and previous experience.

## Coding

For the final thing I use agentic tools for: Coding!
After spending the proper amount of time exercising my wet matter, I take all of the outputs of the previous stages and work with the agent to write code.
Success here is entirely dependant on how well the previous stages went.
Too broad of a scope, and you end up with the work of an intern.
Narrow enough, and you end up with elegant code that you'll be happy to submit a PR for and stay "Built by Claude".

## Wrapping up

These are the main areas I've found value with using agentic tooling.
My plan is to go deeper into each area and provide concrete examples of how I've used them.
I'm by no means an expert on this, I'm learning as we go just like everyone else.
What I sorely miss though is stripped down, realistic takes on these tools.
So if you know of sources that are just trying to explore and learn, please do share!
