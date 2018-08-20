
use strict;
use warnings;
use Cwd qw(abs_path);      
use Getopt::Long;          
use Data::Dumper;         
use FindBin qw($Bin $Script);  
use File::Basename qw(basename dirname);  
my $BEGIN_TIME=time();   
my $version="1.0.0";

#core Perl modules
use Getopt::Long;
use Carp;  

#CPAN modules
use Bio::SeqIO;
use Bio::Perl;

#---------------------------------------------------------------------------
#GetOptions
#---------------------------------------------------------------------------
my($input_file,$output_file);  #ѡ���hash��
GetOptions(
  "in=s"  => \$input_file,     #�����ļ�
  "out=s" => \$output_file,    #����ļ�
  "help|?"=> \&USAGE,
 ) or &USAGE;
&USAGE unless (defined $input_file and $output_file);  #�ж�ѡ��ĺϷ���
&log_current_time("\n$output_file\n$Script start����");    #����ʱ�亯��

#----------------------------------------------------------------------------
#load input file,save the result
#----------------------------------------------------------------------------

#open I,"$input_file"||die "can't open the file: $!\n";  
open O,">$output_file"||die "can't open the file: $!\n";
my $seqio = Bio::SeqIO->new( -file => "$input_file", -format => 'fasta' ) or croak "**ERROR: Could not open FASTA file:$input_file  $!\n";  #���������fasta�ļ�
while(my $sobj = $seqio->next_seq)
{
    my $seqid = $sobj->id;
#    my $seq = $sobj->seq;
    my $len= $sobj->length;
    print O $seqid."\t".$len."\n";
}



#----------------------------------------------------------------------------------
#ending of work
#----------------------------------------------------------------------------------
&log_current_time("\n$output_file\n$Script end����");    #����ʱ�亯��
my $run_time=time()-$BEGIN_TIME;
print "$Script run time :$run_time\.s\n";


#----------------------------------------------------------------------------------
#function 
#----------------------------------------------------------------------------------
sub log_current_time {     
	my ($info) = @_;    
	my $curr_time = &date_time_format(localtime(time()));   
	print "[$curr_time] $info\n";    #�����ӡ
}
##########################################################################################################################
sub date_time_format {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime(time());
	return sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);  #��ȡ��ʽ����ʱ����Ϣ������ӡ��sprintf���÷���
}
########################################################################################################################## 
sub USAGE{   #ѡ���������
	my $usage=<<"__USAGE__";
#-----------------------------------------------------------
 Program:$Script
 Version:$version
 Contact:1291016966\@qq.com
    Data:2015-12-08
Function:get SP annotations of best hits
   USAGE:
         -in    <STR>   input file [Must]
         -out   <STR>   output file   [Optional]
         -help          show the docment and exit
 Example:
    perl $Script -in file1 -out file2
#---------------------------------------------------------
__USAGE__
   print $usage;  #��ӡ������Ϣ
   exit;      #�����ø��ӳ���ʱ��ʾ�����޷�����ִ�У�ʹ��exit����ǿ���˳��ó���
 	} 