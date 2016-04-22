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

  # createAccount takes at least an email (username) and password
  # Below is the rest of one GIANT print statement to get the rest of the details
  print $fh sprintf(qq{createAccount "%s" "$password"}, $line->email),

  # We know a few things for sure
  qq{ zimbraCOSid "$cosid"},
  qq{ zimbraPasswordMustChange TRUE},
  qq{ company "RNAO"}, 

  # Given name is always present, in our case
  sprintf(qq{ givenName "%s"}, $line->givenName),
  sprintf(qq{ displayName "%s"}, $line->givenName . " " . $line->sn),

  # These may or may not be in the data file
  ( ($line->givenName ne "")       ? sprintf(qq{ sn "%s"}, $line->givenName)                    : () ),
  ( ($line->sn ne "")              ? sprintf(qq{ cn "%s"}, $line->sn)                           : () ),
  ( ($line->description ne "")     ? sprintf(qq{ description "%s"}, $line->description)         : () ),
  ( ($line->title ne "")           ? sprintf(qq{ title "%s"}, $line->title)                     : () ),
  ( ($line->telephoneNumber ne "") ? sprintf(qq{ telephoneNumber "%s"}, $line->telephoneNumber) : () ),
  qq{\n}
}

close($fh);
