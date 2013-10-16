#!/usr/bin/perl
use strict;
use warnings;
use Tk;
use Tk::DynaTabFrame;
use IRC;
use IRC::CMD;
use Socket qw(PF_INET SOCK_STREAM);

socket( my $sock, PF_INET, SOCK_STREAM, 0 )
  or die "socket: $!";
my $client = IRC->new(
    {
        sock    => $sock,
        server  => "irc.perl.org",
        port    => 6667,
        nick    => "foobar",
        channel => ['#perl']
    }
);

my %chans;

#$client->connect;
#$client->join_chan;

my $mw        = new MainWindow;
my $main_menu = $mw->Menu();
$mw->geometry("500x450");
$mw->configure( -menu => $main_menu, );
my $file_menu = $main_menu->cascade(
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

my $tab_mw =
  $mw->DynaTabFrame()->pack( -side => 'top', -expand => 1, -fill => 'both' );

new_tab('main');

my $entry = $mw->Entry()->pack(
    -side   => 'left',
    -fill   => 'x',
    -expand => 1,
);
$entry->focus();
$entry->bind( '<Return>', \&send_sock );
$mw->Button(
    -text    => 'Send',
    -command => \&send_sock,
)->pack( -side => "right", );

center_window($mw);

MainLoop;

sub menu_connect {
    $client->connect;
    $mw->fileevent( $sock, 'readable', \&get );
}

sub send_sock {
    $_ = $entry->get();
    s/\x{d}//g;    #remove metachars
    my $cmd = $_;
    if ( $cmd =~ m/^\/(.*)$/ ) {
        $cmd = IRC::CMD->get($1);
        if ( $cmd =~ m/^join #(.*)$/ ) {
            new_tab($1);
        }
        $client->write( $cmd . "\r\n" );
    }
    else {
        my $curr = $tab_mw->raised_name();

        #s/\x{d}//g; #remove metachars
        $client->write("PRIVMSG #$curr :$cmd\r\n");
        write_t( $curr, "ME: " . $cmd . "\n" );
    }

    #write_t($t, "$cmd");
    $entry->delete( 0, 'end' );
}

sub get {
    $_ = $client->read;

    s/\x{d}//g;    #remove metachars
    if ($_) {
        if (m/^:(.*)!~.* PRIVMSG #(.*) :(.*\n)$/) {
            write_t( "$2", "$1: $3" );
        }
        else {
            write_t( 'main', "$_" );
        }
    }
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
        -tabcolor => 'red',
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
