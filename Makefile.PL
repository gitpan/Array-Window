require 5.000;
use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Array::Window',
	'VERSION_FROM' => 'lib/Array/Window.pm',
	'PREREQ_PM'    => {
		Test::Simple => 0,
		Class::Inspector => 0,
	},	
	($] >= 5.005) ? (
		'AUTHOR'   => 'Adam Kennedy (adam@ali.as)',
		'ABSTRACT' => 'Calculate windows/subsets/pages of arrays',
	) : (),
);
