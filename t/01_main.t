#!/usr/bin/perl

# Formal testing for Array::Window

use strict;
use lib '../../../modules'; # For development testing
use lib '../lib'; # For installation testing
use UNIVERSAL 'isa';
use Test::Simple tests => 29;

# Set up any needed globals
use vars qw{$loaded};
BEGIN {
	$loaded = 0;
	$| = 1;
}




# Check their perl version
BEGIN {
	ok( $] >= 5.005, "Your perl is new enough" );
}
	




# Does the module load
END { ok( 0, 'Array::Window loads' ) unless $loaded; }
use Array::Window;
$loaded = 1;
ok( 1, 'Array::Window loads' );


# Run the bulk of the tests
my $group = 'basic';
my $test_id = 0;
foreach ( <DATA> ) {
	$test_id++;
	chomp;
	next if /^\s*$/ || /^\s*#/;

	# Split
	my @parts = map { $_ eq 'undef' ? undef : $_ } split /\W+/, $_;
	die 'Invalid test format' unless scalar @parts == 10;

	# Create the object
	my $Object = Array::Window->new( source_start => $parts[0],
		source_end => $parts[1],
		window_start => $parts[2],
		window_length => $parts[3],
		);
	ok( defined $Object, "$group:$test_id defined " );
	ok( isa( $Object, 'Array::Window' ), "$group:$test_id is an Array::Window" );
	ok( compare($Object->window_start, $parts[4]), "$group:$test_id ->window_start returns correct" );
	ok( compare($Object->window_end, $parts[5]), "$group:$test_id ->window_end returns correct" );
	ok( compare($Object->window_length, $parts[6]), "$group:$test_id ->window_length returns correct" );
	ok( compare($Object->window_length_desired, $parts[3]), "$group:$test_id ->window_length_desired returns correct" );
	ok( compare($Object->required, $parts[7]), "$group:$test_id ->required returns correct" );
	ok( compare($Object->previous_start, $parts[8]), "$group:$test_id ->previous_start returns correct" );
	ok( compare($Object->next_start, $parts[9]), "$group:$test_id ->next_start returns correct" );

}

sub compare {
	return undef unless scalar @_ == 2;
	my ($a, $b) = @_;

	if ( defined $a and defined $b ) {
		return $a == $b ? 1 : 0;
	} elsif ( ! defined $a and ! defined $b ) {
		return 1;
	} else {
		return 0;
	}	
}

__DATA__
0-100:0-10  0-9:10:1  undef:10
0-100:10-10 10-19:10:1  0:20
0-100:98-10 91-100:10:1  81:undef 
