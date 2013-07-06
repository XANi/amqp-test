#!/usr/bin/perl
use AnyEvent;
use EV;
use POE qw( Loop::AnyEvent );
use POE::Component::Client::AMQP;
use Data::Dumper;
use Net::Domain qw(hostname hostfqdn hostdomain domainname);
my $queue_name = 'tt';


Net::AMQP::Protocol->load_xml_spec('amqp0-9-1.xml');

my $end = AnyEvent->condvar;
my $amq = POE::Component::Client::AMQP->create(
    RemoteAddress => 'd03.home.zxz.li',
);

my $i;

$queue_name .= '_' . hostfqdn() . ':' . $$;
 my $channel = $amq->channel();
# print "binding queue to exchange\n";
# $channel->send_frames(
#     Net::AMQP::Protocol::Queue::Bind->new(
#         queue => $queue_name,
#         exchange => 'test_topic',
#         routing_key => 'test.topic',
#     ),
#);


my $queue = $channel->queue($queue_name,
                        {
                            auto_delete => 0,
                            exclusive => 0,
                            durable => 0,
                            arguments => {
                                'x-message-ttl' => 20 * 1000,
                                'x-expires' => 60 * 1000,
                                'x-ha-policy' => 'all',
                            },
                        });
print "binding queue [$queue_name] to exchange\n";
$channel->send_frames(
    Net::AMQP::Protocol::Queue::Bind->new(
        queue => $queue_name,
        exchange => 'test_topic',
        routing_key => 'test.topic',
    ),
);

$queue->subscribe(
    sub {
        my ($payload, $meta) = @_;
        my $reply_to = $meta->{header_frame}->reply_to;
       # print ++$i .  " Msg received: $payload\n";
#        print Dumper $payload;
#        print Dumper $meta;
#        $amq->channel(1)->queue($reply_to)->publish("Message received");
    }
);

$end->recv;
