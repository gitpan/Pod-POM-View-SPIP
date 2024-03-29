package Pod::POM::View::SPIP;

require 5.004;
use strict;

use Pod::POM::View;
use base qw( Pod::POM::View );
use vars qw( $VERSION $DEBUG $ERROR $AUTOLOAD $INDENTLEVEL );
use Text::Wrap;

$VERSION     = 0.03;
$DEBUG       = 0 unless defined $DEBUG;
$INDENTLEVEL = 0;

=head1 NAME

Pod::POM::View::SPIP - POD Object Model View for SPIP

=head1 SYNOPSIS

    use Pod::POM::View::SPIP;

    my $parser = Pod::POM->new(\%options);

    # parse from a text string
    my $pom = $parser->parse_text($text)
      || die $parser->error();

    # parse from a file specified by name or filehandle
    my $pom = $parser->parse_text($file)
      || die $parser->error();

    # parse from text or file
    my $pom = $parser->parse($text_or_file)
      || die $parser->error();

    print Pod::POM::View::SPIP->print($pom);

=head1 DESCRIPTION

SPIP is a popular CMS in France, and as POD is also a popular text format to
write articles, we needed a way to translate POD text into SPIP markup.

This view for L<Pod::POM(3)> implements it. 

=head1 METHODS

=head2 new

Class constructor. Used by L<Pod::POM>.

=cut


sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_)
      || return;
    # initalise stack for maintaining info for nested lists
    $self->{ INDENTLEVEL } = 0;
    return $self;
}

=head1 VIEW DETAILS

=over

=item *
view

Implement L<Pod::POM> C<view> method

=cut

sub view {
    my ($self, $type, $item) = @_;

    if ($type =~ s/^seq_//) {
        return $item;
    }
    elsif (UNIVERSAL::isa($item, 'HASH')) {
        if (defined $item->{content}) {
            return $item->{content}->present($self);
        }
        elsif (defined $item->{text}) {
            my $text = $item->{text};
            return ref $text ? $text->present($self) : $text;
        }
        else {
            return '';
        }
    }
    elsif (! ref $item) {
        return $item;
    }
    else {
        return '';
    }
}


=pod 

=item *
view_head1

C<=head1> POD sections are translated to the following SPIP markup:

  =head1 Title

becomes:

  {{{Title}}}

which is the SPIP classic title markup.

=cut

sub view_head1 {
    my ($self, $head1) = @_;
    my $output = "\n{{{" . $head1->title->present($self)."}}}\n\n" . $head1->content->present($self);

    return $output;
}


=pod 

=item *
view_head2

C<=head2> POD sections are translated to the following SPIP markup:

  =head2 Title

becomes:

  - {{Title}}

which is first level item list with bold text.

Remember that first level lists in SPIP are bulleted with an image (I<puce>).

=cut

sub view_head2 {
    my ($self, $head2) = @_;

    my $output = "\n- {{" . $head2->title->present($self)."}}\n\n" . $head2->content->present($self);

    return $output;
}

=pod 

=item *
view_head3

C<=head3> POD sections are translated to the following SPIP markup:

  =head3 Title

becomes:

  - {Title}

which is first level item list with italic text.

=cut

sub view_head3 {
    my ($self, $head3) = @_;
    my $output = "\n- {" . $head3->title->present($self)."}\n\n" . $head3->content->present($self);

    return $output;
}

=item *
view_head4

C<=head4> POD sections are translated to the following SPIP markup:

  =head4 Title

becomes:

  -* {Title}

which is second level item list with italic text.

In SPIP, second level itemized lists are then translated to E<lt>ULE<gt> HTML
tags.

=cut

sub view_head4 {
    my ($self, $head4) = @_;
    my $output = "\n-* {" . $head4->title->present($self)."}\n\n" . $head4->content->present($self);

    return $output;
}

=item *
view_over

C<view_over> only counts indent levels.

=cut

sub view_over {
    my ($self, $over) = @_;
    my $indentlevel = ref $self ? \$self->{ INDENTLEVEL } : \$INDENTLEVEL;

    $$indentlevel++;
    my $content = $over->content->present($self);
    $$indentlevel--;
    return $content;
}

=item *
view_item

C<=item> POD sections (enclosed between C<=over> & C<=back>) are translated to
the following SPIP markup:

  =over

  =item First level item (no explicit bullet)
  
  =item * First level item (with bullet)

  =over 

  =item *
  Second level item (with bullet)

  
  =item 1 Second level numbered item
  
  =item 1
  Second level numbered item
  
  =back 

  =item 1. First level numbered item
  
  =item 1.
  First level numbered item

  =back

become respectively:

  _First level item (no bullet)
  -* First level item (with bullet)
  -** Title
  -## Title
  -## Title
  -# Title
  -# Title

When multiple nested lists advent, the imbrication levels are respected.
Be careful to specify bullets for sub-level lists, as SPIP only allows them on
the first level (C<_> prefix).

=cut

sub view_item {
    my ($self, $item) = @_;
    my $indentlevel = ref $self ? \$self->{INDENTLEVEL} : \$INDENTLEVEL;

    my $title = $item->title->present($self);
    my $content = $item->content->present($self);
    $content =~ s/(?:\r?\n)+$//m;

    # Taken from Pod::POM::View::HTML::view_over
    if ($title =~ /^\s*\*\s*/ || ($title =~ /^\s[^*]/ && $indentlevel > 1)) {
        # '=item *' => <ul>
        $title =~ s/^\s*\*\s*//;
        if ($title eq '') {
            $title = $content;
            $content='';
        }
        $title = '-' . ('*' x $$indentlevel) . ' ' . $title;
    }
    elsif ($title =~ /^\s*\d+\.?\s*/) {
        # '=item 1.' or '=item 1 ' => <ol>
        $title =~ s/^\s*\d+\.?\s*//;
        if ($title eq '') {
            $title = $content;
            $content='';
        }
        $title = '-' . ('#' x $$indentlevel) . ' ' . $title;
    }
    else {
        $title = "_$title";
    }

    return $content ? "$title\n$content\n" : "$title\n";
}

=item *
view_for

The C<=for> sections are passed directly without any transformation.

=cut

sub view_for {
    my ($self, $for) = @_;
    return '' unless $for->format() =~ /\bspip|html\b/;
    return $for->text()
	. "\n\n";
}

=item *
view_begin

Return only C<=begin spip> sections.
FIXME: maybe it should return anything...

=cut

sub view_begin {
    my ($self, $begin) = @_;
    return '' unless $begin->format() =~ /\bspip\b/;
    return $begin->content->present($self);
}

    
=item *
view_textblock

Suppress leading spaces and return text from text blocks.

=cut

sub view_textblock {
    my ($self, $text) = @_;
#    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
    $text =~ s/\s+/ /mg;

#    $$indent ||= 0;
#    my $pad = ' ' x $$indent;
#    return wrap($pad, $pad, $text) . "\n\n";
    return wrap('', '', $text) . "\n\n";
}


=item *
view_verbatim

Verbatim POD sections are translated to the following SPIP markup:

  <code>
  some code
  </code>

=cut

sub view_verbatim {
    my ($self, $text) = @_;
#    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
#    my $pad = ' ' x $$indent;
#    $text =~ s/^/$pad/mg;
    
    return "<code>\n$text\n</code>\n\n";
}

=item *
view_seq_bold

Bold text is translated to the following SPIP markup:

  {{some text}}

=cut


sub view_seq_bold {
    my ($self, $text) = @_;
    
    return "{{ $text }}"
        if (substr($text, 0, 1) eq '{' && substr($text, -1, 1) eq '}');

    return "{{$text}}";
}

=item *
view_seq_italic

Italic text is translated to the following SPIP markup:

  {some text}

=cut

sub view_seq_italic {
    my ($self, $text) = @_;

    return "{ $text }"
        if (substr($text, 0, 1) eq '{' && substr($text, -1, 1) eq '}');

    return "{$text}";
}

=item *
view_seq_code

Code text is translated to the following SPIP markup:

  <code>some inline code</code>

=cut


sub view_seq_code {
    my ($self, $text) = @_;
    return "<code>$text</code>";
}

=item *
view_seq_file

File text is translated to the following SPIP markup:

  <code>/path/to/file</code>

=cut


sub view_seq_file {
    my ($self, $text) = @_;
    return "<code>$text</code>";
}

=item *
view_seq_entities

Code text is translated to the following SPIP markup:

  <code>some inline code</code>

=cut
my %entities = (
    gt   => '&gt;',
    lt   => '&lt;',
    amp  => '&amp;',
    quot => '&quot;',
);



sub view_seq_entities {
    my ($self, $text) = @_;
    return $entities{$text} if defined $entities{$text};
    return $text;
}


=item *
view_seq_link

Links are treated as in L<Pod::POM::View::HTML>.

=cut

#
# From Pod::POM::View::HTML
#
sub view_seq_link {
    my ($self, $link) = @_;

    # view_seq_text has already taken care of L<http://example.com/>
    if ($link =~ /^<a href=/ ) {
        return $link;
    }

    # full-blown URL's are emitted as-is
    if ($link =~ m{^\w+://}s ) {
        return make_href($link);
    }

    $link =~ s/\n/ /g;   # undo line-wrapped tags

    my $orig_link = $link;
    my $linktext;
    # strip the sub-title and the following '|' char
    if ( $link =~ s/^ ([^|]+) \| //x ) {
        $linktext = $1;
    }

    # make sure sections start with a /
    $link =~ s|^"|/"|;

    my $page;
    my $section;
    if ($link =~ m|^ (.*?) / "? (.*?) "? $|x) { # [name]/"section"
        ($page, $section) = ($1, $2);
    }
    elsif ($link =~ /\s/) {  # this must be a section with missing quotes
        ($page, $section) = ('', $link);
    }
    else {
        ($page, $section) = ($link, '');
    }

    # warning; show some text.
    $linktext = $orig_link unless defined $linktext;

    my $url = '';
    if (defined $page && length $page) {
        $url = $self->view_seq_link_transform_path($page);
    }

    # append the #section if exists
    $url .= "#$section" if defined $url and
        defined $section and length $section;

    return make_href($url, $linktext);
}


# should be sub-classed if extra transformations are needed
#
# for example a sub-class may search for the given page and return a
# relative path to it.
#
# META: where this functionality should be documented? This module
# doesn't have docs section

=item *
view_seq_link_transform_path

FIXME 
view_seq_link_transform_path should handle links to other articles, etc.

=cut
sub view_seq_link_transform_path {
    my($self, $page) = @_;

    # right now the default transform doesn't check whether the link
    # is not dead (i.e. whether there is a corresponding file.
    # therefore we don't link L<>'s other than L<http://>
    # subclass to change the default (and of course add validation)

    # this is the minimal transformation that will be required if enabled
    # $page = "$page.html";
    # $page =~ s|::|/|g;
    #print "page $page\n";
    return undef;
}


=item *
make_href

Identify and create links into SPIP links

For now, just make the link as C<[title->link]>.

=cut

sub make_href {
    my($url, $title) = @_;

    if (!defined $url) {
        return defined $title ? "{$title}"  : '';
    }

    $title = $url unless defined $title;
    #print "$url, $title\n";
    return qq{[$title->$url]};
}

# this code has been borrowed from Pod::Html
my $urls = '(' . join ('|',
     qw{
       http
       telnet
       mailto
       news
       gopher
       file
       wais
       ftp
     } ) . ')';	
my $ltrs = '\w';
my $gunk = '/#~:.?+=&%@!\-';
my $punc = '.:!?\-;';
my $any  = "${ltrs}${gunk}${punc}";


=item *
view_seq_text

FIXME:
view_seq_text should be filtering some specific markup, such as
HTML-like tags, which should be transformed using entities.

=cut

sub view_seq_text {
    my ($self, $text) = @_;

     for ($text) {
         s/&/&amp;/g;
         s/</&lt;/g;
         s/>/&gt;/g;
     }

     $text =~ s{
         \b                           # start at word boundary
          (                           # begin $1  {
            $urls     :               # need resource and a colon
            (?!:)                     # Ignore File::, among others.
            [$any] +?                 # followed by one or more of any valid
                                      #   character, but be conservative and
                                      #   take only what you need to....
          )                           # end   $1  }
          (?=                         # look-ahead non-consumptive assertion
                  [$punc]*            # either 0 or more punctuation followed
                  (?:                 #   followed
                      [^$any]         #   by a non-url char
                      |               #   or
                      $               #   end of the string
                  )                   #
              |                       # or else
                  $                   #   then end of the string
          )
        }{[->$1]}igox;

     return "$text";
}

1;

__END__

=back

=head1 BUGS

No warning is issued when translating nested item lists without bullets nor
number. The result will not be what is expected. Your mileage may vary.

Don't expect for now having C<BE<lt>IE<lt>textE<gt>E<gt>> giving bold italic
text.

=head1 AUTHOR

J�r�me Fenal E<lt>jfenal@free.frE<gt>

=head1 VERSION

This is version 0.03 of the Pod::POM::View::SPIP module.

=head1 COPYRIGHT

Copyright (C) 2004 J�r�me Fenal. All Rights Reserved

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

See L<Pod::POM(3)> and L<pom2(1)> for other ways to use
Pod::POM::View::SPIP.

SPIP can be found at L<http://www.spip.net/>.

