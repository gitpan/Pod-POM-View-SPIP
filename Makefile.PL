use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Pod::POM::View::SPIP',
    PREREQ_PM    => { 'Pod::POM' },
    VERSION      => '0.02',
    EXE_FILES    => ['bin/pom2spip'],
    AUTHOR       => 'J�r�me Fenal <jfenal@free.fr>',
    ABSTRACT     => 'Pod::POM view for SPIP',
);
