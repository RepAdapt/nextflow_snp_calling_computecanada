process addRG {
    tag "Picard add RG to bam files"
    cpus 1
    memory '4GB'
    time '6h'
    errorStrategy 'ignore'
    
    input:
    tuple val(sample_id), path(sorted_bam)

    output:
    path "${sorted_bam[0].baseName}_RG.bam"
 
    script:
    """
    picard AddOrReplaceReadGroups -INPUT ${sorted_bam[0]} -OUTPUT ${sorted_bam[0].baseName}_RG.bam -RGID ${sorted_bam[0].baseName} -RGLB ${sorted_bam[0].baseName}_LB -RGPL ILLUMINA -RGPU unit1 -RGSM ${sorted_bam[0].baseName} --VALIDATION_STRINGENCY SILENT
    """
}
