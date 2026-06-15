import sys
import os

assembler = config.get("assembler")
if not assembler:
    sys.exit('The "assembler" argument must be specified.')
if assembler == 'megahit':
    assembler_mink = 20
    assembler_maxk = 141
elif assembler == 'metaspades':
    assembler_mink = 21
    assembler_maxk = 127
elif assembler == 'idba':
    assembler_mink = 20
    assembler_maxk = 140
else:
    print("use cobra with another assembler (megahit/metaspades/idba)")
    sys.exit(f"Unknown assembler: {assembler}")


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
        directory(expand("{sample}/MEGAHIT/cobra", sample=samples))

rule bwa:
    conda:
        "/home/lanskaya/miniconda3/envs/align"
    input:
        ref = "{sample}/MEGAHIT/res/final.contigs.fa",
        r1 = "{sample}/reads/{sample}_sampled_R1.fq.gz",
        r2 = "{sample}/reads/{sample}_sampled_R2.fq.gz"
    output:
        bam = "{sample}/MEGAHIT/res/aligned_sorted.bam"
    params:
        threads = 8
    shell:
        '''
        bwa index {input.ref}
        bwa mem -t {params.threads} {input.ref} {input.r1} {input.r2} | \
        samtools view -bS - | \
        samtools sort -o {output.bam}
        '''

rule coverage:
    conda:
        "/home/lanskaya/miniconda3/envs/align"
    input:
        bam = "{sample}/MEGAHIT/res/aligned_sorted.bam",
        script = "/home/lanskaya/hdd/lanskaya/genome_assembly/coverage.transfer.py"
    output:
        txt = "{sample}/MEGAHIT/res/coverage.txt",
        cov = "{sample}/MEGAHIT/res/original_coverage.tsv"
    shell:
        '''
        jgi_summarize_bam_contig_depths --outputDepth {output.cov} {input.bam}
        python {input.script} -i {output.cov} -o {output.txt}
        '''

rule cobra:
    conda:
        "/home/lanskaya/miniconda3/envs/align"
    input:
        fasta = "{sample}/MEGAHIT/res/final.contigs.fa",
        query = "{sample}/MEGAHIT/res/final.contigs.fa",
        map = "{sample}/MEGAHIT/res/aligned_sorted.bam",
        cov = "{sample}/MEGAHIT/res/coverage.txt"
    output:
        directory("{sample}/MEGAHIT/cobra")
    shell:
        f'''
        cobra-meta \
        -f {input.fasta} \
        -q {input.query} \
        -m {input.map} \
        -c {input.cov} \
        -a {assembler} \
        -mink {assembler_mink} \
        -maxk {assembler_maxk} \
        -o {output}
        '''
