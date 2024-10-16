rule make_label_library:
    input:
        expand_basecall_batches(paths.brdu_calling.detect)
    output:
        paths.brdu_calling.label_library
    log:
        to_log(paths.brdu_calling.label_library)
    # container: "docker://gerlichlab/sister-pore-c-docker:pore-c"
    params:
        threshold=0.5
    shell:
        "python bin/make_label_library.py --input {input} --output {output} --prob_cutoff {params.threshold}"


rule assign_porec_fragments:
    input:
        fragments=paths.align_table.pore_c,
        label_library=paths.brdu_calling.label_library
    output:
        paths.align_table.annotated_pore_c
    log:
        to_log(paths.align_table.annotated_pore_c)
    container: "docker://gerlichlab/sister-pore-c-docker:latest"
    shell:
        "spoc annotate {input.fragments} {input.label_library} {output}"


rule assign_pairs:
    input:
        contacts=paths.merged_contacts.contacts,
        pairs=paths.pairs.pairs,
        label_library=paths.brdu_calling.label_library
    output:
        paths.pairs.assigned_pairs
    container: "docker://gerlichlab/sister-pore-c-docker:latest"
    shell:
        "python bin/assign_brdu_pairs.py --pairs {input.pairs} --contacts {input.contacts} --label_lib {input.label_library} --output {output}"

rule split_pairs:
    input:
        paths.pairs.assigned_pairs
    output:
        expand(paths.pairs.label_split, label_type=["labelled_only", "all_reads", "mq_heuristic", "no_unlabelled_c"], contact_type=["cis", "trans", "cis_and_trans"], allow_missing=True)
    container: "docker://gerlichlab/sister-pore-c-docker:latest"
    shell:
        "python bin/split_assigned_pairs.py --pairs {input}"
    
