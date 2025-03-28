process samtoolsSort {
    tag "Samtools sorting bam files"
    cpus 4
    memory '4GB'
    time '6h'
    errorStrategy 'ignore'

    input:
    path sample_sam

    output:
    tuple val("${sample_sam.baseName}"), path("${sample_sam.baseName}{_sorted.bam,_sorted.bam.bai}")
    
    script:
    """
    samtools view -Sb -q 10 $sample_sam > temp666.bam
    rm $sample_sam
    samtools sort -n -o temp777.bam temp666.bam
    samtools fixmate -m temp777.bam temp888.bam
    samtools sort --threads $task.cpus temp888.bam > ${sample_sam.baseName}_sorted.bam
    rm temp666.bam temp777.bam temp888.bam
    samtools index ${sample_sam.baseName}_sorted.bam
    """
}
