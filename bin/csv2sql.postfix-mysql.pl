#!/usr/bin/perl

# Simple script to read in a CSV and print out SQL to insert new email
# redirects into postfix/mysql mailserver

# CSV Format should be:
# first,last,phone,real email,virtual email
# Fields 4 and 5 are the only ones that matter

use Text::CSV_XS;
use Data::Dumper;

my($file) = @ARGV;

my @rows;
my $csv = Text::CSV_XS->new ({ binary => 1 }) or
   die "Cannot use CSV: ".Text::CSV->error_diag ();

open my $fh, "<:encoding(utf8)", $file or die "$file: $!";

while (my $row = $csv->getline ($fh)) {
 printf("INSERT INTO virtual_aliases (domain_id, source, destination) VALUES (1, '%s', '%s');\n",$row->[5], $row->[4]);
}
$csv->eof or $csv->error_diag ();
close $fh;
