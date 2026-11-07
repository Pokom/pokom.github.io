+++
date = '2026-10-10T13:27:31Z'
draft = true
title = 'Product Engineering'
readTime = true
+++

A new title has been popping in conversations that I'm not terribly familiar with: Product Engineering.
[Google trends](https://trends.google.com/explore?q=Product%20Engineer&date=all&geo=US) shows that it started to really pop up January 2022.

![Google Trends interest over time for "Product Engineer" in the US, 2004 to present](google-trends.png)

It's relatively new to me, so let's see who's written about it:
* PostHog: https://posthog.com/product-engineer/what-is-a-product-engineer
    * They quote incident.io, which I can't actually find the source
    * https://posthog.com/blog/why-product-engineering-is-so-fun
* Shopify(2018): https://sherifmansour.medium.com/product-engineers-f424da766871
* Lee Robison(https://leerob.com/product-engineers)
* Pragmatic Engineer(2019): https://blog.pragmaticengineer.com/the-product-minded-engineer/#tips-to-become-a-more-product-minded-engineer


A lot went right, but a lot went wrong.
In my opinion, the biggest mistake made was thinking rebranding some roles as DevOps engineers without changing the underlying culture. 
I write this to provide myself a framework that hopefully amplifies the lessons learned from DeVops practices, without going through the pain of having to explain a new job title/function/

## Brief History of DevOps

Back in 2009, Allspaw and Hammond gave their first talk at a Velocity(https://www.youtube.com/watch?v=LdOe18KhtT4) about how dev and ops works together at Flickr to release 10+ times a day.
If you haven't watching this, please do.
This is foundational material that influenced the industry for the better part of 10 years.
Shifting left, continuous releases, continuous improvements, continuous ${PHRASE}, were put into the mainstream nomenclature.
The Pheonix Project and the DevOps Manual were derived from the talk.

For myself, this idea of dev teams and ops teams working together to deliver value for customers was intoxicating.
I still have PTSD around having to submit IT tickets to provision a virtual machine, waiting 3-6 months for it the be provisioned, and then finding out it was not setup correctly.
Plenty of late nights and weekend shifts to "safely release" that was entirely manual.
I've passed plenty of code over the proverbial wall, only to find it didn't land well, which resulted in war rooms with 50+ people around telephones trying to figure out how to get sites back online.
So the notion of having these two areas working closer together was _brilliant_.

Then, came the DevOps engineers.
In my opinion, this came from larger companies that knew they needed to shift the culture, and thought rebranding a role would get them out of it.
The same silo's existed with all of the same problems, but at least there was DevOps engineers there to solve the problem!

## What I learned as DevOps engineer

Despite hating the title, I still had bills to pay and an interest in improving culture and the end result for customers.
So, I did spent the better part of 3 years as a DevOps engineer.
THe main problem I had is my role was highly ambiguous.
Was I a developer that focused my efforts on automating operations(IaC, o11y, CI/CD pipelines etc)?
Or was I
