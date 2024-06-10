#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use Getopt::Long qw(GetOptions);
use Path::Tiny qw(path);
use Pod::Usage qw(pod2usage);

use lib qq{@{[ path($Bin)->parent->child('lib') ]}};

use MHall::SFFoodTrucks qw();

main();
exit;

sub main {
    GetOptions(    #
        'help' => \my $opt_help,
        )
        or pod2usage(1);

    pod2usage( -exitstatus => 0, -verbose => 2 ) if $opt_help;

    pod2usage( -msg => 'Unrecognized parameters.', -verbose => 1 ) if @ARGV;

    print "Hello World\n";

    return;
}

__END__

=head1 NAME

sf_food_trucks.pl - Interface for SF Food Trucks

=head1 SYNOPSIS

./sf_food_trucks.pl

=head1 OPTIONS

=over 4

=item --help -?

This help text

=back

=head1 DESCRIPTION

Interface for MHall::SFFoodTrucks

=head1 AUTHOR

Written by Miller

=cut
