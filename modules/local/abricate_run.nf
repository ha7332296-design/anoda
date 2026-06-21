process ABRICATE_RUN {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::abricate=1.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate:1.4.0--ha8f3691_0' :
        'biocontainers/abricate:1.4.0--ha8f3691_0' }"

    input:
    tuple val(meta), path(assembly)
    val(database)

    output:
    tuple val(meta), path("*.txt"), emit: report
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    abricate \\
        ${assembly} \\
        --db ${database} \\
        --threads ${task.cpus} \\
        ${args} \\
        > ${prefix}_${database}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(abricate --version 2>&1 | sed 's/^.*abricate //')
    END_VERSIONS
    """
}
