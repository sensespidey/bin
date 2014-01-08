#!/usr/bin/perl
# Script to update all powerdns zones imported by zone2sql to allow AXFR to ns1.rnao.ca

# usage: powerdns-setxfrs.pl [-hv] 

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

GetOptions(\%options, 'help|h', 'verbose|v');

if ($options{'verbose'}) { print STDERR "Connecting to database..\n"; }
if ($options{'help'}) { &usage; exit; }

my $dsn = "DBI:mysql:pdns;mysql_read_default_file=/etc/powerdns/powerdns.cnf";
my $dbh = DBI->connect($dsn, "", "") or die "Connection error: $DBI::errstr\n";

sub usage {
  print STDERR
  "Usage: $0 [-hsdfv] <address-file> 

  -h help (print this usage statement)
  -v verbose
\n";
}

# MAIN ROUTINE

my($sql,$sth, $row);
$sql = 'SELECT * FROM domains';
$sth = $dbh->prepare($sql); $sth->execute;
while ($row = $sth->fetchrow_hashref) {
  if ($options{'verbose'}) { 
    printf STDERR "Handling domain %s(%d)\n", $row->{'name'}, $row->{'id'}; 
  }

  $sql = sprintf('UPDATE domains SET master="", type="MASTER" where id=%d;%s', $row->{'id'},"\n");
  $sql .= sprintf('INSERT INTO domainmetadata (domain_id, kind, content) VALUES (%d, "AXFR-MASTER-TSIG", "TRANSFER");%s', $row->{'id'}, "\n");
  $sql .= sprintf('INSERT INTO domainmetadata (domain_id, kind, content) VALUES (%d, "ALLOW-AXFR-FROM", "AUTO-NS");%s', $row->{'id'}, "\n");
  print $sql;
}
