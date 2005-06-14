#!/usr/bin/perl -w

use strict;
use lib qw( ./lib ../lib );
use Pod::POM::Test;
use Pod::POM::View::SPIP;

my $DEBUG = 1;

ntests(5);

my $parser = Pod::POM->new();
my $pom = $parser->parse_file(\*DATA);
assert( $pom );

$Pod::POM::DEFAULT_VIEW = 'Pod::POM::View::SPIP';

my $text = $pom->head1->[0]->text;
assert( $text );
match( scalar @$text, 1 );
match( $text->[0],
       "A test Pod document.\n\n" );
match( $pom->head1->[0],
       "\n{{{NAME}}}\n\n"
     . "A test Pod document.\n\n"
     . "\n- {{HEAD2}}\n\n"
     . "blah2\n\n"
     . "\n- {HEAD3}\n\n"
     . "blah3\n\n"
     . "\n-* {HEAD4}\n\n"
     . "blah4\n\n"
     . "\n-* {HEAD4}\n\n"
     . "blah4\n\n"
     );


__DATA__
=head1 NAME

A test Pod document.

=head2 HEAD2

blah2

=head3 HEAD3

blah3

=head4 HEAD4

blah4

=head4 HEAD4

blah4
