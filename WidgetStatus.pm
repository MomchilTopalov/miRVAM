package WidgetStatus;

use strict;
use Exporter;
use vars qw( @ISA @EXPORT );

@ISA         = qw(Exporter);
@EXPORT      = qw(widgetActivator widgetDeactivator);

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