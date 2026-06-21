/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUMMARIZE RESULTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Combines VF and ARG detection results into a unified summary report.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MERGE_REPORTS } from '../../modules/local/merge_reports'

workflow SUMMARIZE {

    take:
    ch_vf_reports   // channel: [ val(meta), path(report) ]
    ch_arg_reports  // channel: [ val(meta), path(report) ]

    main:
    //
    // MODULE: Merge all VF and ARG reports into a combined TSV
    //
    ch_all_reports = ch_vf_reports
        .mix(ch_arg_reports)
        .map { meta, report -> report }
        .collect()

    MERGE_REPORTS(ch_all_reports)

    emit:
    combined_report = MERGE_REPORTS.out.report  // channel: [ path(combined_report) ]
}
