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
    RemoteAddress => 'd01.home.zxz.li',
);

my $i;
$amq->channel(1)->queue($queue_name,
                        {
                            auto_delete => 0,
                            exclusive => 0,
                            durable => 0,
                            arguments => {
                                'x-message-ttl' => 20 * 1000,
                                'x-expires' => 60 * 1000,
                                'x-ha-policy' => 'all',
                            },
                        })->subscribe(
    sub {
        my ($payload, $meta) = @_;
        my $reply_to = $meta->{header_frame}->reply_to;
#        print ++$i .  " Msg received: $payload\n";
#        print Dumper $payload;
#        print Dumper $meta;
#        $amq->channel(1)->queue($reply_to)->publish("Message received");
    }
);

$end->recv;
