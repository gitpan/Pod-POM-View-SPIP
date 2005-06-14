use Module::Build;
my $build = Module::Build->new(
    module_name  => 'Pod::POM::View::SPIP',
    version_from => 'lib/Pod/POM/View/SPIP.pm',
    scripts      => 'bin/pom2spip',
    license      => 'perl',
    requires     => {
        'Pod::POM'       => 0,
    },
    recommends => { 'Test::More' => '0', },
    add_to_cleanup => [ '*~', '*/*~', '*/*/*~', '*/*/*/*~' ],
    gzip           => 'gzip -9f',
);
$build->create_build_script;
