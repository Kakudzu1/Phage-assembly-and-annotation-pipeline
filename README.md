# Phage-assembly-and-annotation-pipeline

Snakemake pipeline for phage assembly using MEGAHIT, COBRA and annotation with Pharokka/Phold

**Pipeline contains following sections:**
- [Phage assembly with MEGAHIT](https://github.com/Kakudzu1/Phage-assembly-and-annotation-pipeline/blob/main/README.md#phage-assembly-with-megahit)
- [Postprocessing](https://github.com/Kakudzu1/Phage-assembly-and-annotation-pipeline/blob/main/README.md#postprocessing)
- [Annotation](https://github.com/Kakudzu1/Phage-assembly-and-annotation-pipeline/blob/main/README.md#annotation)

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

### Requirments
- [seqtk](https://github.com/lh3/seqtk)
- [MEGAHIT](https://github.com/voutcn/MEGAHIT)
- [Checkv](https://pypi.org/project/checkv/)

To download CheckV database choose version [here](https://portal.nersc.gov/CheckV/) and download it. Then extract and set the environment variable:
```
# Extract the database
tar -xvzf CHECKV_VERSION.tar.gz

# Set CHECKVDB environment variable (replace PATH/TO/DATABASE with your actual path)
echo 'export CHECKVDB=PATH/TO/DATABASE' >> ~/.bashrc
source ~/.bashrc
```

### Running the pipeline
```
snakemake --snakefile ./pipelines/megahit_assembly.smk \
    --directory /PATH/TO/WORKING/DIRECTORY \
    --config samples=/PATH/TO/SAMPLE/FILE \
    --use-conda \
    --cores N
```

## Postprocessing

### Requirments
- [bwa](https://github.com/lh3/BWA)
- [samtools]
- [jgi_summarize_bam_contig_depths] 
- [cobra-meta]

### Running the pipeline
```
snakemake --snakefile ./pipelines/cobra_pipeline.smk \
    --directory /PATH/TO/WORKING/DIRECTORY \
    --config samples=/PATH/TO/SAMPLE/FILE assembler=megahit \
    --use-conda \
    --cores N
```

## Annotation

### Requirments
- [pharokka]
- [phold]
- [clinker]

Please, install pharokka database running:
```
install_databases.py -o /PATH/TO/DATABASE/DIR
```

### Running the pipeline
```
snakemake --snakefile ./pipelines/annotation.smk
    --directory /PATH/TO/WORKING/DIRECTORY \
    --config samples=/PATH/TO/SAMPLE/FILE prefix=CLINKER_PREFIX_NAME \
    --use-conda \
    --cores N
```




