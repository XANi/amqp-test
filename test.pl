#!/usr/bin/perl
use AnyEvent;
use EV;
use POE qw( Loop::AnyEvent );
use POE::Component::Client::AMQP;
use Data::Dumper;
my $queue_name = 'test_queue4';


Net::AMQP::Protocol->load_xml_spec('amqp0-9-1.xml');

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
        durable => 0,
        arguments => {
            'x-message-ttl' => 20 * 1000,
            'x-expires' => 60 * 1000,
            'x-ha-policy' => 'all',
        },
    },
);

my $w = AnyEvent->timer (
    after    => 1,
    interval => 1,
    cb       => sub {
        print "Sending msg\n";
        foreach(my $a =0 ; $a<1000 ; ++$a) {
            $queue->publish('test');
        }
    },
);


$end->recv;
