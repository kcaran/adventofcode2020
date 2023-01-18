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

    my $one = $self->{ cups }[1];

    return $one->{ next }{ label } * $one->{ next }{ next }{ label };
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
    $self->{ curr } = $first;
    $self->{ cups }[ $first->{ label } ] = $first;
    for my $label (@labels, 10 .. 1_000_000) {
      my $cup = { label => $label };
      $self->{ curr }{ next } = $cup;
      $self->{ curr } = $cup;
      $self->{ cups }[ $label ] = $cup;
     }

    $self->{ curr }{ next } = $first;
    $self->{ curr } = $first;
    $self->{ count } = 1_000_000;
#   $self->{ count } = 9;

    return $self;
  }
};

my $input = $ARGV[0] || die "Please enter input\n";

my $circle = Circle->new( $input );

#for my $i (1 .. 100) {
for my $i (1 .. 10_000_000) {
  print "Move $i\n" if ($i % 100000 == 0);
  $circle->move();
 }

print "The product of the cup labels is ", $circle->print(), "\n";

exit;
