#!/usr/bin/perl

my($theme,$rev) = @ARGV;

printf("cvs co -r %s -d %s contributions/themes/%s\n", $rev, $theme, $theme);
printf("svn add %s\n", $theme);
printf('svn commit -m "added %s revision of %s theme to vendor branch" %s'."\n", $rev, $theme, $theme);
