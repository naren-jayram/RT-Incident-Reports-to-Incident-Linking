#!/home/perl/bin/perl
use strict;
use warnings;
use lib qw(/opt/rt4/lib);              # This depends on your installation paths. In this case RT resides in /opt
use RT;
use RT::Queues;
use RT::Tickets;
use Data::Dumper;
use RT::Link;

# CONFIGURATION
my $queue = 'Incidents';               # Destination Queue
my $cf_name = 'Incident Condition';    # Concerned Custom Field name in the destination queue
# END of CONFIGURATION

# Variables
my $type = 'MemberOf';
my @concat;
# End of Variables

RT::LoadConfig();
RT::Init();
my $tx = RT::Tickets->new($RT::SystemUser);
my $cf = RT::CustomField->new($RT::SystemUser);
my $q  = RT::Queue->new($RT::SystemUser);
my $sip = $self->TicketObj->CustomFieldValuesAsString('Source IP');
my $dip = $self->TicketObj->CustomFieldValuesAsString('Destination IP');
my $sig = $self->TicketObj->CustomFieldValuesAsString('Signature_Name');

my $concat_sig_dip = "sig.name+dst.ip-" . $sig . "-" . $dip;
push(@concat, $concat_sig_dip);
my $concat_sig_sip = "sig.name+src.ip-" . $sig . "-" . $sip;
push(@concat, $concat_sig_sip);

foreach (@concat)
{
    $tx->FromSQL(qq[queue="$queue" and Status="open" and "cf.$queue.{$cf_name}" = '$_']);
    $q->Load($queue);
    $cf->LoadByNameAndQueue(Queue => $q->Id, Name => $cf_name);
    unless( $cf->id ) 
    {
        # queue 0 is special case and is a synonym for global queue
        $cf->LoadByNameAndQueue( Name => $cf_name, Queue => '0' );
    }
    unless( $cf->id ) 
    {
        print "No field $cf_name in queue ". $q->Name;
        die "Could not load custom field";
    }

    my $i=0;
    while (my $t = $tx->Next) 
    {
        print "Processing/ Linking record #" . ++$i . "\n";
        my $cf_value = $t->CustomFieldValuesAsString($cf_name);
        if ($_ eq $cf_value)
        {   
            print "Incident found!" ;
            $self->TicketObj->SetStatus($t->Status);
            $self->TicketObj->SetOwner($t->Owner);
            my ($status, $msg) = $self->TicketObj->AddLink( Type => 'MemberOf', Target => $t->Id );
            #link_tickets (src => $self->TicketObj->Id, dst => $t->Id, link_type => $type);
            $RT::Logger->error("Couldn't link: $msg");
            print "Link completed!" . ++$i . "\n";
        }
    
    }
}