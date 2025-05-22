#!/usr/bin/perl
# Simple command to split LHIN zipcode table into CSV lines

my($total_fields) = 8; # Each line should have this many fields
my($start_field) = 4; # Collapse extra fields into this one

while (<>) {
  my(@fields) = split;
  my($num_fields) = scalar(@fields);

  if ($num_fields > $total_fields) {
    # Find the last field to collapse, by adding the difference between the number of fields on this line
    # and the total number we want.
    $end_field = $start_field + ($num_fields - $total_fields);

    my($i,$new_line);

    # Print the first bunch of fields
    for ($i = 0; $i < $start_field ; $i++) {
      $new_line .= sprintf('"%s",',$fields[$i]);
    }

    # Collapse the middle bunch into one field
    $new_line .= '"';
    for ($i = $start_field ; $i <= $end_field ; $i++) {
      $new_line .= sprintf('%s ',$fields[$i]);
    }
    chop($new_line);
    $new_line .= '",';

    # Print the last bunch of fields
    for ($i = $end_field+1 ; $i < $num_fields ; $i++) {
      $new_line .= sprintf('"%s",',$fields[$i]);
    }
    chop($new_line);

    print $new_line."\n";
   
  } else { # It's already got the right number of fields, so just print CSV
    my($new_line);
    foreach my $field (@fields) {
      $new_line .= sprintf('"%s",',$field);
    }
    chop($new_line);
    print $new_line . "\n";
    
  }
}
