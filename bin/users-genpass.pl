#!/usr/bin/perl
# Read a CSV list of users, generate a password for each, and write the result

# Set up
use strict; no strict qw(refs);
use Getopt::Long;
use Class::CSV;
use Data::Dumper;

# Variables
my %options; my $DEBUG = 1;
GetOptions(\%options, 'help|h', 'verbose|v', 'input|i', 'output|o');
if ($options{'verbose'}) { print STDERR "Increasing verbosity..\n"; $DEBUG++; }
if ($options{'help'}) { &usage; exit; }

# Defaults
if (!$options{'input'}) { $options{'input'} = "~/tmp/zcs/users2016-full.csv"; }
if (!$options{'output'}) { $options{'output'} = "~/tmp/zcs/users2016-full-pass.csv"; }

sub usage {
  print STDERR
  "Usage: $0 [-hv] -i <input-csv> -o <output-csv>

  -h help (print this usage statement)
  -v verbose
  -i input CSV
  -o output CSV
  \n";
}

my $users = Class::CSV->parse(
  filename => glob($options{'input'}),
  fields => [qw/Name AlternateRecipientForwarding Description DisplayName EmailAddress FirstName JobTitle LastName TelephoneNumber Username/]
);
my $out = Class::CSV->new(
  fields => [qw/Name AlternateRecipientForwarding Description DisplayName EmailAddress FirstName JobTitle LastName TelephoneNumber Username Password/]
);

my $count = 0;
foreach my $line (@{$users->lines()}) {
  next if (!$count++);
  my $pass = `pwgen -1`; chomp($pass);
  my $f = {};
  foreach my $field (@{$users->fields}) {
    $f->{$field} = trim($line->$field);
  }
  $f->{'Password'} = $pass;
  $out->add_line($f);
}

&write_csv(glob($options{'output'}), $out);

sub write_csv {
  my($filename, $class_csv) = @_;
  open(my $fh, '>', $filename) or die "Unable to open $filename for writing: $!";
  print $fh $class_csv->string();
  close($fh);
}

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
