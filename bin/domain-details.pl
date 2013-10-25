#!/usr/bin/perl

# This script takes a (list of) domains as arguments, and looks up all the
# relevant details for each: Registrar/Registrant info, IP, Host, and DNS
# information. It will also attempt to make a guess at "fingerprinting" the
# software driving the main website on the domain.

# usage: domain-details [-hvf] [-o <output-file>] <domain> [<domain> ...]

# Set up
use strict;
no strict qw(refs);

use Getopt::Long;
use Socket;
use Net::Whois::Raw;
#use Net::Whois::Ripe;
use Net::ParseWhois;

use Data::Dumper;
use FileHandle;

# Variables
my(%options,$fh);
my(@addresses);
my $DEBUG = 3;

GetOptions(\%options, 'help|h','output|o=s','verbose|v','fingerprint|f');

sub usage {
  print 
"Usage: $0 [-hvf] [-o <output-file>] <domain> [<domain> ...]

-h help (print this usage statement)
-v verbose
-f fingerprint (not yet implemented)
-o specify and output file (default: stdout)
<domain> the domain name to gather details for.
";
}

# Generate a wiki-formatted table given a set of header fields and a list of
# domain objects
sub wikitable {
  # Header is a list of fields -> field names for the first row
  # Domains is a list of domains, each containing a field from the $header
  my($fields,$header,$domains) = @_;
  my $table = '';
  
  # First do the header
  foreach my $field (@{$fields}) {
    $table .= sprintf("||'''%s'''", $header->{$field});
  }
  $table .= "||\n"; # Complete row

  # Next a row for each domain
  foreach my $domain (@{$domains}) {
    foreach my $field (@{$fields}) {
      $table .= sprintf("||%s", $domain->{$field});
    }
    $table .= "||\n"; # Complete row
  }
  return $table;
}

if ($options{'help'}) { &usage; exit; }

if ($options{'output'}) { $fh = new FileHandle "> ".$options{'output'}; }
else { $fh = *STDOUT; }

my @fields = ('domain', 'registrar', 'registrant', 'hosting', 'dns', 'ip', 'admin', 'tech', 'webserver', 'software', 'ssl');
my $header = {
  'domain' => 'Domain Name',
  'registrar' => 'Registrar',
  'registrant' => 'Registrant',
  'hosting' => 'Hosting',
  'dns' => 'DNS Servers',
  'ip' => 'IP Address',
  'admin' => 'Admin Contact',
  'tech' => 'Tech Contact',
  'webserver' => 'Web Server',
  'software' => 'Site Software',
  'ssl' => 'SSL Cert Info',
};

my @dom_details;
while (my $domain = shift) {

  my $w = Net::ParseWhois::Domain->new($domain);
  print "Registrar:\n";
  print Dumper($w->registrar);
  #print Dumper($w->contacts);


  print $fh "Gathering details for domain $domain...\n";
  my $ddeets = { 'domain' => 'http://'.$domain };
  
  # Get a list of IP addresses in @addresses
  @addresses = gethostbyname($domain) or die "Can't resolve $domain: $!\n";
  @addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
  
  $ddeets->{'ip'} = $addresses[0];
  
  $domain =~ s/^www.//;
  
  my $whois = whois($domain)
    or die "Couldn't get WHOIS info on $domain: $!\n";

  my $flag = 0;
  my %dwhois;
  foreach my $line (split("\n", $whois)) {
    next unless ($flag || $line =~ /Domain ID/);
    if ($line =~ /Domain ID/ && !$flag) {
      $flag = 1;
    }
    print "WHOIS LINE: ".$line."\n";
    my @wline = split(":", $line);
    if ($wline[0] eq 'Name Server') {
      next unless ($wline[1] !~ /^\s*$/);
      push(@{$dwhois{$wline[0]}}, $wline[1]);
    } else {
      $dwhois{$wline[0]} = $wline[1];
    }
  }
  print Dumper(\%dwhois);

  #print Dumper($whois);

  print Dumper(whois($addresses[0]));

  $ddeets->{'registrant'} = sprintf('%s[[BR]]%s[[BR]]%s[[BR]]Ext.%s',$dwhois{'Registrant Name'}, $dwhois{'Registrant Email'}, $dwhois{'Registrant Phone'},$dwhois{'Registrant Phone Ext.'});
  $ddeets->{'registrar'} = $dwhois{'Sponsoring Registrar'};
  $ddeets->{'hosting'} = '';
  $ddeets->{'dns'} = join('[[BR]]',@{$dwhois{'Name Server'}});
  $ddeets->{'admin'} = sprintf('%s[[BR]]%s[[BR]]%s[[BR]]Ext.%s',$dwhois{'Admin Name'}, $dwhois{'Admin Email'}, $dwhois{'Admin Phone'}, $dwhois{'Admin Phone Ext.'});
  $ddeets->{'tech'} = sprintf('%s[[BR]]%s[[BR]]%s[[BR]]Ext.%s', $dwhois{'Tech Name'}, $dwhois{'Tech Email'}, $dwhois{'Tech Phone'}, $dwhois{'Tech Phone Ext.'});
  $ddeets->{'webserver'} = '';
  $ddeets->{'software'} = '';
  $ddeets->{'ssl'} = '';
  
  push(@dom_details, $ddeets);
}

print wikitable(\@fields, $header, \@dom_details);

#TODO - Add software fingerprinting (ASP/PHP/Drupal/"Powered by")
#TODO - track SSL cert details
#TODO - Add webserver info
#TODO - Output wiki formatted table
#TODO - output domain as a link to the actual site..
