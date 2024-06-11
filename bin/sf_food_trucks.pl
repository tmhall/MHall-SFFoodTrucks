#!/usr/bin/env perl

use strict;
use warnings;

use Carp qw(confess);
use FindBin qw($Bin);
use Getopt::Long qw(GetOptions);
use JSON qw();
use Path::Tiny qw(path);
use Pod::Usage qw(pod2usage);

use lib qq{@{[ path($Bin)->parent->child('lib') ]}};

use MHall::SFFoodTrucks qw(list_sf_food_trucks);

my $ALAMO_SQUARE_LAT = 37.7765544;
my $ALAMO_SQUARE_LON = -122.4348276;

main();
exit;

sub main {
    GetOptions(    #
        'list'         => \my $opt_list,
        'all_statuses' => \my $opt_all_statuses,
        'alamo_square' => \my $opt_alamo_square,
        'latitude=f'   => \my $opt_latitude,
        'longitude=f'  => \my $opt_longitude,
        'radius=f'     => \my $opt_radius,
        'help'         => \my $opt_help,
        )
        or pod2usage(1);

    pod2usage( -exitstatus => 0, -verbose => 2 ) if $opt_help;

    pod2usage( -msg => 'Unrecognized parameters.', -verbose => 1 ) if @ARGV;

    # Short cut for the park near where I live
    if ($opt_alamo_square) {
        $opt_latitude  = $ALAMO_SQUARE_LAT;
        $opt_longitude = $ALAMO_SQUARE_LON;
    }

    if ( $opt_latitude && !$opt_longitude ) {
        pod2usage( -msg => '--latitude must be specified with a --longitude', -verbose => 1 );
    }

    if ( !$opt_latitude && $opt_longitude ) {
        pod2usage( -msg => '--longitude must be specified with a --latitude', -verbose => 1 );
    }

    if ( $opt_radius && ( !$opt_latitude || !$opt_longitude ) ) {
        pod2usage( -msg => '--radius is meaningless without a --latitude and --longitude', -verbose => 1 );
    }

    if ($opt_list) {
        print_food_trucks(
            is_active => !$opt_all_statuses,
            latitude  => $opt_latitude,
            longitude => $opt_longitude,
            radius    => $opt_radius,
        );

    } else {
        pod2usage( -exitstatus => 0, -verbose => 1 );
    }

    return;
}

sub print_food_trucks {
    my %args = @_;

    my $is_active = delete $args{is_active};
    my $latitude  = delete $args{latitude};
    my $longitude = delete $args{longitude};
    my $radius    = delete $args{radius};

    confess "Unrecognized parameters: @{[ keys %args ]}" if keys %args;

    my @food_trucks = list_sf_food_trucks(
        is_active => $is_active,
        latitude  => $latitude,
        longitude => $longitude,
        radius    => $radius,
    );

    if ( $latitude && $longitude ) {
        # Sort by distance
        @food_trucks = sort {
            ( $a->distance_in_miles // 9e9 ) <=> ( $b->distance_in_miles // 9e9 )    # Put undefined at end
                || $a->location_id <=> $b->location_id
        } @food_trucks;
    }

    my $JSON8 = JSON->new->utf8->indent->space_after->convert_blessed;

    print $JSON8->encode( \@food_trucks );

    return;
}

__END__

=head1 NAME

sf_food_trucks.pl - Interface for SF Food Trucks

=head1 SYNOPSIS

./sf_food_trucks.pl

=head1 OPTIONS

=over 4

=item --list

List SF Food Truck Permits

=item --all_statuses

By default we only show "active" permits.  This will show all other statuses as well.

=item --alamo_square

Set the latitude and longitude to that of Alamo Square in SF

=item --latitude <latitude>

Latitude from which to calculate distance

=item --longitude <longitude>

Latitude from which to calculate distance

=item --radius <miles>

Filter out food trucks outside of a given radius

=item --help -?

Full help text

=back

=head1 DESCRIPTION

Interface for MHall::SFFoodTrucks

=head1 AUTHOR

Written by Miller

=cut
