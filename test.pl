#!/usr/bin/perl
use AnyEvent;
use EV;
use POE qw( Loop::AnyEvent );
use POE::Component::Client::AMQP;
use Data::Dumper;
my $queue_name = 'test_queue2';


Net::AMQP::Protocol->load_xml_spec('amqp0-8.xml');

my $end = AnyEvent->condvar;
my $amq = POE::Component::Client::AMQP->create(
    RemoteAddress => 'd02.home.zxz.li',
);


my $channel = $amq->channel();

my $queue = $channel->queue(
    $queue_name,
    {
        auto_delete => 0, # will remain after all consumers part
        exclusive => 0, # not limited to just this connection
    },
);

my $w = AnyEvent->timer (
    after    => 1,
    interval => 1,
    cb       => sub {
        print "Sending msg\n";
        $queue->publish('test');
    },
);


$end->recv;
