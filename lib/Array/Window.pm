package Array::Window;

use strict;
use UNIVERSAL 'isa';

use vars qw{$VERSION};
BEGIN { 
	$VERSION = 0.1;
}

# A description of the properties
# 
# source_start - The lowest index of the source array
# source_end - The highest index of the source array
# window_start - The lowest index of the data window
# window_end - The highest index of the data window
# window_length - The length of the window ( number of items inclusive )
# window_length_desired - The length of the window they would LIKE to have
# previous_start - The index number of window_start for the "Previous" window
# next_start - The index number of window_start for the "Next" window

sub new {
	my $class = shift;
	my %options = @_;
	
	# Create the new object
	my $self = {
		source_start => undef,
		source_end => undef,
		window_start => undef,
		window_end => undef,
		window_length => undef,
		window_length_desired => undef,
		previous_start => undef,
		next_start => undef,
		};
	bless $self, $class;

	# Check for a specific source
	if ( $options{source} ) {
		return undef unless isa( $options{source}, 'ARRAY' );
		
		$self->{source_start} = 0;
		$self->{source_end} = $#{$options{source}};
	} elsif ( defined $options{source_start} and defined $options{source_end} ) {
		$self->{source_start} = $options{source_start};
		$self->{source_end} = $options{source_end};
	} else {
		# Source not defined
		return undef;
	}
	
	# Do we have the window start?
	if ( defined $options{window_start} ) {
		# We can't be before the beginning
		$self->{window_start} = $options{window_start};
	} else {
		return undef;
	}

	# Do we have the window length?
	if ( defined $options{window_length} ) {
		return undef unless $options{window_length} > 0;
		$self->{window_length} = $options{window_length};
		$self->{window_length_desired} = $options{window_length};
	} elsif ( defined $options{window_end} ) {
		return undef if $options{window_end} < $self->{window_start};
		$self->{window_end} = $options{window_end};
	} else {
		# Not enough data to do the math
		return undef;
	}

	# Do the math
	$self->_calculate;
	return $self;
}

# Do the calculations to set things as required.
# We also support incremental calculations.
sub _calculate {
	my $self = shift;

	# First, finish the third of the window_ values.
	# This will be either window_length or window_end.
	$self->_calculate_window_end() unless defined $self->{window_end};
	$self->_calculate_window_length() unless defined $self->{window_length};
	
	# Adjust the window back into the source if needed
	if ( $self->{window_start} < $self->{source_start} ) {
		$self->{window_start} += ($self->{source_start} - $self->{window_start});
		$self->_calculate_window_end();
		
		# If this move puts window_end after source_end, fix it
		if ( $self->{window_end} > $self->{source_end} ) { 
			$self->{window_end} = $self->{source_end};
			$self->_calculate_window_length();
		}
	}
	if ( $self->{window_end} > $self->{source_end} ) {
		$self->{window_start} -= ($self->{window_end} - $self->{source_end});
		$self->_calculate_window_end();
	
		# If this move puts window_start before source_start, fix it
		if ( $self->{window_start} < $self->{source_start} ) {
			$self->{window_start} = $self->{source_start};
			$self->_calculate_window_length();
		}
	}
	
	# Calculate the next window_start
	if ( $self->{window_end} == $self->{source_end} ) {
		$self->{next_start} = undef;
	} else {
		$self->{next_start} = $self->{window_end} + 1;
	}
	
	# Calculate the previous window_start
	if ( $self->{window_start} == $self->{source_start} ) {
		$self->{previous_start} = undef;
	} else {
		$self->{previous_start} = $self->{window_start} - $self->{window_length};
		if ( $self->{previous_start} < $self->{source_start} ) {
			$self->{previous_start} = $self->{source_start};
		}
	}
	
	return 1;
}

# Smaller calculation componants
sub _calculate_window_start {
	my $self = shift;
	$self->{window_start} = $self->{window_end} - $self->{window_length} + 1;
}
sub _calculate_window_end {
	my $self = shift;
	$self->{window_end} = $self->{window_start} + $self->{window_length} - 1;
}
sub _calculate_window_length {
	my $self = shift;
	$self->{window_length} = $self->{window_end} - $self->{window_start} + 1;
}





#####################################################################
# Access methods

sub source_start          { $_[0]->{source_start} }
sub source_end            { $_[0]->{source_end} }
sub window_start          { $_[0]->{window_start} }
sub window_length         { $_[0]->{window_length} }
sub window_length_desired { $_[0]->{window_length_desired} }
sub window_end            { $_[0]->{window_end} }
sub previous_start        { $_[0]->{previous_start} }
sub next_start            { $_[0]->{next_start} }

# Get an object representing the next window.
# Returns 0 if there is no next window.
sub next {
	my $self = shift;
	my $class = ref $self;
	
	# If there is no next, return false
	return 0 unless defined $self->{next_start};
	
	# Create the next window	
	return $class->new( 
		source_start  => $self->{source_start},
		source_end    => $self->{source_end},
		window_length => $self->{window_length_desired},
		window_start  => $self->{next_start},
		);
}

sub previous {
	my $self = shift;
	my $class = ref $self;
	
	# If there is no previou, return false
	return 0 unless defined $self->{previous_start};
	
	# Create the previous window
	return $class->new(
		source_start => $self->{source_start},
		source_end => $self->{source_end},
		window_length => $self->{window_length_desired},
		window_start => $self->{previous_start},
		);
}

# Method to determine if we need to do windowing.
# The method returns false if the subset is the entire set, 
# and true if the subset is smaller than the set
sub required {
	my $self = shift;
	return 1 unless $self->{source_start} == $self->{window_start};
	return 1 unless $self->{source_end} == $self->{window_end};
	return 0;
}

# $window->extract( \@array );
# Method takes a set that matches the window parameters, and extracts
# the specified window
# Returns a reference to the sub array on success
# Returns undef if the array does not match the window
sub extract {
	my $self = shift;
	my $arrayref = shift;
	
	# Check that they match
	return undef unless $self->{source_start} == 0;
	return undef unless $self->{source_end} == $#$arrayref;
	
	# Create the sub array
	my @subarray = ();
	@subarray = @{$arrayref}[$self->window_start .. $self->window_end];
	
	# Return a reference to the sub array
	return \@subarray;
}
	
1;

__END__


=pod

=head1 NAME

Array::Window - Calculate windows/subsets/pages of arrays.

=head1 SYNOPSIS

  # Your search routine returns an array of sorted results
  # of unknown quantity.
  my $results = SomeSearch->find( 'blah' );

  # We want to display 20 results at a time
  my $Window = Array::Window->new( 
  	source => $results,
  	window_start => 0,
  	window_length => 20,
  	);

  # Do we need to split into pages at all?
  my $show_pages = $Window->required;
  
  # Extract the subset from the array
  my $subset = $Window->extract( $results );
  
  # Are there 'Next' or 'Previous' windows?
  my $Next = $Window->next;
  my $Previous = $Window->previous;

=head1 DESCRIPTION

Many applications require that a large set of results be broken down
into a smaller set of 'windows', or 'pages' in web language. Array::Window
implements an algorithm specifically for dealing with these windows. It
is very flexible and permissive, making adjustments to the window as needed.

Note that this is NOT under Math:: for a reason. It doesn't implement
in a pure fashion, it handles idiosyncracies and corner cases specifically
relating to the presentation of data.

=head2 Values are not in Human terms

People will generally refer to the first value in a set as the 1st element,
that is, a set containing 10 things will start at 1 and go up to 10.
Computers refer to the first value as the '0th' element, with the same set
starting at 0 and going up to 9.

The methods for this class return computer orientated values, so if you were
to generate a message for a particular window, it might go as follows.

  print 'Displaying Widgets ' . ($Window->window_start + 1)
  	. ' to ' . ($Window->window_end + 1)
  	. ' of ' . ($Window->source_end + 1);

The inconvenience of this may be addressed in a later version of the module.

=head1 METHODS

=head2 new( %options )

The C<new()> constructor is very flexible with regards to the options that can
be passed to it. However, this generally breaks down into deriving two things.

Firstly, it needs know about the source, usually an array, but more 
generically treated as a range of integers. For a typical 100 element array 
C<@array>, you could use one of the following sets of options.

Either

  Array::Window->new( source => \@array );

OR

  Array::Window->new( source_start => 0, source_end => 99 );

The source value will ONLY be taken as an array reference.

Secondly, the object needs to know information about Window it will be 
finding. Assuming a B<desired> window size of 10, and assuming we use the first
of the two options above, you would end up with the following.

Either

  Array::Window->new( source => \@array, 
  	window_start => 0, window_length => 10 );

OR

  Array::Window->new( source => \@array,
  	window_start => 0, window_end => 9 );

Although the second option looks a little silly, bear in mind that Array::Window
will not assume that just because you WANT a window from 0 - 9, it's actually 
going to fit the size of the array.

Please note that the object does NOT make a copy or otherwise retain information
about the array, so if you change the array later, you will need to create a new
object.

=head2 source_start()

Returns the index of the first source value, which will be 0.

=head2 source_end()

Returns the index of the last source value, which for array @array, will be
the same as $#array.

=head2 window_start()

Returns the index of the first value in the window.

=head2 window_end()

Returns the index of the last value in the window.

=head2 window_length()

Returns the length of the window. This is NOT guarenteed to be the same as 
you initially entered, as the value you entered may have not fit. Imagine
trying to get a 100 element long window on a 10 element array. Something
has to give.

=head2 window_length_desired()

Returns the desired window length. i.e. The value you originally entered.

=head2 previous_start()

If a 'previous' window can be calculated, this will return the index of the
start of the previous window.

=head2 next_start()

If a 'next' window can be calculated, this will return the index of the start
of the next window.

=head2 previous()

This method returns an C<Array::Window> object representing the previous 
window, which you can then apply as needed. Returns C<0> if the window is
already at the 'beginning' of the source, and no previous window exists.

=head2 next()

This method returns an C<Array::Window> object representing the next window,
which you can apply as needed. Returns C<0> if the window is already at the
'end' of the source, and no window exists after this one.

=head2 required()

Looks at the window and source and tries to determine if the entire source
can be shown without the need for windowing. This can be usefull for interface
code, as you can avoid generate 'next' of 'previous' controls at all.

=head2 extract( \@array )

Applies the object to an array, extracting the subset of the array that the
window represents.

=head1 SUPPORT

Contact the author

=head1 TO DO

- The C<first_window> and C<last_window> methods.
- Determine how many windows there are.
- C<human_values> method to return human readable values.

=head1 AUTHOR

        Adam Kennedy ( maintainer )
        cpan@ali.as
        http://ali.as/

=head1 SEE ALSO

L<Set::Window> - For more math orientated windows

=head1 COPYRIGHT

Copyright (c) 2002 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
