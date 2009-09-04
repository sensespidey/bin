#!/usr/bin/perl

use Class::CSV;

my $csv = Class::CSV->parse(
    filename => '/home/dlaventure/tmp/nso-emails.csv',
    fields   => [qw/destination source/]
);

foreach my $line (@{$csv->lines()}) {

   #print 'Source:     '. $line->source(). "\n".
   #      'Destination:      '. $line->destination(). "\n";
   #printf("INSERT INTO virtual_aliases (domain_id, source, destination) VALUES (2, '%s', '%s');\n", $line->source(), $line->destination());
   printf("INSERT INTO virtual_aliases (domain_id, source, destination) VALUES (2, 'executive\@nso.rnao.ca', '%s');\n", $line->source());
}

#my $cvs_as_string = $csv->string();



#while (<>) {

#}
