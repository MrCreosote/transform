use strict;

# BEGIN spec
# "WSBiomType-to-Biom": {
#   "cmd_args": {
#     "input": "-i",
#     "output": "-o"
#     },
#     "cmd_description": "WS Biom Object to Biom File",
#     "cmd_name": "trns_transform_WSBiomType-to-Biom.pl",
#     "max_runtime": 3600,
#     "opt_args": {
# 	 }
#   }
# }
# END spec

use Getopt::Long::Descriptive;
use Bio::KBase::workspace::Client;

my($opt, $usage) = describe_options("%c %o",
				    ['input|i=s', 'workspace object id from which the input is to be read'],
				    ['workspace|w=s', 'workspace id from which the input is to be read'],
				    ['from-file', 'specifies to use the local filesystem instead of workspace'],
				    ['output|o=s', 'file to which the output is to be written'],
				    ['url=s', 'URL for the genome annotation service'],
				    ['help|h', 'show this help message'],
				    );

print($usage->text), exit  if $opt->help;
print($usage->text), exit 1 unless @ARGV == 0;

if (!($opt->from_file)) {
    if (!$opt->workspace) {
	die "A workspace name must be provided";
    }
    my $wsclient = Bio::KBase::workspace::Client->new();
    my $ret = $wsclient->get_object({ id => $opt->input, workspace => $opt->workspace });
    if ($ret->{data}) {
	my $biom = $ret->{data};
        my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
        open OUT, ">$opt->input" || die "Cannot print WS biom object to file: $opt->input\n";
	print OUT $coder->encode ($biom);
	close OUT;
    } else {
	die "Invalid return from get_object for ws=" . $opt->workspace . " input=" . $opt->input;
    }
}

my $rc = system("mv $opt->input $opt->output");

if ($rc != 0)
{
    die "Transform command failed with rc=$rc: @cmd\n";
}
