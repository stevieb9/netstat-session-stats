#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;

# netstats.pl

my $VERSION = 0.03;

# originally posted at http://www.perlmonks.org/?node_id=1140950

# thanks to Discipulus from over at PerlMonks who
# added the Usage output, added the remaining statuses
# and added the Getopt::Long functionality

my $platform = $^O;

my %statuses = map { $_=> undef } qw( ESTABLISHED  SYN_SENT SYN_RECV FIN_WAIT1
                                  FIN_WAIT2 TIME_WAIT CLOSE CLOSE_WAIT
                                  LAST_ACK LISTEN CLOSING UNKNOWN );
my $auto = 0;
my $given_args = scalar @ARGV;

if (grep {$_ =~ /-a|--auto/ } @ARGV){
    $given_args -= 2;
}

unless ( GetOptions (
                        "ESTABLISHED|E" => \$statuses{ESTABLISHED},
                        "SYN_SENT|SS" => \$statuses{SYN_SENT},
                        "SYN_RECV|SR" => \$statuses{SYN_RECV},
                        "FIN_WAIT1|F1" => \$statuses{FIN_WAIT1},
                        "FIN_WAIT2|F2" => \$statuses{FIN_WAIT2},
                        "TIME_WAIT|TW" => \$statuses{TIME_WAIT},
                        "CLOSE|C" => \$statuses{CLOSE},
                        "CLOSE_WAIT|CW" => \$statuses{CLOSE_WAIT},
                        "LAST_ACK|LA" => \$statuses{LAST_ACK},
                        "LISTEN|L" => \$statuses{LISTEN},
                        "CLOSING|CG" => \$statuses{CLOSING},
                        "UNKNOWN|U" => \$statuses{UNKNOWN},
                        "auto|a=i" => \$auto,
                        "help" => \&help,
                        )) {
                            help();
                        }

if ($auto){
    while (1){
        my $clear = $platform eq 'MSWin32' 
          ? 'cls' 
          : 'clear';
        system($clear);
        netstat();
        sleep($auto);
    }
}
else {
    netstat();
}

sub netstat {

    my @stat = split '\n', `netstat -nat`;
   
    if ($given_args == 0){map {$statuses{$_}=1} keys  %statuses}

    my %data = map {$_ => 0} keys %statuses;

    for (@stat){
        s/^\s+//;

        my $status;

        if ($platform eq 'MSWin32'){
            $status = (split)[3];
        }
        else {
            $status = (split)[5];
        }

        next if ! $status;

        $data{$status}++ if defined $data{$status};
    }

    map { printf "%10s\t$data{$_}\n ",$_} 
        sort grep {defined $statuses{$_}} 
        keys %statuses;
}
sub help {
    print "\nUSAGE $0:\n";
    print <<EOF;

OPTIONS:

Options specifies which status will be reported in the output.
Name of status can be given in upper or lower case.

If no options are given all statuses will be printed.

You can use the following option abbreviations:

-E  for --ESTABLISHED
-SS for --SYN_SENT
-SR for --SYN_RECV
-F1 for --FIN_WAIT1 
-F2 for --FIN_WAIT2 
-TW for --Time_WAIT
-C  for --CLOSE
-CW for --CLOSE_WAIT
-LA for --LAST_ACK
-L  for --LISTEN
-CG for --CLOSING
-U  for --UNKNOWN
-h  for --help

The special -a or --auto parameter takes an integer. This will
cause the program to refresh the screen and output every integer seconds.

Here a brief description of status meanings:

   ESTABLISHED
          The socket has an established connection.
   SYN_SENT
          The socket is actively attempting to establish a connection.
   SYN_RECV
          A connection request has been received from the network.
   FIN_WAIT1
          The socket is closed, and the connection is shutting down.
   FIN_WAIT2
          Connection is closed, and the socket is waiting for  a  shutdown
          from the remote end.
   TIME_WAIT
          The socket is waiting after close to handle packets still in the
          network.
   CLOSE  The socket is not being used.
   CLOSE_WAIT
          The remote end has shut down, waiting for the socket to close.
   LAST_ACK
          The remote end has shut down, and the socket is closed.  Waiting
          for acknowledgement.
   LISTEN The  socket is listening for incoming connections.  Such sockets
          are  not  included  in  the  output  unless  you   specify   the
          --listening (-l) or --all (-a) option.
   CLOSING
          Both  sockets are shut down but we still don't have all our data
          sent.
   UNKNOWN
          The state of the socket is unknown.

You can get further information by calling "perldoc netstats.pl".

EOF
}
sub _vim_placeholder {}
__END__

=head1 NAME

netstats.pl

=head1 DESCRIPTION

Display C<netstat> socket status information on Win/*nix platforms.

=head1 README

This script displays the C<netstat> socket status counts on Windows and Unix
platforms.

    # prints all statuses once, and exits

    ./netstat.pl

    # print only specific statuses, and exit

    ./netstat.pl --ARG1 --ARG2 # displays only select statuses

    # clears screen, loops and prints output every N seconds
    # works with specific status arguments

    ./netstat.pl --auto N

OPTIONS:

Options specifies which status will be reported in the output.
Name of status can be given in upper or lower case.

If no options are given all statuses will be printed.

You can use the following option abbreviations:

    -E  for --ESTABLISHED
    -SS for --SYN_SENT
    -SR for --SYN_RECV
    -F1 for --FIN_WAIT1 
    -F2 for --FIN_WAIT2 
    -TW for --Time_WAIT
    -C  for --CLOSE
    -CW for --CLOSE_WAIT
    -LA for --LAST_ACK
    -L  for --LISTEN
    -CG for --CLOSING
    -U  for --UNKNOWN

    -a  for --auto
    -h  for --help

Here a brief description of status meanings:

   ESTABLISHED
          The socket has an established connection.
   SYN_SENT
          The socket is actively attempting to establish a connection.
   SYN_RECV
          A connection request has been received from the network.
   FIN_WAIT1
          The socket is closed, and the connection is shutting down.
   FIN_WAIT2
          Connection is closed, and the socket is waiting for  a  shutdown
          from the remote end.
   TIME_WAIT
          The socket is waiting after close to handle packets still in the
          network.
   CLOSE  The socket is not being used.
   CLOSE_WAIT
          The remote end has shut down, waiting for the socket to close.
   LAST_ACK
          The remote end has shut down, and the socket is closed.  Waiting
          for acknowledgement.
   LISTEN The  socket is listening for incoming connections.  Such sockets
          are  not  included  in  the  output  unless  you   specify   the
          --listening (-l) or --all (-a) option.
   CLOSING
          Both  sockets are shut down but we still don't have all our data
          sent.
   UNKNOWN
          The state of the socket is unknown.


=pod OSNAMES

linux
MSWin32
msys

=pod SCRIPT CATEGORIES

Networking
UNIX/System_administration
Win32/Utilities

=pod PREREQUISITES

Getopt::Long

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 THANKS TO

Discipulus from over at PerlMonks for adding the usage/help output,
added the C<Getopt::Long> functionality, and added the remaining
statuses that weren't included in the original posting of the script.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Devel::Examine::Subs

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it under the terms of either: the GNU General Public License as 
published by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


