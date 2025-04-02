process calculateWgDepth {
    tag "Extracting WG depth statistics from bam files"
    cpus 1
    memory '4GB'
    time '12h'

    input:
    path depth_file
    file "genome.bed"
    file "windows.bed"
    file "windows.list"
    file "genes.bed"
    file "genes.list"

    output:
    path "${depth_file[0].baseName}-wg.txt"

    script:
    """
    awk '{sum += \$3; count++} END {if (count > 0) print sum/count; else print "No data"}' $depth_file > ${depth_file[0].baseName}-wg.txt
    """
}
