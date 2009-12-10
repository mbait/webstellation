package Webstellation::Request;

use strict;
use warnings;

use JSON;
use Data::Dumper;
use File::Path;

sub new {
	my $inv = shift;
	my $class = ref $inv || $inv;
	my %opt = @_;
	die "Cannot find $opt{dbclass} package $@" unless eval "require $opt{dbclass}";
	my $self;
	{
		no strict 'refs';
		$self = { dbi => "$opt{dbclass}"->new($opt{env}) };
	}
	return bless $self, $class;
}

sub process {
	my ($self, $data) = @_;
	my $action = $data->{action} || return { 
		result => 'formatError', 
		message => 'Action is not defined' 
	};
	my $res;
	unless(
	eval {
		no strict 'refs';
		eval "require Webstellation::Query::$action";
		$res =  "Webstellation::Query::$action"->run($self->{dbi}, $data);
	})
	{
		print "$@\n";
		return { result => 'aformatError', message => 'Action is not registered' };
	}
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
