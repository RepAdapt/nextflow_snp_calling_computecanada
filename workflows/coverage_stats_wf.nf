include {joinDepth} from '../modules/combine_depth_outputs'
include {calculateGenesDepth} from '../modules/genes_depth'
include {fastaIndex} from '../modules/index_fasta'
include {calculateDepth} from '../modules/samtools_depth'
include {calculateWgDepth} from '../modules/wg_depth'
include {prepareDepth} from '../modules/depth_of_coverage_prep'
include {calculateWindowsDepth} from '../modules/windows_depth'




workflow coverage_stats {

   // Channel with all BAMs for per-sample processing (one BAM per job)
    Channel
        .fromPath(params.bams, checkIfExists: true)
        .set { realigned_bams }

    all_bams_ch = realigned_bams.collect()
    fai_index = fastaIndex(params.ref_genome)
    depth_prep_files = prepareDepth(fai_index, params.gff_file)

    // Calculate depth stats per sample: genes, windows and wg
    depth_file = calculateDepth(realigned_bams)
    depth_stats_genes = calculateGenesDepth(depth_file, depth_prep_files)
    depth_stats_windows = calculateWindowsDepth(depth_file, depth_prep_files)
    depth_stats_wg = calculateWgDepth(depth_file, depth_prep_files)


    // Combine depth stats outputs across samples
    all_genes_ch = depth_stats_genes.collect()
    all_windows_ch = depth_stats_windows.collect()
    all_wg_ch = depth_stats_wg.collect()
    joinDepth(all_bams_ch, all_genes_ch, all_windows_ch, all_wg_ch)
    

}
