# pokom.github.io

Welcome to my personal websites codebase!
It is built with [hugo](https://gohugo.io/) and currently using the [smol](https://github.com/colorchestra/smol) theme.

## Building

After cloning, you need to pull the submodules which contains the themes used by the website:

```sh
git submodule init
git submodule update
```

Then you can run a dev server like so:

```
make dev
```

If you do not have make installed, it's easy enough to look at the `Makefile` and find the associated command.
