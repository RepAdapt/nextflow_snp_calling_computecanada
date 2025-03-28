process trimSequences {
    tag "Fastp trimming fastq files"
    cpus 4
    memory '4GB'
    time '6h'
    errorStrategy 'ignore'
      
    input:
    tuple val(sample_id), path(reads)
  
    output:
    tuple val(sample_id), path("${sample_id}_{1,2}_trimmed.fastq.gz")

    script:
    """
    fastp -w $task.cpus -i ${reads[0]} -I ${reads[1]} -o ${sample_id}_1_trimmed.fastq.gz -O ${sample_id}_2_trimmed.fastq.gz
    """
}
