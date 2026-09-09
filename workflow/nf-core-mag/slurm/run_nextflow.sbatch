#!/bin/bash
#SBATCH --job-name=nfcore_mag_head
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=7-00:00:00
#SBATCH --output=slurm/logs/nextflow_head_%j.out
#SBATCH --error=slurm/logs/nextflow_head_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sklucas@syr.edu

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Load singularity
module load singularity

# Load nextflow via conda install
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate nf

export NXF_OPTS='-Xms1g -Xmx4g'

nextflow run nf-core/mag \
  -r 5.5.0 \
  -profile singularity \
  -c slurm/nextflow.config \
  -params-file params.json \
  -resume
