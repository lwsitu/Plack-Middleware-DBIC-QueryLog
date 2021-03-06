package Plack::Middleware::DBIC::QueryLog;

use Moo;
use Plack::Util;
extends 'Plack::Middleware';
our $VERSION = '0.01';

sub PSGI_KEY { 'plack.middleware.dbic.querylog' }

has 'anything' => (is=>'ro');

sub call {
  my($self, $env) = @_;
  $env->{+PSGI_KEY} ||= 111;

  use Data::Dump 'dump';
  warn dump $self;
  warn dump $self->app;

  $self->app->($env);
}

1;

=head1 NAME

has 'querylog' => (
  is => 'ro',
  lazy => 1,
  builder => '_build_querylog',
);

has 'querylog_class' => (
  is => 'ro',
  default => sub {'DBIx::Class::QueryLog'},
);

sub _build_querylog {
  Plack::Util::load_class($_[0]->querylog_class)
    ->new($_[0]->querylog_args);
}

has 'querylog_class' => (
  is => 'ro',
  default => sub {'DBIx::Class::QueryLog'},
);

has 'querylog_args' => (
  is => 'ro',
  default => sub { +{} },
);


Plack::Middleware::DBIC::QueryLog - Expose a DBIC QueryLog in Middleware

=head1 SYNOPSIS

    use Plack::Builder;
    builder {
        enable 'DBIC::QueryLog',
          querylog_args => {passthrough => 1};
        $app;
    };

=head1 DESCRIPTION

L<Plack::Middleware::DBIC::QueryLog> does one thing, it places an object that
is either an instance of L<DBIx::Class::QueryLog> OR a compatible object into
the C<$env> under C<plack.middleware.dbic.querylog>.

The querylog is intended to be used L<DBIX::Class> to log and profile SQL
queries, particularly during the context of a web request handled by your
L<Plack> application.  See the documentation for L<DBIx::Class::QueryLog> and
in L<DBIx::Class::Storage/debugobj> for more information.

This middleware is intended to act as a bridge between L<DBIx::Class>, which
can consume and populate the querylog, with a reporting tool such as seen in
L<Plack::Middleware::Debug::DBIC::QueryLog>.  This functionality was refactored
out of L<Plack::Middleware::Debug::DBIC::QueryLog> to facilitate interoperation
with other types of reporting tools.

Unless you are building some custom logging tools, you probably just want to
use the existing debug panel (L<Plack::Middleware::Debug::DBIC::QueryLog>)
rather than building something custom around this middleware.

If you are using an existing web application development system such as L<Catalyst>,
you can use L<Catalyst::TraitFor::Model::DBIC::Schema::QueryLog::AdoptPlack> to
'hook' the query log into your L<DBIx::Class> schema model.  If you are using
a different framework, or building your own, please consider releasing your
code or sending me a document patch suitable for including in a workbook or FAQ.

=head1 USAGE

Used like any other L<Plack> based middlewares.

=head1 ARGUMENTS

This middleware accepts the following arguments.

=head2 querylog

Accepts an instance of L<DBIx::Class::QueryLog> or compatible object.  If you
need a custom version of this, or are mocking the interface, consider looking
at L<Plack::Util/inline_object>.

If you just want to pass arguments to L<DBIx::Class::QueryLog> you can use the
L</querylog_args>.  This argument is provided if you have complicated or very
customized instantiation needs, or your are using an IOC container or similar
tool, such as L<Bread::Board>

=head2 querylog_class

This is the class which is used to build the L</querylog> unless one is already
defined.  It defaults to L<DBIx::Class::QueryLog>.  You should probably leave
this alone unless you need to subclass or augment L<DBIx::Class::QueryLog>.

If the class name you pass has not already been included (via C<use> or 
C<require>) we will automatically include it.  If the class name can't be found
or loaded, an error will be reported.

=head2 querylog_args

Accepts a HashRef of data which will be passed to L</"querylog_class"> when
building the L</"querylog">, unless a </"querylog"> is already defined.

=head1 SEE ALSO

L<Plack>, L<Plack::Middleware>, L<Plack::Middleware::Debug::DBIC::QueryLog>,
L<Catalyst::TraitFor::Model::DBIC::Schema::QueryLog::AdoptPlack>

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

