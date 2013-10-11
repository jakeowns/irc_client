#!/usr/bin/perl
use strict;
use warnings;
use Tk;
use IRC;
use Socket qw(PF_INET SOCK_STREAM);
socket( my $sock, PF_INET, SOCK_STREAM, 0 )
  or die "socket: $!";
my $nick = join( '', map { ( "a" .. "z" )[ rand 26 ] } 1 .. 8 );
my $client = IRC->new( $sock, "irc.freenode.net", 6667, $nick );
$client->connect;
$client->login;

my $mw = new MainWindow;
$mw->title("IRC Client");
$mw->geometry("500x450");
my $t = $mw->Text()->pack( -fill => 'both', -expand => 1, -side => 'top' );
my $entry = $mw->Entry()->pack( -side => 'left', -fill => 'x', -expand => 1 );
$entry->focus();
$entry->bind('<Return>', \&send_sock); 
$mw->Button(
    -text    => 'Send',
    -command => \&send_sock,
)->pack;
$mw->fileevent( $sock, 'readable', \&get );
MainLoop;

sub send_sock {
    my $cmd = $entry->get() . "\n";
    write_t("$cmd");
    $client->write($cmd);
    $entry->delete(0, length($entry));
}

sub get {
    write_t( $client->read );
}

sub write_t {
    my $str = shift;
    $t->insert( 'end', $str );
    $t->see('end');
}
__END__
