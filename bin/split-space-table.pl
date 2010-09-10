#!/usr/bin/perl
# Simple command to split LHIN zipcode table into CSV lines

use Data::Dumper;

my($total_fields) = 8; # Each line should have this many fields
my($start_field) = 4; # Collapse extra fields into this one

while (<>) {
  my(@fields) = split;
  my($num_fields) = scalar(@fields);

  print "NF: $num_fields\n";

  if ($num_fields > $total_fields) {
    # Find the last field to collapse, by adding the difference between the number of fields on this line
    # and the total number we want.
    $end_field = $start_field + ($num_fields - $total_fields);
    print "collapsing fields 4 through $end_field\n";

    my($i,$new_line);
    for ($i = 0; $i < $start_field ; $i++) {
      $new_line .= sprintf('"%s",',$fields[$i]);
    }
    $new_line .= '"';
    for ($i = $start_field ; $i <= $end_field ; $i++) {
      $new_line .= sprintf('%s ',$fields[$i]);
    }
    chop($new_line);
    $new_line .= '",';
    for ($i = $end_field+1 ; $i < $num_fields ; $i++) {
      $new_line .= sprintf('"%s",',$fields[$i]);
    }
    chop($new_line);
    print $new_line."\n";
   
  } else {
    my($new_line);
    foreach my $field (@fields) {
      $new_line .= sprintf('"%s",',$field);
    }
    chop($new_line);
    print $new_line . "\n";
    
  }
  print Dumper(\@fields);
}
