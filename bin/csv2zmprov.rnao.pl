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
if (!$options{'input'}) { $options{'input'} = 'zmprov.users.csv'; }
if (!$options{'output'}) { $options{'output'} = 'zmprov.users.zmp'; }

sub usage {
  print STDERR
  "Usage: $0 [-hv] -i <input-csv> -o <output-zmp>

  -h help (print this usage statement
  -v verbose
  -i input CSV file
  -o output ZMP file (zmprov commands)
\n";
}

# Lookup COS ID
#my $cosid = `sudo su - zimbra -c 'zmprov gc Default | grep zimbraId:'`;
my $cosid = 'fill this in yourself';
my $password = 'changeme';

my $users = Class::CSV->parse(
  filename => $options{'input'},
  fields => [qw/email givenName sn cn description title telephoneNumber/]
);
open($fh, ">", $options{'output'}) or die("Unable to open ".$options{'output'}." for writing: $!");

my $count = 0;
foreach my $line (@{$users->lines()}) {
  my $email = $line->email;
  my $displayName = $line->givenName . " " . $line->sn;
  my $givenName = $line->givenName;
  my $sn = $line->sn;
  my $title = $line->title;
  my $description = $line->description;
  my $telephone = $line->telephoneNumber;
  print $fh qq{ca "$email" "$password"},
  qq{ zimbraCOSid "$cosid"},
  qq{ zimbraPasswordMustChange TRUE},
  qq{ givenName "$givenName"},
  qq{ sn "$givenName"},
  qq{ cn "$sn"},
  qq{ displayName "$displayName"},
  qq{ description "$description"},
  qq{ title "$title"},
  qq{ telephoneNumber "$telephone"},
  qq{ company "RNAO"}, 
  qq{\n}
}

close($fh);
