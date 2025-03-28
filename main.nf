#!/usr/bin/env nextflow

params.reads = "/home/gabnoc/scratch/nextflow_stuff/data_2/*{1,2}.fastq.gz"
params.outdir = "./output/"
params.ref_genome = ""
params.gff_file = ""


include { snp_calling } from './workflows/snp_calling_wf'


log.info """\
    S N P   C A L L I N G   P I P E L I N E
    ===================================
    reference    : ${params.ref_genome}
    reads        : ${params.reads}
    gff          : ${params.gff_file}
    outdir       : ${params.outdir}
    """
    .stripIndent(true)


workflow {
   snp_calling()
}
