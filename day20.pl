#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Card;

sub compare {
  my ($self, $other) = @_;

  # 1 is up
  for my $rot (0 .. 7) {
    return [-1, 0] if ($self->{ h }[0] eq $other->{ h }[-1]);
    return [ 0, 1] if ($self->{ v }[-1] eq $other->{ v }[0]);
    return [ 1, 0] if ($self->{ h }[-1] eq $other->{ h }[0]);
    return [ 0,-1] if ($self->{ v }[0] eq $other->{ v }[-1]);
    $other->transform();
   }

  return;
 }

sub transform {
  my ($self) = @_;

  $self->{ orient }++;

  # First, flip around y-axis
  for my $h (0 .. @{ $self->{ h } } - 1) {
    $self->{ h }[$h] = scalar reverse( $self->{ h }[$h] );
   }
  $self->{ v } = [ reverse( @{ $self->{ v } } ) ];

  # Rotate if even
  if ($self->{ orient } % 2 == 0) {
    my ($roth, $rotv);
    for my $h (reverse( 0 .. @{ $self->{ h } } - 1 )) {
      push @{ $rotv }, $self->{ h }[$h];
     }
    for my $v ( 0 .. @{ $self->{ h } } - 1 ) {
      push @{ $roth }, scalar reverse( $self->{ v }[$v] );
     }
    $self->{ h } = $roth;
    $self->{ v } = $rotv;
   }

  return $self;
 }

sub new {
  my ($class, $id, $map) = @_;

  my $self = {
    id => $id,
    h => [],
    v => [],
    orient => 0,
    transforms => [],
  };
  bless $self, $class;

  $self->{ h } = [ split( "\n", $map ) ];

  for my $i (0 .. length( $self->{ h }[0] ) - 1) {
    for my $j (0 .. @{ $self->{ h } } - 1) {
     $self->{ v }[$i] .= substr( $self->{ h }[$j], $i, 1 );
    }
   }

  #
  # Note: I probably don't need to transform the entire grid (just the
  # first and last rows/columns, but that is the way I first tried it
  # first.
  #
  for my $t (0 .. 7) {
    push @{ $self->{ transform } }, [ $self->{ h }[0], $self->{ v }[-1], $self->{ h }[-1 ], $self->{ v }[0] ];
    $self->transform();
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input20.txt';

my $input = Path::Tiny::path( $input_file )->slurp_utf8();

my @cards;
while ($input =~ /^Tile (\d+):\n(.*?)(?:^\n|\Z)/msg) {
  push @cards, Card->new( $1, $2 );
 }

for my $i (0 .. @cards - 2) {
  for my $j ($i + 1 .. @cards - 1) {
    if ($cards[$i]->compare( $cards[$j] )) {
      push @{ $cards[$i]->{ edges } }, $cards[$j]->{ id };
      push @{ $cards[$j]->{ edges } }, $cards[$i]->{ id };
     }
   }
 }

my $corners = 1;
my $origin = -1;
for my $i (0 .. @cards - 1) {
  if (@{ $cards[$i]->{ edges } } == 2) {
    $corners *= $cards[$i]->{ id };
    $origin = $i unless ($origin >= 0);
   }
 }
print "The product of the corner tiles is $corners\n";

exit;
