package MHall::SFFoodTrucks;

use strict;
use warnings;
use v5.16;

BEGIN {
    our @EXPORT    = qw();
    our @EXPORT_OK = qw(
        list_sf_food_trucks
    );
}

use Carp qw(confess);
use Exporter qw(import);
use Path::Tiny qw(path);
use Text::CSV qw(csv);

use MHall::SFFoodTrucks::PermitRecord;

my $DEFAULT_FOOD_TRUCK_CSV_FILE = path(__FILE__)->parent(3)->child('db/SF_Mobile_Food_Facility_Permit.csv');

sub list_sf_food_trucks {
    my %args = @_;

    my $csv_file  = delete $args{csv_file};
    my $is_active = delete $args{is_active};
    my $latitude  = delete $args{latitude};
    my $longitude = delete $args{longitude};

    confess "Unrecognized parameters: @{[ keys %args ]}" if keys %args;

    my @all_food_trucks = _load_sf_food_trucks_from_csv( csv_file => $csv_file );

    my @food_trucks;

    for my $food_truck (@all_food_trucks) {
        next if $is_active && !$food_truck->is_active;

        if ( $latitude && $longitude ) {
            $food_truck->calculate_distance(
                latitude  => $latitude,
                longitude => $longitude,
            );
        }

        push @food_trucks, $food_truck;
    }

    return @food_trucks;
}

sub _load_sf_food_trucks_from_csv {
    my %args = @_;

    my $csv_file = delete $args{csv_file} || $DEFAULT_FOOD_TRUCK_CSV_FILE;

    confess "Unrecognized parameters: @{[ keys %args ]}" if keys %args;

    my $array_of_hashes = csv(
        in      => "$csv_file",
        headers => 'auto',
        binary  => 1,
        eol     => $/,
    );

    my @food_trucks = map { MHall::SFFoodTrucks::PermitRecord->new( csv_hash => $_ ) } @$array_of_hashes;

    return @food_trucks;
}

1;

__END__
