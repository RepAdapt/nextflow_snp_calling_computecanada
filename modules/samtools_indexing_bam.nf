process samtoolsRealignedIndex {
    tag "Indexing bam files for SNP calling"
    cpus 1
    memory '4GB'
    time '6h'
    errorStrategy 'ignore'

    input:
    path realigned_bam

    output:
    path "${realigned_bam[0].baseName}.bam.bai"

    script:
    """
    samtools index $realigned_bam
    """
}
