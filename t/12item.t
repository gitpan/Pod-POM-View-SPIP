#!/usr/bin/perl -w

use strict;
use lib qw( ./lib ../lib );
use Pod::POM;
use Pod::POM::View::SPIP;
use Pod::POM::Test;
use Data::Dumper;

my $DEBUG = 1;

ntests(4);

my $parser = Pod::POM->new();
my $pom = $parser->parse_file(\*DATA);
$Pod::POM::DEFAULT_VIEW = 'Pod::POM::View::SPIP';

assert( $pom );

my $text = $pom->head1->[0];

# do not test this way, as view_over is not used, and indentlevel not
# honoured
#match( $text->over->[0]->item->[0], "- item 1\n");
#match( $text->over->[0]->item->[1], "- item 2\n-# item 3\n-# item 4\n-# item 5\n");
#match( $text->over->[0]->item->[1]->over->[0]->item->[0]->present, "-## item 3\n");
#match( $text->over->[0]->item->[1]->over->[0]->item->[1]->present, "-## item 4\n");
#match( $text->over->[0]->item->[1]->over->[0]->item->[2]->present, "-## item 5\n");
#match( $text->over->[1]->item->[0], "_No itemization 1\n");
#match( $text->over->[1]->item->[1], "_Still no itemization 2\n");

# test this way...
match( $text->over->[0], "-* item 1\n-* item 2\n-## item 3\n-## item 4\n-## item 5\n-* item 6\n");
match( $text->over->[1], "_No itemization 1\n_Still no itemization 2\n");
match( $text->over->[2], "-* No item title, but text.\n-* Still no title in item.\n");

__DATA__
=head1 NAME

=over 

=item *
item 1

=item *
item 2

=over

=item 1 item 3

=item 1.
item 4

=item 1
item 5

=back

=item * item 6

=back

=over

=item No itemization 1

=item Still no itemization 2

=back

=over 

=item *

No item title, but text.

=item *

Still no title in item.

=over
