#!/usr/bin/perl
# An experiment in parsing the tr-gtd.trx "xml" format

no strict;
use Data::Dumper;
use XML::Simple;
use XML::Twig;

my $arg = shift; # Filename to parse
my $twig = new XML::Twig( 
  pretty_print => 'nice',
  twig_handlers => { 
    'contexts/items/context' => \&context,
    'topics/items/topic' => \&topic,
    'thoughts/items/thought/action' =>  \&action,
  } 
);
$twig->parsefile($arg);

my @contexts;
sub context {
  my($twig, $context) = @_;
  my $id = $context->first_child('id')->text;
  my $name = $context->first_child('name')->text;
  my $desc = $context->first_child('description')->text;
  push(@contexts, {'id' => $id, 'name' => $name, 'description' => $desc });
  return 1;
}

my @topics;
sub topic {
  my($twig, $topic) = @_;
  my $id = $topic->first_child('id')->text;
  my $name = $topic->first_child('name')->text;
  my $desc = $topic->first_child('description')->text;
  push(@topics, {'id' => $id, 'name' => $name, 'description' => $desc });
  return 1;
}

my @action;
sub action {
  my($twig, $action) = @_;
#  $action->print;
  # print "--ACTION--\n";
  #while (my $a = $action->
#k  print $action;
  #print Dumper($action->twig->entity_list());
#  foreach my $a ($action->entity_list()) {
#    $a->print;
  #print "\n----\n";
#  }
}

#print "ENTITY LIST\n";
#print Dumper($twig->root->entity_list());

#my $root = $twig->root;
##my @actions = $root->children_text();
#my @actions = $root->children('action');
#print Dumper(\@actions);
#for (my $i=0 ; $i < @actions ; $i++) {
#  print "Action $i:\n";
#  print Dumper($actions[$i]);
#}
#print $action;
#print "Action ".$i++.":\n";
#print "\n----\n";
#while (my $action = $action->next_sibling('action')) {
#  print "Action ".$i++.":\n";
#  $action->print;
#  print "\n----\n";
#}
#$twig->set_root($action);
#$twig->print;

#print "Contexts:\n";
#print Dumper(\@contexts);
#print "Topics:\n";
#print Dumper(\@topics);


my $xml = new XML::Simple;

# read XML
$data = $xml->XMLin($arg);

foreach my $toplevel (keys %{$data}) {
  print "Toplevel: ".$toplevel."\n";
#  foreach my $sectionkey (keys %{$data->{$toplevel}}) {
#    print "\tSection: $sectionkey\n";
#  }
}
#print Dumper($data);

my $thoughts = $data->{'thoughts'}->{'items'}->{'thought'};
my $version = $data->{'version'};
my $information = $data->{'information'}->{'items'};

print "THOUGHTS\n";
my @thought_hashes;
#print Dumper($thoughts); # includes next actions
for (my $i=0 ; $i < @{$thoughts} ; $i++) {
  $t = $thoughts->[$i];
  $h = {};
  foreach my $tkey (keys %{$t}) {
    print "Thought key: ".$tkey."\n";
    if ($tkey eq 'topic') {
        $topic = $t->{$tkey}->{'reference'};
        $topic =~ m!topics/items/topic\[(\d+)\]!;
        $topic = $topics[$1]->{'name'};
        print "Topic: $topic\n";
        $h->{$tkey} = $topic;
    } elsif ($tkey eq 'action') {
      #print Dumper(keys(%{$t->{$tkey}}));
      my $action = $t->{$tkey};
      #$h{$tkey} = $action;
      foreach my $k (keys %{$action}) {
        print "$k: $action->{$k}\n" unless ($k eq 'parent');
      }
      #parse_action($t->{$tkey});
    } else {
      print "$tkey: ". $t->{$tkey} . "\n";
      $h->{$tkey} = $t->{$tkey};
    }
#    if ($tkey eq 'action') {
#      print Dumper($t->{$tkey});
#    }
    #print "Thought topic: ".Dumper($t->{$tkey}) if $tkey = 'topic';
  }
  push(@thought_hashes, $h);
}
print "THOUGHT HASHES\n";
print Dumper(\@thought_hashes);

sub parse_action {
  my $action = @_;
  print Dumper($action);
  foreach my $k (keys %{$action}) {
    print "$k: $action->{$k}\n" unless ($k eq 'parent');
  }
}

#print "INFO\n";
#print Dumper($information); # This looks like 'reference' material

#Toplevel: version
#Toplevel: futures
#	Section: items
#Toplevel: information
#	Section: items
#Toplevel: maxLogID
#Toplevel: energyCriterion
#	Section: use
#	Section: name
#	Section: values
#Toplevel: maxID
#Toplevel: priorityCriterion
#	Section: use
#	Section: name
#	Section: values
#Toplevel: timeCriterion
#	Section: use
#	Section: name
#	Section: values
#Toplevel: rootFutures
#	Section: organising
#	Section: success
#	Section: topic
#	Section: done
#	Section: sequence
#	Section: brainstorming
#	Section: purpose
#	Section: children
#	Section: description
#	Section: modified
#	Section: created
#	Section: class
#	Section: id
#Toplevel: rootTemplates
#	Section: organising
#	Section: success
#	Section: topic
#	Section: done
#	Section: sequence
#	Section: brainstorming
#	Section: purpose
#	Section: children
#	Section: description
#	Section: modified
#	Section: created
#	Section: class
#	Section: id
#Toplevel: rootProject
#	Section: reference
#	Section: class
#Toplevel: rootActions
#	Section: reference
#	Section: class
#$VAR1 = {
#          'contexts' => {
#                        'items' => {
#                                   'context' => {
#                                                'Read/Review' => {
#                                                                 'id' => '2413',
#                                                                 'description' => {}
#                                                               },
#                                                'At Computer' => {
#                                                                 'id' => '2409',
#                                                                 'description' => {}
#                                                               },
#                                                'None' => {
#                                                          'id' => '2407',
#                                                          'description' => 'No context.'
#                                                        },
#                                                'Calls' => {
#                                                           'id' => '2408',
#                                                           'description' => {}
#                                                         },
#                                                'Errands' => {
#                                                             'id' => '2410',
#                                                             'description' => {}
#                                                           },
#                                                'At Home' => {
#                                                             'id' => '2411',
#                                                             'description' => {}
#                                                           },
#                                                'Office' => {
#                                                            'id' => '2415',
#                                                            'description' => {}
#                                                          },

#                'organising' => {},
#                'success' => {},
#                'topic' => {
#                           'reference' => '../../../../../../../../topics/items/topic'
#                         },
#                'done' => 'false',
#                'sequence' => 'false',
#                'brainstorming' => {},
#                'purpose' => {},
#                'children' => {
#                              'actions' => {
#
#     'organising' => {},
#     'success' => {},
#     'topic' => {
#                'reference' => '../../../../../../../../../../topics/items/topic[8]'
#              },
#     'done' => 'false',
#     'parent' => {
#                 'reference' => '../../..',
#                 'class' => 'tr.model.project.ProjectRoot'
#               },
#     'sequence' => 'false',
#     'brainstorming' => {},
#     'purpose' => {},
