import os
include: workflow.source_path('utils.py')
samples = get_samples(config)

envvars:
    'CHECKVDB'

rule all:
    input:
        expand('{sample}/MEGAHIT/{sample}.fasta', sample=samples)

rule seqtk:
    conda:
        "/home/lanskaya/miniconda3/envs/assembly"
    input:
        r1 = '{sample}/reads/{sample}_filtered_R1.fq.gz',
        r2 = '{sample}/reads/{sample}_filtered_R2.fq.gz'
    output:
        r1 = '{sample}/reads/{sample}_sampled_R1.fq.gz',
        r2 = '{sample}/reads/{sample}_sampled_R2.fq.gz'
    params:
        sample_size = config.get('sample-size', 10_000)
    shell:
        'seqtk sample -s42 {input.r1} {params.sample_size} | gzip > {output.r1} && '
        'seqtk sample -s42 {input.r2} {params.sample_size} | gzip > {output.r2}'

rule megahit:
    conda:
        "/home/lanskaya/miniconda3/envs/megahit"
    input:
        r1 = '{sample}/reads/{sample}_sampled_R1.fq.gz',
        r2 = '{sample}/reads/{sample}_sampled_R2.fq.gz'
    output:
        '{sample}/MEGAHIT/final.contigs.fa'
    shell:
        'megahit -1 {input.r1} -2 {input.r2} -o {wildcards.sample}/MEGAHIT'

rule checkv:
    conda:
        "/home/lanskaya/miniconda3/envs/assembly"
    input:
        '{sample}/MEGAHIT/final.contigs.fa'
    output:
        '{sample}/MEGAHIT/checkv_out/quality_summary.tsv'
    params:
        outdir = '{sample}/MEGAHIT/checkv_out'
    threads:
        config.get('threads', 1)
    shell:
        'checkv end_to_end -t {threads} {input} {params.outdir}'

rule extract:
    input:
        quality_summary = '{sample}/MEGAHIT/checkv_out/quality_summary.tsv',
        contigs = '{sample}/MEGAHIT/final.contigs.fa'
    output:
        '{sample}/MEGAHIT/{sample}.fasta'
    script:
        'scripts/extract_complete_genome.py'
