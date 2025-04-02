#!/bin/bash
#SBATCH --time=6-23:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --account=def-yeaman

module load nextflow
module load apptainer

source /home/gabnoc/nf-core-env/bin/activate

export NXF_SINGULARITY_CACHEDIR=/project/def-yeaman/NXF_SINGULARITY_CACHEDIR


nextflow run main.nf --ref_genome=/home/gabnoc/scratch/nextflow_stuff/data/ref/Betula_pendula_subsp._pendula.fasta --gff_file=/home/gabnoc/scratch/nextflow_stuff/data/genes/Betula_pendula_subsp._pendula_annos1-cds0-id_typename-nu1-upa1-add_chr0.gid35080.gff -profile narval -config nextflow.config -w ./work/
