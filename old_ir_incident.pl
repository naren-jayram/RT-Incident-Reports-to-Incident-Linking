# CONFIGURATION
my $queue = 'Incidents';                # Destination Queue; Matching tickets from source queue is linked to appropriate incident ticket in this queue
my $src_queue = 'IDS Alerts';           # Source Queue 
my $cf_name = 'Incident Condition';     # Custom field name in Destination Queue, which acts as a lookup for tickets created in Source Queue 
my $cf_name_sip = 'Source IP';          # Custom field name in Destination Queue
my $cf_name_dip = 'Destination IP';     # Custom field name in Destination Queue
my $cf_name_sig = 'Signature_Name';     # Custom field name in Destination Queue
my $time_frame = '10 hours ago';      # Time Frame to link old tickets  
my $inc_condn = $self->TicketObj->CustomFieldValuesAsString('Incident Condition');
# END CONFIGURATION

RT::LoadConfig();
RT::Init();
my $tx = RT::Tickets->new($RT::SystemUser);
my $cf = RT::CustomField->new($RT::SystemUser);
my $q  = RT::Queue->new($RT::SystemUser);
$q->Load($queue);
$cf->LoadByNameAndQueue(Queue => $q->Id, Name => $cf_name);


unless( $cf->id ) 
{
  die "Could not load custom field, Incident Condition";
}


if ($inc_condn eq 'sig.name+dst.ip')
{
    my $cf_value_sig = $self->TicketObj->CustomFieldValuesAsString($cf_name_sig);
    my $cf_value_dip = $self->TicketObj->CustomFieldValuesAsString($cf_name_dip);
    my $concat = "sig.name+dst.ip-" . $cf_value_sig . "-" . $cf_value_dip;
    my $new_cf_value = $self->TicketObj->AddCustomFieldValue(Field => $cf->Id, Value => $concat);

    my $ir_tx = RT::Tickets->new($RT::SystemUser);
    my $ir_cf = RT::CustomField->new($RT::SystemUser);
    my $ir_q  = RT::Queue->new($RT::SystemUser);
    $ir_q->Load($src_queue);
    $ir_cf->LoadByNameAndQueue(Queue => $ir_q->Id, Name => $cf_name_sig);
    my ($status, $msg) = $ir_tx->FromSQL(qq[queue="$src_queue" and Status="new" and Created > "$time_frame" and "CF.{$cf_name_sig}" = '$cf_value_sig' and "CF.{$cf_name_dip}" = '$cf_value_dip']);
    $RT::Logger->error("Database query Failed : $msg - $status");


    my $i=0;
    while (my $st = $ir_tx->Next)
    {   
        print "Processing Incident Report#: status - new" . ++$i . "\n";
        print "Incident found!" . "\n"; 
        $st->SetStatus('open');
        my ($reason, $message) = $st->AddLink( Type => 'MemberOf', Target => $self->TicketObj->Id );
        $RT::Logger->error("Linking Failed : $message - $reason");
        print "Link completed!"  . "\n";
    }
}



elsif ($inc_condn eq 'sig.name+src.ip')
{
    my $cf_value_sig = $self->TicketObj->CustomFieldValuesAsString($cf_name_sig);
    my $cf_value_sip = $self->TicketObj->CustomFieldValuesAsString($cf_name_sip);
    my $concat = "sig.name+src.ip-" . $cf_value_sig . "-" . $cf_value_sip;
    my $new_cf_value = $self->TicketObj->AddCustomFieldValue(Field => $cf->Id, Value => $concat);

    my $ir_tx = RT::Tickets->new($RT::SystemUser);
    my $ir_cf = RT::CustomField->new($RT::SystemUser);
    my $ir_q  = RT::Queue->new($RT::SystemUser);
    $ir_q->Load($src_queue);
    $ir_cf->LoadByNameAndQueue(Queue => $ir_q->Id, Name => $cf_name_sig);
    my ($status, $msg) = $ir_tx->FromSQL(qq[queue="$src_queue" and Status="new" and Created > "$time_frame" and "CF.{$cf_name_sig}" = '$cf_value_sig' and "CF.{$cf_name_sip}" = '$cf_value_sip']);
    $RT::Logger->error("Database query Failed : $msg - $status");


    my $i=0;
    while (my $st = $ir_tx->Next)
    {   
        print "Processing Incident Report#: status - new" . ++$i . "\n";
        print "Incident found!" . "\n"; 
        $st->SetStatus('open');
        my ($reason, $message) = $st->AddLink( Type => 'MemberOf', Target => $self->TicketObj->Id );
        $RT::Logger->error("Linking Failed : $message - $reason");
        print "Link completed!"  . "\n";
    }
}


