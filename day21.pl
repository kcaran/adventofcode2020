#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package List;

  sub allergens {
    my ($self) = @_;

    my $complete = 1;
    do {
      $complete = 1;
      for my $a (keys %{ $self->{ allerg } }) {
        my @keys = keys %{ $self->{ allerg }{ $a } };
        if (@keys == 1) {
         my $ingred = $keys[0];
          for my $c (keys %{ $self->{ allerg } }) {
            next if ($c eq $a);
            if ($self->{ allerg }{ $c }{ $ingred }) {
              delete $self->{ allerg }{ $c }{ $ingred };
              $complete = 0;
             }
           }
         }
       }
     }
    until ($complete);

    return $self;
   }

  # Note: I'm not checking if ingredient has already been cleaned
  sub clean {
    my ($self) = @_;

    my $clean = 0;
    for my $l (@{ $self->{ list } }) {
      my $ingred = $l->[0];
      for my $i (@{ $ingred }) {
        my $unclean = 0;
        for my $a (keys %{ $self->{ allerg } }) {
          if ($self->{ allerg }{ $a }->{ $i }) {
            $unclean = 1;
            last;
           }
         }
        $clean++ if (!$unclean);
       }
     }

    return $clean;
   }

  sub dangerous {
    my ($self) = @_;

    return join( ',', map { keys %{ $self->{ allerg }{ $_ } } } (sort keys %{ $self->{ allerg } }) );
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     list => [],
     allerg => {},
     ingred => [],
    };

    for my $row ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
#print $row, "\n";
      $row =~ s/\(contains (.*?)\)$//;
      my @allerg = split( /,\s+/, $1 );
      my @ingred = split( /\s+/, $row );
      push @{ $self->{ list } }, [ \@ingred, \@allerg ];
      push @{ $self->{ ingred } }, @ingred;
      for my $a (@allerg) {
        #
        # If we've already seen the allergen, the ingredient must be in the
        # intersection of the two arrays
        #
        $self->{ allerg }{ $a } = { map { $_ => 1 } @ingred } if (!$self->{ allerg }{ $a });
        $self->{ allerg }{ $a } = { map { $self->{ allerg }{ $a }{ $_ } ? ($_ => 1) : () } @ingred };
       }
#      next;
     }

    bless $self, $class;

    $self->allergens();

    return $self;
   }
}

my $input_file = $ARGV[0] || 'input21.txt';
my $list = List->new( $input_file );

print "The number of clean ingredients is ", $list->clean(), "\n";

print "The dangerous list is ", $list->dangerous(), "\n";

exit;
