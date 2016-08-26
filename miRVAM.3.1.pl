   # Copyright momchil.topalov@gmail.com Momchil Topalov

   # Licensed under the Apache License, Version 2.0 (the "License");
   # you may not use this file except in compliance with the License.
   # You may obtain a copy of the License at

     # http://www.apache.org/licenses/LICENSE-2.0

   # Unless required by applicable law or agreed to in writing, software
   # distributed under the License is distributed on an "AS IS" BASIS,
   # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   # See the License for the specific language governing permissions and
   # limitations under the License.

#!usr/bin/perl

#	BASIC
use strict;
use warnings;
use autodie;
use utf8;
use Readonly;
use subs qw/menu_bar_items/;

#	MODULES
use Tk;
use Tk::PNG;
use Tk::JPEG;
use Tk::ProgressBar;
use Tk::Balloon;
use Tk::BrowseEntry;
use Tk::Dialog;
use Text::Table;
use MIME::Base64;
use GD::Graph;
use GD::Graph::bars;

#	==========	==========	==========	==========	==========	<GLOBAL VARIABLES>
my $time = localtime ();					# FOR WELCOMING MESSAGE
my ( @dir_content, @fasta_array ) = ( (), () );			# FILE VERIFICATION
my ( $workspace, $referent_DB ) = ( q{}, q{} );			# FILEHANDLER VARIABLES
my $state = 'disabled';						# BUTTONS` STATE
my ( $isF, $isR, $isT, $isS, $isMT, ) = ( 0, 0, 0, 0, 0, );	# RADIOBUTTONS VARIABLES
my ( $redT, $redF, $tabT, $tabF, $matT, $matF, ) 
	= ( 0, 0, 0, 0, 0, 0, );				# RADIOBUTTON FUNCS	
my ( $var1, $var2, $var3, $var4 ) = ( 0, 0, 0, 0, );		# CHECKBUTTON VARIABLES
my ( $scale_from, $scale_to,) = ( 15, 30, );			# INTERVAL
my ( $search_incounter, $search_inmatch ) = ( q{}, q{} );	# SEARCH
my ( %hist_data, @hist_y ) = ( (), () );			# HISTOGRAM ATRIBUTES
my ( @res_rlc,
# @res_ref
 ) = ( (), () );				# &SAVE VARIABLES
my $progress_lvl = 0;						# PROGRESSBAR VARIABLES
my @colors = ( 
	 0, '#ff002a',  1, '#ff0014',  2, '#ff000a',  3, '#ff0500',  4, '#ff1000',
	 5, '#ff1b00',  6, '#ff3000',  7, '#ff3b00',  8, '#ff4600',  9, '#ff5100',
	10, '#ff6100', 11, '#ff7600', 12, '#ff8100', 13, '#ff8c00', 14, '#ff9700',
	15, '#ffa100', 16, '#ffbc00', 17, '#ffc700', 18, '#ffd200', 19, '#ffdd00',
	20, '#ffe700', 21, '#fffd00', 22, '#f0ff00', 23, '#e5ff00', 24, '#dbff00',
	25, '#d0ff00', 26, '#baff00', 27, '#afff00', 28, '#9fff00', 29, '#95ff00',
	30, '#8aff00', 31, '#74ff00', 32, '#6aff00', 33, '#5fff00', 34, '#54ff00',
	35, '#44ff00', 36, '#2eff00', 37, '#24ff00', 38, '#19ff00', 39, '#0eff00',
	40, '#03ff00', 41, '#00ff17', 42, '#00ff21', 43, '#00ff2c', 44, '#00ff37',
	45, '#00ff42', 46, '#00ff57', 47, '#00ff67', 48, '#00ff72', 49, '#00ff7d',
	50, '#00ff87', 51, '#00ff9d', 52, '#00ffa8', 53, '#00ffb8', 54, '#00ffc3',
	55, '#00ffcd', 56, '#00ffe3', 57, '#00ffee', 58, '#00fff8', 59, '#00faff',
	60, '#00eaff', 61, '#00d4ff', 62, '#00c9ff', 63, '#00bfff', 64, '#00b4ff',
	65, '#00a9ff', 66, '#008eff', 67, '#0083ff', 68, '#0079ff', 69, '#006eff',
	70, '#0063ff', 71, '#004eff', 72, '#003eff', 73, '#0033ff', 74, '#0028ff',
	75, '#001dff', 76, '#0008ff', 77, '#0200ff', 78, '#1200ff', 79, '#1d00ff',
	80, '#2800ff', 81, '#3d00ff', 82, '#4800ff', 83, '#5300ff', 84, '#5d00ff',
	85, '#6e00ff', 86, '#8300ff', 87, '#8e00ff', 88, '#9900ff', 89, '#a300ff',
	90, '#ae00ff', 91, '#c900ff', 92, '#d400ff', 93, '#df00ff', 94, '#e900ff',
	95, '#f400ff', 96, '#ff00f3', 97, '#ff00e3', 98, '#ff00d9', 99, '#ff00ce', 
	);
my @types_img = (
		[ "Log files", [ qw/.png .jpg/]  ],
		[ "All files", '*'],
	);	
Readonly my $line	=> q{"};				# MENU_SEPARATOR
Readonly my $sp		=> q/ /;				# SPACE
#	==========	==========	==========	==========	==========	</GLOBAL VARIABLES>

#	==========	==========	==========	==========	==========	<GUI>
my $mw = new MainWindow( -background => 'red');
$mw -> title( "miRVAM" );
$mw -> configure( 
	-menu => my $menu_bar =	$mw -> Menu( 
		-menuitems => menu_bar_items )
	);

my $fr_len_distribution	= $mw	-> Frame(
	# -borderwidth	=> 3,	-relief		=> 'groove' 
	); 

my $fr_status	= $fr_len_distribution	-> Frame(); 
my $txt_status	= $fr_status	-> Scrolled( 
	"Text", -borderwidth	=> 1,
	-width		=> 37,	-height		=> 7,	
	-padx		=> 15, 	-pady		=> 5,	
	-scrollbars	=> "e",	-background	=> 'grey90',
	);
$txt_status	-> insert('end', "Welcome to miRVAM.\n"
	. "$time\nis an excellent time to do science!\n\n"
	. "Pleace,choose the directory with your\nFASTA files.\n" 
	);
my $fr_buttons	= $fr_len_distribution	-> Frame(); 		
my $bttn_open	= $fr_buttons	-> Button(
	-image	=> $fr_buttons	-> Photo( -file => 'open.jpg' ),
	-activebackground => 'yellow',	
	-command	=> \&B_OPEN_DIR,
	);
my $bttn_count	= $fr_buttons	-> Button(
	-image	=> $fr_buttons	-> Photo( -file => 'count.jpg' ),
	-activebackground => 'yellow',	-state	=> $state,
	-command	=> sub { &B_COUNT_MIRNA( @fasta_array ) }, 
	);
my $bttn_hmode	= $fr_buttons	-> Button(
	-image	=> $fr_buttons	-> Photo( -file => 'hist.jpg' ),
	-activebackground => 'yellow',	-state	=> $state,
	-command	=> \&B_HIST_MODE,
	);
my $bttn_mmode	= $fr_buttons	-> Button(
	-image	=> $fr_buttons	-> Photo( -file => 'match.jpg' ),
	-activebackground => 'yellow',	-state	=> $state,
	-command	=> \&B_MATCH_MODE, 
	);
my $bttn_reset	= $fr_buttons	-> Button(
	-image	=> $fr_buttons	-> Photo( -file => 'reset.jpg' ),
	-activebackground => 'yellow',
	-command	=> \&B_RESET_ALL, 
	);
	
my $fr_options	= $fr_len_distribution	-> Frame( 
	-borderwidth	=> 1,	-relief		=> 'groove' , 
	);
	
my $fr_radiobttns	= $fr_options	-> Frame(); 
my $lbl_radiobttns	= $fr_radiobttns	-> Label(
	-text	=> "Format$sp:",
	-font	=> '-*-Calibri-R-Normal-*-*-15' , 
	); 
my $rbttn_nontab	= $fr_radiobttns	-> Radiobutton(
	-text	=> "Non-tabulated$sp|",
	-font	=> '-*-Calibri-R-Normal-*-*-12' ,
	-value	=> 1,		-variable	=> \$isT,
	-state	=> $state,	-command	=> sub { ( $tabT, $tabF, ) = ( 0, 1, ) },
	);
my $rbbtn_tab	= $fr_radiobttns	-> Radiobutton(
	-text	=> "Tabulated$sp$sp$sp$sp$sp$sp$sp$sp$sp$sp|",
	-font	=> '-*-Calibri-R-Normal-*-*-12' ,
	-value	=> 2,		-variable	=> \$isT,
	-state	=> $state,	-command 	=> sub { ( $tabT, $tabF, ) = ( 1, 0, ) },
	);
my $lbl_dataset	= $fr_radiobttns -> Label(
	-text	=> "Dataset:",
	-font	=> '-*-Calibri-R-Normal-*-*-15' , 
	);
my $rbttn_red	= $fr_radiobttns -> Radiobutton(
	-text	=> "Redundant$sp$sp$sp$sp$sp$sp$sp|",
	-font	=> '-*-Calibri-R-Normal-*-*-12' ,
	-value	=> 1,		-variable	=> \$isR,
	-state	=> $state,	-command	=> sub { ( $redT, $redF, ) = ( 1, 0, ) },
	);
my $rbttn_nonred	= $fr_radiobttns -> Radiobutton(
	-text	=> "Non-redundant$sp|",
	-font	=> '-*-Calibri-R-Normal-*-*-12' ,
	-value	=> 2,		-variable	=> \$isR,
	-state	=> $state,	-command	=> sub	{ ( $redT, $redF, ) = ( 0, 1, ) },
	);
	
my $fr_scale	= $fr_options	-> Frame();
my $scale_down	= $fr_scale	-> Scale(
	-label	=> "  Min [ 15, 20 ]",
	-font	=> '-*-Calibri-R-Normal-*-*-15' ,
	-activebackground => 'green',	-orient	=> 'h',
	-length => 95,		-digit	=>  1,	
	-from	=> 15,		-to	=> 20,
	-state	=> $state,	-variable => \$scale_from, 
	);
my $scale_label	= $fr_scale	-> Label(
	-text	=> "\n\n>  Interval  >",
	-font	=> '-*-Calibri-R-Normal-*-*-16' , 
	);
my $scale_up	= $fr_scale	-> Scale(
	-label	=>"Max [ 25, 30 ]",
	-font	=> '-*-Calibri-R-Normal-*-*-15' ,
	-activebackground => 'green',	-orient	=> 'h',	
	-length	=> 95,		-digit	=>  1,	
	-from	=>  25,		-to	=> 30,	
	-state	=> $state,	-variable => \$scale_to, 
	);
	
my $fr_results	= $fr_options	-> Frame();		
my $txt_results	= $fr_results	-> Scrolled(
	'Text',	-scrollbars => 'e',
	-width	=> 37,	-height => 21, 
	-padx	=> 15,	-pady	=>  5,
	-borderwidth	=> 1, 
	);
$txt_results	-> insert( 'end',"The results will be printed\nin this box.\n"
	. "Pleace, read them before saving.\n\n"
	. "For additional information\npleace read the manual\n"
	); 
$txt_results ->tagConfigure(
	'curSel',
	-background	=> $txt_results -> cget( -selectbackground	),
	-borderwidth	=> $txt_results -> cget( -selectborderwidth	),
	-foreground	=> $txt_results -> cget( -selectforeground	), 
	);
my $be_rlc	= $fr_results	-> BrowseEntry(
	-width	=> 30,	-borderwidth=> 2,
	-variable	=> \$search_incounter, 
	);
my $bttn_src_rlc	= $fr_results	->Button(
	-image	=> $fr_results -> Photo( -file =>'search.png' ),
	-activebackground => 'blue', -state => $state,
	-command => sub { search( $search_incounter, $be_rlc, $txt_results ) }, 
	);	
my $bttn_saveC	= $fr_results	->Button(
	-image	=> $fr_results -> Photo( -file =>'save.png' ),
	-activebackground => 'green',	-state	=> $state,
	-command => sub{ &SAVE( 'length_distribution.txt', @res_rlc ) },
	);
	
my $fr_progress	= $mw	-> Frame();
my $progress_rlc	= $fr_progress	-> ProgressBar(
	-borderwidth	=>  2,		-blocks	=> 100, 
	-troughcolor	=> 'white',	-colors	=> \@colors,
	-width		=> 15,		-length => 631,
	-relief 	=> 'sunken',	-gap	=>   0,
	-from		=>  0,		-to	=> 100,
	-anchor		=> 's',		-variable => \$progress_lvl, 
	);

my $fr_histbox	= $mw	-> Frame();  
my $listbox	= $fr_histbox	-> Scrolled( 
	"Listbox",	-scrollbars	=> "e",	
	-selectmode	=> "single",	-borderwidth	=> 1,
	-width		=> 60,		-height		=> 8,
	-selectbackground	=> 'lightgreen',	
	-selectborderwidth	=>  3, 
	);
my $instruction_area	= $fr_histbox	->Label(
	-width		=> 63,	-height		=> 5,
	-borderwidth	=>  2,	-relief 	=> 'groove', 
	); 
	
my $fr_histopt	= $fr_histbox	-> Frame();	
my $bttn_show_h	= $fr_histopt	-> Button(
	-image	=> $fr_histopt	-> Photo( -file	=> 'show_hist.png' ),
	-activebackground => 'orange',	-state	=> $state,
	-command	=> sub{ &H_show_hist() }, 
	);  
my $bttn_save_oneh	= $fr_histopt	-> Button(
	-image	=> $fr_histopt	-> Photo( -file	=> 'save_hist.png' ),
	-activebackground => 'yellow',	-state	=> $state,
	-command	=> sub{ &H_show_hist(), &H_save_oneh(), }, 
	);  
my $buttn_save_allh	= $fr_histopt	-> Button(
	-image	=> $fr_histopt	-> Photo( -file => 'save_allhist.png' ),
	-activebackground => 'green',	-state	=> $state,
	-command	=>  sub{ &H_save_allh( &_hist( 
		$listbox -> get( $listbox -> curselection )
		,%hist_data ) ) 
		}, 
	);
my $lbl_hist	= $fr_histbox -> Label(
	-width	=> 58,	-height	=> 27, 
	);
	
my $fr_progress2	= $mw	-> Frame();
my $progress_rlc2	= $fr_progress2	-> ProgressBar(
	-borderwidth	=>  2,		-blocks	=> 100, 
	-troughcolor	=> 'white',	-colors	=> \@colors,
	-width		=> 15,		-length => 631,
	-relief 	=> 'sunken',	-gap	=>   0,
	-from		=>  0,		-to	=> 100,
	-anchor		=> 's',		-variable => \$progress_lvl, 
	);		
	
my $fr_refere	= $mw	-> Frame(); 	

my $fr_outer	= $fr_refere	-> Frame(
	-borderwidth	=> 1,	-relief	=> 'sunken', 
	); 

my $fr_outer_rb	= $fr_outer	-> Frame();
my $lbl_ref_istab	= $fr_outer_rb	-> Label(
	-text	=> "Referent DB format:\n\n",
	-font	=> '-*-Calibri-R-Normal-*-*-16' , 
	);
my $rbbt_ref_nontab	= $fr_outer_rb	 -> Radiobutton(
	-text	=> "Non-tabulated\t|",
	-font	=> '-*-Calibri-R-Normal-*-*-14' ,
	-value	=> 1,		-variable	=> \$isMT,
	-state	=> $state,	-command	=> sub { ( $matT, $matF, ) = ( 0, 1, ) },	
	);
my $rbbt_ref_tab	= $fr_outer_rb	 -> Radiobutton(
	-text	=> "Tabulated\t|",
	-font	=> '-*-Calibri-R-Normal-*-*-14' ,
	-value	=> 2,		-variable	=> \$isMT,
	-state	=> $state,	-command	=> sub { ( $matT, $matF, ) = ( 1, 0, ) },
	);

my $fr_outer_cb	= $fr_outer	-> Frame();
my $lbl_pattern	= $fr_outer_cb	-> Label(
	-text	=>  "Output preferences:",
	-font	=> '-*-Calibri-R-Normal-*-*-16' ,
	);	
my $cb1	= $fr_outer_cb -> Checkbutton(
	-text	=> "Ref DB miRNA header\t|",
	-font	=> '-*-Calibri-R-Normal-*-*-12' ,
	-state	=> $state,	-variable	=>\$var1, 
        );	
my $cb2	= $fr_outer_cb -> Checkbutton(
	-text	=>  "Sample miRNA header\t|",
	-font	=> '-*-Calibri-R-Normal-*-*-12' ,
        -state	=> $state,	-variable	=>\$var2, 
        );	
my $cb3	= $fr_outer_cb -> Checkbutton(
	-text	=> "Matched sequences\t|",
	-font	=> '-*-Calibri-R-Normal-*-*-12' ,
        -state	=> $state,	-variable	=>\$var3, 
        );	
my $cb4	= $fr_outer_cb -> Checkbutton(
	-text	=> "Lenght of the sequences\t|",
	-font	=> '-*-Calibri-R-Normal-*-*-12' ,
        -state	=> $state,	-variable	=>\$var4, 
        );	

my $fr_outertxt	= $fr_refere	-> Frame();                 
my $txt_compare	= $fr_outertxt	-> Scrolled( 
	"Text",	-borderwidth	=> 2,
	-width		=> 65,	-height		=> 33, 	
	-padx		=> 15,	-pady		=>  5,
	-scrollbars	=> "e",	-background	=> 'grey98', 
	);
$txt_compare -> tagConfigure(
	'curSel',
	-background	=> $txt_compare -> cget( -selectbackground	),
	-borderwidth	=> $txt_compare -> cget( -selectborderwidth	),
	-foreground	=> $txt_compare -> cget( -selectforeground	), 
	);
my $be_match	= $fr_outertxt	-> BrowseEntry(
	-width	=> 44,
	-variable	=> \$search_inmatch, 
	);
my $bttn_src_ref	= $fr_outertxt	-> Button(
	-image	=> $fr_outertxt -> Photo( -file	=>'search.png' ),
	-activebackground	=> 'blue',	-state	=> $state,
	-command	=> sub { search( $search_inmatch, $be_match, $txt_compare ) }, 
	);
my $bttn_match_one	= $fr_outertxt	-> Button(
	-image	=> $fr_outertxt -> Photo ( -file	=>'match_one.png' ),
	-activebackground	=> 'yellow',	-state	=> $state,
	-command	=> \&M_match_one,
	);
my $bttn_match_all	= $fr_outertxt	->Button(
	-image	=> $fr_outertxt -> Photo( -file	=>'match_all.png' ),
	-activebackground	=> 'orange',	-state	=> $state,
	-command	=> \&M_match_all, 
	);
{ #	==========	==========	==========	==========	==========	<MOUSEOVER>
my $bl_bttn_open	= $fr_buttons	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_open -> attach( $bttn_open,
	-balloonmsg	=> "Open Dir",  
	-statusmsg	=> "Browses for the directory \nwith files of sequenced miRNA samples.",
	);	
my $bl_bttn_count	= $fr_buttons	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_count	-> attach( $bttn_count,
	-balloonmsg	=> "Run theCounter",  
	-statusmsg	=> "Counts the number of all sequences with the same length for each sample.",
	);	
my $bl_bttn_hmode	= $fr_buttons	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_hmode	-> attach( $bttn_hmode,
	-balloonmsg	=> "Histogram mode",  
	-statusmsg	=> "Allows you to draw histograms with the results of the counting and save them.",
	);	
my $bl_bttn_mmode	= $fr_buttons	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_mmode	-> attach( $bttn_mmode,
	-balloonmsg	=> "Sequence match mode",  
	-statusmsg	=> "Compares your data with outer list of miRNAs and and shows which are present.", 
	);	
# my $bl_bttn_masrun	= $fr_buttons	-> Balloon( -statusbar => $instruction_area );
# $bl_bttn_masrun	-> attach( $bttn_masrun,
	# -balloonmsg	=> "Masive analizes",  
	# -statusmsg	=> "Runs all  the features at once.",
	# );	
# my $bl_bttn_massave	= $fr_buttons	-> Balloon( -statusbar => $instruction_area );
# $bl_bttn_massave	-> attach( $bttn_massave,
	# -balloonmsg	=> "Save all",  
	# -statusmsg	=> "Saves all results after the masive analizes.",
	# );	
my $bl_bttn_reset	= $fr_buttons	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_reset	-> attach( $bttn_reset,
	-balloonmsg	=> "Reset",  
	-statusmsg	=> "Clears all user`s actions and setts the program at start position.", 
	);

my $bl_bttn_src_rlc	= $fr_results	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_src_rlc	-> attach( $bttn_reset,
	-balloonmsg	=> "",  
	-statusmsg	=> "",
	);
my $bl_bttn_saceC	= $fr_results	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_saceC	-> attach( $bttn_reset,  
	-balloonmsg	=> "",  
	-statusmsg	=> "",
	);

my $bl_bttn_show_h	= $fr_histopt	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_show_h	-> attach( $bttn_show_h,
	-balloonmsg	=> "",  
	-statusmsg	=> "",
	);
my $bl_bttn_save_oneh	= $fr_histopt	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_save_oneh	-> attach( $bttn_save_oneh,
	-balloonmsg	=> "",  
	-statusmsg	=> "",
	);
my $bl_buttn_save_allh	= $fr_histopt	-> Balloon( -statusbar => $instruction_area );
$bl_buttn_save_allh	-> attach( $buttn_save_allh,
	-balloonmsg	=> "",  
	-statusmsg	=> "",
	);

my $bl_bttn_src_ref	= $fr_outertxt	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_src_ref	-> attach( $bttn_src_ref,
	-balloonmsg	=> "",  
	-statusmsg	=> "",
	);
my $bl_bttn_match_one	= $fr_outertxt	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_match_one	-> attach( $bttn_match_one,
	-balloonmsg	=> "",  
	-statusmsg	=> "",
	);
my $bl_bttn_match_all	= $fr_outertxt	-> Balloon( -statusbar => $instruction_area );
$bl_bttn_match_all	-> attach( $bttn_match_all,
	-balloonmsg	=> "",  
	-statusmsg	=> "",
	);
} #	==========	==========	==========	==========	==========	</MOUSEOVER>

{ #	==========	==========	==========	==========	==========	<GEOMETRY>
$fr_len_distribution	-> grid( -row => 1, -column => 1 );
	$fr_status	-> grid( -row => 1, -column => 1 ); 
		$txt_status	-> grid( -row => 1, -column => 1 );
	$fr_buttons	-> grid( -row => 2, -column => 1 ); 
			$bttn_open	-> grid( -row => 1, -column => 1 );
			$bttn_count	-> grid( -row => 1, -column => 2 );
			$bttn_hmode	-> grid( -row => 1, -column => 3 );
			$bttn_mmode	-> grid( -row => 1, -column => 4 );
			$bttn_reset	-> grid( -row => 1, -column => 5 );
	$fr_options	-> grid ( -row => 3, -column => 1 );
		$fr_radiobttns	-> grid ( -row => 1, -column => 1 ); 
			$lbl_radiobttns	-> grid( -row => 1, -column => 1 ); 
			$rbttn_nontab	-> grid( -row => 1, -column => 2 );
			$rbbtn_tab	-> grid( -row => 1, -column => 3 );
			$lbl_dataset	-> grid( -row => 3, -column => 1 );
			$rbttn_red	-> grid( -row => 3, -column => 2 );
			$rbttn_nonred	-> grid( -row => 3, -column => 3 );
		$fr_scale	-> grid( -row => 2, -column => 1 );
			$scale_down	-> grid( -row => 1, -column => 1 );
			$scale_label	-> grid( -row => 1, -column => 2 );
			$scale_up	-> grid( -row => 1, -column => 3 );
		$fr_results	-> grid( -row => 3, -column => 1 );
			$txt_results	-> pack( -side => 'bottom' );
			$be_rlc		-> pack( -side => 'left' );
			$bttn_src_rlc	-> pack( -side => 'left' );
			$bttn_saveC	-> pack( -side => 'left' );
$fr_progress 	-> grid( -row => 1, -column => 2 );
	$progress_rlc	-> grid( -row => 1, -column => 1 );
$fr_histbox	-> grid( -row => 1, -column => 3 );  
	$listbox	-> grid( -row => 1, -column => 1 );
	$instruction_area	-> grid( -row => 2, -column => 1 );
	$fr_histopt	-> grid( -row => 3, -column => 1 );
		$bttn_show_h	-> grid( -row => 1, -column => 1 );  
		$bttn_save_oneh	-> grid( -row => 1, -column => 2 );  
		$buttn_save_allh -> grid( -row => 1, -column => 3 ); 
	$lbl_hist	-> grid( -row => 4, -column => 1 ); #HERE IS THE HISTOGRAM
$fr_progress2	-> grid( -row => 1, -column => 4 );
	$progress_rlc2	-> grid( -row => 1, -column => 1 );		
$fr_refere	-> grid( -row => 1, -column => 5 ); 	
	$fr_outer	-> grid( -row => 1, -column => 1 );   
		$fr_outer_rb	-> grid( -row => 1, -column => 1 );
			$lbl_ref_istab	-> grid( -row => 1, -column => 1 );
			$rbbt_ref_nontab -> grid( -row => 2, -column => 1 );
			$rbbt_ref_tab	-> grid( -row => 3, -column => 1 );
	$fr_outer_cb	-> grid( -row => 1, -column => 2 );
		$lbl_pattern	-> grid( -row => 1, -column => 1 );	
		$cb1		-> grid( -row => 2, -column => 1 );	
		$cb2		-> grid( -row => 3, -column => 1 );	
		$cb3		-> grid( -row => 4, -column => 1 );	
		$cb4		-> grid( -row => 5, -column => 1 );	
	$fr_outertxt	-> grid( -row => 2, -column => 1 );                 
		$txt_compare	-> pack( -side => 'bottom' );
		$be_match	-> pack( -side => 'left' );
		$bttn_src_ref	-> pack( -side => 'left' );
		$bttn_match_one	-> pack( -side => 'left' );
		$bttn_match_all	-> pack( -side => 'left' );
} #	==========	==========	==========	==========	==========	</GEOMETRY>

{ #	==========	==========	==========	==========	==========	<CONTROLS>
$mw -> bind( '<Control-o>', [ \&B_OPEN_DIR	] );
$mw -> bind( '<Control-c>', [ \&B_COUNT_MIRNA	] );
$mw -> bind( '<Control-d>', [ \&B_HIST_MODE	] );
$mw -> bind( '<Control-m>', [ \&B_MATCH_MODE	] );
$mw -> bind( '<Control-b>', [ \&B_MAS_RUN	] );
$mw -> bind( '<Control-s>', [ \&B_MAS_SAVE	] );
$mw -> bind( '<Control-r>', [ \&B_RESET_ALL	] );
$mw -> bind( 'all' => '<Key-Escape>' => sub { exit; } );
} #	==========	==========	==========	==========	==========	</CONTROLS>

MainLoop ();	#	==========	==========	==========	==========	</GUI>

sub	B_OPEN_DIR # ===============================
# Sets a working directory and gives a description
# of the content. Sorts fasta from non-fasta files.
# Loads the listbox with valid FASTAs.
# ==================================================
{
	# 1. Unlock all dependant widgets.
	_widget_activator( $bttn_mmode,$bttn_count, $scale_up, $scale_down
	, $rbttn_red, $rbttn_nonred, $rbbtn_tab, $rbttn_nontab,  );
	
	# 2. Reset globals.
	$workspace	= q{};
	$txt_status	-> delete ( '0.0', 'end' );
	$listbox	-> delete ( 0, 'end' );
	( @dir_content, @fasta_array ) = ( (), () ); 
	
	# 3. Set a working dir.
	$workspace	= $mw -> chooseDirectory;	
	$txt_status	-> insert( 'end', "For working directory is set :\n$workspace/\n" );
	
	# 4. Sort and describe.	
	opendir( DIR, $workspace );
	while( my $file = readdir DIR )
	{
		if( $file ne "." and $file ne ".." )
		{
			push( @dir_content, $file ); # removes some Windows stuff.
		}
	}
	closedir DIR;
	
	for( my $i = 0; $i <= $#dir_content; $i++ )
	{
		my	$file_size	= 0;
		my	@description	= ();	
		
		if( $dir_content[ $i ] =~ /.fa/|| $dir_content[ $i ] =~ /.fas/
			|| $dir_content[ $i ] =~ /.fasta/|| $dir_content[ $i ] =~ /.txt/ )
		{
			push( @fasta_array, $dir_content[ $i ] );
		}
		else
		{
			$txt_status -> insert( 'end', "\nTHIS IS NOT FASTA-->" );
		}
		
		open( FILE_DESCRIPTION, "$workspace/$dir_content[ $i ]" );
		if( -e FILE_DESCRIPTION )
		{
			push @description, 'binary|'			if ( -B _ );
			push @description, 'socket|'			if ( -S _ );
			push @description, 'text file|'			if ( -T _ );
			push @description, 'block special file|'	if ( -b _ );
			push @description, 'character special file|'	if ( -c _ );
			push @description, 'directory|'			if ( -d _ );
			push @description, 'executable|'		if ( -x _ );
			push @description, ( ( $file_size	= -s _ ) ) ? " $file_size bytes." : ' empty';		
			$txt_status -> insert( 'end', "$dir_content[ $i ]| ", @description );
			$txt_status -> insert( 'end', "\n" );
		}
		close FILE_DESCRIPTION;	
	}
	
	# 5. Add only FASTA files to the listbox
	for( my $l = 0; $l <= $#fasta_array;$ l++ )
	{
		$listbox -> insert( 'end', $fasta_array[ $l ] );
	}
}

sub	B_COUNT_MIRNA # ============================
# Counts all miRNA from (non)redundant data in
# (non)tabulated format with same length 
# + histogram data + progres bar
# ==================================================
{	
	my @files_array = @_;
	
	$progress_lvl	= 0;
	$txt_results	-> delete ( '0.0', 'end' );
	
	# 1.  Check for missing working directory and (un)lock widgets;
	if( $workspace eq q{} )
	{
		_widget_deactivator( $bttn_hmode, 
		######################################################$bttn_masrun, 
		$bttn_save_oneh, );
		
		$txt_results	-> delete( '0.0', 'end' );
		$txt_status	-> delete( '0.0', 'end' );
		$txt_status	-> insert( 'end', "ERROR\t!\t!\t!\n\nWorking directory not found!\n\n"
			. "Pleace, choose the directory with your\nFASTA files.\n" ); 
	}
	else 
	{
		_widget_activator( $bttn_hmode, $bttn_src_rlc, $bttn_saveC );
	}
	
	my $dir	= $workspace; # else
	my $bar_of_progress = 100 / $#files_array;
	
	# 2. Counts the length distribution.	
	$txt_results	-> insert( 'end',"THE RESULTS FROM ANALYSES\n"
		."OF LENGHT DISTRIBUTION\nFOR THE UPLOADED SAMPLES ARE:\n" );
	for ( my $j = 0; $j <= $#files_array; $j++ )
	{	
		my ( $eq_seq_copies, $total_copies, $seq_len, ) = ( 0, 0, 0, );
		my ( %seq_len_hash, %redF_hash ) = ( (), (), );
		my $rlc_tbl = Text::Table -> new( qw/seq_len copies [%]/ );
		
		# 2.1 Sums the copies of all miRNA with same length.
		$txt_results -> insert( 'end', "\n$files_array[ $j ]\n" );
		push( @res_rlc, "\n$files_array[ $j ]\n" );
		open( FILE_ANALYZER, "$dir/$files_array[ $j ]" );
		while( <FILE_ANALYZER> )
		{ 
			chomp;
			if( $redT eq 1 and $tabF eq 1 )
			{	
				if( $_ =~ /^>(.+)/ )
				{
					$eq_seq_copies = substr ( $_, index ( $_, "x" ) + 1 );
					$total_copies += $eq_seq_copies;
				}
				else
				{
					$seq_len_hash{ length ( $_ ) } += $eq_seq_copies;
				}
			}
			elsif( $redT eq 1 and $tabT eq 1 )
			{
				my @rowcols = split ( "\t", $_ );
				$eq_seq_copies = substr ( $rowcols[ 0 ], index ( $rowcols[ 0 ], "x" ) + 1 );
				$total_copies += $eq_seq_copies;
				
				$seq_len_hash{ length ( $rowcols[ 1 ] ) } += $eq_seq_copies;
			}
			elsif( $redF eq 1 and $tabF eq 1 )
			{
				$redF_hash{ $_  } = $eq_seq_copies if !( $_ =~ /^>(.+)/ );
			}
			elsif( $redF eq 1 and $tabT eq 1 )
			{
				my @rowcols = split( "\t", $_ );
				$redF_hash{ $rowcols[ 1 ] } = $eq_seq_copies;
			}
			else
			{
				$txt_status -> delete( '0.0', 'end' );
				$txt_status -> insert( 'end', "WARNING ! ! ! \n\n"
					. "Missing Dataset and/or Tabulation Format\n"
					);
			}
		}
		close FILE_ANALYZER;
		
		# 2.2 Non-redundant manager.
		if( $redF eq 1 )
		{
			foreach my $key ( sort keys %redF_hash )
			{	
				$redF_hash{ $key } = reverse $redF_hash{ $key };
				$redF_hash{ $key } = reverse $redF_hash{ $key };
				$eq_seq_copies = 1;
				$total_copies += $eq_seq_copies;
				
				$seq_len_hash{ length ( $key ) } += $eq_seq_copies;	
			}
		}
		# 2.3 Load results in a table and print.
		foreach my $key ( sort keys %seq_len_hash )
		{	
			my $total_copies_percent = 0;
			if ( $key ge $scale_from  and $key le $scale_to )
			{
				push( @hist_y, $seq_len_hash{ $key } );
				
				$total_copies_percent 
					= sprintf( "%.2f", ( $seq_len_hash{ $key } / $total_copies ) * 100 );
				$rlc_tbl -> add( $key, $seq_len_hash{ $key }, $total_copies_percent . "%\n" );
			}
		}		
		$rlc_tbl	-> add( "total_copies", $total_copies, "100%" );
		push( @res_rlc, $rlc_tbl );
		$txt_results	-> insert( 'end', $rlc_tbl );
		
		# 2.4 Load data for histogram.
		$hist_data{ $files_array[ $j ] } = [ @hist_y ];
		
		# 2.5 ProgressBar update.
		$progress_lvl	+= $bar_of_progress ;
		print chr ( 7 ) if ( $progress_lvl >= 100 );
		# $fr_len_distribution -> update;
	}
	# $results_rlc = ( $txt_results );
}

sub	B_HIST_MODE # ==============================
# Allows to draw and save histograms.
# ==================================================
{
	_widget_activator( $bttn_show_h, $bttn_save_oneh, $buttn_save_allh );
	$listbox -> bind( '<Double-Button-1>', sub{ &H_show_hist(), &H_save_oneh() } );
	
	$txt_status	-> delete( '0.0', 'end' );
	$txt_status	-> insert( 'end', "Pleace, choose from the listbox\n"
		."for which file to draw a histogram.\n\n"
		."You can save the histogram by double-click on the"
		."listbox element or by using \none of the save buttons."
		);
}

sub	B_MATCH_MODE # =============================
# Allows to compare samples with referent DB.
# ==================================================
{
	_widget_activator( $bttn_src_ref,$bttn_match_one, $bttn_match_all 
		, $cb1, $cb2, $cb3, $cb4, $rbbt_ref_tab, $rbbt_ref_nontab 
		);

	my @types = ( 
		[ "Log files", [ qw/.txt .fa .fas .fasta/ ] ],
		[ "All files",	'*' ],
		);
	my $filepath = $mw -> getOpenFile( -filetypes => \@types ) or return();
	
	$txt_status -> delete( '0.0', 'end' );
	$txt_status -> insert( 'end', "The reference database is:\n$filepath\n" );
	$referent_DB = $filepath;
}

sub	B_MAS_RUN # ================================
# 
# ==================================================
{

}

sub	B_MAS_SAVE # ===============================
#
# ==================================================
{

}

sub	B_RESET_ALL # ==============================
#
# ==================================================
{
	( @dir_content, @fasta_array ) = ( (), () );
	( $workspace, $referent_DB ) = ( q{}, q{} );
	( $isF, $isR, $isT, $isS, $isMT, ) = ( 0, 0, 0, 0, 0, );
	( $redT, $redF, $tabT, $tabF, $matT, $matF, ) = ( 0, 0, 0, 0, 0, 0, );
	( $var1, $var2, $var3, $var4 ) = ( 0, 0, 0, 0, );
	( $scale_from, $scale_to,) = ( 15, 30, );
	( $search_incounter, $search_inmatch ) = ( q{}, q{} );
	( %hist_data, @hist_y ) = ( (), () );
	$progress_lvl = 0;				
	
	_widget_deactivator(
		$bttn_count,$bttn_hmode, $bttn_mmode,####################$bttn_masrun
		############################################, $bttn_massave,
		 $rbttn_nontab, $rbbtn_tab, $rbttn_red
		, $rbttn_nonred, $scale_down, $scale_up, $bttn_src_rlc
		, $bttn_saveC, $bttn_show_h, $bttn_save_oneh, $buttn_save_allh
		, $rbbt_ref_nontab, $rbbt_ref_tab, $cb1, $cb2, $cb3, $cb4, $bttn_src_ref
		, $bttn_match_one, $bttn_match_all,
		);

	$fr_histbox -> Label( -width => 58, -height => 27, )-> grid( -row => 4, -column => 1 );
	
	$listbox	-> delete( 0, 'end' );
	$txt_status	-> delete( '0.0', 'end' );
	$txt_results	-> delete( '0.0', 'end' );
	$txt_compare	-> delete( '0.0', 'end' );
	$txt_status	-> insert( 'end', "The reset was successful !\n\n" 
		. "The program is ready for the next task.\n" );
	
	$mw	->update();
}

sub	H_show_hist # ==============================
# 
# ==================================================
{	
	my $histogram = $fr_histbox -> Frame() -> grid( -row => 4, -column => 1 );
	my $png	= $histogram -> Photo( 
		-data => encode_base64(
			_hist( 
				$listbox -> get( $listbox -> curselection )
				, %hist_data 
			) -> png )
		);
	$histogram -> Label( -image => $png ) -> grid ( -row => 1, -column => 1 );
}

sub	H_save_oneh # ==============================
# 
# ==================================================
{
	my $file_title = $listbox -> get( $listbox -> curselection );
	$file_title =~ s/.fa//;
	$file_title = "$file_title.NR.png"	if $redF eq 1;
	$file_title = "$file_title.R.png" 	if $redT eq 1;
	
	my $filepath = $mw -> getSaveFile(
		-filetypes	=> \@types_img,
		-initialfile	=> $file_title,
                ) or return();
	my $png = _hist( 
		$listbox -> get( $listbox -> curselection )
		, %hist_data 
	) -> png;
	
	open( my $out, '>', $filepath );
	binmode $out;
	print $out $png;
	close $out;
}

sub	H_save_allh # ==============================
# 
# ==================================================
{
	my $save_dir = $mw -> chooseDirectory();
	my @elements = $listbox -> get( 0, 'end' );
	
	for( my $i= 0; $i <= $#elements; $i++ )
	{
		my $file_title = $elements[ $i ];
		$file_title =~ s/.fa//;
		$file_title = "$file_title.NR.png"	if $redF eq 1;
		$file_title = "$file_title.R.png" 	if $redT eq 1;
		
		my $png = _hist( 
			$elements[ $i ],
			%hist_data,
		) -> png ;
		
		open( my $out, '>', "$save_dir/$file_title" );
		binmode $out;
		print $out $png;
		close $out;
	}
}

sub	_hist # ====================================
# 
# ==================================================
{	
	my ( $hist_title, %_hist_data ) = @_;
	
	my $graph = GD::Graph::bars-> new( 355, 355 );
	foreach( sort keys %_hist_data )
	{
		if( $_ eq $hist_title )
		{	
			my $data = [ [ $scale_from .. $scale_to ], [ @{ $_hist_data{ $_ } } ] ];
			my $max = 0;
			foreach( @{ $_hist_data{ $_ } } ) 
			{
				$max = $_ if !$max || $_ > $max;
			}
			# $max += $max * 0.05;	#???
			$hist_title =~ s/.fa//;
			$hist_title = "$hist_title.NR.png"	if $redF eq 1;
			$hist_title = "$hist_title.R.png" 	if $redT eq 1;
			
			$graph -> set( 
				x_label		=> 'Lenght of the sequences',
				y_label		=> 'Copies',
				title		=> $hist_title,
				y_max_value     => int( $max ),
				y_tick_number   => 10,
				y_label_skip    =>  1,
				bar_spacing     => 10,
				shadow_depth    =>  4,
				shadowclr       => 'dred',
				transparent     =>  0,
				);
			my $gd	= $graph	-> plot( $data );
			return( $gd );
		}
	}
}

sub	M_match_one # ==============================
# 
# ==================================================
 {
	$txt_compare -> delete( '0.0', 'end' );
	
	my @toSave = ();
	@toSave = _match( $listbox -> get( $listbox -> curselection ) );
	my $answer = $mw -> Dialog(
		-title		=> 'Please Reply', 
		-text		=> "Would you like to save the results ?", 
		-default_button	=> 'Yes',
		-buttons	=> [ 'Yes', 'No'], 
		-bitmap		=> 'question' 
		) -> Show(),;
	if( $answer eq 'Yes' )
	{
		my $sample = $listbox -> get( $listbox -> curselection );
		$sample =~ s/.fa//;
		$sample = "$sample-refDB.csv";
		
		SAVE( $sample, @toSave );
	}
	elsif( $answer eq 'No' )	{ return(); }
	elsif( !defined $answer )	{ return(); }
}
 
sub	M_match_all # ==============================
#
# ==================================================
 {
	$txt_compare -> delete( '0.0', 'end' );
	my @elements = $listbox -> get( 0, 'end' );
	
	my $answer = $mw -> Dialog(
		-title		=> 'Please Reply', 
		-text		=> "Would you like to save the results ?", 
		-default_button	=> 'Yes',
		-buttons	=> [ 'Yes', 'No'], 
		-bitmap		=> 'question' 
		) -> Show(),;
	if( $answer eq 'Yes' )
	{
		my $save_dir = $mw -> chooseDirectory();
		
		for( my $i= 0; $i <= $#elements; $i++ )
		{
			my $sample = $elements[ $i ];
			$sample =~ s/.fa//;
			$sample = "$sample-refDB.csv";
			
			my @ss = _match( $elements[ $i ] );
			open( my $out, '>', "$save_dir/$sample" );
			print $out @ss;
			close $out;
		}		
	}
	elsif( $answer eq 'No' )
	{ 
		for( my $i= 0; $i <= $#elements; $i++ )
		{
			_match( $elements[ $i ] );
		}
	}
	elsif( !defined $answer )	{ return(); }
}


# sub	M_save_match_all # =========================
# # 
# # ==================================================
# {
	# my @r = split "\n\n", @res_ref;
	
	# print $res_ref[0]."--0\n";
	# print $res_ref[1]."--1\n";
	# print $res_ref[2]."--2\n";
	
# }

sub	_match # ===================================
# 
# ==================================================
{
	_widget_activator( $bttn_src_ref );
	
	my ( %ref_db, %sampleHash, ) = ( (), () ); 
	my ( $refID, $refS, $sampleID, $sampleS, ) = ( q{}, q{}, q{}, q{}, );
	my ( @matches,@res_ref ) = ( (), () );
	open( REF_DB, '<', $referent_DB );
	while( <REF_DB> )
	{	
		chomp;	
		if( $matF eq 1 )
		{		
			if( $_ =~ /^>(.+)/ )
			{
				$refID = $_;
			}
			else
			{
				$ref_db{ $_ } = $refID;
			}
			
		}
		elsif( $matT eq 1 )
		{
			my @rowcols = split ( "\t", $_ );
			$ref_db{ $rowcols[ 1 ] } = $rowcols[ 0 ];
		}
		else
		{
			_widget_deactivator( $bttn_src_ref );
			$txt_status -> delete( '0.0', 'end' );
			$txt_status -> insert( 'end', "WARNING ! ! ! \n\n"
				. "Missing tabulation format\nfor the referent DB\n"
				."Pleace, choose a tabulation format.\n"
				);
		}
	}
	close REF_DB;
	
	open( SAMPLE, '<', "$workspace/@_" );
	while( <SAMPLE> )
	{
		chomp;
		if( $tabF eq 1 )
		{
			if( $_ =~ /^>(.+)/ )
			{ 
				$sampleID = $_;
			}
			else
			{ 
				$sampleS = $_;		      
				$sampleS =~tr/T/U/;
				$sampleHash{ $sampleS} = $sampleID;
			}
		}
		elsif( $tabT eq 1 )
		{
			my @rowcols = split ( "\t", $_ );
			$rowcols[ 1 ] =~tr/T/U/;
			$sampleHash{ $rowcols[ 1 ] } = $rowcols[ 0 ];	
		}
	}
	close SAMPLE;
	
	foreach( keys %sampleHash ) 
	{
		push( @matches, $_ ) if exists $ref_db{ $_ };
	}
	
	$txt_compare -> insert( 'end', "[ @_ ] is compared to referent DB\n[ $referent_DB ]\n\n" );
	push( @res_ref, "[ @_ ] - [ $referent_DB ]\n" );
	for( my $k = 0; $k <= $#matches; $k++ )
	{	
		my $matched_seq_len = length( $matches[ $k ] );	
		if( $var1 eq 1 )
		{	
			$txt_compare -> insert( 'end', "$ref_db{ $matches[ $k ] }\t" );
			push( @res_ref, "$ref_db{ $matches[ $k ] },");
		}
		if( $var2 eq 1 )
		{
			$txt_compare -> insert( 'end', "$sampleHash{ $matches[ $k ] }\t" );
			push( @res_ref, "$sampleHash{ $matches[ $k ] }," );
		}
		if( $var3 eq 1 )
		{
			$txt_compare -> insert( 'end', "$matches[ $k ]\t" );
			push( @res_ref, "$matches[ $k ]," );
		}
		if( $var4 eq 1 )
		{
			$txt_compare -> insert( 'end', "$matched_seq_len" );
			push( @res_ref, "$matched_seq_len," );
		}
		$txt_compare -> insert( 'end', "\n" );		
		push( @res_ref, "\n" );
	}
	push( @res_ref, "\n" );
	return( @res_ref );
}

sub	SAVE # =====================================
# 
# ==================================================
{
	my ( $file_name, @toPrint, ) = @_;
	
	my @type = (
		[ "Log files", [ qw/.txt .csv/ ] ],
		[ "All files", '*'],
	);
	my $file_path = $mw -> getSaveFile(
		-filetypes	=> \@type,
		-initialfile	=> $file_name,
                ) or return();
	
	open( my $fh, '>', $file_path );
	print $fh @toPrint;
	close $fh;
}

sub	menu_bar_items # ===========================
# The MENU of the program.
# ==================================================
{
	[ map [ 'cascade', $_ -> [ 0 ], -menuitems => $_ -> [ 1 ] ],

	[ '~File',
		[
			[ qw/command Open -command/	=> \&open_dir		],	$line,
			[ qw/command Run -command/	=> \&results_handler	],	$line,
			[ qw/command Save  -command/	=> \&save_file		],	$line,
			[ qw/command Close/					],       $line,
			[ qw/command Quit -command/	=> \&exit		],
		],
	],
	[ '~Sample verification',
		[
			# [ qw/command Redundant -command/	=> \&redT	],
			# [ qw/command Non-redundant -command/	=> \&redF	],	$line,
			# [ qw/command Non-tabulated -command/	=> \&tabF	],
			# [ qw/command Tabulated -command/	=> \&tabT	],	$line,
			[ qw/cascade Set_interval_from -menuitems/ =>
				[
					[ 'command', 15, -command => \sub { $scale_from = 15 } ],
					[ 'command', 16, -command => \sub { $scale_from = 16 } ],
					[ 'command', 17, -command => \sub { $scale_from = 17 } ],
					[ 'command', 18, -command => \sub { $scale_from = 18 } ],
					[ 'command', 19, -command => \sub { $scale_from = 19 } ],
					[ 'command', 20, -command => \sub { $scale_from = 20 } ],
				],
			],
			[ qw/cascade Set_interval_to -menuitems/ =>
				[
					[ 'command', 25, -command => \sub { $scale_to = 25 } ],
					[ 'command', 26, -command => \sub { $scale_to = 26 } ],
					[ 'command', 27, -command => \sub { $scale_to = 27 } ],
					[ 'command', 28, -command => \sub { $scale_to = 28 } ],
					[ 'command', 29, -command => \sub { $scale_to = 29 } ],
					[ 'command', 30, -command => \sub { $scale_to = 30 } ],
				],
			],	$line,
			[ qw/command Reset -command/		=> \&reset	],	$line,
			[ qw/command Close/	],
		],
	],
	[ '~Histogram mode',
		[
			[ qw/command Show_histogram -command/	=> \&show_hist	],
			[ qw/command Save_histogram -command/	=> \&save_oneh	],
			[ qw/command Save_all_hist -command/	=> \&save_allh	],	$line,
			[ qw/command Close/	], 
		], 
	],
	[ '~Match mode',
		[
			[ qw/command Non-tabulated -command/	=> \&matF	],
			[ qw/command Tabulated -command/	=> \&matT	],	$line,
			[ qw/command Close/	], 
		],
	],
	
	[ '~Controls',
		[
			[ qw/command HotKeys -command/	=> \sub { window( qw/Controls controls.txt/ ) }	],	$line,
			[ qw/command Close/	], 
		],
	],
	[ '~Help',
		[
			[ qw/cascade Manual -menuitems/		=>
				[
					[ 'command', 'READ_ME(.pdf)', -command => \&pdf_handler	],
				],
			],
			[ qw/command Version -command/	=> \sub { window( qw/Version version.txt/ ) }	],
			[ qw/command About -command/	=> \sub { window( qw/About about.txt/ ) }	],	$line,
			[ qw/command Close/	], 
		],
	],
];
}

sub	search # ===================================
# 
# ==================================================
{
	my ( $search_string, $be_widjet, $txt_widjet ) = @_;
	my %searches =();
	# Add search string to list if it's not already there
	if(! exists $searches{ $search_string } ) 
	{
		$be_widjet -> insert( 'end', $search_string );
	}
	$searches{ $search_string }++;
  
	# Calculate where to search from, and what to highlight next  
	my $startindex = 'insert';
	if( defined $txt_widjet -> tagRanges( 'curSel' ) ) 
	{ 
		$startindex = 'curSel.first + 1 chars'; 
	}    
	my $index = $txt_widjet -> search( '-nocase', $search_string, $startindex );
	if( $index ne '' ) 
	{
		$txt_widjet -> tagRemove( 'curSel', '1.0', 'end' );
		my $endindex = "$index + " . ( length $search_string ) . " chars";
		$txt_widjet -> tagAdd( 'curSel', $index, $endindex );
		$txt_widjet -> see( $index );
	} 
	else 
	{
		$mw -> bell; 
	}
	$be_widjet -> selectionRange( 0, 'end' ); # Select word we just typed/selected
}

sub	window # ===================================
# Opens a window with label of single .txt file on it.
# ==================================================
{
	my ( $ttl, $txt ) = @_;

	my $win	= new MainWindow( -title => $ttl );
	my $frm	= $win -> Frame() -> pack();
	my $lbl	= q{};
	
	open( IN, $txt );
	while( <IN> )
	{
		chomp;
		$lbl = $frm -> Label( -text => $_ ) -> pack();
	}
	close IN;
}

sub	pdf_handler # ==============================
# 
# ==================================================
{
	my $pdf_w =  new MainWindow;
	$pdf_w -> title( "PDF" );	
	MainLoop();
}

sub	_widget_activator # ========================
# Unlocks an arrey of widgets for further usage.
# ==================================================
{
	my @widgets = @_;
	for( my $i = 0; $i <= $#widgets; $i++ )
	{
		$widgets[ $i ] -> configure( -state => 'active' );
	}
}

sub	_widget_deactivator # ======================
# Locks an arrey of widgets for further usage.
# ==================================================
{
	my @widgets = @_;
	for( my $i = 0; $i <= $#widgets; $i++ )
	{
		$widgets[ $i ] -> configure( -state => 'disabled' );
	}
}