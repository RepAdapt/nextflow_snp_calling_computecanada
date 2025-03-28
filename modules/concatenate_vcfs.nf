process concatVCFs {
    tag "Concatenating chromosomes VCFs"
    cpus 1
    memory '16GB'
    time '23h'
    publishDir params.outdir, mode: 'copy'

    input:
    path vcfs

    output:
    path "final_variants.vcf.gz"
    path "final_variants.vcf.gz.tbi"

    script:
    """
    bcftools concat $vcfs -Oz > final_variants.vcf.gz
    tabix -p vcf final_variants.vcf.gz
    """
}
