#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Passport;

  my @fields = qw( byr iyr eyr hgt hcl ecl pid );
  my @eye_colors = qw( amb blu brn gry grn hzl oth );

  sub has_fields {
    my ($self) = @_;

    return (grep { $self->{ $_ } } @fields) == @fields;
   }

  sub is_valid {
    my ($self) = @_;

    return 0 if ($self->{ byr } !~ /^\d{4}$/ || $self->{ byr } < 1920 || $self->{ byr } > 2002);
    return 0 if ($self->{ iyr } !~ /^\d{4}$/ || $self->{ iyr } < 2010 || $self->{ iyr } > 2020);
    return 0 if ($self->{ eyr } !~ /^\d{4}$/ || $self->{ eyr } < 2020 || $self->{ eyr } > 2030);
    return 0 unless ($self->{ hgt } =~ /^(\d{3})cm$/ && $1 >= 150 && $1 <= 193)
		|| ($self->{ hgt } =~ /^(\d{2})in$/ && $1 >= 59 && $1 <= 76);
    return 0 unless ($self->{ hcl } =~ /^#[0-9a-f]{6}$/);
    return 0 unless (grep { $_ eq $self->{ ecl } } @eye_colors);
    return 0 unless ($self->{ pid } =~ /^\d{9}$/);

    return 1;
   }

  sub new {
    my ($class, $input) = @_;
    my $self = { map { split( ':', $_ ) } split( /\s+/, $input ) };

    bless $self, $class;
    return $self;
  };
}

my $input_file = $ARGV[0] || 'input04.txt';

my $input = path( $input_file )->slurp_utf8( { chomp => 1 } );

my $field_cnt = 0;
my $valid_cnt = 0;
for my $data ($input =~ /^(.*?)(?:\n\n|\Z)/smg) {
  my $passport = Passport->new( $data );
  if ($passport->has_fields()) {
    $field_cnt++;
    $valid_cnt++ if ($passport->is_valid());
   }
 }

print "The number of passports with all the fields is $field_cnt.\n";
print "The number of valid passports is $valid_cnt.\n";

exit;
