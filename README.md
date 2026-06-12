[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A523.04.3-brightgreen.svg)](https://www.nextflow.io/)

# `staramrnf`: nextflow pipeline

**staramrnf: nextflow pipeline** is the nextflow adaptation of [staramr](https://github.com/phac-nml/staramr/)

> `staramr` (AMR) scans bacterial genome contigs against the [ResFinder][resfinder-db], [PointFinder][pointfinder-db], and [PlasmidFinder][plasmidfinder-db] databases (used by the [ResFinder webservice][resfinder-web] and other webservices offered by the Center for Genomic Epidemiology) and compiles a summary report of detected antimicrobial resistance genes. The `star`in`staramr` indicates that it can handle all of the ResFinder, PointFinder, and PlasmidFinder databases.

## Table of Contents

- [Usage](#usage)
- [Input](#input)
- [Output](#output)
- [Parameters](#parameters)

## Usage

If you are new to `Nextflow` and `nf-core`, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
with `-profile test` before running the workflow on actual data.

```bash
nextflow run phac-nml/staramrnf -r main -latest -profile test,docker --outdir ./results
```

To run `staramrnf`, you will need to include both mandatory parameters:

#### Mandatory Parameters

- `--input`: a URI to the samplesheet
- `--output`: the directory for pipeline output

```bash
nextflow run phac-nml/staramrnf -r main -latest -profile docker --outdir path/output_folder --input path/samplesheet.csv
```

For more information see [usage doc](docs/usage.md).

## Input

### Samplesheet Input

You will need to create a samplesheet with information about the samples you would like to analyze before running the pipeline. Use this parameter to specify its location.

```bash
--input '[path to samplesheet file]'
```

### Samplesheet Description

The input samplesheet requires two columns: `sample`, `contigs` with an optional third column `species`. The `species` column is used in the selecting of the Pointfinder organism database (empty if "None"). Rows of the `sample` column within a samplesheet must be unqiue. Any additional columns that aren't named `sample`, `contigs`, or `species` will be ignored by the pipeline.

Note: The [parameter](#parameters) `--pointfinder_database` overrides the `species` column for all samples.

A final samplesheet file consisting of `sample`, `contigs` and `species`.

```csv title="samplesheet.csv"
sample,sample_name,contigs,species
SAMPLE1,A1,sample1.fastq.gz,Salmonella
SAMPLE2,A1,sample2fastq.gz,Escherichia coli
SAMPLE3,,sample3.fastq.gz,
```

| Column        | Description                                                                                          |
| ------------- | ---------------------------------------------------------------------------------------------------- |
| `sample`      | Sample key. Samples should be unique within a samplesheet. **Required**                              |
| `sample_name` | Sample name used in outputs (filenames and sample names)                                             |
| `contigs`     | Full path to genome contig(s). Uncompressed or gzipped (.gz) fasta file (fna,fa,fasta). **Required** |
| `species`     | Species of genome (see accepted Pointfinder organisms below). **Optional**                           |

If `sample_name` value is left blank for a sample, then the `sample` value will replace the value. To ensure that all `sample_name` values are unique, `sample` will be suffixed to `sample_name` that are not unique. Non-alphanumeric characters (excluding `_`,`-`,`.`) will be replaced with `"_"`.

An [example samplesheet](assets/samplesheet.csv) has been provided with the pipeline.

Note: Validated Pointfinder organisms for `species` include: Enterococcus faecalis, Helicobacter pylori, Salmonella, Enterococcus faecium, Escherichia coli, Campylobacter. Accepted but unvalidated species: Klebsiella, Staphylococcus aureus, Mycobacterium tuberculosis, Neisseria gonorrhoeae, Plasmodium falciparum.

## Output

The directories listed below will be created in the `--outdir <OUTDIR>` directory after the pipeline has finished. All paths are relative to the top-level output directory.

```
.
├── csvtk
├── pipeline_info
└── staramr
```

The IRIDA Next-compliant JSON output file will be named `iridanext.output.json.gz` and will be written to the top-level of the results directory. This file is compressed using GZIP and conforms to the [IRIDA Next JSON output specifications](https://github.com/phac-nml/pipeline-standards#42-irida-next-json).

### Output Sections

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [AMR Bacterial Scans](#amr-bacterial-scans) - Scans bacterial genome contigs against the ResFinder, PointFinder, and PlasmidFinder databases and compiles a summary report of detected antimicrobial resistance genes.
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### AMR Bacterial Scans

<details markdown="1">
<summary>Output files</summary>

For More information see [staramr output description](https://github.com/phac-nml/staramr/?tab=readme-ov-file#output)

- `staramr/`
  - StarAMR search results for each sample:
    - `sample_detailed_summary.staramr.tsv` : A detailed summary of all detected AMR genes/mutations/plasmids/sequence type in each genome, one gene per line.
    - `sample_mlst.staramr.tsv` : A tabular file of each multi-locus sequence type (MLST) and it's corresponding locus/alleles, one genome per line.
    - `sample_plasmidfinder.staramr.tsv` :A tabular file of each AMR plasmid type and additional BLAST information from the PlasmidFinder database, one plasmid type per line.
    - `sample_pointfinder.staramr.tsv` : A tabular file of each AMR point mutation and additional BLAST information from the PointFinder database, one gene per line.(Pointfinder organisms)
    - `sample_resfinder.staramr.tsv` : A tabular file of each AMR gene and additional BLAST information from the ResFinder database, one gene per line.
    - `sample_results.staramr.xlsx` : An Excel spreadsheet containing the previous 6 files as separate worksheets.
    - `sample_settings.staramr.txt` :The command-line, database versions, and other settings used to run `staramr`.
    - `sample_summary.staramr.tsv` : A summary of all detected AMR genes/mutations/plasmids/sequence type in each genome, one genome per line. A series of descriptive statistics is also provided for each genome as well as feedback for whether or not the genome passes several quality metrics and if not, feedback on why the genome fails.
- `csvtk/`
  - Combine results from all samples into a single report
    - `merged_detailed_summary.staramr.tsv`
    - `merged_mlst.staramr.tsv`
    - `merged_plasmidfinder.staramr.tsv`
    - `merged_pointfinder.staramr.tsv` (Pointfinder organisms)
    - `merged_resfinder.staramr.tsv`
    - `merged_summary.staramr.tsv`

</details>

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.
  - Parameters used by the pipeline run: `params.json`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.

See the [staramr documentation](https://github.com/phac-nml/staramr/blob/development/README.md) for more details and explanations.

For more information see [output doc](docs/output.md).

## Parameters

### StarAMR

For more information on [StarAMR](https://github.com/phac-nml/staramr/) parameters

Parameters are run with `--` prefix

Example:

```bash
nextflow run main.nf --outdir ./results --input samplesheet.csv --pid_threshold 99
```

| Parameters                             | Description                                                                                                                                                                                                                                          |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pointfinder_database`                 | Select a single Pointfinder database to use on all samples (overriding samplesheet `species`). Enterococcus faecium, Enterococcus faecalis, Helicobacter pylori, Salmonella, Campylobacter, Escherichia coli **Default:** None (or `species` column) |
| `plasmidfinder_database`               | Plasmidfinder database (gram positive or enterobacteriales). **Default:** Both                                                                                                                                                                       |
| `mlst_scheme`                          | Specify scheme name [(listed here)](https://github.com/tseemann/mlst/tree/master/db/pubmlst) **Default:** Auto-detect                                                                                                                                |
| `genome_size_lower_bound`              | The lower bound for our genome size for the quality metrics **Default:** 4000000                                                                                                                                                                     |
| `genome_size_upper_bound`              | The upper bound for our genome size for the quality metrics **Default:** 6000000                                                                                                                                                                     |
| `minimum_N50_value`                    | The minimum N50 value for the quality metrics **Default:** 10000                                                                                                                                                                                     |
| `minimum_contig_length`                | The minimum contig length for the quality metrics **Default:** 300 (bp)                                                                                                                                                                              |
| `unacceptable_number_contigs`          | The minimum, unacceptable number of contigs which are equal to or above the minimum contig length for our quality metrics **Default:** 1000                                                                                                          |
| `pid_threshold`                        | BLAST percent identity threshold **Default:** 98                                                                                                                                                                                                     |
| `percent_length_overlap_plasmidfinder` | The percent length overlap for plasmidfinder results **Default:** 60                                                                                                                                                                                 |
| `percent_length_overlap_resfinder`     | The percent length overlap for pointfinder results **Default:** 95                                                                                                                                                                                   |
| `no_exclude_genes`                     | Disable the default exclusion of some genes from ResFinder/PointFinder/PlasmidFinder **Default:** False                                                                                                                                              |
| `exclude_negatives`                    | Exclude negative results (those susceptible to antimicrobials) **Default:** False                                                                                                                                                                    |
| `exclude_resistance_phenotypes`        | Exclude predicted antimicrobial resistances **Default:** False                                                                                                                                                                                       |

### Genus specific settings

### Genus-specific settings

Genus-specific settings are used when the `species` column of the sample sheet contains any of the following genera:

```
genus_list = ['salmonella', 'campylobacter', 'escherichia', 'shigella']
```

#### Salmonella, Shigella, or Escherchia
- Lower bound for our genome size for quality metrics = 4,000,000
- Upper bound for our genome size for quality metrics = 6,700,000 
- Percent length overlap of BLAST hit for ResFinder Database = 52
- PointFinder Database = Salmonella or PointFinder Database = E.coli
#### Campylobacter
- Lower bound for our genome size for quality metrics = 1,250,000
- Upper bound for our genome size for quality metric s= 2,500,000
- Percent length overlap of BLAST hit for ResFinder Database = 52 
- Percent length overlap of BLAST hit for PointFinder Database = 58
- PointFinder Database = Campylobacter

### Nextflow

For a full set of Nextflow options

```bash
nextflow run main.nf -help
```

Nextflow parameters use `-` prefix

Example `-profile`

```bash
nextflow run main.nf -profile test,docker --outdir ./results
```

| Parameters | Description                                                                                             |
| ---------- | ------------------------------------------------------------------------------------------------------- |
| `profile`  | Choose a configuration profile (e.g. test, docker, or singularity)                                      |
| `resume`   | Execute the script using the cached results, useful to continue executions that was stopped by an error |
| `revision` | Revision of the project to run (either a git branch, tag or commit SHA number)                          |

## Citation

### staramr

> Bharat A, Petkau A, Avery BP, Chen JC, Folster JP, Carson CA, Kearney A, Nadon C, Mabon P, Thiessen J, Alexander DC, Allen V, El Bailey S, Bekal S, German GJ, Haldane D, Hoang L, Chui L, Minion J, Zahariadis G, Domselaar GV, Reid-Smith RJ, Mulvey MR. **Correlation between Phenotypic and In Silico Detection of Antimicrobial Resistance in Salmonella enterica in Canada Using Staramr**. Microorganisms. 2022; 10(2):292. https://doi.org/10.3390/microorganisms10020292

### Databases used by staramr

> **Zankari E, Hasman H, Cosentino S, Vestergaard M, Rasmussen S, Lund O, Aarestrup FM, Larsen MV**. 2012. Identification of acquired antimicrobial resistance genes. J. Antimicrob. Chemother. 67:2640–2644. doi: [10.1093/jac/dks261][resfinder-cite]

> **Zankari E, Allesøe R, Joensen KG, Cavaco LM, Lund O, Aarestrup F**. PointFinder: a novel web tool for WGS-based detection of antimicrobial resistance associated with chromosomal point mutations in bacterial pathogens. J Antimicrob Chemother. 2017; 72(10): 2764–8. doi: [10.1093/jac/dkx217][pointfinder-cite]

> **Carattoli A, Zankari E, Garcia-Fernandez A, Voldby Larsen M, Lund O, Villa L, Aarestrup FM, Hasman H**. PlasmidFinder and pMLST: in silico detection and typing of plasmids. Antimicrob. Agents Chemother. 2014. April 28th. doi: [10.1128/AAC.02412-14][plasmidfinder-cite]

> **Seemann T**, MLST Github https://github.com/tseemann/mlst

> **Jolley KA, Bray JE and Maiden MCJ**. Open-access bacterial population genomics: BIGSdb software, the PubMLST.org website and their applications [version 1; peer review: 2 approved]. Wellcome Open Res 2018, 3:124. doi: [10.12688/wellcomeopenres.14826.1][mlst-cite]

### nf-core

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> The nf-core framework for community-curated bioinformatics pipelines.
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> Nat Biotechnol. 2020 Feb 13. doi: 10.1038/s41587-020-0439-x.
> In addition, references of tools and data used in this pipeline are as follows:

## Legal

Copyright 2024 Government of Canada

Licensed under the MIT License (the "License"); you may not use
this work except in compliance with the License. You may obtain a copy of the
License at:

https://opensource.org/license/mit/

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

[resfinder-db]: https://bitbucket.org/genomicepidemiology/resfinder_db
[pointfinder-db]: https://bitbucket.org/genomicepidemiology/pointfinder_db
[plasmidfinder-db]: https://bitbucket.org/genomicepidemiology/plasmidfinder_db
[resfinder-web]: http://genepi.food.dtu.dk/resfinder
