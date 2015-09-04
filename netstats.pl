#!/usr/bin/perl
use strict;
use warnings;

# originally posted at http://www.perlmonks.org/?node_id=1140950

# thanks to Discipulus from over at PerlMonks who
# added the Usage output, added the remaining statuses
# and added the Getopt::Long functionality

use Getopt::Long;
my @stat = split '\n', `netstat -nat`;


my %statuses = map { $_=> undef } qw( ESTABLISHED  SYN_SENT SYN_RECV FIN_WAIT1
                                  FIN_WAIT2 TIME_WAIT CLOSE CLOSE_WAIT
                                  LAST_ACK LISTEN CLOSING UNKNOWN );
my $given_args = scalar @ARGV;

unless ( GetOptions (
                        "ESTABLISHED" => \$statuses{ESTABLISHED},
                        "SYN_SENT|SS" => \$statuses{SYN_SENT},
                        "SYN_RECV|SR" => \$statuses{SYN_RECV},
                        "FIN_WAIT1|F1" => \$statuses{FIN_WAIT1},
                        "FIN_WAIT2|F2" => \$statuses{FIN_WAIT2},
                        "TIME_WAIT" => \$statuses{TIME_WAIT},
                        "CLOSE|C" => \$statuses{CLOSE},
                        "CLOSE_WAIT|CW" => \$statuses{CLOSE_WAIT},
                        "LAST_ACK" => \$statuses{LAST_ACK},
                        "LISTEN" => \$statuses{LISTEN},
                        "CLOSING" => \$statuses{CLOSING},
                        "UNKNOWN" => \$statuses{UNKNOWN},

                        )) {
                            print "USAGE $0:\n";
                            print while <DATA>;
                            exit 1;
                        }
if ($given_args == 0){map {$statuses{$_}=1} keys  %statuses}

my %data = map {$_ => 0} keys %statuses;

for (@stat){
    s/^\s+//;

    my $status;

    if ($^O eq 'MSWin32'){
        $status = (split)[3];
    }
    else {
        $status = (split)[5];
    }

    next if ! $status;

    $data{$status}++ if defined $data{$status};
}

map { printf "%10s\t$data{$_}\n ",$_} sort grep {defined $statuses{$_}} keys %statuses;

__DATA__
OPTIONS:
Options specifies which status will be reported in the output.
Name of status can be given in upper or lower case and in abbreviated form as
Getopt::Long is used. Additionally you can use SS insetead of SYN_SENT, SR for
SYN_RECV, F1 for FIN_WAIT1, F2 for FIN_WAIT2, C for CLOSE and CW for CLOSE_WAIT.

If no options are given all status will be printed.

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
