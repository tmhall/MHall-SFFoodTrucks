package MHall::Geo::Distance;

use strict;
use warnings;
use v5.16;

BEGIN {
    our @EXPORT    = qw();
    our @EXPORT_OK = qw(
        great_circle_miles
    );
}

use Carp qw(confess);
use Exporter qw(import);
use Math::Trig qw(great_circle_distance deg2rad);

my $EARTH_RADIUS_MEAN_IN_MILES = 3_958.8;

sub great_circle_miles {
    my %args = @_;

    my $lat1_in_degrees = delete $args{lat1} // confess "lat1 is required";
    my $lon1_in_degrees = delete $args{lon1} // confess "lon1 is required";
    my $lat2_in_degrees = delete $args{lat2} // confess "lat2 is required";
    my $lon2_in_degrees = delete $args{lon2} // confess "lon2 is required";

    confess "Unrecognized parameters: @{[ keys %args ]}" if keys %args;

    my $theta0 = deg2rad($lon1_in_degrees);
    my $phi0   = deg2rad( 90 - $lat1_in_degrees );
    my $theta1 = deg2rad($lon2_in_degrees);
    my $phi1   = deg2rad( 90 - $lat2_in_degrees );

    my $distance_in_radians = great_circle_distance( $theta0, $phi0, $theta1, $phi1 );

    my $miles = $EARTH_RADIUS_MEAN_IN_MILES * $distance_in_radians;

    # The following is just an approximation to within .5%
    # Therefore lets round it to 4 significant figures only
    $miles = sprintf "%.4g", $miles;

    return $miles;
}

1;

__END__
