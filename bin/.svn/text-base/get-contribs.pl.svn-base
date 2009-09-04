#!/usr/bin/perl

use Data::Dumper;

my($name,$tag);
my($i);
my $modules = {};
# Provide a file in the following format:
# <project-name>
# [NT]DRUPAL-6--1-1 <- CVS Branch/Tag ID
while (<>) {
  chomp;
  if (/^[NT]/) { # It's a tag
    s/^[NT]//;
    $tag = $_;
    $modules->{$name} = $tag;
  } else {
    $name = $_;
    $i++;
    #print "$i: $name\n";
  }
}

#print Dumper($modules);
while (($name,$rev) = each(%{$modules})) {
  printf("cvs co -r %s -d %s contributions/modules/%s\n", $rev, $name, $name);
  printf("svn add %s\n", $name);
  printf('svn commit -m "added %s revision of %s module to vendor branch" %s'."\n", $rev, $name, $name);
}
