use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Pod::POM::View::SPIP',
    PREREQ_PM    => { 'Pod::POM' },
    PM => { map { ( "lib/$_.pm" => "\$(INST_LIBDIR)/" . ( split /\// )[-1] . ".pm" ) }
          qw( Pod/POM/View/SPIP )
      },
    VERSION      => '0.03',
    EXE_FILES    => ['script/pom2spip'],
    AUTHOR       => 'Jérôme Fenal <jfenal@free.fr>',
    ABSTRACT     => 'Pod::POM view for SPIP',
);

