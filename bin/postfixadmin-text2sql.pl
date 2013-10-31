#!/usr/bin/perl
# Script to read a list of address aliases and ensure they exist as entries in
# a postfixadmin-driven mysql database. It checks that a row with the same
# source and/or destination, and warns the user

# usage: address2postfix-sql.pl [-hsdfv] <address-file> (one alias per line:
# source -- destination

# Set up
use strict;
no strict qw(refs);

use Getopt::Long;
use DBI;

use Data::Dumper;
use FileHandle;

# Variables
my(%options,$fh);
my(@addresses);
my $DEBUG = 3;

GetOptions(\%options, 'help|h', 'verbose|v',
  'force-source|s',
  'force-destination|d',
  'force-all|f',
);

if ($options{'force-all'}) {
  $options{'force-source'} = 1;
  $options{'force-destination'} = 1;
}

if ($options{'verbose'}) { print "Opening address file $ARGV[0]..\n"; }
if ($options{'help'}) { &usage; exit; }

open(FILE, $ARGV[0]) or die "Couldn't open file $ARGV[0]\n";
while (<FILE>) { chomp; push(@addresses,$_); }

if ($options{'verbose'}) { print "Addresses:\n" . Dumper(\@addresses); }

my $dsn = "DBI:mysql:postfix;mysql_read_default_file=/etc/postfix/postfixadmin.cnf";
my $dbh = DBI->connect($dsn, "", "") or die "Connection error: $DBI::errstr\n";

sub usage {
  print
  "Usage: $0 [-hsdfv] <address-file> 

  -h help (print this usage statement)
  -v verbose
  -s force source (ignore duplicates)
  -d force destination (ignore duplicates)
  -f force all

  <address-file> is one alias per line: source -- destination.
\n";
}

# MAIN ROUTINE

foreach my $line (@addresses) {
  my($source, $dest) = split(/ -?->? /, $line);
  my $insert = 1;
  my($sql,$sth, $row);
  
  print "ORIGINAL $line\n" if ($options{'verbose'});

  unless ($options{'force-source'}) { 
    # Check for existing records with this source address
    $sql = sprintf('SELECT * FROM alias WHERE address like "%%%s%%"', $source);
    $sth = $dbh->prepare($sql); $sth->execute;
    while ($row = $sth->fetchrow_hashref) {
      $insert = 0;
      if ($options{'verbose'}) { print "Duplicate source address found:\n $line \n" .  Dumper($row); }
      if ($row->{'address'} == $source) {
        printf("Duplicate row exists with matching source address [%s]\n", $line);
      } else {
        printf( "Duplicate row exists with different source address (%s vs.  %s)\n", $row->{'address'}, $source);
      }
    }
  }

  unless ($options{'force-destination'} || !$insert) {
    # Check for existing records with this dest address
    $sql = sprintf('SELECT * FROM alias WHERE goto LIKE "%%%s%%"', $dest);
    $sth = $dbh->prepare($sql); $sth->execute;
    while ($row = $sth->fetchrow_hashref) {
      $insert = 0;
      if ($options{'verbose'}) { print "Duplicate destination address found:\n $line \n" .  Dumper($row); }
      if ($row->{'goto'} == $dest) {
        printf("Duplicate row exists with matching dest address [%s]\n", $line);
      } else {
        printf("Duplicate row exists with different source address (%s vs.  %s)\n", $row->{'goto'}, $dest);
      }
    }
  }

  if ($insert) {
    # no duplicates found
    $sql = sprintf('INSERT INTO alias (address, goto, domain, created, modified) VALUES ("%s", "%s", "rnao.ca", now(), now());', $source, $dest);
    print $sql . "\n";
  }
}
