#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my %flip = (
   'E' => 'W',
   'W' => 'E',
   'N' => 'S',
   'S' => 'N',
 );

my %cards;

{ package Card;

sub edges {
  my ($self) = @_;
  my @edges;
  for my $n (@{ $self->{ edges } }) {
    push @edges, $self->compare( $cards{ $n } );
   }

  return join( '', sort { $a cmp $b } @edges );
 }

sub compare {
  my ($self, $other, $aim) = @_;

  return unless ($other);

  # 1 is up
  for my $rot (0 .. 7) {
    return 'N' if ($self->{ h }[0] eq $other->{ h }[-1] && (!$aim || $aim eq 'N'));
    return 'E' if ($self->{ v }[-1] eq $other->{ v }[0] && (!$aim || $aim eq 'E'));
    return 'S' if ($self->{ h }[-1] eq $other->{ h }[0] && (!$aim || $aim eq 'S'));
    return 'W' if ($self->{ v }[0] eq $other->{ v }[-1] && (!$aim || $aim eq 'W'));
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

{ package Grid;

  sub find {
    my ($self) = @_;
    my $rough = 0;

    my $off = length( $self->{ h }[0] ) - 19;
    my $s = join( '', @{ $self->{ h } } );
    #
    # NOTE: My regex doesn't take into account monsters on the same
    # line! :-(
    #
    my $found = 0;
    while (my $matches = $s =~ s/#(.{$off})#(.{4})##(.{4})##(.{4})###(.{$off})#(.{2})#(.{2})#(.{2})#(.{2})#(.{2})#/O$1O$2OO$3OO$4OOO$5O$6O$7O$8O$9O$10O/msg) {
      $found += $matches;
     }

    if ($found) {
      my @r = $s =~ /#/g;
      $rough = scalar( @r );
     }

    return $rough;
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
    my ($class, $tiles) = @_;

    my $self = {
      h => [],
      v => [],
      orient => 0,
     };

    bless $self, $class;
    my $size = @{ $tiles->[0][0]{ h } };

    for my $row (0 .. @{ $tiles } - 1) {
      for my $h (1 .. $size - 2) {
        my $map = '';
        for my $col (0 .. @{ $tiles->[$row] } - 1) {
          my $tile = $tiles->[$row][$col];
          $map .= substr( $tile->{ h }[$h], 1, -1 );
         }
        push @{ $self->{ h } }, $map;
       }
     }

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

while ($input =~ /^Tile (\d+):\n(.*?)(?:^\n|\Z)/msg) {
  my $card = Card->new( $1, $2 );
  $cards{ $card->{ id } } = $card;
 }

my @ids = keys %cards;
for my $i (0 .. @ids - 2) {
  for my $j ($i + 1 .. @ids - 1) {
    my $card_i = $ids[$i];
    my $card_j = $ids[$j];
    if (my $orient = $cards{ $card_i }->compare( $cards{ $card_j } )) {
      push @{ $cards{ $card_i }->{ edges } }, $cards{ $card_j }->{ id };
      push @{ $cards{ $card_j }->{ edges } }, $cards{ $card_i }->{ id };
     }
   }
 }

my $corners = 1;
my $origin = -1;
for my $i (keys %cards) {
  if (@{ $cards{ $i }->{ edges } } == 2) {
    $corners *= $cards{ $i }->{ id };
    $origin = $cards{ $i } if ($origin < 0);
   }
 }
print "The product of the corner tiles is $corners\n";

my $size = int( sqrt( %cards ) + 0.5 );
my $grid = [];
$grid->[0][0] = $origin;
delete $cards{ $origin->{ id } };
my $row = 0;
my $col = 0;
# Ensure that origin is in upper left
while ($origin->edges() ne 'ES') {
  $origin->transform();
 }

while (%cards) {
  if ($col == $size - 1) {
    $row++;
    $col = 0;
  my $card = $grid->[$row-1][$col];
  my $found = 0;
  for my $n (@{ $card->{ edges } }) {
    next unless $cards{ $n };
    if ($card->compare( $cards{ $n }, 'S' )) {
      $grid->[$row][$col] = $cards{ $n };
      delete $cards{ $n };
      $found = 1;
      last;
     }
   }
  die "Can't find next neighbor for $card->{ id }" unless ($found);
   }

  my $card = $grid->[$row][$col];
  my $found = 0;
  for my $n (@{ $card->{ edges } }) {
    next unless $cards{ $n };
    if ($card->compare( $cards{ $n }, 'E' )) {
      $col++;
      $grid->[$row][$col] = $cards{ $n };
      delete $cards{ $n };
      $found = 1;
      last;
     }
   }
  die "Can't find next neighbor for $card->{ id }" unless ($found);
 }

my $monsters = Grid->new( $grid );
my $rough;
while (!($rough = $monsters->find())) {
  $monsters->transform();
 }

print "The rough left after the monsters is $rough\n";

exit;
