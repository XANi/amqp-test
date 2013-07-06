#!/usr/bin/perl
use AnyEvent;
use EV;
use POE qw( Loop::AnyEvent );
use POE::Component::Client::AMQP;
use Data::Dumper;
my $queue_name = 'tt';


Net::AMQP::Protocol->load_xml_spec('amqp0-9-1.xml');

my $end = AnyEvent->condvar;
my $amq = POE::Component::Client::AMQP->create(
    RemoteAddress => 'd02.home.zxz.li',
);


my $channel = $amq->channel();
print "Declaring exchange\n";
$channel->send_frames(
    Net::AMQP::Protocol::Exchange::Declare->new(
        exchange => 'test_topic',
        type => 'topic',
    ),
);
#print "binding queue to exchange\n";
#$channel->send_frames(
#    Net::AMQP::Protocol::Queue::Bind->new(
#        queue => 'tt',
#        exchange => 'test_topic',
#        routing_key => 'test.topic',
#    ),
#);


# print "Creating queue\n";
# my $queue = $channel->queue(
#     $queue_name,
#     {
#         auto_delete => 0, # will remain after all consumers part
#         exclusive => 0, # not limited to just this connection
#         durable => 0,
#         arguments => {
#             'x-message-ttl' => 20 * 1000,
#             'x-expires' => 60 * 1000,
#             'x-ha-policy' => 'all',
#         },
#     },
#);
print "Ready to send msgs\n";
my $w = AnyEvent->timer (
    after    => 1,
    interval => 1,
    cb       => sub {
        print "Sending msg\n";
        foreach(my $a =0 ; $a<1000 ; ++$a) {
        $channel->send_frames(
            $amq->compose_basic_publish(
                'asd',
                exchange => 'test_topic',
                routing_key => 'test.topic',
            )
        );

#            $queue->publish('test');
        }
    },
);


$end->recv;
