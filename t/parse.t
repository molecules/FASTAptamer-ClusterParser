use 5.008;  # Require at least Perl version 5.8
use strict;   # Must declare all variables before using them
use warnings; # Emit helpful warnings
use autodie;  # Fatal exceptions for common unrecoverable errors (e.g. w/open)

# Testing-related modules
use Test::More;                  # provide testing functions (e.g. is, like)

use Test::LongString;            # Compare strings byte by byte
use Data::Section -setup;        # Set up labeled DATA sections
use File::Temp  qw( tempfile );  #
use File::Slurp qw( slurp    );  # Read a file into a string
use English '-no_match_vars'; # Readable names for special variables
                              #  (e.g. $@ is $EVAL_ERROR)
{
    my $input_filename  = filename_for('input');
    my $output_filename = temp_filename();
    my $filename_A = assign_filename_for('A.TEMP_DELETE_ME.cluster.fa', 'A.cluster.fa');
    my $filename_G = assign_filename_for('G.TEMP_DELETE_ME.cluster.fa', 'G.cluster.fa');
    system("perl6 lib/FASTAptamer/ClusterParser.pm6 $filename_A $filename_G > $output_filename");
    my $result   = slurp $output_filename;
    my $expected = string_from('cluster_table');
    is( $result, $expected, 'successfully created cluster_table from the command line' );
    unlink($filename_A, $filename_G);
}


done_testing();

sub sref_from {
    my $section = shift;

    #Scalar reference to the section text
    return __PACKAGE__->section_data($section);
}


sub string_from {
    my $section = shift;

    #Get the scalar reference
    my $sref = sref_from($section);

    #Return a string containing the entire section
    return ${$sref};
}

sub fh_from {
    my $section = shift;
    my $sref    = sref_from($section);

    #Create filehandle to the referenced scalar
    open( my $fh, '<', $sref );
    return $fh;
}

sub assign_filename_for {
    my $filename = shift;
    my $section  = shift;

    my $string   = string_from($section);
    open(my $fh, '>', $filename);
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub filename_for {
    my $section           = shift;
    my ( $fh, $filename ) = tempfile();
    my $string            = string_from($section);
    print {$fh} $string;
    close $fh;
    return $filename;
}

sub temp_filename {
    my ($fh, $filename) = tempfile();
    close $fh;
    return $filename;
}

sub delete_temp_file {
    my $filename  = shift;
    my $delete_ok = unlink $filename;
    ok($delete_ok, "deleted temp file '$filename'");
}

#------------------------------------------------------------------------
# IMPORTANT!
#
# Each line from each section automatically ends with a newline character
#------------------------------------------------------------------------

__DATA__
__[ input ]__
__[ A.cluster.fa ]__
>1-100-100-1-1-0
RQMSHKIAPTVCWLNEFGDY
>542-14-14-1-2-1
RQMSHKIAPTVDWLNEFGDY
>730-10-10-1-3-1
RQMSHKIAPTVCWLPEFGDY
>802-9-9-1-4-1
RQMSHKIAPTVCWLNEFGDW
>2-70-70-2-1-0
KLHNAIYFWCMQTPDVERGS
>996-7-7-2-2-6
KMIPAIYFWCMQTPDVFSHS
__[ G.cluster.fa ]__
>1-50-50-1-1-0
RQMSHKIAPTVCWLNEFGDY
>542-7-7-1-2-1
RQMSHKIAPTVDWLNEFGDY
>730-5-5-1-3-1
RQMSHKIAPTVCWLPEFGDY
>802-4-4-1-4-1
RQMSHKIAPTVCWLNEFGDW
>3-42-42-3-1-0
KLHNAIYFWCMQTPDVERGS
>396-7-7-3-2-6
KMIPAIYFWCMQTPDVFSHS
>2-179-179-2-1-0
DIATEGPKSRMCQHFWLNYV
>103-17-17-2-1-3
DIATFGPKSRMDRHFWLNYV
__[ cluster_table ]__
seed sequence	A	G
RQMSHKIAPTVCWLNEFGDY	133	66
KLHNAIYFWCMQTPDVERGS	77	49
DIATEGPKSRMCQHFWLNYV	-	196
