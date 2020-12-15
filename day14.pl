#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Program;

 my $default_mask = '111111111111111111111111111111111111';

 sub calc {
   my ($self) = @_;

   my $sum = 0;
   for my $reg (keys %{ $self->{ register } }) {
     $sum += $self->{ register }{ $reg };
    }

   return $sum;
  }

 sub run {
   my ($self) = @_;

   for my $cmd (@{ $self->{ program } }) {
     if ($cmd =~ /^mask\s+=\s+(.*?)$/) {
       my $mask0 = $1;
       my $mask1 = $1;
       $mask0 =~ s/X/1/g;
       $mask1 =~ s/X/0/g;
       $self->{ mask_0 } = oct( "0b$mask0" );
       $self->{ mask_1 } = oct( "0b$mask1" );
      }
     elsif ($cmd =~ /^mem\[(\d+)\]\s+=\s+(\d+)$/) {
       my $reg = $1;
       my $val = $2;
       $val = $val & $self->{ mask_0 } | $self->{ mask_1 };
       $self->{ register }{ $reg } = $val;
      }
     else {
       die "Illegal command $cmd\n";
      }
    }
   return $self;
  }

 sub new {
    my ($class, $input_file) = @_;
    my $self = {
     program => [ Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } ) ],
     mask_0 => oct( "0b$default_mask" ),
     mask_1 => 0,
     register => {},
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input14.txt';

my $program = Program->new( $input_file );

$program->run();

print "The sum is ", $program->calc(), "\n";

exit;
