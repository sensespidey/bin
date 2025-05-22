#!/usr/bin/perl

# file-db reimplementation of locate/updatedb mechanism
use strict 'vars';

my @PRUNE = ();
my $ROOT = '/';
my $DEF_OUTPUT = '/var/lib/slocate/FILES';
my $OUTPUT = $DEF_OUTPUT;

my @COMMAND =  ('find', $ROOT);
push @COMMAND, ('-path', $_, '-prune', '-o' ) for @PRUNE;
push @COMMAND, '-print';

open F, "> $OUTPUT" or die "$0: Couldn't open database file $OUTPUT: $!\n";
open STDOUT, ">&F" or die "$0: Couldn't dup to stdout: $!\n";
open SAVESTDERR, ">&STDERR" or die "$0: Couldn't dup to stderr: $!\n";
open STDERR, "> /dev/null" or die "$0: Couldn't discard stderr: $!\n";
close F;

exec @COMMAND;
print SAVESTDERR "$0: Couldn't run 'find' command:\n\t@COMMAND\n\t$!\n"; 
exit 1;

