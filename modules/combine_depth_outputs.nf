process joinDepth {
    tag "Joining depth statistics across samples"
    cpus 1
    memory '4GB'
    time '6h'
    publishDir params.outdir, mode: 'copy'

    input:
    path bam_files
    path gene_statistics_files
    path window_statistics_files
    path wg_statistics_files    

    output:
    path "combined_windows.tsv"
    path "combined_genes.tsv"
    path "combined_wg.tsv"
    
    script:
    """
    echo -e "${bam_files.collect { it.baseName.replace('.bam', '') }.join('\\n')}" > list.txt
    echo -e "location\\t\$(cut -f2 list.txt | sort | uniq | paste -s -d '\\t')" > depthheader.txt
    cut -f2 list.txt | sort | uniq > samples.txt

    while read samp; do cut -f2 \${samp}-windows.sorted.tsv > \${samp}-windows.sorted.depthcol ; done < samples.txt
    paste \$(sed 's/^/.\\//' samples.txt | sed 's/\$/-windows.sorted.tsv/' | head -n 1) \$(sed 's/^/.\\//' samples.txt | sed 's/\$/-windows.sorted.depthcol/' | tail -n +2) > combined-windows.temp
    cat depthheader.txt combined-windows.temp > combined_windows.tsv

    while read samp; do cut -f2 \${samp}-genes.sorted.tsv > \${samp}-genes.sorted.depthcol ; done < samples.txt
    paste \$(sed 's/^/.\\//' samples.txt | sed 's/\$/-genes.sorted.tsv/' | head -n 1) \$(sed 's/^/.\\//' samples.txt | sed 's/\$/-genes.sorted.depthcol/' | tail -n +2) > combined-genes.temp
    cat depthheader.txt combined-genes.temp > combined_genes.tsv

    while read samp; do echo -e \$samp"\\t"\$(cat ./\$samp-wg.txt); done < samples.txt > combined_wg.tsv
    """
}
