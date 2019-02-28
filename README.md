# Blog

In this repository I will be writing my blog posts.

I am going to use the static site generator [hugo](https://gohugo.io/).

The blog is deployed on github pages. The public folder is a submodule for the github pages
repository which is deployed.

## Local changes

In order to test local changes both in content or style using `hugo server`:

```bash
make local
```

## Generate site and publish

In order to generate the site to be published:

```bash
make generate
```

In order to push the changes to github pages and make them public push the changes on the submodule.

## Emojis enabled

In the `config.toml` file I have enabled emojis. Check the [cheatsheet](https://www.webfx.com/tools/emoji-cheat-sheet/)
to know how to add them.

## TODO List

- [ ] Add fontawesome to page for external links
- [ ] Add navigation bar as floating on the top