import sys
import os

PHAROKKA_DB = os.environ["PHAROKKA_DB"]

prefix = config["prefix"]
if not prefix:
    sys.exit('The "prefix" argument must be specified.')

def get_samples(config: dict) -> list[str]:
    samples = config.get('samples')

    if samples:
        if os.path.isfile(samples):
            with open(samples) as file:
                return [line for line in map(lambda line: line.strip(), file) if line]
        else:
            return samples.strip().split(',')
    else:
        sys.exit('The "samples" argument must be specified.')

samples = get_samples(config)

rule all:
    input:
        f"{prefix}_clinker.html",
        expand("pharokka-gv/all_plots/{sample}.png", sample=samples)

rule pharokka:
    conda:
        "/home/lanskaya/miniconda3/envs/pharok_env"
    input:
        "{sample}/{sample}.fasta"
    output:
        "pharokka-gv/{sample}/pharokka.gbk"
    shell:
        "pharokka.py -i {input} -o pharokka-gv/{wildcards.sample} -d {PHAROKKA_DB} -t 8 --dnaapler -g prodigal-gv -f"

rule phold:
    conda:
        "/home/lanskaya/miniconda3/envs/phold"
    input:
        "pharokka-gv/{sample}/pharokka.gbk"
    output:
        "pharokka-gv/{sample}/phold/phold.gbk"
    params:
        dir = "pharokka-gv/{sample}/phold"
    shell:
        "phold run -i {input} -o {params.dir} -t 8 --force"

rule copy:
    input:
        "pharokka-gv/{sample}/phold/phold.gbk"
    output:
        "pharokka-gv/clusters/{sample}.gbk"
    shell:
        "cp {input} {output}"

rule clinker:
    conda:
        "/home/lanskaya/miniconda3/envs/pharok_env"
    input:
        expand("pharokka-gv/clusters/{sample}.gbk", sample=samples)
    output:
        f"{prefix}_clinker.html"
    shell:
        "clinker {input} -p {output}"

rule plots:
    conda:
        "/home/lanskaya/miniconda3/envs/phold"
    input:
        "pharokka-gv/{sample}/phold/phold.gbk"
    output:
        "pharokka-gv/all_plots/{sample}.png"
    params:
        dir = "pharokka-gv/{sample}/phold/phold_plots",
        name = lambda wildcards: "_".join(wildcards.sample.split("_")[-2:])
    shell:
        '''
        phold plot -i {input} -o {params.dir} -t {params.name} --force
        mv {params.dir}/*.png {output}
        '''
