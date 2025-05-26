process realignIndel {
    tag "GATK 3.8 Indel realignment of bam files"
    cpus 1
    memory '20GB'
    time '48h'
    errorStrategy 'ignore'
    publishDir params.outdir, mode: 'copy'

    input:
    path dedup_bam
    path reference
    file "${reference.baseName}.fasta.fai"
    file "${reference.baseName}.dict"

    output:
    path "${dedup_bam[0].baseName}_realigned.bam"

    script:
    """
    gatk3 -T RealignerTargetCreator -R $reference -I $dedup_bam -o ${dedup_bam[0].baseName}_intervals.intervals -U ALLOW_UNINDEXED_BAM
    gatk3 -T IndelRealigner -R $reference -I $dedup_bam -targetIntervals ${dedup_bam[0].baseName}_intervals.intervals --consensusDeterminationModel USE_READS  -o ${dedup_bam[0].baseName}_realigned.bam -U ALLOW_UNINDEXED_BAM
    """
}
