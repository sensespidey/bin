#!/usr/bin/perl

use Data::Dumper;

open(PDFS, 'find . -path ./Quark\ files\ \-\ BPG -prune -o -name "*.pdf" -print|');
while (<PDFS>) {
  $line = $_;
  chomp($line);
  printf("LINE: [$line]\n");
  $dir = `dirname "$line"`;
  chomp($dir);
  printf("DIR: [$dir]\n");
  $file = `basename "$line"`;
  chomp($file);
  printf("FILE: [$file]\n");
  $jpeg = $file;
  $jpeg =~ s/.pdf/.jpg/;
  printf("JPEG: [$jpeg]\n");
  $file = $dir . '/' . $file . "[0]";
  $jpeg = $dir . '/' . $jpeg;
  system('/usr/bin/convert',$file,$jpeg);
}

