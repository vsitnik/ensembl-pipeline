## Bioperl Test Harness Script for Modules
##
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

#-----------------------------------------------------------------------
## perl test harness expects the following output syntax only!
## 1..3
## ok 1  [not ok 1 (if test fails)]
## 2..3
## ok 2  [not ok 2 (if test fails)]
## 3..3
## ok 3  [not ok 3 (if test fails)]
##
## etc. etc. etc. (continue on for each tested function in the .t file)
#-----------------------------------------------------------------------



## We start with some black magic to print on failure.
BEGIN { 
        $| = 1; print "1..6\n"; 
	    use vars qw($loaded); 
      }

END {   print "not ok 1\n" unless $loaded;  }

use lib 't';
use EnsTestDB;
use Bio::EnsEMBL::Pipeline::RunnableDB::Clone_Genscan;
use Bio::EnsEMBL::Analysis;

$loaded = 1;
print "ok 1\n";    # 1st test passes.
    
my $ens_test = EnsTestDB->new();
# Load some data into the db
$ens_test->do_sql_file("t/runnabledb.dump");
    
# Get an EnsEMBL db object for the test db
my $db = $ens_test->get_DBSQL_Obj;
print "ok 2\n";    

my $runnable = 'Bio::EnsEMBL::Pipeline::RunnableDB::Clone_Genscan';
my $ana_adaptor = $db->get_AnalysisAdaptor;
my $ana = Bio::EnsEMBL::Analysis->new (   -db             => 'HumanIso',
                                                    -db_version     => '__NONE__',
                                                    -db_file        => '/usr/local/ensembl/data/HumanIso.smat',
 
                                                    -program        => 'Genscan',
                                                    -program_file   => '/usr/local/ensembl/bin/genscan',
                                                    -module         => $runnable,
                                                    -module_version => 1,
                                                    -gff_source     => 'genscan',
                                                    -gff_feature    => 'exon', 
						    -logic_name     => 'clone_genscan',
                                                    #-parameters     => '',
                                                     );

unless ($ana)
{ print "not ok 3\n"; }
else
{ print "ok 3\n"; }
my $id ='AC015914';
$ana_adaptor->exists( $ana );
my $runobj = "$runnable"->new(  
                                -dbobj      => $db,
			        -input_id   => $id,
                                -analysis   => $ana );
unless ($runobj)
{ print "not ok 4\n"; }
else
{ print "ok 4\n"; }

$runobj->fetch_input;;
$runobj->run;

my @out = $runobj->output;
unless (@out)
{ print "not ok 5\n"; }
else
{ print "ok 5\n"; }
display(@out);

$runobj->write_output();

my $clone = $db->get_Clone($id);

my @features;

foreach my $contig ($clone->get_all_Contigs()) {
    push @features, $contig->get_all_PredictionFeatures();
}
display(@features);

unless (@features)
{ print "not ok 6\n"; }
else
{ print "ok 6\n"; }

sub display {
    my @results = @_;
    #Display output
    foreach my $obj (@results)
    {
       print STDERR ($obj->gffstring."\n");
       if ($obj->sub_SeqFeature)
       {
            foreach my $exon ($obj->sub_SeqFeature)
            {
                print STDERR "Sub: ".$exon->gffstring."\n";
            }
       }
    }
}
