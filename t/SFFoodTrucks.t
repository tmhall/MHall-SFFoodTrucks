#!/usr/bin/env perl

use strict;
use warnings;
use v5.16;

use Test::More tests => 2;

use Carp qw(confess);
use FindBin qw($Bin $Script);
use Path::Tiny qw(path tempdir);
use POSIX qw(strftime);
use Text::CSV qw(csv);
use YAML qw(Dump);

use lib qq{@{[ path($Bin)->parent->child('lib') ]}};

use MHall::SFFoodTrucks qw(list_sf_food_trucks);

my @csv_headers = qw(
    locationid
    Applicant
    LocationDescription
    Address
    Status
    FoodItems
    Latitude
    Longitude
    dayshours
    ExpirationDate
);

subtest "list_sf_food_trucks - record counts" => sub {
    my @test_record_counts = ( 3, 10, 100 );

    plan tests => 0 + @test_record_counts;

    for my $record_count (@test_record_counts) {
        my $test_csv_file = test_csv_file( number_of_records => $record_count );

        my @food_trucks = list_sf_food_trucks( csv_file => $test_csv_file );

        is( scalar(@food_trucks), $record_count, "CSV with $record_count records" );
    }
};

subtest "list_sf_food_trucks - verify fields" => sub {
    plan tests => 10;

    my $test_csv_file = test_csv_file( number_of_records => 5 );

    my @food_trucks = list_sf_food_trucks( csv_file => $test_csv_file );

    my $record = $food_trucks[3];

    is( $record->location_id,          "row_4_locationid",          "\$sf_food_truck->location_id" );
    is( $record->applicant,            "row_4_Applicant",           "\$sf_food_truck->applicant" );
    is( $record->location_description, "row_4_LocationDescription", "\$sf_food_truck->location_description" );
    is( $record->address,              "row_4_Address",             "\$sf_food_truck->address" );
    is( $record->status,               "row_4_Status",              "\$sf_food_truck->status" );
    is( $record->food_items,           "row_4_FoodItems",           "\$sf_food_truck->food_items" );
    is( $record->latitude,             "row_4_Latitude",            "\$sf_food_truck->latitude" );
    is( $record->longitude,            "row_4_Longitude",           "\$sf_food_truck->longitude" );
    is( $record->days_hours,           "row_4_dayshours",           "\$sf_food_truck->days_hours" );
    is( $record->expiration_date,      "row_4_ExpirationDate",      "\$sf_food_truck->expiration_date" );
};

sub test_csv_file {
    my %args = @_;

    my $number_of_records = delete $args{number_of_records};

    confess "Unrecognized parameters: @{[ keys %args ]}" if keys %args;

    # Create a tempdir
    state $tempdir = do {
        my $today_date = strftime "%Y%m%d", localtime;

        tempdir(
            "${Script}_${today_date}_XXXXX",
            TMPDIR  => 1,
            CLEANUP => 1,
        );
    };

    state $csv_counter = 0;

    my $basename = sprintf "file_%03d.csv", ++$csv_counter;

    my $test_csv_file = $tempdir->child($basename);

    my @records = [@csv_headers];

    for my $row ( 1 .. $number_of_records ) {
        # Prefix each header with row number
        my @data = map {"row_${row}_$_"} @csv_headers;
        push @records, \@data;
    }

    my $csv_data = csv( in => \@records, out => "$test_csv_file" );

    return "$test_csv_file";
}
