/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    DETECT VIRULENCE FACTORS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Screens MAG assemblies against the VFDB database using ABRicate.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { ABRICATE_RUN     } from '../../modules/local/abricate_run'
include { ABRICATE_SUMMARY } from '../../modules/local/abricate_summary'

workflow DETECT_VF {

    take:
    ch_mags  // channel: [ val(meta), path(fasta) ]

    main:
    //
    // MODULE: Run ABRicate against VFDB
    //
    ABRICATE_RUN(
        ch_mags,
        'vfdb'
    )

    //
    // MODULE: Summarize all VF reports
    //
    ch_all_reports = ABRICATE_RUN.out.report
        .map { meta, report -> report }
        .collect()

    ABRICATE_SUMMARY(
        ch_all_reports,
        'vf'
    )

    emit:
    reports = ABRICATE_RUN.out.report       // channel: [ val(meta), path(report) ]
    summary = ABRICATE_SUMMARY.out.summary  // channel: [ path(summary) ]
}
