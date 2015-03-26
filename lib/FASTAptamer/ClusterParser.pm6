#!/bin/env perl6

module FASTAptamer::ClusterParser
{     
    # CONSTANT
    my $NONE = '-';
    
    sub get_fh_for_clusters is export
    {
        return dir( test => /.* cluster.fa$/); # All files ending in 'cluster.fa'
    }
    
    #| Get the first part of the filename (just up to the first period)
    sub basenames ( @filenames ) is export
    {
        @filenames.map( { .split('.')[0] } );
    }
    
    sub extract_cluster_info ($filename) is export
    {
        my %cluster_count_for;
        my %seed_for;
        my $loop_counter=0;
    
        # Iterate over FASTA file two lines at a time
        for $filename.IO.lines -> $header, $sequence
        {
            my ($reads,$rank) = $header.split('-')[1,3];
            if ( ! (%seed_for{$rank}) )
            {
                %seed_for{$rank} = $sequence;
            }
    
            my $seed = %seed_for{$rank};
            %cluster_count_for{$seed}  += +$reads; # plus symbol forces numeric context
        }
        my $cluster_count = %cluster_count_for;
        return $cluster_count;
    }
    
    sub extract_item_info ($filename) is export
    {
        my %item_count_for;
        my %seed_for;
        my $loop_counter=0;
    
        # Iterate over FASTA file two lines at a time
        for $filename.IO.lines -> $header, $sequence
        {
            my ($reads,$rank) = $header.split('-')[1,3];
            %item_count_for{$sequence}  = +$reads;
        }
        my $item_count = %item_count_for;
        return $item_count;
    }
    
    sub cluster_table_for ( @filenames) is export
    {
        my $reference_filename = @filenames[0];
        my @other_filenames    = @filenames[1 .. *];

        my @basenames = basenames( @filenames);

        # Start building up table
        my $table = table_header_for(@basenames);
    
        my $ref_cluster    = extract_cluster_info($reference_filename);

        my @other_clusters;

        for @other_filenames -> $filename 
        {
            push @other_clusters,  extract_cluster_info($filename);
        }

        my @ref_seqs   = sorted_cluster_seqs($ref_cluster);

        my @other_seqs;
        for @other_clusters -> $cluster
        {
            push @other_seqs, sorted_cluster_seqs($cluster);
        }

        @other_seqs.=unique;


        my @extra_seqs = ( @other_seqs (-) @ref_seqs ).list;
    
        for (@ref_seqs, @extra_seqs) -> $seq
        {
            $table ~=   (   $seq,
                            $ref_cluster{$seq} // $NONE,
                        ).join("\t");
            for @other_clusters -> $count_by_cluster
            {
                $table ~= "\t";
                $table ~= $count_by_cluster{$seq} // $NONE;
            }
            $table ~= "\n";
        }
        return $table;
    }

    sub table_header_for (@names)
    {
        return ('seed sequence',@names).join("\t") ~ "\n";
    }

    sub diagnostic ($message, $var)
    {
        say "$message ( $var.perl() )";
    }
    
    sub sorted_cluster_seqs ( $cluster )
    {
        my @sorted_seqs = $cluster.keys.sort({
               $cluster{$^a}
               <=>  
               $cluster{$^b} 
            }).reverse;
        return @sorted_seqs;
    }
    
    sub matching_cluster ( :%cluster, :$sequence ) is export
    {
        for %cluster.keys.sort -> $rank 
        {
            for %cluster{$rank}.keys -> $cluster_sequence
            {
                return $rank if $sequence eq $cluster_sequence;
            }
        }
    
        # Nothing found, returning undefined value Any
        return;
    }

}


sub MAIN( *@filenames)
{
    import FASTAptamer::ClusterParser;
    print cluster_table_for(@filenames);
}
