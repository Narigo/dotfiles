# dotfiles - Narigo

Setting up my environments in a modular fashion.

A lot of settings and commands are taken from
[Mathias Bynens dotfiles repository](https://github.com/mathiasbynens/dotfiles). A great resource what you can set up!

**Update February 2020**

This repository needs a major overhaul. Since Mac OS changed their default 
shell to zsh and I kind of get used to it, I should put aliases into oh-my-zsh
plugins.

I started sandboxing my applications through docker as well. With installing
[docker-box](https://github.com/compose-us-research/docker-box), I can use all
of the programming languages I need quite quickly and especially use it more
safely.

I have added Automator workflows that I don't want to miss on my next machine.
There are flows to automatically encrypt a PDF and send it through email,
sorting PDF documents after scanning them with a document feeder that cannot
turn pages and a quick action to turn a screen recording `.mov` into a `.gif`.

____

## Mac OS X

1. Install [Homebrew](https://brew.sh/).
2. Run `. install.sh` to setup the environment. For a dry-run to see what will be written, use `. install.sh -d`.

## Modules

To create a new module, add a `.settings-<your-platform>` and write down the settings you want to use.

There are multiple settings you can use:

### copy_files_to

Copies all files into the set directory.

### platform_file

Concatenates all files into the set file.
