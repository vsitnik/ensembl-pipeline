#!/usr/local/bin/perl -w



=head1 NAME

  prepare_ests.pl

=head1 SYNOPSIS
 
  prepare_ests.pl
  Chunks ESTs into required number of chunks
  Indexes parent EST file

  Sanger/EBI notes
  NB the index still needs to be distributed over the farm in order for seqfetching to work
  The EST files MUST live on somewhere on acari or NFS overhead is horrific

=head1 DESCRIPTION


=head1 OPTIONS

  all options set in ESTConf.pm

=cut

use strict;
use Getopt::Long;
use Bio::EnsEMBL::Pipeline::ESTConf qw (
					EST_FILE
					EST_CHUNKDIR
					EST_CHUNKNUMBER
					EST_FILESPLITTER
					EST_MAKESEQINDEX
				       );

my $estfile   = $EST_FILE;
my $chunkdir  = $EST_CHUNKDIR;
my $chunknum  = $EST_CHUNKNUMBER;
my $splitter  = $EST_FILESPLITTER;
my $makeindex = $EST_MAKESEQINDEX;

print "1 $estfile\n2 $chunkdir\n3 $chunknum\n4 $splitter\n5 $makeindex\n\n";


if(!defined $estfile || !defined $chunkdir || !defined $chunknum || !defined $splitter || !defined $makeindex){
  print "Usage: prepare_ests.pl\n " . 
        "options to be set in EST_conf.pl are estfile, estfiledir, estchunknumber, makeindex and filesplitter\n";
  exit(1);

}

&chunk_ests;
&index_ests;

=head2 chunk_ests

  Title   : chunk_ests
  Usage   : chunk_ests
  Function: 
  Returns : nothing, but $estfiledir contains $chunknum files
  Args    : none - uses globals

=cut

sub chunk_ests {
  my $output = `$splitter $estfile $chunkdir $chunknum`;
  if($output ne '') { print "output from $splitter: $output\n"; }
}

=head2 index_ests

  Title   : index_ests
  Usage   : index_ests
  Function: indexes $estfile using 
  Returns : nothing, but there\'s a .jidx file accompanying $estfile 
  Args    : none - uses globals

=cut

sub index_ests {
  my $inxfile = $estfile . ".jidx";
  my $output = `$makeindex $estfile > $inxfile`;
  if($output ne '') { print "output from makeindex: $output\n"; }
}
