process STARAMR_SEARCH {
    tag "$meta.id"
    label 'process_single'

    conda "bioconda::staramr=0.11.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/staramr:0.11.1--pyhdfd78af_0':
        'biocontainers/staramr:0.11.1--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(contigs)

    output:
    tuple val(meta), path("*_results/${meta.id}_results.staramr.xlsx")          , emit: results_xlsx
    tuple val(meta), path("*_results/${meta.id}_summary.staramr.tsv")           , emit: summary_tsv
    tuple val(meta), path("*_results/${meta.id}_detailed_summary.staramr.tsv")  , emit: detailed_summary_tsv
    tuple val(meta), path("*_results/${meta.id}_resfinder.staramr.tsv")         , emit: resfinder_tsv
    tuple val(meta), path("*_results/${meta.id}_plasmidfinder.staramr.tsv")     , emit: plasmidfinder_tsv
    tuple val(meta), path("*_results/${meta.id}_mlst.staramr.tsv")              , emit: mlst_tsv
    tuple val(meta), path("*_results/${meta.id}_settings.staramr.txt")          , emit: settings_txt
    tuple val(meta), path("*_results/${meta.id}_pointfinder.staramr.tsv")       , emit: pointfinder_tsv, optional: true
    path "versions.yml"                                                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def is_gzipped = contigs.getName().endsWith(".gz") ? true : false
    def genome_uncompressed_name = contigs.getName().replace(".gz", "")
    def genome_filename = "${meta.id}.fasta"
    """
    if [ "$is_gzipped" = "true" ]; then
        gzip -c -d $contigs > $genome_uncompressed_name
    fi

    #Change name of input genome to allow irida-next output of metadata
    mv $genome_uncompressed_name $genome_filename

    staramr \\
        search \\
        $args \\
        --nprocs $task.cpus \\
        -o ${prefix}_results \\
        $genome_filename


    # Add prefix ($meta.id) to the names of output files (allows for CSVTK module to concatenate files downstream)
    for f in ${prefix}_results/* ; do mv "\$f" \$(echo \$f | sed 's;/;/${prefix}_;'); done

    # Add extension (.staramr) to the names of output files (to simplify output differntiation amongst other modules)
    for f in ${prefix}_results/*{.tsv,.xlsx,.txt} ; do mv "\$f" \$(echo \$f | sed 's;\\.\\([^\\.]*\\)\$;\\.staramr\\.\\1;'); done

    # Add a meta.irida column to the *_summary.staramr.tsv file to allow for meta.irida to be passed to the iridanext.output.json.gz
    awk 'BEGIN{ FS = OFS = "\\t" } { print (NR==1? "IRIDA_ID" : "${meta.irida_id}"), \$0 }' ${prefix}_results/${prefix}_summary.staramr.tsv > tmp && mv tmp ${prefix}_results/${prefix}_summary.staramr.tsv


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        staramr : \$(echo \$(staramr --version 2>&1) | sed 's/^.*staramr //' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir ${prefix}_results
    touch ${prefix}_results/results.staramr.xlsx
    touch ${prefix}_results/{${prefix}_summary,${prefix}_detailed_summary,${prefix}_resfinder,${prefix}_pointfinder,${prefix}_plasmidfinder,mlst}.staramr.tsv
    touch ${prefix}_results/settings.staramr.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        staramr : \$(echo \$(staramr --version 2>&1) | sed 's/^.*staramr //' )
    END_VERSIONS
    """
}
