#!/usr/bin/perl
# Script to read a file consisting of two-line entries like so:
# url.rnao.ca
# mysql --database=smarty_cleverpants --host=localhost --user=smarty --password=cleverpants
# 
# And subsequently create the database, GRANTs and dump/import the data itself
# on a remote host given on the cmdline

# usage: db-xfer.pl [-hv] -f <filename> -r <remotehost>

# Set up
use strict;
no strict qw(refs);

use Getopt::Long;
use Data::Dumper;
use FileHandle;

# Variables
my(%options,$file,$host);
my(%sites);
my $DEBUG = 1;

GetOptions(\%options, 'help|h','verbose|v','file|f=s','host|r=s');
if ($options{'help'}) { &usage; exit; }
if ($options{'file'}) { $file = $options{'file'}; } else { &usage; die "No filename provided.\n"; }
if ($options{'host'}) { $host = $options{'host'}; } else { &usage; die "No remotehost provided.\n"; }

sub usage {
  print "Usage: $0 [-hv] [-f <filename] <remotehost>

         -h help (print this usage statement)
         -v verbose
         -f specify an input file (default: cwd)
";
}

# MAIN ROUTINE
open(FILE, "< $file") or die "Can't open $file: $!";
my($url, $dbc);
while (<FILE>) {
  chomp($_);
  if ($. % 2 ==  1) { # Odd lines are URLs
    $url = $_;
  } else {            # Even lines are DB connect strings
    $sites{$url}{'url'} = $url;   # First store the url
    $sites{$url}{'connect'} = $_; # and the raw connect string (for later testing)

    # mysql --database=smarty_cleverpants --host=localhost --user=smarty --password=cleverpants
    if (m/mysql --database=(.*) --host=(.*) --user=(.*) --password=(.*)/) {
      $sites{$url}{'dbname'} = $1;
      $sites{$url}{'dbhost'} = $2;
      $sites{$url}{'dbuser'} = $3;
      $sites{$url}{'dbpass'} = $4;
    }
  }
}

printf("Counted %d sites.\n", scalar(keys %sites));
foreach (keys %sites) {
  my %site = %{$sites{$_}};
  print Dumper(\%site);
  # create the database, GRANTs and dump/import the data itself
  my ($create, $grant, $dump);
  $create = sprintf('ssh %s "echo \'CREATE DATABASE %s DEFAULT CHARSET=utf8\' | mysql"', $host, $site{'dbname'});
  print "CREATE: $create\n";
  system($create);
  $grant  = sprintf('ssh %s "echo \'GRANT ALL ON %s.* to %s@%s IDENTIFIED BY \\"%s\\"\' | mysql mysql"', $host, $site{'dbname'}, $site{'dbuser'}, $site{'dbhost'}, $site{'dbpass'});
  # ssh dlaventure@192.168.100.17 "echo 'GRANT ALL ON live_nrf.* to live_nrf@localhost IDENTIFIED BY \"ii8anguNuRoh0iec\"' | mysql mysql"
  print "GRANT: $grant\n";
  system($grant);
  $dump   = sprintf('mysqldump %s | ssh %s "mysql %s"', $site{'dbname'}, $host, $site{'dbname'});
  print "DUMP: $dump\n";
  system($dump);
}

