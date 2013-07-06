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
    RemoteAddress => 'd01.home.zxz.li',
);


$amq->channel(1)->queue($queue_name, { auto_delete => 0,  exclusive => 0})->subscribe(
    sub {
        my ($payload, $meta) = @_;
        my $reply_to = $meta->{header_frame}->reply_to;
        print "Msg received: $payload\n";
#        print Dumper $payload;
#        print Dumper $meta;
#        $amq->channel(1)->queue($reply_to)->publish("Message received");
    }
);

$end->recv;
