#!/usr/bin/perl
# Simple script to take a prepared zmprov.users.csv and create a users.zmp

# Setup
use strict; no strict qw(refs);

use Getopt::Long;
use Class::CSV;
use Data::Dumper;

# Vars
my(%options, $fh); my $DEBUG = 1;
GetOptions(\%options, 'help|h', 'verbose|v', 'input|i', 'output|o');
if ($options{'verbose'}) { print STDERR "Increasing verbosity..\n"; $DEBUG++; }
if ($options{'help'}) { &usage; exit; }

# Defaults
if (!$options{'input'}) { $options{'input'} = 'zmprov.groups.csv'; }
if (!$options{'output'}) { $options{'output'} = 'zmprov.groups.zmp'; }

sub usage {
  print STDERR
  "Usage: $0 [-hv] -i <input-csv> -o <output-zmp>

  -h help (print this usage statement
  -v verbose
  -i input CSV file
  -o output ZMP file (zmprov commands)
\n";
}

my $groups = Class::CSV->parse(
  filename => $options{'input'},
  fields => [qw/email members/]
);
open($fh, ">", $options{'output'}) or die("Unable to open ".$options{'output'}." for writing: $!");

foreach my $line (@{$groups->lines()}) {

  # createDistributionList(cdl) {list@domain}
  # addDistributionListMember(adlm) {list@domain|id} {member@domain}+
  print $fh sprintf(qq{createDistributionList %s\n}, $line->email);
  print $fh sprintf(qq{addDistributionListMember %s %s\n}, $line->email, $line->members);
}

close($fh);
