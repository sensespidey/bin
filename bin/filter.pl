#!/usr/bin/perl -n

use Data::Dumper;
my @f = split(/,/);
printf('"%s" <%s>%s', $f[0], $f[28], "\n");
#print Dumper(\@f);

