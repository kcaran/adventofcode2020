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
  };
  bless $self, $class;

  $self->{ h } = [ split( "\n", $map ) ];

  for my $i (0 .. length( $self->{ h }[0] ) - 1) {
    for my $j (0 .. @{ $self->{ h } } - 1) {
     $self->{ v }[$i] .= substr( $self->{ h }[$j], $i, 1 );
    }
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input20.txt';

my $input = Path::Tiny::path( $input_file )->slurp_utf8();

my $cards;
while ($input =~ /^Tile (\d+):\n(.*?)(?:^\n|\Z)/msg) {
  push @{ $cards }, Card->new( $1, $2 );
 }

exit;
