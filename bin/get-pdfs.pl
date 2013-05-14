#!/usr/bin/perl

# This script will grab PDF documents linked from a given URL and download them into a directory

# usage: get-pdfs [-hv] [-o <output-file>] <URL> [<URL> ... ]

# Set up
use strict;
no strict qw(refs);

use Getopt::Long;
use LWP::Simple;
use HTML::LinkExtor;

use Data::Dumper;
use FileHandle;

# Variables
my(%options,$dir);
my(@pdfs);
my $DEBUG = 1;

GetOptions(\%options, 'help|h','output|o=s','verbose|v');

# MAIN ROUTINE

if ($options{'help'}) { &usage; exit; }
if ($options{'output'}) { $dir = $options{'output'}; }
else { chomp($dir = `pwd`); }

while (my $url = shift) {
  print "Searching $url for .pdf links...\n";
  @pdfs = &collect_links($url);
  &download_files($dir, @pdfs);
}

sub usage {
  print 
  "Usage: $0 [-hv] [-o <output-dir] <URL> [<URL> ... ]

   -h help (print this usage statement)
   -v verbose
   -o specify and output dir (default: cwd)
   <URL> URL to gather PDFs from.
   ";
}

sub basename {
  my ($url) = @_;
  $url =~ q!http://.*/([^/]*)$!;
  return $1;
}

sub collect_links {
  my ($url) = @_;
  my ($content, $parser, @links, %seen);

  unless (defined ($content = get $url)) { # LWP::Simple provides 'get'
    die "Could not GET $url\n";
  }

  $parser = HTML::LinkExtor->new(undef, $url);
  $parser->parse($content)->eof;
  @links = $parser->links;

  foreach my $linkarray (@links) {
    my @element = @$linkarray;
    my $elt_type = shift @element;

    while (@element) {
      my ($attr_name, $attr_value) = splice(@element, 0, 2);
      if ($attr_value =~ /.pdf$/i) {
        $seen{$attr_value}++;
        print "Found PDF: $attr_value\n";
      }
    }
  }
  return keys %seen;
}

sub download_files {
  my ($dir, @files) = @_;

  foreach my $file (@files) {
    my $filename = $dir . "/" . &basename($file);
    print "Downloading $file -> $filename\n";
    getstore($file, $filename);
  }
}

