process addRG {
    tag "Picard add RG to bam files"
    cpus 1
    memory '16GB'
    time '12h'
    errorStrategy 'ignore'
    
    input:
    tuple val(sample_id), path(sorted_bam)

    output:
    path "${sorted_bam[0].baseName}_RG.bam"
 
    script:
    def id = sorted_bam[0].baseName.replaceFirst(/_sorted$/, '')
    """
    picard AddOrReplaceReadGroups -INPUT ${sorted_bam[0]} -OUTPUT ${sorted_bam[0].baseName}_RG.bam -RGID ${id} -RGLB ${id}_LB -RGPL ILLUMINA -RGPU unit1 -RGSM ${id} --VALIDATION_STRINGENCY SILENT
    """
}
