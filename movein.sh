#!/bin/bash
# My own personal movein.sh

# This will (eventually) be(come) my favouritest script (for a time, at least).
#
# movein.sh is designed to quickly "move in" to a new server environment,
# complete with my own customizations, including:
# * various dotfiles from a private repository i specify from the commandline
#   * bash login/aliases scripts
#   * ssh config+pubkey setup (depending on a couple (or gpg keychain) of identities, perhaps?)
#   * .my.cnf, possibly pulling per-host passwords?
#   * screenrc's, customized to the different boxen (possibly templated?)
#   * personal puppetrcs to configure things the way i like?
#   * other custom configurations
# * this public bin/

# * configurable via a simple 

# Design goals:
# * make the movein process as simple yet secure as possible
# * make it portable, but also easy to replicate from nothing
# * non-destructive, and perma-syncing (it should be trivial to sync any given
#   host by re-running/updating this script)
# * as my first git-controlled devscript, it should be git-aware, of course ;)

# Major Steps:
# 0. Basic Diagnostic: Check what shell I'm running, and do something sensible if I can
# 1. Pull in a clone of public "bin" git repo
# 2. (TBD) Grab the latest copy of myself, and if there's an update
# 3. Clone private "dotfiles" git repo
# 4. Arrange the configured set of dotfiles/dirs (treat .ssh specially?) with symlinks
# 5. Setup ssh keys: 
# 5a. - explicit option to provide one of my "identity" pubkeys by hand (use with care) or create a dummy one
# 5b. - known_hosts + config templates
# 6. (TBD) puppet magic? (local etc)

# Step 0: Basic Diagnostic
# check to see if i've moved in already, or just assume not, for now?

declare uname=`uname -a`
echo "Uname: ${uname}\n"

# Shell?
# Net?
declare pingtest=`ping -c 3 8.8.8.8`
echo "Network status: ${pingtest}\n"

# base perl5?
# git?

cd ~

# Step 1: Clone private "dotfiles" git repo
git clone $1 ~/dotfiles

# Step 2: TBD (self-update)
# For now, just read some config details:
#source ~/dotfiles/.moveinrc

# Step 2: Pull in a clone of public "bin" git repo
#git clone git://github.com/sensespidey/bin.git ~/bin

# Step 4: Arrange the configured set of dotfiles/dirs (treat .ssh specially?) with symlinks
if [! -x ~/archive] ;
  mkdir ~/archive
fi
#for $DIR in $DOTDIRS ; do
#  mv ~/$DIR ~/archives/$DIR
#  ln -s ~/dotfiles/$DIR/ ~/$DIR/
#done
#
#for $FILE in $DOTFILES ; do
#  mv ~/$FILE $/archives/$FILE
#  ln -s ~/dotfiles/$FILE ~/$FILE
#done

# Step 5: Setup ssh keys: 
# Step 5a - explicit option to provide one of my "identity" pubkeys by hand (use with care) or create a dummy one
# Step 5b - known_hosts + config templates
# Step 6: (TBD) puppet magic? (local etc)

# BONUS: setup ThinkingRock, Dropbox, etc. and host-specific customizations/branches/submodules..

