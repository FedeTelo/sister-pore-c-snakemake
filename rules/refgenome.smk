rule add_refgenome:
    output:
        catalog=paths.refgenome.catalog,
        chrom_metadata=paths.refgenome.chrom_metadata,
        chrom_sizes=paths.refgenome.chromsizes,
        fasta=paths.refgenome.fasta,
        fai=paths.refgenome.fai,
    params:
        fasta=lookup_value("refgenome_path", reference_df),
        prefix=to_prefix(paths.refgenome.catalog),
    log:
        to_log(paths.refgenome.catalog),
    benchmark:
        to_benchmark(paths.refgenome.catalog)
    threads: 5
    container: "docker://gerlichlab/sister-pore-c-docker:pore-c"
    shell:
        "pore_c {DASK_SETTINGS} --dask-num-workers {threads} "
        "refgenome prepare {params.fasta} {params.prefix} --genome-id {wildcards.refgenome_id} 2> {log}"


rule virtual_digest:
    input:
        paths.refgenome.fasta,
    output:
        paths.virtual_digest.catalog,
        paths.virtual_digest.fragments,
        paths.virtual_digest.digest_stats,
    params:
        prefix=to_prefix(paths.virtual_digest.catalog),
    benchmark:
        to_benchmark(paths.virtual_digest.catalog)
    log:
        to_log(paths.virtual_digest.catalog),
    threads: 10
    container: "docker://gerlichlab/sister-pore-c-docker:pore-c"
    shell:
        "pore_c {DASK_SETTINGS} --dask-num-workers {threads} "
        "refgenome virtual-digest {input} {wildcards.enzyme} {params.prefix} -n {threads} 2> {log}"


rule bwa_index_refgenome:
    input:
        paths.refgenome.fasta,
    output:
        paths.refgenome.bwt,
    # conda:
    #     "../envs/bwa.yml"
    container: "docker://gerlichlab/sister-pore-c-docker:bwa"
    log:
        to_log(paths.refgenome.bwt),
    benchmark:
        to_benchmark(paths.refgenome.bwt)
    shell:
        "bwa index {input} 2>{log}"
