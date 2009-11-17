#!/usr/bin/perl

use Data::Dumper;

my($number, $title, $abstract, $line);
my(%abstracts);
while (<>) {
  if (/^\s*ABSTRACT #([0-9]+)\s*$/) {
    # new ABSTRACT: save the existing one
    if ($number) { # only after there's one saved
      $abstracts{$number} = { 'title' => $title, 'abstract' => $abstract, };
    }
    # now reset for new abstract.
    $number = $1; $line = 0;
    $title = ''; $abstract = '';
  } else {
    $line++;
    if ($line == 1) { # Grab the title
      $title = $_;
    } else { 
      $abstract .=  $_ . "<br />";
    }
  }
}
$abstracts{$number} = { 'title' => $title, 'abstract' => $abstract, };

print "<a name='top'>\n";
print "<ul>\n";
for (my $i=1; $i<=$number; $i++) {
  $aname = "abstract$i";
  $obj = $abstracts{$i};

   print "<li>#$i: ";
   printf('<a href="#%s">%s</a></li>%s', $aname, $obj->{'title'}, "\n");
}
print "</ul>\n";

for (my $i=1; $i<=$number; $i++) {
  $aname = "abstract$i";
  $obj = $abstracts{$i};
  print "<div class='abstract'>\n";
  printf('<a name="%s">%s',$aname,"\n");
  printf('<h3>Abstract #%s: %s</h3></a>%s', $i, $obj->{'title'}, "\n");
  printf('<p>%s</p>', $obj->{'abstract'}, "\n");
#  foreach my $line (split(/\n/, $obj->{'abstract'})) {
#    print "<p>line:[" . $line . "]</p>"
#    #printf('</p>%s<p>%s', "\n", $line);
#  }
  printf('<a href="#top">back to top</a>%s', "\n");
  print "</div>\n";
}
