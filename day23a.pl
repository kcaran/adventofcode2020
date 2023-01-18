#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Circle;

  sub print {
    my ($self) = @_;

    my $start = $self->{ curr }{ label };
    print "($start) ";
    my $next = $self->{ curr }{ next };
    while ($next->{ label } != $start) {
      print "$next->{ label } ";
      $next = $next->{ next };
     }
    print "\n";
    return;
   }

  sub move {
    my ($self) = @_;

    my $curr = $self->{ curr }{ label };
    my $pickup = $self->{ curr }{ next };
    $self->{ curr }{ next } = $self->{ curr }{ next }{ next }{ next }{ next };
    $self->{ curr } = $self->{ curr }{ next };
    $self->place( $curr, $pickup );

    return $self;
   }

  sub place {
    my ($self, $label, $pickup) = @_;

    # These are excluded
    my %exclude;
    $exclude{ $pickup->{ label } } = 1;
    $exclude{ $pickup->{ next }{ label } } = 1;
    $exclude{ $pickup->{ next }{ next }{ label } } = 1;

    my $target = $label;
    do {
      $target--;
      $target = $self->{ count } if ($target == 0);
    } until (!$exclude{ $target });

    my $dest = $self->{ cups }[ $target ];
    my $last = $dest->{ next };
    $pickup->{ next }{ next }{ next } = $last;
    $dest->{ next } = $pickup;

    return;
   }

  sub new {
    my ($class, $input) = @_;
    my $self = {
      cups => [],
    };
    bless $self, $class;

    my @labels = split( '', $input );
    my $first = { label => shift @labels };
    $self->{ cups }[ $first->{ label } ] = $first;
    $self->{ curr } = $first;
    for my $label (@labels) {
      my $cup = { label => $label };
      $self->{ curr }{ next } = $cup;
      $self->{ curr } = $cup;
      $self->{ cups }[ $label ] = $cup;
     }
    $self->{ curr }{ next } = $first;
    $self->{ curr } = $first;
    $self->{ count } = @labels + 1;

    return $self;
  }
};

my $input = $ARGV[0] || '389125467';

my $circle = Circle->new( $input );

for my $i (1 .. 100) {
  $circle->move();
 }

$circle->print();

exit;
