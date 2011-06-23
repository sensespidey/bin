#!/usr/bin/perl -w
# Stolen from: http://www.ibm.com/developerworks/linux/library/l-pexcel/

use strict;
use Spreadsheet::ParseExcel;
use Data::Dumper;

my $oExcel = new Spreadsheet::ParseExcel;

die "You must provide a filename to $0 to be parsed as an Excel file" unless @ARGV;

my $oBook = $oExcel->Parse($ARGV[0]);
my($iR, $iC, $oWkS, $oWkC);
print "FILE  :", $oBook->{File} , "\n";
print "COUNT :", $oBook->{SheetCount} , "\n";

print "AUTHOR:", $oBook->{Author} , "\n"
 if defined $oBook->{Author};

$oWkS = $oBook->{Worksheet}[0]; # First sheet is the only one we care about atm
my @keywords = ();
my %kc; # Hash to count keywords
my @synonyms = ();
my %sc; # Hash to count synonyms
print "Sheet: ".$oWkS->{Name}, "\n";
for(my $iR = ($oWkS->{MinRow}+1) ;
    defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ;
    $iR++)
  {
#    print "Row $iR\n";
    my($keywords, $synonyms);

    if ($oWkS->{Cells}[$iR][11]) {
      $keywords = $oWkS->{Cells}[$iR][11]->Value;
      foreach my $word (split(/,/, $keywords)) {
        next if $word eq '';
        $word = trim($word);
        $word = lc($word);
        $kc{$word}++;
        #print "Keyword: $word\n";
      }
    }
    if ($oWkS->{Cells}[$iR][12]) {
      $synonyms = $oWkS->{Cells}[$iR][12]->Value;
      foreach my $word (split(/,/, $synonyms)) {
        next if $word eq '';
        $word = trim($word);
        $word = lc($word);
        $sc{$word}++;
        #print "Synonym: $word\n";
      }
    }
  }

  printf("Counted %d unique keywords\n", (scalar keys %kc));
  printf("Counted %d unique synonyms\n", (scalar keys %sc));

  my @ksorted = map { $_->[0] }
                sort { $b->[1] <=> $a->[1] }
                map { [ $_, $kc{$_} ] }
                keys %kc;

   foreach my $s (@ksorted) {
     printf("Keyword: [%d] %s\n", $kc{$s}, $s);
   }

  my @ssorted = map { $_->[0] }
                sort { $b->[1] <=> $a->[1] }
                map { [ $_, $sc{$_} ] }
                keys %sc;

   foreach my $s (@ssorted) {
     printf("Synonym: [%d] %s\n", $sc{$s}, $s);
   }

#  print Dumper(\%kc);
#  print Dumper(\%sc);

 die;

for(my $iSheet=0; $iSheet < $oBook->{SheetCount} ; $iSheet++)
{
 $oWkS = $oBook->{Worksheet}[$iSheet];
 print "--------- SHEET:", $oWkS->{Name}, "\n";
 for(my $iR = $oWkS->{MinRow} ;
     defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ;
     $iR++)
 {
  for(my $iC = $oWkS->{MinCol} ;
      defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol} ;
      $iC++)
  {
   $oWkC = $oWkS->{Cells}[$iR][$iC];
   print "( $iR , $iC ) =>", $oWkC->Value, "\n" if($oWkC);
  }
 }
}

sub trim {
  my @out = @_;
  for (@out) {
    s/^\s+//;
    s/\s+$//;
  }
  return wantarray ? @out : $out[0];
}
