package Dist::Zilla::Plugin::DROLSKY::License;
$Dist::Zilla::Plugin::DROLSKY::License::VERSION = '0.21';
use v5.10;

use strict;
use warnings;
use autodie;

use Module::Runtime qw( use_module );
use String::RewritePrefix;

use Moose;

with 'Dist::Zilla::Role::LicenseProvider';

sub provide_license {
    my $self = shift;
    my $args = shift;

    my $year      = $args->{copyright_year};
    my $this_year = (localtime)[5] + 1900;
    my $years     = $year == $this_year ? $year : "$year - $this_year";

    my $license_class = String::RewritePrefix->rewrite(
        {
            '=' => '',
            ''  => 'Software::License::'
        },
        $self->zilla()->_license_class() // 'Artistic_2_0',
    );

    use_module($license_class);

    return $license_class->new(
        {
            holder => 'David Rolsky',
            year   => $years,
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Sets up default license and copyright holder

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::DROLSKY::License - Sets up default license and copyright holder

=head1 VERSION

version 0.21

=for Pod::Coverage .*

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by David Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
