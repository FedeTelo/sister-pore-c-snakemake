snakemake --use-conda --use-singularity --rerun-incomplete --cluster "sbatch -t {cluster.time} -c {cluster.nodes} --mem {cluster.memory} --output {cluster.output}"\
          --cluster-config /groups/gerlich/experiments/Experiments_005400/005484/sequencing_analysis/sister-pore-c-snakemake/config/cluster_config.yml --jobs 100 --output-wait 60 annotated_pore_c