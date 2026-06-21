process AMRFINDERPLUS {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::ncbi-amrfinderplus=4.2.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ncbi-amrfinderplus:4.2.7--hf69fac8_0' :
        'biocontainers/ncbi-amrfinderplus:4.2.7--hf69fac8_0' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.tsv"), emit: report
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    amrfinder_update --force_update --database amrfinderdb

    amrfinder \\
        --nucleotide ${fasta} \\
        --database amrfinderdb \\
        --threads ${task.cpus} \\
        --plus \\
        ${args} \\
        --output ${prefix}_amrfinderplus.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        amrfinderplus: \$(amrfinder --version)
    END_VERSIONS
    """
}
