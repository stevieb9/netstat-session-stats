#!/usr/bin/perl
use strict;
use warnings;

my @stat = split '\n', `netstat -nat`;

my @wanted = qw(
                ESTABLISHED
                TIME_WAIT
                CLOSED_WAIT
                SYN_SENT
                SYN_RECV
            );

my %data = map {$_ => 0} @wanted;

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

print "$data{$_}\n" for @wanted;
