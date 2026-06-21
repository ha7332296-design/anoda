process MERGE_REPORTS {
    label 'process_single'

    conda "conda-forge::coreutils=9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:22.04' :
        'ubuntu:22.04' }"

    input:
    path(reports)

    output:
    path "combined_report.tsv", emit: report

    script:
    """
    # Merge all TSV/TXT reports, keeping header from first file
    head -n 1 \$(ls *.txt *.tsv 2>/dev/null | head -1) > combined_report.tsv
    for f in *.txt *.tsv; do
        [ -f "\$f" ] && tail -n +2 "\$f" >> combined_report.tsv
    done
    """
}
