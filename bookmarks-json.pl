#!/usr/bin/perl

use JSON; # imports encode_json, decode_json, to_json and from_json.
use Data::Dumper;

open(FILE,"</home/dlaventure/Desktop/bookmarks-2010-07-28.json") or die "Couldn't open file\n";

$json_text = <FILE>;

$perl_scalar = from_json($json_text);

$folders = $perl_scalar->{'children'};

#printf("Parsing %d folders...\n",scalar(@{$folders}));
&parse_folders($folders);

sub parse_folders {
  my($folders) = @_;
  foreach my $f (@{$folders}) {
    parse_folder($f);
  }
}

sub parse_folder {
  my ($folder) = @_;
  if ($folder->{'title'}) {
    #print "Title: ".$folder->{'title'}."\n";
    if ($folder->{'title'} eq 'temp') {
      foreach (@{$folder->{'children'}}) {
        print "Title: ".$_->{'title'}."\n";
        print "URL: ".$_->{'uri'}."\n";
      }
      #print Dumper($folder);
    }
  }
  if ($folder->{'children'}) {
    $subf = $folder->{'children'};
    #printf("Parsing %d subfolders...\n",scalar(@{$subf}));
    parse_folders($folder->{'children'});
  } else {
    return;
  } 
}

# option-acceptable
#$json_text   = to_json($perl_scalar, {ascii => 1});
#$perl_scalar = from_json($json_text, {utf8 => 1});

