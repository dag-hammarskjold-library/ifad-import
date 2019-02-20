#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

package main;
use List::Util qw<first>;

use MARC;

binmode STDOUT, ':utf8';

MARC::Set->new->iterate_xml(
	path => $ARGV[0],
	callback => sub {
		my $r = shift;
		
		_001_035: {
			my $ctr = '(IFAD)'.$r->id;
			$r->delete_tag('001');
			$r->delete_tag('035');
			$r->add_field(MARC::Field->new(tag => '035')->sub('a',$ctr));
		}
		
		_005: {
			$r->delete_tag('005');
		}
		
		_020: {
			for ($r->get_fields('020')) {
				my $val = $_->get_sub('a');
				$val =~ s/-//g;
				$_->set_sub('a',$val, replace => 1);
			}
		}
		
		_039: {
			$r->delete_tag('039');
		}
		
		_090: {
			$r->delete_tag('090');
		}
		
		_100_110: {
			$r->change_tag('100','700');
			$r->change_tag('110','710');
		}
		
		_191: {
			$r->add_field(MARC::Field->new(tag => '191')->set_sub('b','IFAD/'));
		}
		
		_260_269: {
			my $f = first {$_} $r->get_fields('260');
			
			my ($a,$b,$c) = $f->list_subfield_values(qw<a b c>);
			$f->set_sub('a',$a.':', replace => 1);
			$f->set_sub('b',$b.',', replace => 1);
			
			$r->add_field(MARC::Field->new(tag => '269')->set_sub('a',$c));
		}
		
		_598: {
			$r->delete_tag('598');
		}
		
		_773: {
			$r->delete_tag('773');
		}
		
		_830: {
			$r->add_field(MARC::Field->new(tag => '830')->set_sub('a','IFAD Research Series'));
		}
		
		_852: {
			$r->delete_tag('852');
		}
		
		_856_FFT: {
			for my $f ($r->get_fields('856')) {
				next if $f->ind2 eq '8';
				my $url = $f->get_sub('u');
				unless ($url eq 'http://library2018.ifad.org:8080/16328.pdf') {
					# exception for broken link
					$r->add_field(MARC::Field->new(tag => 'FFT')->set_sub('a',$url)->set_sub('d','English'));
				}
			}
			
			$r->delete_tag('856');
		}
		
		_981: {
			$r->add_field(MARC::Field->new(tag => '981')->set_sub('a','Other UN Bodies and Entities'));
		}
		 
		_989: {
			my $f = MARC::Field->new(tag => '989');
			$f->set_sub('a','Documents and Publications');
			$f->set_sub('b','Publications');
			$r->add_field($f);
		}
		
		_999: {
			$r->delete_tag('999');
		}
		
		print $r->to_xml;
	}
);

