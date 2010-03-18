#!/usr/bin/perl -w
use strict;
use LWP::Simple;
use HTML::TableExtract;
use Data::Dumper;

my $DEBUG = 0;

# get params for later use.
my $RUN_STATE = shift(@ARGV);

# the base URL of the site we are scraping and
# the URL of the page where the bugtraq list is located.
my $url = "http://www.unc.edu/~rowlett/units/codes/country.htm";
my $file = "/Users/spiderman/anarres/projects/SCW/country.txt";

# get our data.
my $html_file = get($url) or die "$!\n";
$html_file =~ s//\n/g;

my $table = 1;
my $countries = {};
while ($table <= 5) {
  my $te = new HTML::TableExtract( depth => 0, count => $table++ );
  $te->parse($html_file);
  foreach my $ts ($te->table_states) {
    if ($DEBUG >= 2) { print "Table $table found at ", join(',', $ts->coords), ":\n"; }
    foreach my $row ($ts->rows) {
      next if ($row->[0] =~ /Country Name/);
      foreach my $i (0,1,2,6) { $row->[$i] =~ s/^\s//; $row->[$i] =~ s/,//g; }
      if ($DEBUG >= 1) {
	print "Country: ".$row->[0]."\n";
	print "ISO2: ".$row->[1]."\n";
	print "ISO3: ".$row->[2]."\n";
	print "ISO#: ".$row->[6]."\n";
      }

      my $name = $row->[0];

      $row->[0] =~ s/St\. /St./i;
      $row->[0] =~ s/SAINT VINCENT/ST.VINCENT/i;
      $row->[0] =~ s/C.TE D/COTE D/i;
      $row->[0] =~ s/R.UNION/REUNION/i;
      if ($row->[0] =~ /CONGO REPUBLIC/) { $row->[0] = 'Congo'; }
      if ($row->[0] =~ /CONGO THE DEMOCRATIC/) { $row->[0] = 'Zaire'; }
      my($key,@rest) = split(/\s/,lc $row->[0]);
      print "key: $key\n";
#      my $id = $row->[6] + 0;
#      my $key = sprintf("%03d",int($row->[6]));
      $countries->{$key} = {
	'NAME' => $name,
	'ISO2' => $row->[1],
	'ISO3' => $row->[2],
        'NUM' => $row->[6]
      };
    }
  }
}

if ($DEBUG >= 1) {
  print Dumper($countries);
}

# now step through the list rose sent me and construct an SQL statement for each one:

print "Opening $file..";
die("\nCouldn't open $file\n") unless open(F,$file);
print "done.\n";

my $fcountries = {};
my $output;
foreach (<F>) {
  chomp;
  my($code,$country,$rest) = split(",");
  unless ($rest) { $rest = ''; }
  $country =~ s/"//g;
  $code =~ s/"//g;

  next if ($country eq 'Ascension' || $country eq 'Yugoslavia');
  next if ($country eq 'Zaire');
  if ($country =~ /congo/i && $rest =~ /democratic/i) { $country = 'Zaire'; print "zaire == congo"; }

  if ($DEBUG >= 0) {
    print ("country: $country\n");
    print ("code: $code\n");
  }

  my $c = {};
  my ($c_first,$c_rest) = split(/\s/,$country); 
  $c_first =~ s/St\. /St./i;
  if (defined $countries->{$code}) {
    $c = $countries->{$code};
  } elsif (defined $countries->{lc $country}) {
    $c = $countries->{lc $country};
  } elsif (defined $countries->{lc $c_first}) {
    $c = $countries->{lc $c_first};
  } elsif (defined $countries->{'myanmar'} && $country eq 'Burma') {
    $c = $countries->{'myanmar'};
  } elsif (defined $countries->{'czech'} && $country eq 'Czechoslovakia') {
    $c = $countries->{'czech'};
  } elsif (defined $countries->{'russian'} && $country eq 'Russia') {
    $c = $countries->{'russian'};
  } elsif (defined $countries->{'timor-leste'} && $country eq 'East Timor') {
    $c = $countries->{'timor-leste'};
  } elsif (defined $countries->{'syrian'} && $country eq 'Syria') {
    $c = $countries->{'syrian'};
  } elsif (defined $countries->{'belarus'} && $country eq 'Byelorussia (Belarus)') {
    $c = $countries->{'belarus'};
  } elsif (defined $countries->{'georgia'} && $country eq 'Republic of Georgia') {
    $c = $countries->{'georgia'};
  } elsif (defined $countries->{'kyrgyzstan'} && $country eq 'Kirghizia (Kyrgyzstan)') {
    $c = $countries->{'kyrgyzstan'};
  } elsif (defined $countries->{'faeroe'} && $country eq 'Faroe Islands') {
    $c = $countries->{'faeroe'};
  } elsif (defined $countries->{'st.vincent'} && $country eq 'St. Vincent&The Grenadines') {
    $c = $countries->{'st.vincent'};
  } else {
    print "Couldn't find $country ($code) in table.\n";
    next;
  }
#    if ($country eq 'Algeria')  {}
  $output .= sprintf("REPLACE INTO uc_countries VALUES (%s, '%s', '%s', '%s','%s',1);\n", $c->{'NUM'}, $country, $c->{'ISO2'}, $c->{'ISO3'},$code);
  
}

print "OUTPUT:\n";
print $output;
