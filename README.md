# nextflow_snp_calling_computecanada_narval
Nextflow pipeline for Narval/Beluga Compute Canada HPC with SLURM

This pipeline takes fastq reads, a reference genome and a gff file and will produce:
- a minimally filtered vcf (removing SNPs where all indidivuals are homozyogous ALT and any SNP with MQ < 30).
- 3 depth statistics files per dataset: samples genes depth, samples windows depth and samples whole-genome depth.

Login to ComputeCanada Narval or Beluga.
From a login node in your home dir run:

<pre>module purge # Make sure that previously loaded modules are not polluting the installation 
module load python/3.11
module load rust # New nf-core installations will err out if rust hasn't been loaded
module load postgresql # Will not use PostgresSQL here, but some Python modules which list psycopg2 as a dependency in the installation would crash without it.
python -m venv nf-core-env
source nf-core-env/bin/activate
python -m pip install nf_core==2.13</pre>


Now, create or edit the file (you probably have to create it):  ~/.nextflow/config   

This is like a general config for EVERY workflow you will run with nextflow in this cluster. You can copy and paste the text below into it, but change def-group to your compute canada account name:



<pre>params {
    config_profile_description = 'Alliance HPC config'
    config_profile_contact = 'https://docs.alliancecan.ca/wiki/Technical_support'
    config_profile_url = 'docs.alliancecan.ca/wiki/Nextflow'
}


singularity {
  enabled = true
  autoMounts = true
}

apptainer {
  autoMounts = true
}

process {
  executor = 'slurm'
  clusterOptions = '--account=def-group'
  maxRetries = 1
  errorStrategy = { task.exitStatus in [125,139] ? 'retry' : 'finish' }
  memory = '4GB'
  cpu = 1
  time = '1h'
}

executor {
  pollInterval = '60 sec'
  submitRateLimit = '60/1min'
  queueSize = 900
}

profiles {
  beluga {
    max_memory='186G'
    max_cpu=40
    max_time='168h'
  }
  
  narval {
    max_memory='249G'
    max_cpu=64
    max_time='168h'
  }
}
</pre>

Do not worry about the cpus, memory and time of the slurm process. These slurm global options will be overwritten by the cpus, memory and time specified for each process of the workflow defined in modules. 

Do not change anything in the narval and beluga profiles, these are the specs of the machines in those clusters.


Now, download all the singularity images needed: https://github.com/RepAdapt/singularity/blob/main/RepAdaptSingularity.md

Create this directory and place them here (replace def-group with your account name):
<pre>mkdir /project/def-group/NXF_SINGULARITY_CACHEDIR</pre>
then:
<pre>export NXF_SINGULARITY_CACHEDIR=/project/def-group/NXF_SINGULARITY_CACHEDIR</pre>

Also add the above export command to your ~/.bashrc


Now we have everything ready to start the workflow.

The workflow should be run on a computing node, using the script <b>run_pipeline.sh</b> (submit with sbatch -- give this job only 1 cpu, 8 GB RAM but MAX available run time which is 7 days in narval and beluga). 

Change the profile flag in run_pipeline.sh to either beluga or narval (depending on which one you are using).



# Options

--reads (default CWD: "./*{1,2}.fastq.gz") ### this can be changed, use it to match your raw fastq reads path and names patterns (ie. fq.gz)

--outdir (default: "./output/") ### this can be changed to any directory

--ref_genome (No default, give full path)

--gff_file (No default, give full path)




# Important

It is required to pull all the apptainer images as sif files and link them to the directory where you saved  them (/project/def-group/NXF_SINGULARITY_CACHEDIR) in the config file nextflow_singularity.config

Apptainer images vailable at: https://github.com/RepAdapt/singularity/blob/main/RepAdaptSingularity.md








# Comments

- **Reference too fragmented -- stitching the reference genome:**  
  If a reference genome is highly fragmented, consisting of thousands or even millions of scaffolds, it is beneficial to stitch them into larger contiguous sequences before running the SNP calling pipeline to reduce the total number of scaffolds.  
  Having a reference composed of too many scaffolds will cause errors in the indel realignment step with GATK3 – I am not sure which threshold is “too many.”  
  Additionally, the pipeline parallelizes the SNP calling step (`bcftools mpileup + call`) by chromosome (calling SNPs in each chromosome in parallel), therefore having a very fragmented reference would result in sending thousands (or millions) of very fast jobs – it would still work but it would be an overkill and probably not ideal for queue times on a job scheduler.  
  So, if your reference is too fragmented, please stitch it and unstitch it after SNP calling!  

- **Reference must have `.fasta` suffix while genes GFF must have `.gff` suffix.**  

- **Make sure that the `.gff` file and reference genome use the same exact chromosome names.**  
  else the depth of coverage statistics will not be calculated. The names need to be exactly the same, so if, for example, the reference has `chromosome_1` and the GFF has `chr_1`, these will have to be changed to the same naming.  

- **Make sure the chromosome/scaffold names do not contain weird characters that may break commands.**  
  A very unusual case that I found was a reference that had `|` pipes included in the chromosome names – this can cause a lot of issues, as the pipe `|` may be interpreted as a Linux pipe command.  

- **If a process fails, the first thing to check is whether it was due to low run time or RAM.**  
  RAM and run time can be easily edited for each process by modifying its corresponding script in the `modules` directory. I tried to provide high enough values that will work for most datasets, but if your dataset is particularly large (in terms of reference size or raw FASTQ files per sample), it might be necessary to increase RAM and run time for some processes.  

