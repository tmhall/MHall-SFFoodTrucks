package MHall::SFFoodTrucks::PermitRecord;

use strict;
use warnings;
use v5.16;

use Carp qw(confess);
use Tie::IxHash;

sub new {
    my $pkg  = shift;
    my %args = @_;

    # Currently the only interface we need is a csv_hash
    my $csv_hash = delete $args{csv_hash} or confess "csv_hash is required";

    confess "Unrecognized parameters: @{[ keys %args ]}" if keys %args;

    my $self = bless {}, $pkg;

    if ($csv_hash) {
        $self->_load_from_csv_hash($csv_hash);
    }

    return $self;
}

sub _load_from_csv_hash {
    my $self     = shift;
    my $csv_hash = shift;

    # Translation of CSV Columns to Record fields
    # - Includes a comment with an example record value.  For our purposes we only care
    #   about ones relavant for those looking for food trucks to eat at.
    #<<< No PerlTidy here, please.
    my %csv_column_to_field = (
        'locationid'                => 'location_id',             # 848184
        'Applicant'                 => 'applicant',               # Reecees Soulicious
        'FacilityType'              => undef,                     # Truck
        'cnn'                       => undef,                     # 2799106
        'LocationDescription'       => 'location_description',    # BAY SHORE BLVD: BAY SHORE BLVD to OAKDALE AVE (185 - 299) -- EAST --
        'Address'                   => 'address',                 # 201 BAY SHORE BLVD
        'blocklot'                  => undef,                     # 5559021
        'block'                     => undef,                     # 5559
        'lot'                       => undef,                     # 021
        'permit'                    => undef,                     # 16MFF-0139
        'Status'                    => 'status',                  # REQUESTED
        'FoodItems'                 => 'food_items',              # Fried Chicken: Fried Fish: Greens: Mac & Cheese: Peach Cobbler: and String beans
        'X'                         => undef,                     # 6011355.555
        'Y'                         => undef,                     # 2099442.374
        'Latitude'                  => 'latitude',                # 37.74530890865633
        'Longitude'                 => 'longitude',               # -122.40342005999852
        'Schedule'                  => undef,                     # http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=16MFF-0139&ExportPDF=1&Filename=16MFF-0139_schedule.pdf
        'dayshours'                 => 'days_hours',              # Mo-We:7AM-7PM,
        'NOISent'                   => undef,                     #
        'Approved'                  => undef,                     #
        'Received'                  => undef,                     # 20160908
        'PriorPermit'               => undef,                     # 0
        'ExpirationDate'            => 'expiration_date',         # 03/15/2017 12:00:00 AM
        'Location'                  => undef,                     # "(37.74530890865633, -122.40342005999852)"
        'Fire Prevention Districts' => undef,                     # 10
        'Police Districts'          => undef,                     # 3
        'Supervisor Districts'      => undef,                     # 8
        'Zip Codes'                 => undef,                     # 58
        'Neighborhoods (old)'       => undef,                     # 1
    );
    #>>>

    if ( my @unrecognized_fields = grep { !exists $csv_column_to_field{$_} } keys %$csv_hash ) {
        # It looks like our csv file has changed format.  We might just need to add new fields as
        # recognized in the above hash even if we just ignore them.
        confess "Unrecognized csv_fields: @unrecognized_fields";
    }

    for my $csv_column (%$csv_hash) {
        # The csv files has a lot of fields that we'll just ignore
        next unless my $field = $csv_column_to_field{$csv_column};

        $self->$field( $csv_hash->{$csv_column} );
    }

    return $self;

}

### Basic Accessor/Mutators

sub location_id {
    my $self = shift;

    if (@_) {
        $self->{location_id} = shift;
    }

    return $self->{location_id};
}

sub applicant {
    my $self = shift;

    if (@_) {
        $self->{applicant} = shift;
    }

    return $self->{applicant};
}

sub location_description {
    my $self = shift;

    if (@_) {
        $self->{location_description} = shift;
    }

    return $self->{location_description};
}

sub address {
    my $self = shift;

    if (@_) {
        $self->{address} = shift;
    }

    return $self->{address};
}

sub status {
    my $self = shift;

    if (@_) {
        $self->{status} = shift;
    }

    return $self->{status};
}

sub food_items {
    my $self = shift;

    if (@_) {
        $self->{food_items} = shift;
    }

    return $self->{food_items};
}

sub latitude {
    my $self = shift;

    if (@_) {
        $self->{latitude} = shift;
    }

    return $self->{latitude};
}

sub longitude {
    my $self = shift;

    if (@_) {
        $self->{longitude} = shift;
    }

    return $self->{longitude};
}

sub days_hours {
    my $self = shift;

    if (@_) {
        $self->{days_hours} = shift;
    }

    return $self->{days_hours};
}

sub expiration_date {
    my $self = shift;

    if (@_) {
        $self->{expiration_date} = shift;
    }

    return $self->{expiration_date};
}

###

sub TO_JSON {
    my $self = shift;

    my @field_order = qw(
        location_id
        applicant
        location_description
        address
        status
        food_items
        latitude
        longitude
        days_hours
        expiration_date
    );

    tie my %hash, 'Tie::IxHash', (%$self);

    tied(%hash)->Reorder(@field_order);

    return \%hash;
}

1;

__END__
