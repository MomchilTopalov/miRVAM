package SetTitle;

use strict;
use Exporter;
use vars qw( @ISA @EXPORT );

@ISA	= qw( Exporter );
@EXPORT	= qw( setTitle );

sub	setTitle # =================================
# 
# ==================================================
{
	my ( $file_name, $sufix ) = @_;
	
	$file_name =~ s/.fa//		if(  $file_name =~ /.fa/ );
	$file_name =~ s/.fas//		if(  $file_name =~ /.fas/ );
	$file_name =~ s/.fasta//	if(  $file_name =~ /.fasta/ );
	$file_name =~ s/.txt// 		if(  $file_name =~ /.txt/ );
	
	return( "$file_name" . "$sufix" );	
}
1;