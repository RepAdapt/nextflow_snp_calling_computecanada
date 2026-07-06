#!/usr/bin/env nextflow

params.bams = "./output/*.bam"
params.outdir = "/home/gabnoc/scratch/output/"
params.ref_genome = ""
params.gff_file = ""


include { coverage_stats } from './workflows/coverage_stats_wf'


log.info """\
    C O V E R A G E   S T A T S   P I P E L I N E
    ===================================
    reference    : ${params.ref_genome}
    bams         : ${params.bams}
    gff          : ${params.gff_file}
    outdir       : ${params.outdir}
    """
    .stripIndent(true)


workflow {
   coverage_stats()
}
