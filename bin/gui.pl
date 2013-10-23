#!/usr/bin/perl
use strict;
use warnings;
use lib qw(./lib ../lib ./local/lib/perl5/ ../local/lib/perl5/);
use Tk;
use Tk::DynaTabFrame;
use Socket qw(PF_INET SOCK_STREAM);
use IRC;
use IRC::CMD;

my ( %chans, $mw, $mw_button ,$main_menu ,$file_menu ,$entry ,$tab_mw, $sock, $client);

#$client->connect;
#$client->join_chan;

__PACKAGE__->run unless caller();

sub run {
	init();
	pack_gui();
	MainLoop;
}

sub init {
	socket( $sock, PF_INET, SOCK_STREAM, 0 )
	  or die "socket: $!";
	$client = IRC->new(
	    {
		sock    => $sock,
		server  => shift || "irc.perl.org",
		port    => 6667,
		nick    => "foobar1241",
		channel => ['#perl']
	    }
	);
	$mw        = new MainWindow;
	$main_menu = $mw->Menu();
	$mw->geometry("500x450");
	$mw->configure( -menu => $main_menu, );
	$file_menu = $main_menu->cascade(
	    -label     => "File",
	    -underline => 0,
	    -tearoff   => 0,
	);
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

	$entry = $mw->Entry( -state => 'disabled' );
	$tab_mw =
	  $mw->DynaTabFrame( -tabclose => \&tab_close, -raisecmd => \&refocus );

	new_tab('main');

	$entry->bind( '<Return>', \&send_sock );
	$mw_button = $mw->Button(
	    -text    => 'Send',
	    -command => \&send_sock,
	);

	center_window($mw);
}

sub pack_gui {
	$tab_mw->pack( -side => 'top', -expand => 1, -fill => 'both' );
	$entry->pack(
	    -side   => 'left',
	    -fill   => 'x',
	    -expand => 1,
	);
	$mw_button->pack( -side => "right", );
}


#begin sub
sub tab_close {
    my ( $obj, $caption ) = @_;
    if ( $caption ne "main" ) {
        $obj->delete($caption);
	delete $chans{$caption};
        $client->write("PART #$caption\r\n");
    } else {
	exit if scalar(keys %chans) == 1;
    }
}

sub refocus {
    $entry->focus();
}

sub menu_connect {
    $client->connect;
    $mw->fileevent( $sock, 'readable', \&get );
    $entry->configure( -state => 'normal' );
    refocus();
}

sub send_sock {
    $_ = $entry->get();
    s/\x{d}//g;    #remove metachars
    my $cmd = $_;
    if ( $cmd ne "" ) {
        if ( $cmd =~ m/^\/(.*)$/ ) {
            $cmd = IRC::CMD->get($1);
            if ( $cmd =~ m/^join #(.*)$/ ) {
		($chans{$1}) ? $tab_mw->raise($1) : new_tab($1); 
                refocus();
            }
            $client->write( $cmd . "\r\n" );
        }
        else {
            my $curr = $tab_mw->raised_name();
            $client->write("PRIVMSG #$curr :$cmd\r\n");
            write_t( $curr, $client->get_nick . ": " . $cmd . "\n" );
        }
    }

    $entry->delete( 0, 'end' );
}

sub get {
    $_ = $client->read;
    s/\x{d}//g;    #remove metachars
    my $tab_is = 'main';    #default output
    next unless defined($_);    #ignore blank input
    if (m/^:(.*)!~.* PRIVMSG #(.*) :(.*\n)$/) {
        write_t( $2, "$1: $3" );
        $tab_is = $2;

    }
    else {
        write_t( $tab_is, $_ );
    }
    $tab_mw->flash($tab_is) if ( $tab_is ne $tab_mw->raised_name() );
}

sub write_t {
    my $x = $chans{ $_[0] };
    $x->configure( -state => 'normal' );
    $x->insert( 'end', $_[1] );
    $x->see('end');
    $x->configure( -state => 'disabled' );
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

sub new_tab {
    $chans{ $_[0] } = $tab_mw->add(
        -caption  => "$_[0]",
        -tabcolor => 'white',
        -hidden   => 0
      )->Scrolled(
        'Text',
        -scrollbars => 'osoe',
        -foreground => 'black',
        -background => 'white',
        -wrap       => 'word',
        -state      => 'disabled'
      );
    $chans{ $_[0] }
      ->pack( -fill => 'both', -expand => 1, -side => 'top', -anchor => 'nw' );
}
__END__
