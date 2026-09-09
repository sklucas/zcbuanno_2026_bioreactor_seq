# nf-core/mag on HTCondor

The SLURM setup is in [slurm/](slurm/). See [slurm/README.md](slurm/README.md) for
the `sbatch` submission workflow.

Runs the [nf-core/mag](https://nf-co.re/mag) assembly/binning pipeline (which includes
`fastp` QC and `MEGAHIT`/SPAdes assembly internally) against this project's HTCondor pool.

## Requirements

- Nextflow available on the submit/login node
- Singularity/Apptainer available on execute nodes (jobs run with `-profile singularity`)
- A shared filesystem between the submit node and execute nodes, mounted at the same
  path on both (Nextflow's `condor` executor does not support HTCondor file transfer)

## Input

Reuses the existing sample sheet [data/raw/AUG2026/mgx/AUG2026_mgx.csv](../../data/raw/AUG2026/mgx/AUG2026_mgx.csv),
which already matches the nf-core/mag samplesheet format
(`sample,group,short_reads_1,short_reads_2,long_reads,short_reads_platform,long_reads_platform`).

## Usage

If you can run `nextflow` directly on your submit/login node, run it from this
directory so relative paths in `params.json` and the default `work/` directory land
on the shared filesystem:

```bash
cd workflow/nf-core-mag
nextflow run nf-core/mag -r 5.5.0 -profile singularity -c nextflow.config -params-file params.json -resume
```

### Submitting the Nextflow head process as a condor job

If your submit node doesn't allow launching long-running foreground processes
directly (e.g. you must submit everything through condor), submit the Nextflow head
process itself as a `local` universe job. `local` universe runs on the submit
machine (not an execute node), so it retains `condor_submit` access and the shared
filesystem needed to launch nf-core/mag's own per-task jobs:

```bash
cd workflow/nf-core-mag
condor_submit submit/nextflow_head.sub
```

Edit `scripts/run_nextflow.sh` first to load/activate however `nextflow` and
`singularity` are made available in your environment (module load, conda activate,
etc.) — `getenv = true` in the submit file otherwise only inherits your shell's
current environment at submit time. Track progress via `condor_q` and the logs in
`logs/nextflow_head.*`; the pipeline's own task jobs will appear as separate condor
jobs once Nextflow starts submitting them.

Results are written to `results/mag/` at the repo root; Nextflow's work directory and
the Singularity image cache are created locally in this directory (both are gitignored).

## Files

- `nextflow.config` — sets the HTCondor (`condor`) executor and Singularity settings.
  Edit the `clusterOptions` requirements expression to match your pool's node
  attributes (e.g. singularity availability, accounting group).
- `params.json` — pipeline parameters (`--input`, `--outdir`). Add other nf-core/mag
  parameters here (e.g. `--busco_db`, `--gtdb_db`) to avoid re-downloading databases
  and to keep runs reproducible; see the [parameter docs](https://nf-co.re/mag/parameters).
- `submit/nextflow_head.sub` / `scripts/run_nextflow.sh` — condor submit description
  and wrapper for running the Nextflow head process itself as a `local` universe job.

## Notes

- Pin the pipeline version with `-r <version>` for reproducibility.
- Use `nextflow pull nf-core/mag` to refresh the cached pipeline code before switching versions.
