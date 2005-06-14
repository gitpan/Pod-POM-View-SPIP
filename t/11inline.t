#!/usr/bin/perl -w

use strict;
use lib qw( ./lib ../lib );
use Pod::POM;
use Pod::POM::View::SPIP;
use Pod::POM::Test;

ntests(7);

my $parser = Pod::POM->new();
my $pom = $parser->parse_file(\*DATA);
$Pod::POM::DEFAULT_VIEW = 'Pod::POM::View::SPIP';
assert($pom);

my $text = $pom->head1->[0]->text;

match( $text->[0], "This is {{bold}} text. Just {{bold}}.\n\n");
match( $text->[1], "This is {italic} text. Just {italic}.\n\n");
match( $text->[2], "This is {{ {italic bold} }} text. Just {{ {italic bold} }}.\n\n");
match( $text->[3], "This is { {{bold italic}} } text. Just { {{bold italic}} }.\n\n");
match( $text->[4], "This is <code>inline code</code> text. Just <code>inline code</code>.\n\n");
match( $text->[5], "There be <code>/a/file</code>.\n\n");

__DATA__
=head1 NAME

This is B<bold> text. Just B<bold>.

This is I<italic> text. Just I<italic>.

This is B<I<italic bold>> text. Just B<I<italic bold>>.

This is I<B<bold italic>> text. Just I<B<bold italic>>.

This is C<inline code> text. Just C<inline code>.

There be F</a/file>.
