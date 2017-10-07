# Groom your app’s Ruby environment with jlenv.

Use jlenv to pick a Ruby version for your application and guarantee
that your development environment matches production. Put jlenv to work
with [Bundler](http://bundler.io/) for painless Ruby upgrades and
bulletproof deployments.

**Powerful in development.** Specify your app's Ruby version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Ruby. Just Works™
  from the command line and with app servers like [Pow](http://pow.cx).
  Override the Ruby version anytime: just set an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. With jlenv and [Bundler
  binstubs](https://github.com/jlenv/jlenv/wiki/Understanding-binstubs)
  you'll never again need to `cd` in a cron job or Chef recipe to
  ensure you've selected the right runtime. The Ruby version
  dependency lives in one place—your app—so upgrades and rollbacks are
  atomic, even when you switch versions.

**One thing well.** jlenv is concerned solely with switching Ruby
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own Ruby versions, or
  use the [ruby-build][]
  plugin to automate the process. Specify per-application environment
  variables with [jlenv-vars](https://github.com/jlenv/jlenv-vars).
  See more [plugins on the
  wiki](https://github.com/jlenv/jlenv/wiki/Plugins).

[**Why choose jlenv over
RVM?**](https://github.com/jlenv/jlenv/wiki/Why-jlenv%3F)

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Ruby Version](#choosing-the-ruby-version)
  * [Locating the Ruby Installation](#locating-the-ruby-installation)
* [Installation](#installation)
  * [Homebrew on macOS](#homebrew-on-macos)
    * [Upgrading with Homebrew](#upgrading-with-homebrew)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading with Git](#upgrading-with-git)
  * [How jlenv hooks into your shell](#how-jlenv-hooks-into-your-shell)
  * [Installing Ruby versions](#installing-ruby-versions)
    * [Installing Ruby gems](#installing-ruby-gems)
  * [Uninstalling Ruby versions](#uninstalling-ruby-versions)
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

At a high level, jlenv intercepts Ruby commands using shim
executables injected into your `PATH`, determines which Ruby version
has been specified by your application, and passes your commands along
to the correct Ruby installation.

### Understanding PATH

When you run a command like `ruby` or `rake`, your operating system
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
directory to match every Ruby command across every installed version
of Ruby—`irb`, `gem`, `rake`, `rails`, `ruby`, and so on.

Shims are lightweight executables that simply pass your command along
to jlenv. So with jlenv installed, when you run, say, `rake`, your
operating system will do the following:

* Search your `PATH` for an executable file named `rake`
* Find the jlenv shim named `rake` at the beginning of your `PATH`
* Run the shim named `rake`, which in turn passes the command along to
  jlenv

### Choosing the Ruby Version

When you execute a shim, jlenv determines which Ruby version to use by
reading it from the following sources, in this order:

1. The `JLENV_VERSION` environment variable, if specified. You can use
   the [`jlenv shell`](#jlenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.ruby-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.ruby-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.ruby-version` file in the current working
   directory with the [`jlenv local`](#jlenv-local) command.

4. The global `~/.jlenv/version` file. You can modify this file using
   the [`jlenv global`](#jlenv-global) command. If the global version
   file is not present, jlenv assumes you want to use the "system"
   Ruby—i.e. whatever version would be run if jlenv weren't in your
   path.

### Locating the Ruby Installation

Once jlenv has determined which version of Ruby your application has
specified, it passes the command along to the corresponding Ruby
installation.

Each Ruby version is installed into its own directory under
`~/.jlenv/versions`. For example, you might have these versions
installed:

* `~/.jlenv/versions/1.8.7-p371/`
* `~/.jlenv/versions/1.9.3-p327/`
* `~/.jlenv/versions/jruby-1.7.1/`

Version names to jlenv are simply the names of the directories in
`~/.jlenv/versions`.

## Installation

**Compatibility note**: jlenv is _incompatible_ with RVM. Please make
  sure to fully uninstall RVM and remove any references to it from
  your shell initialization files before installing jlenv.

### Homebrew on macOS

If you're on macOS, we recommend installing jlenv with
[Homebrew](https://brew.sh).

1. Install jlenv.

    ~~~ sh
    $ brew install jlenv
    ~~~

   Note that this also installs `ruby-build`, so you'll be ready to
   install other Ruby versions out of the box.

2. Run `jlenv init` and follow the instructions to set up
   jlenv integration with your shell. This is the step that will make
   running `ruby` "see" the Ruby version that you choose with jlenv.

3. Close your Terminal window and open a new one so your changes take
   effect.

4. Verify that jlenv is properly set up using this
   [jlenv-doctor](https://github.com/jlenv/jlenv-installer/blob/master/bin/jlenv-doctor) script:

    ~~~ sh
    $ curl -fsSL https://github.com/jlenv/jlenv-installer/raw/master/bin/jlenv-doctor | bash
    Checking for `jlenv' in PATH: /usr/local/bin/jlenv
    Checking for jlenv shims in PATH: OK
    Checking `jlenv install' support: /usr/local/bin/jlenv-install (ruby-build 20170523)
    Counting installed Ruby versions: none
      There aren't any Ruby versions installed under `~/.jlenv/versions'.
      You can install Ruby versions like so: jlenv install 2.2.4
    Checking RubyGems settings: OK
    Auditing installed plugins: OK
    ~~~

5. That's it! Installing jlenv includes ruby-build, so now you're ready to
   [install some other Ruby versions](#installing-ruby-versions) using
   `jlenv install`.


#### Upgrading with Homebrew

To upgrade to the latest jlenv and update ruby-build with newly released
Ruby versions, upgrade the Homebrew packages:

~~~ sh
$ brew upgrade jlenv ruby-build
~~~


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
   running `ruby` "see" the Ruby version that you choose with jlenv.

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.)

5. Verify that jlenv is properly set up using this
   [jlenv-doctor](https://github.com/jlenv/jlenv-installer/blob/master/bin/jlenv-doctor) script:

    ~~~ sh
    $ curl -fsSL https://github.com/jlenv/jlenv-installer/raw/master/bin/jlenv-doctor | bash
    Checking for `jlenv' in PATH: /usr/local/bin/jlenv
    Checking for jlenv shims in PATH: OK
    Checking `jlenv install' support: /usr/local/bin/jlenv-install (ruby-build 20170523)
    Counting installed Ruby versions: none
      There aren't any Ruby versions installed under `~/.jlenv/versions'.
      You can install Ruby versions like so: jlenv install 2.2.4
    Checking RubyGems settings: OK
    Auditing installed plugins: OK
    ~~~

6. _(Optional)_ Install [ruby-build][], which provides the
   `jlenv install` command that simplifies the process of
   [installing new Ruby versions](#installing-ruby-versions).

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

### Installing Ruby versions

The `jlenv install` command doesn't ship with jlenv out of the box, but
is provided by the [ruby-build][] project. If you installed it either
as part of GitHub checkout process outlined above or via Homebrew, you
should be able to:

~~~ sh
# list all available versions:
$ jlenv install -l

# install a Ruby version:
$ jlenv install 2.0.0-p247
~~~

Alternatively to the `install` command, you can download and compile
Ruby manually as a subdirectory of `~/.jlenv/versions/`. An entry in
that directory can also be a symlink to a Ruby version installed
elsewhere on the filesystem. jlenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Ruby version.

#### Installing Ruby gems

Once you've installed some Ruby versions, you'll want to install gems.
First, ensure that the target version for your project is the one you want by
checking `jlenv version` (see [Command Reference](#command-reference)). Select
another version using `jlenv local 2.0.0-p247`, for example. Then, proceed to
install gems as you normally would:

```sh
$ gem install bundler
```

**You don't need sudo** to install gems. Typically, the Ruby versions will be
installed and writeable by your user. No extra privileges are required to
install gems.

Check the location where gems are being installed with `gem env`:

```sh
$ gem env home
# => ~/.jlenv/versions/<ruby-version>/lib/ruby/gems/...
```

### Uninstalling Ruby versions

As time goes on, Ruby versions you install will accumulate in your
`~/.jlenv/versions` directory.

To remove old Ruby versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Ruby version with the `jlenv prefix` command, e.g. `jlenv prefix
1.8.7-p357`.

The [ruby-build][] plugin provides an `jlenv uninstall` command to
automate the removal process.

### Uninstalling jlenv

The simplicity of jlenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** jlenv managing your Ruby versions, simply remove the
  `jlenv init` line from your shell startup configuration. This will
  remove jlenv shims directory from PATH, and future invocations like
  `ruby` will execute the system Ruby version, as before jlenv.

  `jlenv` will still be accessible on the command line, but your Ruby
  apps won't be affected by version switching.

2. To completely **uninstall** jlenv, perform step (1) and then remove
   its root directory. This will **delete all Ruby versions** that were
   installed under `` `jlenv root`/versions/ `` directory:

        rm -rf `jlenv root`

   If you've installed jlenv using a package manager, as a final step
   perform the jlenv package removal. For instance, for Homebrew:

        brew uninstall jlenv

## Command Reference

Like `git`, the `jlenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### jlenv local

Sets a local application-specific Ruby version by writing the version
name to a `.ruby-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `JLENV_VERSION` environment variable or with the `jlenv shell`
command.

    $ jlenv local 1.9.3-p327

When run without a version number, `jlenv local` reports the currently
configured local version. You can also unset the local version:

    $ jlenv local --unset

### jlenv global

Sets the global version of Ruby to be used in all shells by writing
the version name to the `~/.jlenv/version` file. This version can be
overridden by an application-specific `.ruby-version` file, or by
setting the `JLENV_VERSION` environment variable.

    $ jlenv global 1.8.7-p352

The special version name `system` tells jlenv to use the system Ruby
(detected by searching your `$PATH`).

When run without a version number, `jlenv global` reports the
currently configured global version.

### jlenv shell

Sets a shell-specific Ruby version by setting the `JLENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ jlenv shell jruby-1.7.1

When run without a version number, `jlenv shell` reports the current
value of `JLENV_VERSION`. You can also unset the shell version:

    $ jlenv shell --unset

Note that you'll need jlenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`JLENV_VERSION` variable yourself:

    $ export JLENV_VERSION=jruby-1.7.1

### jlenv versions

Lists all Ruby versions known to jlenv, and shows an asterisk next to
the currently active version.

    $ jlenv versions
      1.8.7-p352
      1.9.2-p290
    * 1.9.3-p327 (set by /Users/sam/.jlenv/version)
      jruby-1.7.1
      rbx-1.2.4
      ree-1.8.7-2011.03

### jlenv version

Displays the currently active Ruby version, along with information on
how it was set.

    $ jlenv version
    1.9.3-p327 (set by /Users/sam/.jlenv/version)

### jlenv rehash

Installs shims for all Ruby executables known to jlenv (i.e.,
`~/.jlenv/versions/*/bin/*`). Run this command after you install a new
version of Ruby, or install a gem that provides commands.

    $ jlenv rehash

### jlenv which

Displays the full path to the executable that jlenv will invoke when
you run the given command.

    $ jlenv which irb
    /Users/sam/.jlenv/versions/1.9.3-p327/bin/irb

### jlenv whence

Lists all Ruby versions with the given command installed.

    $ jlenv whence rackup
    1.9.3-p327
    jruby-1.7.1
    ree-1.8.7-2011.03

## Environment variables

You can affect how jlenv operates with the following settings:

name | default | description
-----|---------|------------
`JLENV_VERSION` | | Specifies the Ruby version to be used.<br>Also see [`jlenv shell`](#jlenv-shell)
`JLENV_ROOT` | `~/.jlenv` | Defines the directory under which Ruby versions and shims reside.<br>Also see `jlenv root`
`JLENV_DEBUG` | | Outputs debug information.<br>Also as: `jlenv --debug <subcommand>`
`JLENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for jlenv hooks.
`JLENV_DIR` | `$PWD` | Directory to start searching for `.ruby-version` files.

## Development

The jlenv source code is [hosted on
GitHub](https://github.com/jlenv/jlenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/jlenv/jlenv/issues).


  [ruby-build]: https://github.com/jlenv/ruby-build#readme
  [hooks]: https://github.com/jlenv/jlenv/wiki/Authoring-plugins#jlenv-hooks
