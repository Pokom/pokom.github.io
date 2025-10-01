+++
date = '2025-09-30T22:02:23-04:00'
draft = false 
title = 'One Month with Arch'
readTime = true
+++

I had a laptop refresh at work and decided to try running [Arch Linux](https://archlinux.org/) for the first time.
I've used Ubuntu for workstations at a few other jobs, but not all of the places I worked supported this.
The challenge I had for myself was to get a basic setup within a weeks time and then decide if I wanted to switch back to Ubuntu.
A week turned into a month, but here's some of my experiences.

## Initial Impressions

Arch has a reputation as being a challening linux distro to get up and running.
I'm no stranger to running linux, but I would in no way consider myself an expert. 
So I was expecting my learning curve to be a bit steeper as most things worked (with a bit of effort) out of the box.
With a little bit of effort largely meant reading through the [installation guide](https://wiki.archlinux.org/title/Installation_guide) and tweaking things to get it to work.


### First boot

What was fun about Arch is that the install gives you a kernel and _very_ little else.
During installation you can install packages, useful ones being `networkmanager|(n)vim|sway|firefox`, however there's no recommendation on what do to.
After that you're dropped into a tty screen and if you (hopefully) setup an admin password(`passwd`) or regular user, you can login.
Otherwise, it's back to the boot media to create those users.
Once you're logged in, you're basically given what I would consider a server. 

At this point, I think it's totally fair to wonder why you wouldn't just install Ubuntu or Debian.
You'd likely already have a working machine with all of your tools setup. 

Without installing extra packages, the following things do not work:
- display manager
- networking
- bluetooth
- audio
- laptop clamshell functionality
- basic keyboard shortcuts like volume up/down
- network discovery for things like printers

Despite all of this, what I found most enjoyable was going through each of those components and learning a little bit deeper about how they work. 

## Tools learned

Here's a bit of what I learned in the first week.
- accessing wifi without a gui(`nmcli`, `networkmanager`)
- setting up disk from scratch(`lsblk`, `fdisk`, `cfisdk`)
- encrypting full disks(`dm-crypt`, `luks`, `lvm`, `(pv|vg|lv)create`, `cryptsetup`)
- filesystems(`mkfs.$`, `mount`)
- bootloaders(`grub`)
- audio/video(`pactl`, `pipewire`)
- bluetooth(`bluez`)

## Biggest Surprise

Arch has a well earned reputation for it's learning curve. 
If you've used any Linux system before, then there's a good chance you could piece things together.
But what suprised me is how reasonable it was to get to a decent spot.
Arch has is one of the better curated wiki's with documentation for almost any problem you have.
If that doesn't work, they have a fairly active forum(though this is daunting).
I used tools that I normally wouldn't have considered(`strace`) to debug problems I was having.
Every now and then I find setting things up easier on Arch then on Ubuntu(`obs` + `scarlett focusrite`).

## Sharp Edges

One of the more sharp edges that I'm having is around Sway + Wayland.
A considerable amount of Gui's are built with some form of [QT](https://www.qt.io/product/framework).
So for some reason, when I launch some GUI based applications, I run into some weird states.
Chromium + Signal I need to launch with a special flag.
I'm sure there's a good reason for it, but to me it's a bit magical.
