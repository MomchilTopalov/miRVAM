package Window;

use strict;
use Exporter;
use vars qw( @ISA @EXPORT );

@ISA	= qw( Exporter );
@EXPORT	= qw( window );

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
1;