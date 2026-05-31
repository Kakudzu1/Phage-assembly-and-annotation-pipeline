# Phage-assembly-and-annotation-pipeline
---
Snakemake pipeline for phage assembly using MEGAHIT, COBRA and annotation with Pharokka/Phold

**Pipeline contains following sections:**
- [Phage assembly with MEGAHIT]
- [Postprocessing]
- [Annotation]

## Usage

This pipeline is designed to run **after** the following pipelines by [ArtemF42](https://github.com/ArtemF42/phage-host-assembly):

1. `quality_control.smk` — read QC and filtering
2. `taxonomic_classification.smk` — host read removal

After these steps, run the present pipeline for **phage assembly with MEGAHIT**.

Snakemake allows you to use software from [Conda](https://www.anaconda.com/) environments. To enable this, specify the conda field in your .smk file, for example:
```
rule <RULE_NAME>:
    conda:
        <ENV_NAME>
```
Also, make sure to add the `--use-conda` flag when running the pipeline:
```
snakemake ... --use-conda
```
All pipelines require the samples argument. It can be provided in one of two formats:
```
# Specify a comma-separated list of sample names
snakemake ... --config samples=sample1,sample2,sample3

# Alternatively, provide the path to a text file with one sample name per line
snakemake ... --config samples=/PATH/TO/SAMPLE/FILE
```
Use the threads option to set the number of threads
```
snakemake ... --config threads=NUM_THREADS
```
## Phage assembly with MEGAHIT
---
### Requirments
- seqtk
- MEGAHIT
- Checkv

To download CheckV database

### Running the pipeline
```
snakemake --snakefile ./pipelines/megahit_assembly.smk \
    --directory /PATH/TO/WORKING/DIRECTORY \
    --config samples=/PATH/TO/SAMPLE/FILE \
    --use-conda \
    --cores 8
```


