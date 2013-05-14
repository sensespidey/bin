#!/usr/bin/perl

use strict;
no strict qw(refs);

use DBI;                                                                                                  
use Getopt::Long;
use Data::Dumper;

my(%options, $dbh, $sth);
my(%fields);

GetOptions(\%options, 'help|h','output|o=s','verbose|v','courseid|c');

sub usage {
  print 
"Usage: $0 [-h] [-o <output-file>] [-c <courseid>]

-h help (print this usage statement)
-o specify and output file (default: stdout)
-c specify a courseid to print student info for. If not present, prints a list of courses and their ids.
";
}

if ($options{'help'}) { &usage; exit; } 
                                                                                                          
# First off, clear the existing DB                                                                        
my $dbh = DBI->connect('DBI:mysql:elearning:localhost:3306', 'moodle', 'pass' , { RaiseError => 1, AutoCommit => 1 });                                                                  

if ($options{'courseid'}) {
  $sth = $dbh->prepare(sprintf("SELECT id,fullname from mdl_course WHERE id=%d",$options{'courseid'}));
  $sth->execute();
  my @row = $sth->fetchrow_array;
  print STDERR "Selecting all users for the ".$row[1]." course\n";

  $sth = $dbh->prepare("SELECT id,name FROM mdl_user_info_field");
  $sth->execute();
  while (my $row = $sth->fetchrow_hashref) {
    $fields{$row->{'id'}} = $row->{'name'};
  }

  $sth = $dbh->prepare("SELECT * FROM mdl_user");
  
} else {
  #$sth = $dbh->prepare("SELECT id,fullname from mdl_course");
  $sth = $dbh->prepare("select ctx.id as contextid,c.id,c.fullname from mdl_context ctx left join mdl_course c on ctx.instanceid=c.id where contextlevel=50");
  $sth->execute();
  printf("Context ID\tID\t\tCourse Name\n");
  printf("===========================================================\n");
  while (my @row = $sth->fetchrow_array) {
    printf("%d\t\t%d\t\t%s\n", @row);
  }
}

