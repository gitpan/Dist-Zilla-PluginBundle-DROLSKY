package Dist::Zilla::PluginBundle::DROLSKY;
{
  $Dist::Zilla::PluginBundle::DROLSKY::VERSION = '0.04';
}
BEGIN {
  $Dist::Zilla::PluginBundle::DROLSKY::AUTHORITY = 'cpan:DROLSKY';
}

use v5.10;

use strict;
use warnings;

use Dist::Zilla;

use Moose;

with 'Dist::Zilla::Role::PluginBundle::Easy';

has dist => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has make_tool => (
    is      => 'ro',
    isa     => 'Str',
    default => 'MakeMaker',
);

has authority => (
    is      => 'ro',
    isa     => 'Str',
    default => 'DROLSKY',
);

has prereqs_skip => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has stopwords => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has next_release_width => (
    is      => 'ro',
    isa     => 'Int',
    default => 8,
);

has remove => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
);

has _plugins => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_plugins',
);

has _plugin_options => (
    traits   => ['Hash'],
    is       => 'ro',
    isa      => 'HashRef[HashRef]',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_plugin_options',
    handles  => {
        __plugin_options_for => 'get',
    },
);


sub mvp_multivalue_args {
    return qw( prereqs_skip remove stopwords );
}

sub _plugin_options_for {
    $_[0]->__plugin_options_for( $_[1] ) // {};
}

sub _build_plugins {
    my $self = shift;

    my %remove = map { $_ => 1 } @{ $self->remove() };
    return [
        grep { !$remove{$_} } $self->make_tool(),

        # from @Basic
        qw(
            GatherDir
            PruneCruft
            ManifestSkip
            MetaYAML
            License
            Readme
            ExtraTests
            ExecDir
            ShareDir

            Manifest

            TestRelease
            ConfirmRelease
            UploadToCPAN
            ),

        qw(
            Authority
            AutoPrereqs
            CopyReadmeFromBuild
            CheckPrereqsIndexed
            InstallGuide
            MetaJSON
            MetaResources
            NextRelease
            PkgVersion
            ReadmeFromPod
            SurgicalPodWeaver
            ),

        qw(
            EOLTests
            NoTabsTests
            PodCoverageTests
            PodSyntaxTests
            Test::CPAN::Changes
            Test::Compile
            Test::Pod::LinkCheck
            Test::Pod::No404s
            Test::PodSpelling
            Test::Synopsis
            ),

        # from @Git
        qw(
            Git::Check
            Git::Commit
            Git::Tag
            Git::Push
            ),
    ];
}

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $p = $class->$orig(@_);

    my %args = ( %{ $p->{payload} }, %{$p} );

    for my $key (qw(  prereqs_skip stopwords )) {
        if ( $args{$key} && !ref $args{$key} ) {
            $args{$key} = [ delete $args{$key} ];
        }
        $args{$key} //= [];
    }

    push @{ $args{stopwords} }, $class->_default_stopwords();

    return \%args;
};

sub _default_stopwords {
    qw(
        DROLSKY
        DROLSKY's
        Rolsky
        Rolsky's
    );
}

sub configure {
    my $self = shift;

    $self->add_plugins(
        [
            'Prereqs' => 'TestMoreDoneTesting' => {
                -phase       => 'test',
                -type        => 'requires',
                'Test::More' => '0.88',
            }
        ]
    );

    $self->add_plugins( map { [ $_ => $self->_plugin_options_for($_) ] }
            @{ $self->_plugins } );

    return;
}

sub _build_plugin_options {
    my $self = shift;

    return {
        Authority   => { authority => 'cpan:' . $self->authority() },
        AutoPrereqs => { skip      => $self->prereqs_skip() },
        MetaResources => $self->_meta_resources(),
        NextRelease   => {
            format => '%-' . $self->next_release_width() . 'v %{yyyy-MM-dd}d'
        },
        'Test::PodSpelling' => { stopwords => $self->stopwords() },
    };
}

sub _meta_resources {
    my $self = shift;

    return {
        'repository.type' => 'git',
        'repository.url' =>
            sprintf( 'git://git.urth.org/%s.git', $self->dist() ),
        'repository.web' =>
            sprintf( 'http://git.urth.org/%s.git', $self->dist() ),
        'bugtracker.web' => sprintf(
            'http://rt.cpan.org/Public/Dist/Display.html?Name=%s',
            $self->dist()
        ),
        'bugtracker.mailto' =>
            sprintf( 'bug-%s@rt.cpan.org', lc $self->dist() ),
        'homepage' =>
            sprintf( 'http://metacpan.org/release/%s', $self->dist() ),
    };
}

1;

# ABSTRACT: DROLSKY's plugin bundle

__END__

=pod

=head1 NAME

Dist::Zilla::PluginBundle::DROLSKY - DROLSKY's plugin bundle

=head1 VERSION

version 0.04

=for Pod::Coverage   mvp_multivalue_args

=for Pod::Coverage configure

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
