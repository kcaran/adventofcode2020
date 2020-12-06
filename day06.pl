#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Group;

  sub all {
    my ($self) = @_;
    my $num = scalar @{ $self->{ group } };
    my $all = 0;
    for my $q (keys %{ $self->{ answers } }) {
      $all++ if ($self->{ answers }{ $q } == $num);
     }
    return $all;
   }

  sub total {
    my ($self) = @_;

    return scalar keys %{ $self->{ answers } };
   }

  sub new {
    my ($class, $input) = @_;
    my $self = {
      group => [ split( /\s+/, $input ) ],
      answers => {},
    };

    for my $p (@{ $self->{ group } }) {
      for my $a (split( '', $p )) {
        $self->{ answers }{ $a }++;
       }
     }
    bless $self, $class;

    return $self;
  }
};

my $input_file = $ARGV[0] || 'input06.txt';

my $input = path( $input_file )->slurp_utf8( { chomp => 1 } );

my $sum = 0;
my $all = 0;
for my $data ($input =~ /^(.*?)(?:\n\n|\Z)/smg) {
  my $group = Group->new( $data );
  $sum += $group->total();
  $all += $group->all();
 }

print "The total for all groups is $sum\n";
print "They all answered yes to $all\n";

exit;
