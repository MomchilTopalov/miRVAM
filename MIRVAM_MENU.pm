package MIRVAM_MENU;

use strict;
use Exporter;
use Readonly;
use Window;
use vars qw( @ISA @EXPORT );

@ISA 	= qw( Exporter );
@EXPORT	= qw( menu_bar_items );

Readonly my $line	=> q{"};	
sub	menu_bar_items # ===========================
# The MENU of the program.
# ==================================================
{
	[ map [ 'cascade', $_ -> [ 0 ], -menuitems => $_ -> [ 1 ] ],

	# [ '~File',
		# [
			# [ qw/command Open -command/	=> \&open_dir		],	$line,
			# [ qw/command Run -command/	=> \&results_handler	],	$line,
			# [ qw/command Save  -command/	=> \&save_file		],	$line,
			# [ qw/command Close/					],       $line,
			# [ qw/command Quit -command/	=> \&exit		],
		# ],
	# ],
	# [ '~Sample verification',
		# [
			# [ qw/command Redundant -command/	=> \&redT	],
			# [ qw/command Non-redundant -command/	=> \&redF	],	$line,
			# [ qw/command Non-tabulated -command/	=> \&tabF	],
			# [ qw/command Tabulated -command/	=> \&tabT	],	$line,
			# [ qw/cascade Set_interval_from -menuitems/ =>
				# [
					# [ 'command', 15, -command => \sub { $scale_from = 15 } ],
					# [ 'command', 16, -command => \sub { $scale_from = 16 } ],
					# [ 'command', 17, -command => \sub { $scale_from = 17 } ],
					# [ 'command', 18, -command => \sub { $scale_from = 18 } ],
					# [ 'command', 19, -command => \sub { $scale_from = 19 } ],
					# [ 'command', 20, -command => \sub { $scale_from = 20 } ],
				# ],
			# ],
			# [ qw/cascade Set_interval_to -menuitems/ =>
				# [
					# [ 'command', 25, -command => \sub { $scale_to = 25 } ],
					# [ 'command', 26, -command => \sub { $scale_to = 26 } ],
					# [ 'command', 27, -command => \sub { $scale_to = 27 } ],
					# [ 'command', 28, -command => \sub { $scale_to = 28 } ],
					# [ 'command', 29, -command => \sub { $scale_to = 29 } ],
					# [ 'command', 30, -command => \sub { $scale_to = 30 } ],
				# ],
			# ],	$line,
			# [ qw/command Reset -command/		=> \&reset	],	$line,
			# [ qw/command Close/	],
		# ],
	# ],
	# [ '~Histogram mode',
		# [
			# [ qw/command Show_histogram -command/	=> \&show_hist	],
			# [ qw/command Save_histogram -command/	=> \&save_oneh	],
			# [ qw/command Save_all_hist -command/	=> \&save_allh	],	$line,
			# [ qw/command Close/	], 
		# ], 
	# ],
	# [ '~Match mode',
		# [
			# [ qw/command Non-tabulated -command/	=> \&matF	],
			# [ qw/command Tabulated -command/	=> \&matT	],	$line,
			# [ qw/command Close/	], 
		# ],
	# ],
	
	[ '~Controls',
		[
			[ qw/command HotKeys -command/	=> \sub { window( qw/Controls txt\controls.txt/ ) }	],	$line,
			[ qw/command Close/	], 
		],
	],
	[ '~Help',
		[
			# [ qw/cascade Manual -menuitems/		=>
				# [
					# [ 'command', 'READ_ME(.pdf)', -command => \&pdf_handler	],
				# ],
			# ],
			[ qw/command Version -command/	=> \sub { window( qw/Version txt\version.txt/ ) }	],
			[ qw/command About -command/	=> \sub { window( qw/About txt\about.txt/ ) }	],	$line,
			[ qw/command Close/	], 
		],
	],
];
}
1;