#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

my $rules;

{ package Rules;

  sub num_bags {
    my ($self) = @_;
    my $count = 1;
    for my $bag (@{ $self->{ contents } }) {
      $count += $bag->[0] * $rules->{ $bag->[1] }->num_bags();
     }
    return $count;
   }

  sub has_color {
    my ($self, $color) = @_;

    for my $bag (@{ $self->{ contents } }) {
      return 1 if ($bag->[1] eq $color);
      return 1 if ($rules->{ $bag->[1] }->has_color( $color ));
     }

    return 0;
   }

  sub new {
    my ($class, $input) = @_;
    my $self = { contents => [] };
    $input =~ s/^(.*?) bags? contain // || die "Illegal input $input";
    $self->{ color } = $1;
    while ($input =~ /(\d+)\s(.*?)\sbags?/g) {
      push @{ $self->{ contents } }, [ $1, $2 ];
     }

    bless $self, $class;
    $rules->{ $self->{ color } } = $self;
    return $self;
  };
}

sub contents {
  my ($color) = @_;

  my $count = 0;
  for my $bag (keys %{ $rules }) {
    $count++ if ($rules->{ $bag }->has_color( $color ));
   }

  print "The number of bags that can contain $color is $count\n";

  return $count;
 }

my $input_file = $ARGV[0] || 'input07.txt';

for my $input (path( $input_file )->lines_utf8( { chomp => 1 } )) {
  Rules->new( $input );
 }

contents( 'shiny gold' );

# Don't count the most-outer bag!
print "The shiny gold bag contains ", $rules->{ 'shiny gold' }->num_bags() - 1, " other bags\n";

exit;
