process samtoolsDedupIndex {
    tag "Indexing bam files for SNP calling"
    cpus 1
    memory '4GB'
    time '12h'
    errorStrategy 'ignore'

    input:
    path dedup_bam

    output:
    path "${dedup_bam[0].baseName}.bam.bai"

    script:
    """
    samtools index $dedup_bam
    """
}
