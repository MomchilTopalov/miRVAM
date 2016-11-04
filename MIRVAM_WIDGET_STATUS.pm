package MIRVAM_WIDGET_STATUS;

use strict;
use Exporter;
use vars qw( @ISA @EXPORT );

@ISA         = qw(Exporter);
@EXPORT      = qw(widgetDefaultState widgetActivator widgetDeactivator);

sub	widgetDefaultState # =======================
# If a widget has a status at all, it should be 'disabled' 
# by default in order to be (un)locked only when it is needed.
# ==================================================
{
	my $default_state ='disabled' ;
	return $default_state;
}

sub	widgetActivator # ==========================
# Unlocks an array of widgets for further usage.
# ==================================================
{
	my @widgets = @_;
	for( my $i = 0; $i <= $#widgets; $i++ )
	{
		$widgets[ $i ] -> configure( -state => 'active' );
	}
}

sub	widgetDeactivator # ========================
# Locks an array of widgets for further usage.
# ==================================================
{
	my @widgets = @_;
	for( my $i = 0; $i <= $#widgets; $i++ )
	{
		$widgets[ $i ] -> configure( -state => 'disabled' );
	}
}
1;