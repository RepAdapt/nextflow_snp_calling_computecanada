process gatkIndex {
    tag "Reference GATK index building"
    cpus 1
    memory '4GB'
    time '6h'

    input:
    path reference

    output:
    file "${reference.baseName}.dict"

    script:
    """
    picard CreateSequenceDictionary R=$reference O=${reference.baseName}.dict
    """
}
