#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Map;

  sub count {
    my ($self, $x0, $y0, $z0) = @_;

    my $count = 0;
    for my $x ($x0 - 1 .. $x0 + 1) {
      for my $y ($y0 - 1 .. $y0 + 1) {
        for my $z ($z0 - 1 .. $z0 + 1) {
          next if ($x == $x0 && $y == $y0 && $z == $z0);
          next unless ($self->{ map }{ "$x,$y,$z" });
          $count++;
         }
       }
     }

    return $count;
   }

  sub cycle {
    my ($self) = @_;

    my $new = Map->new();
    for my $x ($self->{ min }[0] - 1 .. $self->{ max }[0] + 1) {
      for my $y ($self->{ min }[1] - 1 .. $self->{ max }[1] + 1) {
        for my $z ($self->{ min }[2] - 1 .. $self->{ max }[2] + 1) {
          my $count = $self->count( $x, $y, $z );
          if ($self->{ map }{ "$x,$y,$z" } && $self->{ map }{ "$x,$y,$z" } eq '#') {
            $new->set( $x, $y, $z ) if ($count == 2 || $count == 3);
           }
          else {
            $new->set( $x, $y, $z ) if ($count == 3);
           }
         }
       }
     }

    return $new;
   }

  sub set {
    my ($self, $x, $y, $z) = @_;

    $self->{ min }[0] = $x if ( $self->{ min }[0] > $x);
    $self->{ min }[1] = $y if ( $self->{ min }[1] > $y);
    $self->{ min }[2] = $z if ( $self->{ min }[2] > $z);
    $self->{ max }[0] = $x if ( $self->{ max }[0] < $x);
    $self->{ max }[1] = $y if ( $self->{ max }[1] < $y);
    $self->{ max }[2] = $z if ( $self->{ max }[2] < $z);
    $self->{ map }{ "$x,$y,$z" } = '#';

    return $self;
   }

  sub init {
    my ($self, $input_file) = @_;

    my @rows = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );
    my ($x, $y, $z) = (0, 0, 0);
    for my $row (@rows) {
      my $x = 0;
      for my $c (split( '', $row )) {
        $self->set( $x, $y, $z ) if ($c eq '#');
        $x++;
       }
      $y++;
     }

    return $self;
   }

  sub new {
    my ($class, $input_file) = @_;

    my $self = {
      map => {},
      min => [ 0, 0, 0 ],
      max => [ 0, 0, 0 ],
    };
    bless $self, $class;

    $self->init( $input_file ) if ($input_file);

    return $self;
   }
}

my $input_file = $ARGV[0] || 'input17.txt';
my $map = Map->new( $input_file );

for my $i (0 .. 5) {
  $map = $map->cycle();
 }

print "The are ", scalar keys (%{ $map->{ map } }), " cubes left after 6 cycles.\n";

exit;
