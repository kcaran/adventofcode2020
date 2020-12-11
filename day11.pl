#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Seats;

  sub taken_2 {
    my ($self, $r, $c) = @_;

    my $state = substr( $self->{ map }[$r], $c, 1 );

    my $count = 0;
    $count++ if (substr( $self->{ map }[$r], 0, $c ) =~ /#\.*$/);
    $count++ if (substr( $self->{ map }[$r], $c + 1 ) =~ /^\.*#/);
    return 'L' if ($count > 0 && $state eq 'L');

    my $d0 = $c;
    my $d1 = $c - 1;
    my $d2 = $c + 1;
    my $row = $r - 1;
    while ($row >= 0 && ($d1 >= 0 || $d0 >= 0 || $d2 < $self->{ cols })) {
      if ($d1 >= 0 && substr( $self->{ map }[$row], $d1, 1 ) ne '.') {
        $count++ if (substr( $self->{ map }[$row], $d1, 1 ) eq '#');
        return 'L' if ($count && $state eq 'L');
        $d1 = -1;
       }
      if ($d2 < $self->{ cols } && substr( $self->{ map }[$row], $d2, 1 ) ne '.') {
        $count++ if (substr( $self->{ map }[$row], $d2, 1 ) eq '#');
        return 'L' if ($count && $state eq 'L');
        $d2 = $self->{ cols };
       }
      if ($d0 >= 0 && substr( $self->{ map }[$row], $d0, 1 ) ne '.') {
        $count++ if (substr( $self->{ map }[$row], $d0, 1 ) eq '#');
        return 'L' if ($count && $state eq 'L');
        $d0 = -1;
       }
      $d1--;
      $d2++;
      $row--;
     }

    $d0 = $c;
    $d1 = $c - 1;
    $d2 = $c + 1;
    $row = $r + 1;
    while ($row < $self->{ rows } && ($d1 >= 0 || $d0 >= 0 || $d2 < $self->{ cols })) {
      if ($d1 >= 0 && substr( $self->{ map }[$row], $d1, 1 ) ne '.') {
        $count++ if (substr( $self->{ map }[$row], $d1, 1 ) eq '#');
        return 'L' if ($count && $state eq 'L');
        $d1 = -1;
       }
      if ($d2 < $self->{ cols } && substr( $self->{ map }[$row], $d2, 1 ) ne '.') {
        $count++ if (substr( $self->{ map }[$row], $d2, 1 ) eq '#');
        return 'L' if ($count && $state eq 'L');
        $d2 = $self->{ cols };
       }
      if ($d0 >= 0 && substr( $self->{ map }[$row], $d0, 1 ) ne '.') {
        $count++ if (substr( $self->{ map }[$row], $d0, 1 ) eq '#');
        return 'L' if ($count && $state eq 'L');
        $d0 = -1;
       }
      $d1--;
      $d2++;
      $row++;
     }

    return 'L' if ($count > 0 && $state eq 'L');
    return 'L' if ($count > 4 && $state eq '#');

    return '#';
   }

  sub taken {
    my ($self, $r, $c) = @_;

    my $state = substr( $self->{ map }[$r], $c, 1 );

    my $min_row = ($r > 0 ? $r - 1 : 0);
    my $max_row = ($r < $self->{ rows } - 1 ? $r + 1 : $self->{ rows } - 1);
    my $min_col = ($c > 0 ? $c - 1 : 0);
    my $max_col = ($c < $self->{ cols } - 1 ? $c + 1 : $self->{ cols } - 1);

    my $count = 0;
    for my $row ($min_row .. $max_row) {
      $count += substr( $self->{ map }[$row], $min_col, ($max_col - $min_col + 1) ) =~ tr/#//;
     }

    # Make sure you count the current seat in the adjacents!
    return 'L' if ($count > 0 && $state eq 'L');
    return 'L' if ($count > 4 && $state eq '#');

    return '#';
   }

  sub fill {
    my ($self, $part_2) = @_;

    my @changes = ();
    $self->{ taken } = 0;

    my $routine = $part_2 ? 'taken_2' : 'taken';
    for my $row (0 .. $self->{ rows } - 1) {
      for my $col (0 .. $self->{ cols } - 1) {
        my $state = substr( $self->{ map }[$row], $col, 1 );
        next if ($state eq '.');
        my $new = $self->$routine( $row, $col );
        if ($new ne $state) {
          push @changes, [ $row, $col, $new ];
         }
        $self->{ taken }++ if ($new eq '#');
       }
      }
    for my $n (@changes) {
      substr( $self->{ map }[ $n->[0] ], $n->[1], 1, $n->[2] );
     }

    return @changes > 0 ? 1 : 0;
   }

  sub new {
    my ($class, @rows) = @_;

    my $self = {
      map => [],
      taken => 0,
    };

    for my $row (@rows) {
      push @{ $self->{ map } }, $row;
     }

    $self->{ rows } = @{ $self->{ map } };
    $self->{ cols } = length( $self->{ map }[0] );

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input11.txt';
my @rows = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );

my $seats = Seats->new( @rows );
while ($seats->fill()) {};

print "The number of taken seats in part 1 is $seats->{ taken }\n";

$seats = Seats->new( @rows );
while ($seats->fill( 1 )) {};

print "The number of taken seats in part 2 is $seats->{ taken }\n";

exit;
