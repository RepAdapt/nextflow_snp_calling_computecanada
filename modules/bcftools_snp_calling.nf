process snpCalling {
    tag "SNP calling with bcftools mpileup + call"
    cpus 1
    memory '16GB'
    time '48h'

    input:
    path reference
    file fai
    path bam_files  // This is the collected list of BAM files
    path bai_files
    val chr

    output:
    path "final_variants_chr_*.vcf.gz"

    script:
    """   
        echo "Processing chromosome: $chr"
        bcftools mpileup -Ou -f ${reference} -r $chr ${bam_files} -q 5 -I -a FMT/AD,FMT/DP | \
        bcftools call -G - -f GQ -mv -Oz > variants_chr_${chr}.vcf.gz
        bcftools filter -e 'AC=AN || MQ < 30' variants_chr_${chr}.vcf.gz -Oz > final_variants_chr_${chr}.vcf.gz
    """
}
