#!/usr/bin/perl

use Carp;

# This is a little util to search and replace for a string in a set of files.
#
# Usage: searchreplace <searchstring> <replacestring> <file> [file] ...
if (@ARGV < 3) { &usage; die "Invalid number of arguments"; }

# Setup the search and replace strings.
my $search = shift(@ARGV);
my $replace = shift(@ARGV);
print "Finding instances of [$search] and replacing with [$replace]\n";

# Start the main loop through the files provided.
$i=1;
foreach (@ARGV) {
  $file = $_;
  $err=open(FILE,$file) || carp("Couldn't open file for reading: $file [$!]\n");  if ($err) { # The open worked
    print "Searching " . $file . "...";  # Do output

    # Here's the work
    my($num,@lines);
    while (<FILE>) {
	if (/$search/) {
	  print("found match: $_");
      	  $num += s/$search/$replace/g;
	}
      	  @lines = (@lines,$_);
    }
    close(FILE);

    # Now finish off the file (if changes were found, rewrite the file, otherwise leave it alone.
    if ($num) {
      print "changed $num matches...";
      &write_file($file,@lines);
    } else {
      print "no matches (unchanged)...";
    }
    print "done.\n";        # Finish line of output
  }
}


# This subroutine receives a filename (which will currently exist) and a list of lines
sub write_file {
  my($file,@lines) = @_;        # Get subroutine args
  $err=open(FILE,">".$file) || carp("Couldn't open file to write changes: $file [$!]\n");
  if ($err) { # The open worked okay
    foreach(@lines) {
      print FILE $_;
    } # print the lines of text back to the file.
  }
  close(FILE);
}

sub usage {
  print "Usage: searchreplace.pl <searchstring> <replacestring> <file> [file] ...\n";
}
