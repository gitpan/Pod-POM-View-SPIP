use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Pod::POM::View::SPIP',
    PREREQ_PM    => { 'Pod::POM' },
    VERSION      => '0.01',
    EXE_FILES    => ['bin/pom2spip'],
    AUTHOR       => 'Jérôme Fenal <jfenal@free.fr>',
    ABSTRACT     => 'Pod::POM view for SPIP',
);

