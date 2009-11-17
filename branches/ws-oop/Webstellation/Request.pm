package Webstellation::Request;

use strict;
use warnings;

use JSON;

use Webstellation::Status;

sub new {
	my $inv = shift;
	my $class = ref $inv || $inv;
	my $self = { dbname => shift };
	return bless $self, $class;
}

sub process {
	my $self = shift;
	my $data;
	my $action = ucfirst $data->{action} || return 'formatError';	
	my $obj;
	return 'formatError' unless eval {
		no strict 'refs';
		$obj = &{"Webstellation::Request::${action}::new"}();
	};
	return $obj->run($data);
}

sub dispatch {
	my $self = shift;
	my ($res, $data);
   	if(eval { $data = decode_json shift }) { $res = $self->process($data) }
    else { $res = { result => 'formatError' } }
	return encode_json $res;
}

1;
