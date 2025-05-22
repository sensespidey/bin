#!/usr/bin/perl
# A simple perl script to automate the use of /usr/bin/convert to
# extract the first page of a directory full of PDFs, and replace with a set of
# cover image .jpg files in the same directory.

# Update: It's also very verbose, as of now :)

use Data::Dumper;

$dir = './QuarkFiles';
open(PDFS, "find . -path $dir -prune -o -name '*.pdf' -print|");
while (<PDFS>) {
  $line = $_; chomp($line); # Grab a line, remove newline
  printf("LINE: [$line]\n"); # This is the filename we're working with (results of the find call above)

  $dir = `dirname "$line"`; chomp($dir); # Find it's dirname, remove newline (another system call!)
  printf("DIR: [$dir]\n");

  $file = `basename "$line"`; chomp($file); # Get it's basename, remove newline (and yet a third!)
  printf("FILE: [$file]\n");

  $jpeg = $file; $jpeg =~ s/.pdf/.jpg/; # Generate a .jpg name for the new file (yay perl!)
  printf("JPEG: [$jpeg]\n");

  $file = $dir . '/' . $file . "[0]"; # The complete filename
  $jpeg = $dir . '/' . $jpeg; # The corresponding .jpeg cover image
  system('/usr/bin/convert',$file,$jpeg); # Make it so!
}

