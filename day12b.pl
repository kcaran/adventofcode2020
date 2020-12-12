#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Nav;

  sub distance {
    my ($self) = @_;

    return abs( $self->{ x } ) + abs( $self->{ y } );
   }

  sub move {
    my ($self, $cmd) = @_;

    my ($action, $val) = ($cmd =~ /^(.)(\d+)/);
 
    $self->{ wp }{ x } -= $val if ($action eq 'W');
    $self->{ wp }{ x } += $val if ($action eq 'E');
    $self->{ wp }{ y } -= $val if ($action eq 'N');
    $self->{ wp }{ y } += $val if ($action eq 'S');
    if ($action eq 'F') {
      $self->{ x } += $val * $self->{ wp }{ x };
      $self->{ y } += $val * $self->{ wp }{ y };
     }
    my $dir = 0;
    $dir = $val if ($action eq 'L');
    $dir = (360 - $val) if ($action eq 'R');
    if ($dir == 90) {
      my $x = $self->{ wp }{ x };
      $self->{ wp }{ x } = $self->{ wp }{ y };
      $self->{ wp }{ y } = -$x;
     }

    if ($dir == 180) {
      $self->{ wp }{ x } = -$self->{ wp }{ x };
      $self->{ wp }{ y } = -$self->{ wp }{ y };
     }

    if ($dir == 270) {
      my $x = $self->{ wp }{ x };
      $self->{ wp }{ x } = -$self->{ wp }{ y };
      $self->{ wp }{ y } = $x;
     }

    return $self;
   }

  sub new {
    my ($class, $x, $y) = @_;

    my $self = {
      x => 0,
      y => 0,
      dir => 0,
      wp => {
        x => $x || 0,
        y => $y || 0,
        dir => 0,
      },
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input12.txt';
my $nav = Nav->new( 10, -1 );

for my $cmd (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  $nav->move( $cmd );
 };

print "The distance away is now ", $nav->distance, "\n";

exit;
