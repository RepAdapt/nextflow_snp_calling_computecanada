process bwaIndex {
    tag "BWA index building"    
    cpus 1
    memory '4GB'
    time '12h'

    input:
    path reference
    
    output:
    file "${reference.baseName}.fasta.amb"
    file "${reference.baseName}.fasta.ann"
    file "${reference.baseName}.fasta.bwt"
    file "${reference.baseName}.fasta.pac"
    file "${reference.baseName}.fasta.sa"    

    script:
    """
    bwa index -a bwtsw $reference 
    """
}
