include {snpCalling} from '../modules/bcftools_snp_calling'
include {joinDepth} from '../modules/combine_depth_outputs'
include {calculateGenesDepth} from '../modules/genes_depth'
include {concatVCFs} from '../modules/concatenate_vcfs'
include {fastaIndex} from '../modules/index_fasta'
include {calculateDepth} from '../modules/samtools_depth'
include {calculateWgDepth} from '../modules/wg_depth'
include {prepareDepth} from '../modules/depth_of_coverage_prep'
include {gatkIndex} from '../modules/gatk_index'
include {samtoolsRealignedIndex} from '../modules/samtools_indexing_bam'
include {calculateWindowsDepth} from '../modules/windows_depth'




workflow bcftools_only {

   // Channel with all BAMs for per-sample processing (one BAM per job)
    Channel
        .fromPath(params.bams, checkIfExists: true)
        .set { realigned_bams }

    gatk_index = gatkIndex(params.ref_genome)
    fai_index = fastaIndex(params.ref_genome)
    realigned_bai = samtoolsRealignedIndex(realigned_bams)

    // Extract all bam and bai paths and collect all of them
    all_bams_ch = realigned_bams.collect()
    all_bai_ch = realigned_bai.collect()


    // Extract chromosomes to parallelize SNP calling
    chromosomes_ch = fai_index
                            .splitCsv(sep: '\t')
                            .map { it[0] }


    // SNP calling per chromosome, minimal filtering and concatenating into a single final vcf
    vcfs = snpCalling(params.ref_genome,fai_index, all_bams_ch, all_bai_ch, chromosomes_ch)
    all_vcfs_ch = vcfs.collect()
    concatVCFs(all_vcfs_ch)

}
