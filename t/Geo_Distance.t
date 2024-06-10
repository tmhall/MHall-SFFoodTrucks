#!/usr/bin/env perl

use strict;
use warnings;
use v5.16;

use Test::More tests => 1;

use Carp qw(confess);
use FindBin qw($Bin);
use Path::Tiny qw(path);
use Test::Deep;

use lib qq{@{[ path($Bin)->parent->child('lib') ]}};

use MHall::Geo::Distance qw(great_circle_miles);

my $ALAMO_SQUARE_LAT = 37.7765544;
my $ALAMO_SQUARE_LON = -122.4348276;

my $OAK_GLEN_PARK_LAT = 37.8204553;
my $OAK_GLEN_PARK_LON = -122.2590285;

my $CHATTANOOGA_LAT = 35.043831;
my $CHATTANOOGA_LON = -85.3459737;

my $CENTRAL_PARK_LAT = 40.7923753;
my $CENTRAL_PARK_LON = -73.9930341;

subtest "great_circle_miles" => sub {
    my @test_cases = (
        {   test_name      => "North Pole to South Pole",
            lat1           =>  90,
            lon1           =>  15,                          # Longitude should not matter
            lat2           => -90,
            lon2           =>  87,
            expected_miles =>  12451,
        },
        {   test_name      => "Alamo Square to Antipode",
            lat1           => $ALAMO_SQUARE_LAT,
            lon1           => $ALAMO_SQUARE_LON,
            lat2           => -1 * $ALAMO_SQUARE_LAT,
            lon2           => 180 + $ALAMO_SQUARE_LON,
            expected_miles => 12451,
        },
        {   test_name      => "Alamo Square to Oak Gen Park",
            lat1           => $ALAMO_SQUARE_LAT,
            lon1           => $ALAMO_SQUARE_LON,
            lat2           => $OAK_GLEN_PARK_LAT,
            lon2           => $OAK_GLEN_PARK_LON,
            expected_miles => 10,
        },
        {   test_name      => "Alamo Square to Chattanooga",
            lat1           => $ALAMO_SQUARE_LAT,
            lon1           => $ALAMO_SQUARE_LON,
            lat2           => $CHATTANOOGA_LAT,
            lon2           => $CHATTANOOGA_LON,
            expected_miles => 2057,
        },
        {   test_name      => "Alamo Square to Central Park",
            lat1           => $ALAMO_SQUARE_LAT,
            lon1           => $ALAMO_SQUARE_LON,
            lat2           => $CENTRAL_PARK_LAT,
            lon2           => $CENTRAL_PARK_LON,
            expected_miles => 2565,
        },
    );

    plan tests => scalar @test_cases;

    for my $test_case (@test_cases) {
        my $test_name      = delete $test_case->{test_name};
        my $lat1           = delete $test_case->{lat1};
        my $lon1           = delete $test_case->{lon1};
        my $lat2           = delete $test_case->{lat2};
        my $lon2           = delete $test_case->{lon2};
        my $expected_miles = delete $test_case->{expected_miles};

        confess "Unrecognized parameters: @{[ keys %$test_case ]}" if keys %$test_case;

        my $miles = great_circle_miles(
            lat1 => $lat1,
            lon1 => $lon1,
            lat2 => $lat2,
            lon2 => $lon2,
        );

        cmp_deeply( $miles, num( $expected_miles, $expected_miles / 100 ), "$test_name is $expected_miles" );
    }
};
