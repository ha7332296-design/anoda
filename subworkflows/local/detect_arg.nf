/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    DETECT ANTIMICROBIAL RESISTANCE GENES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Screens MAG assemblies for ARGs. Supports two tools:
      - abricate (with CARD or ResFinder databases)
      - amrfinderplus (NCBI AMRFinderPlus)
    Selected via params.arg_tool parameter.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { ABRICATE_RUN     } from '../../modules/local/abricate_run'
include { AMRFINDERPLUS    } from '../../modules/local/amrfinderplus'
include { ABRICATE_SUMMARY } from '../../modules/local/abricate_summary'

workflow DETECT_ARG {

    take:
    ch_mags  // channel: [ val(meta), path(fasta) ]

    main:
    ch_reports = channel.empty()

    if (params.arg_tool == 'abricate') {
        //
        // MODULE: Run ABRicate against CARD or ResFinder
        //
        ABRICATE_RUN(
            ch_mags,
            params.arg_db
        )
        ch_reports = ABRICATE_RUN.out.report

    } else if (params.arg_tool == 'amrfinderplus') {
        //
        // MODULE: Run AMRFinderPlus
        //
        AMRFINDERPLUS(ch_mags)
        ch_reports = AMRFINDERPLUS.out.report

    } else {
        error "Unsupported ARG tool: ${params.arg_tool}. Use 'abricate' or 'amrfinderplus'."
    }

    //
    // MODULE: Summarize ARG reports (ABRicate format only)
    //
    if (params.arg_tool == 'abricate') {
        ch_all_reports = ch_reports
            .map { meta, report -> report }
            .collect()

        ABRICATE_SUMMARY(
            ch_all_reports,
            'arg'
        )
    }

    emit:
    reports = ch_reports  // channel: [ val(meta), path(report) ]
}
