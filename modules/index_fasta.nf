process fastaIndex {
    tag "Reference FASTA index building"    
    cpus 1
    memory '4GB'
    time '6h'
    
    input:
    path reference

    output:
    file "${reference.baseName}.fasta.fai"

    script:
    """
    samtools faidx $reference
    """
}
