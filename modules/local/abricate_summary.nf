process ABRICATE_SUMMARY {
    label 'process_single'

    conda "bioconda::abricate=1.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate:1.4.0--ha8f3691_0' :
        'biocontainers/abricate:1.4.0--ha8f3691_0' }"

    input:
    path(reports)
    val(report_tag)

    output:
    path "*.tsv"        , emit: summary
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    abricate \\
        --summary \\
        ${args} \\
        ${reports} \\
        > ${report_tag}_summary.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(abricate --version 2>&1 | sed 's/^.*abricate //')
    END_VERSIONS
    """
}
