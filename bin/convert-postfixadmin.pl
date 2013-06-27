#!/usr/bin/perl

use Data::Dumper;

$aliases = {};
$domains = {};

$date = `date '+%Y-%m-%d %H:%m:%S'`;
chomp($date);

while (<>) {
  if (/INSERT INTO..virtual_domains..VALUES..([0-9]+),'([^']+)'/) {
    $domains->{$1} = $2;
  }
  if (/INSERT INTO..virtual_aliases..VALUES..([0-9]+),([0-9]+),'([^']+)','([^']+)'/) {
    my $alias = {};
    $source = lc($3);
    $destination = lc($4);
    $alias->{'domain_id'} = $2;
    $alias->{'source'} = $source;
    $alias->{'destination'} = $destination;
    if (exists($aliases->{$source})) {
      $aliases->{$source}->{'destination'} .= ", " . $destination;
    } else {
      $aliases->{$source} = $alias;
    }
  }
}

foreach $id (keys $aliases) {
  $domain_id = $aliases->{$id}->{'domain_id'};
  $aliases->{$id}->{'domain'} = $domains->{$domain_id};
}

foreach $domain (values $domains) {
  unless ($domain eq 'rnao.ca') {
    #  printf("INSERT INTO domain (domain,description,mailboxes,transport,created,modified) VALUES ('%s','%s',-1,'virtual','%s','%s');\n", $domain, $domain, $date, $date);
  }
}

foreach $alias (values $aliases) {
  printf('INSERT INTO `alias` (`address`, `goto`, `domain`, `created`, `modified`, `active`) VALUES (\'%s\', \'%s\', \'%s\', \'%s\', \'%s\', 1);%s', $alias->{source}, $alias->{destination}, $alias->{domain}, $date, $date, "\n");
}
