#!/usr/bin/perl
# An experiment in parsing the tr-gtd.trx "xml" format

no strict;
use Data::Dumper;
use XML::Simple;

my $arg = shift;

my $xml = new XML::Simple;

# read XML
$data = $xml->XMLin($arg);

foreach my $toplevel (keys %{$data}) {
  print "Toplevel: ".$toplevel."\n";
  foreach my $sectionkey (keys %{$data->{$toplevel}}) {
    print "\tSection: $sectionkey\n";
  }
}
print Dumper($data);
