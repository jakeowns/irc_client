#!/usr/bin/perl
use strict;
use warnings;
use Tk;
use IRC;
use Socket qw(PF_INET SOCK_STREAM);
socket( my $sock, PF_INET, SOCK_STREAM, 0 )
  or die "socket: $!";
my $client = IRC->new(
    {
        sock    => $sock,
        server  => "irc.perl.org",
        port    => 6667,
        channel => ['#perl']
    }
);

#$client->connect;
#$client->join_chan;

my $mw        = new MainWindow;
my $main_menu = $mw->Menu();
$mw->configure( -menu => $main_menu );
my $file_menu =
  $main_menu->cascade( -label => "File", -underline => 0, -tearoff => 0 );
$file_menu->command(
    -label     => "Connect",
    -underline => 0,
    -command   => \&menu_connect
);
$file_menu->command(
    -label     => "Exit",
    -underline => 0,
    -command   => sub { exit }
);
$mw->title("IRC Client");
$mw->geometry("500x450");
my $t = $mw->Text( -state => 'disabled' )
  ->pack( -fill => 'both', -expand => 1, -side => 'top' );
my $entry = $mw->Entry()->pack( -side => 'left', -fill => 'x', -expand => 1 );
$entry->focus();
$entry->bind( '<Return>', \&send_sock );
$mw->Button(
    -text    => 'Send',
    -command => \&send_sock,
)->pack;

center_window($mw);

MainLoop;

sub menu_connect {
    $client->connect;
    $mw->fileevent( $sock, 'readable', \&get );
}

sub send_sock {
    my $cmd = $entry->get() . "\n";
    write_t("$cmd");
    $client->write($cmd);
    $entry->delete( 0, length($entry) );
}

sub { $client->connect }
  ub get {
    write_t( $client->read );
}

sub write_t {
    my $str = shift;
    $t->configure( -state => 'normal' );
    $t->insert( 'end', $str );
    $t->see('end');
    $t->configure( -state => 'disabled' );
}

sub center_window {
    my ($window) = @_;
    $window->update;
    my $new_width  = int( ( $window->screenwidth() - $window->width ) / 2 );
    my $new_height = int( ( $window->screenheight() - $window->height ) / 2 );
    $window->geometry(
        $window->width . 'x' . $window->height . "+$new_width+$new_height" );
    $window->update;
    return;
}
__END__
