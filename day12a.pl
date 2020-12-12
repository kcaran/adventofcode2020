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
 
    $self->{ x } -= $val if ($action eq 'W');
    $self->{ x } += $val if ($action eq 'E');
    $self->{ y } -= $val if ($action eq 'N');
    $self->{ y } += $val if ($action eq 'S');
    $self->{ dir } = ($self->{ dir } + $val) % 360 if ($action eq 'L');
    $self->{ dir } = (360 + $self->{ dir } - $val) % 360 if ($action eq 'R');
    $self->{ x } -= $val if ($action eq 'F' && $self->{ dir } == 180);
    $self->{ x } += $val if ($action eq 'F' && $self->{ dir } == 0);
    $self->{ y } -= $val if ($action eq 'F' && $self->{ dir } == 90);
    $self->{ y } += $val if ($action eq 'F' && $self->{ dir } == 270);

    return $self;
   }

  sub new {
    my ($class) = @_;

    my $self = {
      x => 0,
      y => 0,
      dir => 0,
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input12.txt';
my $nav = Nav->new();

for my $cmd (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  $nav->move( $cmd );
 };

print "The distance away is now ", $nav->distance, "\n";

exit;
