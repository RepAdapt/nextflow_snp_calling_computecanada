include {snpCalling} from '../modules/bcftools_snp_calling'
include {joinDepth} from '../modules/combine_depth_outputs'
include {trimSequences} from '../modules/fastp_trimming'
include {calculateGenesDepth} from '../modules/genes_depth'
include {dupRemoval} from '../modules/picard_duplicates_removal'
include {samtoolsSort} from '../modules/samtools_sort'
include {bwaIndex} from '../modules/bwa_index'
include {concatVCFs} from '../modules/concatenate_vcfs'
include {realignIndel} from '../modules/gatk3_indel_realignment'
include {fastaIndex} from '../modules/index_fasta'
include {calculateDepth} from '../modules/samtools_depth'
include {calculateWgDepth} from '../modules/wg_depth'
include {bwaMap} from '../modules/bwa_mapping'
include {prepareDepth} from '../modules/depth_of_coverage_prep'
include {gatkIndex} from '../modules/gatk_index'
include {addRG} from '../modules/picard_add_read_groups'
include {samtoolsRealignedIndex} from '../modules/samtools_indexing_bam'
include {calculateWindowsDepth} from '../modules/windows_depth'




workflow snp_calling {

    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .set { read_pairs_ch }
   
    // Trim reads  
    trimmed_ch = trimSequences(read_pairs_ch)
    
    // Preparing reference genome indexes and depth of coverage files
    fai_index = fastaIndex(params.ref_genome)
    depth_prep_files = prepareDepth(fai_index, params.gff_file)
    gatk_index = gatkIndex(params.ref_genome)
    bwa_index = bwaIndex(params.ref_genome)

    // BWA mem mapping
    mapped_sam = bwaMap(params.ref_genome, bwa_index, trimmed_ch)
    
    // Sorting bam, adding read groups and removing duplicates
    sorted_bam = samtoolsSort(mapped_sam)
    rg_bam = addRG(sorted_bam)
    dedup_bams = dupRemoval(rg_bam)
    
    // Indel realignment and re-indexing
    realigned_bams = realignIndel(dedup_bams, params.ref_genome, fai_index, gatk_index)
    realigned_bai = samtoolsRealignedIndex(realigned_bams)
    
    // Calculate depth stats per sample: genes, windows and wg
    depth_file = calculateDepth(realigned_bams)
    depth_stats_genes = calculateGenesDepth(depth_file, depth_prep_files)
    depth_stats_windows = calculateWindowsDepth(depth_file, depth_prep_files)
    depth_stats_wg = calculateWgDepth(depth_file, depth_prep_files)

    // Extract all bam and bai paths and collect all of them
    all_bams_ch = realigned_bams.collect()
    all_bai_ch = realigned_bai.collect()


    // Combinedepth stats outputs across samples
    all_genes_ch = depth_stats_genes.collect()
    all_windows_ch = depth_stats_windows.collect()
    all_wg_ch = depth_stats_wg.collect()
    joinDepth(all_bams_ch, all_genes_ch, all_windows_ch, all_wg_ch)
    

    // Extract chromosomes to parallelize SNP calling
    chromosomes_ch = fai_index
                            .splitCsv(sep: '\t')
                            .map { it[0] }


    // SNP calling per chromosome, minimal filtering and concatenating into a single final vcf
    vcfs = snpCalling(params.ref_genome,fai_index, all_bams_ch, all_bai_ch, chromosomes_ch)
    all_vcfs_ch = vcfs.collect()
    concatVCFs(all_vcfs_ch)

}
