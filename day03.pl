#!/usr/bin/env perl
#
# When storing a map, it makes the most sense to think in (row, col) rather
# than (x,y). It makes it easier to debug since you can see the full row
# using @{ $map->[row] }.
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Map;

  sub move {
    my ($self, $slope_y, $slope_x) = @_;
    my ($pos_y, $pos_x) = (0, 0);
    my $num_trees;
    while ($pos_y + $slope_y < $self->{ num_rows }) {
       $pos_x = ($pos_x + $slope_x) % $self->{ num_cols };
       $pos_y = $pos_y + $slope_y;
       $num_trees++ if ($self->{ map }[$pos_y][$pos_x] eq '#');
     }

    return $num_trees;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
    };

    my $x = 0;
    my $y = 0;
    for my $row ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
      $x = 0;
      for my $col (split( '', $row )) {
        $self->{ map }[$y][$x] = $col;
        $x++;
       }
      $y++;
     }

    $self->{ num_cols } = $x;
    $self->{ num_rows } = $y;

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input03.txt';

my $map = Map->new( $input_file );

my @slopes = (
	[ 1, 1 ],
	[ 1, 3 ],
	[ 1, 5 ],
	[ 1, 7 ],
	[ 2, 1 ],
);

print "The number of trees in part a is ", $map->move( @{ $slopes[1] } ), "\n";

my $total = 1;
for my $slope (@slopes) {
  $total = $total * $map->move( @{ $slope } );
 }

print "The total product of all the slopes is $total.\n";

exit;
