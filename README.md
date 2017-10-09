# jlenv: Simple Julia Version Management

This project was forked from [rbenv](https://github.com/rbenv/rbenv.git)

---

Use jlenv to pick a Julia version for your application and guarantee
that your development environment matches production.

**Powerful in development.** Specify your app's Julia version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Julia. Just Works™
  from the command line and with app servers like [Pow](http://pow.cx).
  Override the Julia version anytime: just set an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. The Julia version
  dependency lives in one place—your app—so upgrades and rollbacks are
  atomic, even when you switch versions.

**One thing well.** jlenv is concerned solely with switching Julia
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own Julia versions, or
  use the [julia-build][]
  plugin to automate the process.
  See more [plugins on the
  wiki](https://github.com/jlenv/rbenv/wiki/Plugins).

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Julia Version](#choosing-the-julia-version)
  * [Locating the Julia Installation](#locating-the-julia-installation)
* [Installation](#installation)
  * [Homebrew on macOS](#homebrew-on-macos)
    * [Upgrading with Homebrew](#upgrading-with-homebrew)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading with Git](#upgrading-with-git)
  * [How jlenv hooks into your shell](#how-jlenv-hooks-into-your-shell)
  * [Installing Julia versions](#installing-julia-versions)
    * [Installing Julia gems](#installing-julia-gems)
  * [Uninstalling Julia versions](#uninstalling-julia-versions)
  * [Uninstalling jlenv](#uninstalling-jlenv)
* [Command Reference](#command-reference)
  * [jlenv local](#jlenv-local)
  * [jlenv global](#jlenv-global)
  * [jlenv shell](#jlenv-shell)
  * [jlenv versions](#jlenv-versions)
  * [jlenv version](#jlenv-version)
  * [jlenv rehash](#jlenv-rehash)
  * [jlenv which](#jlenv-which)
  * [jlenv whence](#jlenv-whence)
* [Environment variables](#environment-variables)
* [Development](#development)

## How It Works

At a high level, jlenv intercepts Julia commands using shim
executables injected into your `PATH`, determines which Julia version
has been specified by your application, and passes your commands along
to the correct Julia installation.

### Understanding PATH

When you run a command like `julia`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

jlenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.jlenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, jlenv maintains shims in that
directory to match every Julia command across every installed version
of Julia.

Shims are lightweight executables that simply pass your command along
to jlenv. So with jlenv installed, when you run, say, `julia`, your
operating system will do the following:

* Search your `PATH` for an executable file named `julia`
* Find the jlenv shim named `julia` at the beginning of your `PATH`
* Run the shim named `julia`, which in turn passes the command along to
  jlenv

### Choosing the Julia Version

When you execute a shim, jlenv determines which Julia version to use by
reading it from the following sources, in this order:

1. The `JLENV_VERSION` environment variable, if specified. You can use
   the [`jlenv shell`](#jlenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.julia-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.julia-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.julia-version` file in the current working
   directory with the [`jlenv local`](#jlenv-local) command.

4. The global `~/.jlenv/version` file. You can modify this file using
   the [`jlenv global`](#jlenv-global) command. If the global version
   file is not present, jlenv assumes you want to use the "system"
   Julia—i.e. whatever version would be run if jlenv weren't in your
   path.

### Locating the Julia Installation

Once jlenv has determined which version of Julia your application has
specified, it passes the command along to the corresponding Julia
installation.

Each Julia version is installed into its own directory under
`~/.jlenv/versions`. For example, you might have these versions
installed:

* `~/.jlenv/versions/v0.6.0/`
* `~/.jlenv/versions/v0.6.0-rc3/`
* `~/.jlenv/versions/v0.5.0/`

Version names to jlenv are simply the names of the directories in
`~/.jlenv/versions`.

## Installation

1. Install jlenv.
   Note that this also installs `julia-build`, so you'll be ready to
   install other Julia versions out of the box.

2. Run `jlenv init` and follow the instructions to set up
   jlenv integration with your shell. This is the step that will make
   running `julia` "see" the Julia version that you choose with jlenv.

3. Close your Terminal window and open a new one so your changes take
   effect.

4. That's it! Installing jlenv includes julia-build, so now you're ready to
   [install some other Julia versions](#installing-julia-versions) using
   `jlenv install`.


### Basic GitHub Checkout

This will get you going with the latest version of jlenv without needing
a systemwide install.

1. Clone jlenv into `~/.jlenv`.

    ~~~ sh
    $ git clone https://github.com/jlenv/jlenv.git ~/.jlenv
    ~~~

    Optionally, try to compile dynamic bash extension to speed up jlenv. Don't
    worry if it fails; jlenv will still work normally:

    ~~~
    $ cd ~/.jlenv && src/configure && make -C src
    ~~~

2. Add `~/.jlenv/bin` to your `$PATH` for access to the `jlenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.jlenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Run `~/.jlenv/bin/jlenv init` and follow the instructions to set up
   jlenv integration with your shell. This is the step that will make
   running `julia` "see" the Julia version that you choose with jlenv.

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.)

5. _(Optional)_ Install [julia-build][], which provides the
   `jlenv install` command that simplifies the process of
   [installing new Julia versions](#installing-julia-versions).

#### Upgrading with Git

If you've installed jlenv manually using Git, you can upgrade to the
latest version by pulling from GitHub:

~~~ sh
$ cd ~/.jlenv
$ git pull
~~~

### How jlenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`jlenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `jlenv init` actually does:

1. Sets up your shims path. This is the only requirement for jlenv to
   function properly. You can do this by hand by prepending
   `~/.jlenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.jlenv/completions/jlenv.bash` will set that
   up. There is also a `~/.jlenv/completions/jlenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `jlenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   jlenv and plugins to change variables in your current shell, making
   commands like `jlenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `jlenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `jlenv init -` for yourself to see exactly what happens under the
hood.

### Installing Julia versions

The `jlenv install` command doesn't ship with jlenv out of the box, but
is provided by the [julia-build][] project. If you installed it either
as part of GitHub checkout process outlined above or via Homebrew, you
should be able to:

~~~ sh
# list all available versions:
$ jlenv install -l

# install a Julia version:
$ jlenv install v0.6.0
~~~

Alternatively to the `install` command, you can download and compile
Julia manually as a subdirectory of `~/.jlenv/versions/`. An entry in
that directory can also be a symlink to a Julia version installed
elsewhere on the filesystem. jlenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Julia version.

### Uninstalling Julia versions

As time goes on, Julia versions you install will accumulate in your
`~/.jlenv/versions` directory.

To remove old Julia versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Julia version with the `jlenv prefix` command, e.g. `jlenv prefix
1.8.7-p357`.

The [julia-build][] plugin provides an `jlenv uninstall` command to
automate the removal process.

### Uninstalling jlenv

The simplicity of jlenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** jlenv managing your Julia versions, simply remove the
  `jlenv init` line from your shell startup configuration. This will
  remove jlenv shims directory from PATH, and future invocations like
  `julia` will execute the system Julia version, as before jlenv.

  `jlenv` will still be accessible on the command line, but your Julia
  apps won't be affected by version switching.

2. To completely **uninstall** jlenv, perform step (1) and then remove
   its root directory. This will **delete all Julia versions** that were
   installed under `` `jlenv root`/versions/ `` directory:

        rm -rf `jlenv root`

   If you've installed jlenv using a package manager, as a final step
   perform the jlenv package removal. For instance, for Homebrew:

        brew uninstall jlenv

## Command Reference

Like `git`, the `jlenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### jlenv local

Sets a local application-specific Julia version by writing the version
name to a `.julia-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `JLENV_VERSION` environment variable or with the `jlenv shell`
command.

    $ jlenv local v0.6.0

When run without a version number, `jlenv local` reports the currently
configured local version. You can also unset the local version:

    $ jlenv local --unset

### jlenv global

Sets the global version of Julia to be used in all shells by writing
the version name to the `~/.jlenv/version` file. This version can be
overridden by an application-specific `.julia-version` file, or by
setting the `JLENV_VERSION` environment variable.

    $ jlenv global v0.6.0

The special version name `system` tells jlenv to use the system Julia
(detected by searching your `$PATH`).

When run without a version number, `jlenv global` reports the
currently configured global version.

### jlenv shell

Sets a shell-specific Julia version by setting the `JLENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ jlenv shell v0.6.0

When run without a version number, `jlenv shell` reports the current
value of `JLENV_VERSION`. You can also unset the shell version:

    $ jlenv shell --unset

### jlenv versions

Lists all Julia versions known to jlenv, and shows an asterisk next to
the currently active version.

    $ jlenv versions
      v0.6.0
    * v0.6.0-rc1 (set by /Users/sam/.jlenv/version)

### jlenv version

Displays the currently active Julia version, along with information on
how it was set.

    $ jlenv version
    v0.6.0 (set by /Users/sam/.jlenv/version)

### jlenv rehash

Installs shims for all Julia executables known to jlenv (i.e.,
`~/.jlenv/versions/*/bin/*`). Run this command after you install a new
version of Julia, or install a gem that provides commands.

    $ jlenv rehash

### jlenv which

Displays the full path to the executable that jlenv will invoke when
you run the given command.

    $ jlenv which julia
    /Users/sam/.jlenv/versions/v0.6.0/bin/julia

### jlenv whence

Lists all Julia versions with the given command installed.

    $ jlenv whence julia
    v0.6.0

## Environment variables

You can affect how jlenv operates with the following settings:

name | default | description
-----|---------|------------
`JLENV_VERSION` | | Specifies the Julia version to be used.<br>Also see [`jlenv shell`](#jlenv-shell)
`JLENV_ROOT` | `~/.jlenv` | Defines the directory under which Julia versions and shims reside.<br>Also see `jlenv root`
`JLENV_DEBUG` | | Outputs debug information.<br>Also as: `jlenv --debug <subcommand>`
`JLENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for jlenv hooks.
`JLENV_DIR` | `$PWD` | Directory to start searching for `.julia-version` files.

## Development

The jlenv source code is [hosted on
GitHub](https://github.com/jlenv/jlenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/HiroakiMikami/jlenv/issues).


  [julia-build]: https://github.com/HiroakiMikami/julia-build#readme
  [hooks]: https://github.com/rbenv/rbenv/wiki/Authoring-plugins#jlenv-hooks
