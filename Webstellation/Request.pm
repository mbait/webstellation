package Webstellation::Request;

use strict;
use warnings;

use JSON;
use Data::Dumper;

use Webstellation::DB;
use Webstellation::Request::ClearAll;
use Webstellation::Request::Register;
use Webstellation::Request::GetUsers;
use Webstellation::Request::Logout;
use Webstellation::Request::JoinGame;
use Webstellation::Request::GetMaps;

sub new {
	my $inv = shift;
	my $class = ref $inv || $inv;
	my $self = { dbname => shift };
	return bless $self, $class;
}

sub process {
	my ($self, $data) = @_;
	my $action = ucfirst $data->{action} || return { 
		result => 'formatError', 
		message => 'Action is not defined' 
	};
	my $obj;
	eval {
		no strict 'refs';
		$obj =  "Webstellation::Request::$action"->new($data);
	} ||  return { result => 'formatError', message => "$@" };
	unless($obj->can('run')) { 
		return { result => 'formatError', message => "Action '$action' is not runnable" }
	};
	my $res = $obj->run(Webstellation::DB->new($self->{dbname}));
	return $res;
}

sub dispatch {
	my $self = shift;
	my ($res, $data);
   	if(eval { $data = decode_json shift }) { $res = $self->process($data) }
    else { $res = { result => 'formatError', message => 'Invalid JSON' } }
	return encode_json $res;
}

1;
