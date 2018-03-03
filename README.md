# dotfiles - Narigo

Setting up my environments in a modular fashion.

A lot of settings and commands are taken from [Mathias Bynens dotfiles 
repository](https://github.com/mathiasbynens/dotfiles). A great resource what you can set up!

## Mac OS X

1. Install Homebrew.
2. Run `. install.sh` to setup the environment. For a dry-run to see what will be written, use `. install.sh -d`.


## Modules

To create a new module, add a `.settings-<your-platform>` and write down the settings you want to use.

There are multiple settings you can use:

### copy_files_to

Copies all files into the set directory.

### platform_file

Concatenates all files into the set file.
