#!/usr/bin/suidperl
use strict 'vars';

# http://perl.plover.com/classes/mybin/samples/slide080.html

$ENV{PATH} = '/bin:/usr/bin';

my $DEF_DB= '/var/lib/slocate/FILES';
my $DB = $DEF_DB;
my @GREPFLAGS = ();

while ($ARGV[0] =~ /^-/) {
  if ($ARGV[0] =~ /^--([^=]*)=(.*)/) {
    if ($1 eq 'database') {
      $DB = $2;
    } else {
      push @GREPFLAGS, $ARGV[0];
    }
  } elsif ($ARGV[0] =~ /^-(.)/) {
    if ($1 eq 'd') {
      $DB = $ARGV[1];
      shift;
    } else {
      push @GREPFLAGS, $ARGV[0];
    }
  } 
  shift;
}
my $PAT = shift;
usage() if @ARGV > 0;

