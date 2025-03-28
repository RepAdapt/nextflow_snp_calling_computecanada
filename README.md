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

Do not worry about the cpus, memory and time of the slurm process. These slurm global options will be overwritten by the cpus, memory and time specified for each process of the workflow defined in modules. Do not change anything in the narval and beluga profiles.


Now, download all the singularity images needed: https://github.com/RepAdapt/singularity/blob/main/RepAdaptSingularity.md

Create this directory and place them here (replace def-group with your account name):
<pre>mkdir /project/def-group/NXF_SINGULARITY_CACHEDIR</pre>
then:
<pre>export NXF_SINGULARITY_CACHEDIR=/project/def-group/NXF_SINGULARITY_CACHEDIR</pre>

Also add the above export command to your ~/.bashrc


Now we have everything ready to start the workflow.

The workflow should be run on a computing node, using the script <b>run_pipeline.sh</b> (submit with sbatch -- give this job only 1 cpu, 8 GB RAM but MAX available run time which is 7 days in narval and beluga). 

Change the profile flag in run_pipeline.sh to either beluga or narval (depending on which one you are using).

<b>AVAILABLE OPTIONS</b>

--reads (default CWD: "./*{1,2}.fastq.gz") ### this can be changed, use it to match your raw fastq reads path and names patterns (ie. fq.gz)

--outdir (default: "./output/") ### this can be changed to any directory

--ref_genome (No default, give full path)

--gff_file (No default, give full path)


<b>IMPORTANT</b>

The reference genome file MUST HAVE .fasta suffix (change it to .fasta if yours is .fa)

The GFF file MUST HAVE .gff suffix

It is required to pull all the apptainer images as sif files and link them to the directory where you saved  them (/project/def-group/NXF_SINGULARITY_CACHEDIR) in the config file nextflow_singularity.config
