# phac-nml/staramrnf: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2025-10-09

### `Update`

- Updated the starAMR version to [0.11.1](https://github.com/phac-nml/staramr/releases/tag/0.11.1) [PR #34](https://github.com/phac-nml/staramrnf/pull/34):
  - Removed `parse_seqids` from `makeblastdb` command. Fixes issue with contig headers greater than 50 characters.[PR #225](https://github.com/phac-nml/staramr/pull/225) NCBI assembled genomes with accessions in the header will have slightly different contig names.

### `Changed`

- Adding GitHub CI tests against Nextflow `24.10.3`. [PR #33](https://github.com/phac-nml/staramrnf/pull/33)

### `Added`

- `software_version.yml` file in `pipeline_info` results. [PR #36](https://github.com/phac-nml/staramrnf/pull/36)

## [0.3.0] - 2025-03-20

### `Update`

- starAMR version was updated from `0.10.0` to [0.11.0](https://github.com/phac-nml/staramr/releases/tag/0.11.0). [PR#30](https://github.com/phac-nml/staramrnf/pull/30)
  - Resfinder database to use the 2024-08-06 release
  - Pointfinder database to use the 2024-08-08 release

## [0.2.0] - 2024-09-20

The pipeline has been modified to accept an input (samplesheet) with an optional `sample_name` column. The goal of the `sample_name` is to allow for IRIDA-Next users to modify their output filenames and sample names. Previously, all files and samples were named using the IRIDA-Next ID (for which users do not chose). This modification will not impact the running locally of `staramrnf` because if `sample_name` column is absent (as was the case prior to the release) then the `sample` column will behave as it had previously.

- `sample_name` special characters will be replaced with `"_"`
- If no `sample_name` is supplied in the column `sample` will be used
- To avoid repeat values for `sample_name` all `sample_name` values will be suffixed with the `sample` value. Which is a unique value.

## [0.1.0] - 2024-08-14

Initial release of staramrnf, or staramr nextflow pipeline, is a nextflow wrapper of [staramr](https://github.com/phac-nml/staramr/).

`staramr` (AMR) scans bacterial genome contigs against the [ResFinder][resfinder-db], [PointFinder][pointfinder-db], and [PlasmidFinder][plasmidfinder-db] databases (used by the [ResFinder webservice][resfinder-web] and other webservices offered by the Center for Genomic Epidemiology) and compiles a summary report of detected antimicrobial resistance genes. The `star|_`in`staramr` indicates that it can handle all of the ResFinder, PointFinder, and PlasmidFinder databases.

staramrnf follows the `nf-core` pipeline file structure and used the nf-core [template](https://nf-co.re/docs/contributing/pipelines/pipeline_file_structure)

[resfinder-db]: https://bitbucket.org/genomicepidemiology/resfinder_db
[pointfinder-db]: https://bitbucket.org/genomicepidemiology/pointfinder_db
[plasmidfinder-db]: https://bitbucket.org/genomicepidemiology/plasmidfinder_db
[resfinder-web]: http://genepi.food.dtu.dk/resfinder
[0.1.0]: https://github.com/phac-nml/staramrnf/releases/tag/0.1.0
[0.2.0]: https://github.com/phac-nml/staramrnf/releases/tag/0.2.0
[0.3.0]: https://github.com/phac-nml/staramrnf/releases/tag/0.3.0
[0.3.1]: https://github.com/phac-nml/staramrnf/releases/tag/0.3.1
