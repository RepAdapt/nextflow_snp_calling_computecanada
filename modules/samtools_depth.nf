process calculateDepth {
    tag "Extracting depth statistics from bam files"
    cpus 1
    memory '4GB'
    time '6h'
    errorStrategy 'ignore'

    input:
    path realigned_bam

    output:
    path "${realigned_bam[0].baseName}.depth"

    script:
    """
    samtools depth -aa $realigned_bam > ${realigned_bam[0].baseName}.depth
    """
}
