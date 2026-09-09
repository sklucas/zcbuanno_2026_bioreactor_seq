# nf-core/mag on SLURM

This is the SLURM setup for running nf-core/mag. It is separate from the HTCondor
configuration in the parent directory. nf-core/mag includes fastp QC and MEGAHIT/SPAdes
assembly internally.

## Requirements

- Nextflow and Singularity/Apptainer available in the SLURM job environment
- A shared filesystem visible at the same path from the submit, head, and compute nodes
- The existing sample sheet and input FASTQ files accessible on that filesystem
- A SLURM account and, if required, a partition

## Submit

From this directory:

```bash
mkdir -p logs
sbatch run_nextflow.sbatch
```

The `sbatch` job is the Nextflow head process. It remains running while Nextflow
submits the individual nf-core/mag processes to SLURM through the `slurm` executor.
Monitor both the head job and pipeline tasks with:

```bash
squeue --me
sacct --name=nfcore_mag_head --starttime=today
```

Head-process logs are written to `logs/nextflow_head_<jobid>.out` and
`logs/nextflow_head_<jobid>.err`.


