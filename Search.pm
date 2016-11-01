package Search;

use strict;
use Exporter;
use vars qw( @ISA @EXPORT );

@ISA 	= qw( Exporter );
@EXPORT	= qw( search );

sub	search # ===================================
# Demo search engine customized from an example.
# ==================================================
{
	my ( $search_string, $be_widget, $txt_widget ) = @_;
	
	my %search_hash = ();
	# Add search string to list if it's not already there
	if( ! exists $search_hash{ $search_string } ) 
	{
		$be_widget -> insert( 'end', $search_string );
	}
	$search_hash{ $search_string }++;
  
	# Calculate where to search from, and what to highlight next  
	my $start_index = 'insert';
	if( defined $txt_widget -> tagRanges( 'curSel' ) ) 
	{ 
		$start_index = 'curSel.first + 1 chars'; 
	}    
	my $index = $txt_widget -> search( '-nocase', $search_string, $start_index );
	if( $index ne '' ) 
	{
		$txt_widget -> tagRemove( 'curSel', '1.0', 'end' );
		my $endindex = "$index + " . ( length $search_string ) . " chars";
		$txt_widget -> tagAdd( 'curSel', $index, $endindex );
		$txt_widget -> see( $index );
	} 
	else 
	{
		print chr ( 7 );
	}
	# Selects the word just typed/selected word
	$be_widget -> selectionRange( 0, 'end' );
}
1;