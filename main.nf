#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VF & ARG Detection Pipeline
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Detect Virulence Factors (VF) and Antimicrobial Resistance Genes (ARGs)
    from Metagenome-Assembled Genomes (MAGs).
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

nextflow.enable.strict = true

include { validateParameters; paramsSummaryLog } from 'plugin/nf-schema'
include { DETECT_VF      } from './subworkflows/local/detect_vf'
include { DETECT_ARG     } from './subworkflows/local/detect_arg'
include { SUMMARIZE      } from './subworkflows/local/summarize'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

validateParameters()
log.info paramsSummaryLog(workflow)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    // Parse samplesheet: each row = one MAG FASTA
    ch_input = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            def meta = [id: row.sample]
            def fasta = file(row.fasta, checkIfExists: true)
            [meta, fasta]
        }

    //
    // SUBWORKFLOW: Detect Virulence Factors
    //
    DETECT_VF(ch_input)

    //
    // SUBWORKFLOW: Detect Antimicrobial Resistance Genes
    //
    DETECT_ARG(ch_input)

    //
    // SUBWORKFLOW: Summarize all results
    //
    ch_vf_reports  = DETECT_VF.out.reports
    ch_arg_reports = DETECT_ARG.out.reports

    SUMMARIZE(
        ch_vf_reports,
        ch_arg_reports
    )
}
