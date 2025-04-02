process prepareDepth {
    tag "Preparing files for depth statistics"
    cpus 1
    memory '4GB'
    time '12h'

    input:
    path reference_fai
    path gff_file

    output:
    file "genome.bed"
    file "windows.bed"
    file "windows.list"
    file "genes.bed"
    file "genes.list"
   
    script:
    """
    awk '{print \$1"\\t"\$2}' $reference_fai > genome.bed

    awk -v w=5000 '{chr = \$1; chr_len = \$2;
    for (start = 0; start < chr_len; start += w) {
        end = ((start + w) < chr_len ? (start + w) : chr_len);
        print chr "\\t" start "\\t" end;
       }
    }' $reference_fai > windows.bed

    awk -F "\\t" '{print \$1":"\$2"-"\$3}' windows.bed | sort -k1,1 > windows.list
    awk '\$3 == "gene" {print \$1"\\t"\$4"\\t"\$5}' $gff_file | uniq > genes.bed

    cut -f1 $reference_fai | while read chr; do awk -v chr=\$chr '\$1 == chr {print \$0}' genes.bed | sort -k2,2n; done > genes.sorted.bed
    mv genes.sorted.bed genes.bed

    awk -F "\\t" '{print \$1":"\$2"-"\$3}' genes.bed | sort -k1,1 > genes.list
    """
}
