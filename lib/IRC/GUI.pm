#!/usr/bin/perl
use strict;
use warnings;

package IRC::GUI;
use Tk;
use Tk::DynaTabFrame;
use IRC;
use IRC::CMD;
use Data::Dumper;

my (
    %chans,         $mw,           $mw_button,  $main_menu,
    $file_menu,     $entry,        $tab_mw,     $client,
    $connect_frame, $server_entry, $nick_entry, $connect_button
);

__PACKAGE__->run unless caller();

sub run {
    init_gui();
    pack_gui();
    MainLoop;
}

sub init {
    $client = IRC->new(
        {
            server  => $server_entry->get(),
            port    => 6667,
            nick    => $nick_entry->get(),
            channel => ['#perl']
        }
    );
}

sub init_gui {
    $mw = new MainWindow;
    $mw->geometry("500x450");
    $mw->title("IRC Client");

    $main_menu = $mw->Menu();

    $mw->configure( -menu => $main_menu, );
    $file_menu = $main_menu->cascade(
        -label     => "File",
        -underline => 0,
        -tearoff   => 0,
    );
    $file_menu->command(
        -label     => "Exit",
        -underline => 0,
        -command   => sub { exit }
    );

    $connect_frame = $mw->Frame();
    $server_entry = $connect_frame->Entry( -state => 'normal', );
    $server_entry->insert( 'end', 'irc.freenode.net' );

    $nick_entry = $connect_frame->Entry( -state => 'normal', );
    $nick_entry->insert( 'end', 'guest12415' );

    $connect_button = $connect_frame->Button(
        -text    => 'Connect',
        -command => \&connect_action,
    );

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
    $connect_frame->pack( -side => 'top', -fill => 'x' );

    $connect_frame->Label( -text => 'Server' )->pack( -side => 'left' );
    $server_entry->pack( -side => 'left' );
    $connect_frame->Label( -text => 'Nickname' )->pack( -side => 'left' );
    $nick_entry->pack( -side => 'left' );

    $connect_button->pack( -side => 'right' );
    $tab_mw->pack( -side => 'top', -expand => 1, -fill => 'both' );
    $entry->pack(
        -side   => 'left',
        -fill   => 'x',
        -expand => 1,
    );
    $mw_button->pack( -side => "right", );
}

sub con_switch {
    my $state =
        ( $connect_button->cget( -text ) eq "Connect" )
      ? [ "Disconnect", "disabled" ]
      : [ "Connect", "normal" ];
    $connect_button->configure( -text => @$state[0] );
    $server_entry->configure( -state => @$state[1] );
    $nick_entry->configure( -state => @$state[1] );
    return ( @$state[0] eq "Connect" ) ? 0 : 1;
}

#begin sub
sub tab_close {
    my ( $obj, $caption ) = @_;
    if ( $caption ne "main" ) {
        $obj->delete($caption);
        delete $chans{$caption};
        if( $caption =~ /^#/ ) {
            $client->write("PART $caption\r\n");
        }
    }
    else {
        exit if scalar( keys %chans ) == 1;
    }
}

sub refocus {
    $entry->focus();
}

sub connect_action {
    if (con_switch) {
        init();
        $client->connect;
        $mw->fileevent( $client->sock, 'readable', => \&get);
        $entry->configure( -state => 'normal' );
        refocus();
    }
    else {
        $client->write( "DISCONNECT" . "\r\n" );
        $entry->configure( -state => 'disable' );
	$client->DEMOLISH;
        undef $client;
    }
}

sub send_sock {
    $_ = $entry->get();
    s/\x{d}//g;    #remove metachars
    my $cmd = $_;
    if ( $cmd ne "" ) {
        if ( $cmd =~ m/^\/(.*)$/ ) {
            $cmd = IRC::CMD->get($1);
            if ( $cmd =~ m/^join (#.*)$/ ) {
                ( $chans{$1} ) ? $tab_mw->raise($1) : new_tab($1);
                refocus();
            }
            $client->write( $cmd . "\r\n" );
        }
        else {
            my $curr = $tab_mw->raised_name();
            $client->write("PRIVMSG $curr :$cmd\r\n");
            write_t( $curr, $client->nick . ": " . $cmd . "\n" );
        }
    }

    $entry->delete( 0, 'end' );
}

sub get {
    my $str = $client->read;
    return unless defined $str and length($str);
    my $tab_is = 'main';    #default output
    my $parsed =  IRC::CMD->parse($str);
    print Dumper($parsed);
    my $cmd  = $parsed->{command};
    if ( defined($cmd) and $cmd eq "PRIVMSG" ) {
	my ( $chan, $msg ) = @{ $parsed->{params} };
	$parsed->{prefix} =~ /(.*)!~?/;
        if( $chan eq $client->nick ) {
            $chan = $1;
        }
        write_t( $chan, "$1: $msg" . "\n" );
        $tab_is = $chan;
    }
    else {
        $_ = $str;
        s/\x{d}//g;    #remove metachars
        s/:.*?:(.*\n)/$1/g;
        write_t( $tab_is, $_ );
    }
    $tab_mw->flash($tab_is) if ( $tab_is ne $tab_mw->raised_name() );
}

sub write_t {
    new_tab($_[0]) unless $chans{ $_[0] };
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
