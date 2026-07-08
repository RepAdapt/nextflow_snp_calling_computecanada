#!/usr/bin/env nextflow

params.bams = "./output/*.bam"
params.outdir = "./output/"
params.ref_genome = ""


include { bcftools_only } from './workflows/bcftools_only_wf'


log.info """\
    B C F T O O L S   O N L Y   P I P E L I N E
    ===================================
    reference    : ${params.ref_genome}
    bams         : ${params.bams}
    outdir       : ${params.outdir}
    """
    .stripIndent(true)


workflow {
   bcftools_only()
}
