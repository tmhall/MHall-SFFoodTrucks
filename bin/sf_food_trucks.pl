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

main();
exit;

sub main {
    GetOptions(    #
        'list'         => \my $opt_list,
        'all_statuses' => \my $opt_all_statuses,
        'help'         => \my $opt_help,
        )
        or pod2usage(1);

    pod2usage( -exitstatus => 0, -verbose => 2 ) if $opt_help;

    pod2usage( -msg => 'Unrecognized parameters.', -verbose => 1 ) if @ARGV;

    if ($opt_list) {
        print_food_trucks( is_active => !$opt_all_statuses );

    } else {
        pod2usage( -exitstatus => 0, -verbose => 1 );
    }

    return;
}

sub print_food_trucks {
    my %args = @_;

    my $is_active = delete $args{is_active};

    confess "Unrecognized parameters: @{[ keys %args ]}" if keys %args;

    my @food_trucks = list_sf_food_trucks( is_active => $is_active );

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

=item --help -?

Full help text

=back

=head1 DESCRIPTION

Interface for MHall::SFFoodTrucks

=head1 AUTHOR

Written by Miller

=cut
