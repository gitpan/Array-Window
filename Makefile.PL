require 5.000;
use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Array::Window',
	'VERSION_FROM' => 'lib/Array/Window.pm',
	'PREREQ_PM'    => {
		File::Spec       => 0.83,
		Test::More       => 0,
	},
	($] >= 5.005) ? (
		'AUTHOR'   => 'Adam Kennedy (cpan@ali.as)',
		'ABSTRACT' => 'Calculate windows/subsets/pages of arrays',
	) : (),
);
