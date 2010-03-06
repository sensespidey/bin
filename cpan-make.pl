#!/usr/bin/perl

use 5.010;

use strict;
use warnings FATAL => 'all';

run();

sub run {
    fetch_and_test($_)
      for @ARGV;

    for my $dir (grep -d, glob "*") {
        system qw[rm -rf], "$dir/debian"
          if -e "$dir/debian";

        my ($module, $ver) = $dir =~ m/(.*)-(.*)/;
        my $deb = lc "lib$module-perl";            

        system(qw/dh-make-perl --version/, "$ver-0.0", "--build", $dir) == 0
          and system qw/rm -rf/, $dir; #created a deb
    }
}

sub fetch_and_test {
    my $module = shift;
    system qw[
        cpanp
        s conf prereqs 1;
    ],
    "t", $module;
}
