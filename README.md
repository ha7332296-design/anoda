# anoda — VF & ARG Detection Pipeline

A Nextflow DSL2 pipeline for detecting **Virulence Factors (VF)** and **Antimicrobial Resistance Genes (ARGs)** from Metagenome-Assembled Genomes (MAGs).

## Pipeline Overview

```
MAG FASTA files (samplesheet.csv)
        │
        ├──► DETECT_VF ──► ABRicate (VFDB)
        │
        ├──► DETECT_ARG ──► ABRicate (CARD/ResFinder/NCBI/ARG-ANNOT)
        │                    OR AMRFinderPlus (selectable)
        │
        └──► SUMMARIZE ──► Combined report (TSV)
```

## Quick Start

```bash
nextflow run ha7332296-design/anoda \
    --input samplesheet.csv \
    --outdir results \
    -profile docker
```

## Samplesheet Format

```csv
sample,fasta
MAG_001,/path/to/mag_001.fasta
MAG_002,/path/to/mag_002.fasta
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--input` | — | Path to samplesheet CSV |
| `--outdir` | `results` | Output directory |
| `--vf_db` | `vfdb` | VF database (ABRicate) |
| `--vf_min_id` | `80` | Minimum % identity for VF hits |
| `--vf_min_cov` | `80` | Minimum % coverage for VF hits |
| `--arg_tool` | `abricate` | ARG tool: `abricate` or `amrfinderplus` |
| `--arg_db` | `card` | ARG database: `card`, `resfinder`, `ncbi`, `argannot` |
| `--arg_min_id` | `80` | Minimum % identity for ARG hits |
| `--arg_min_cov` | `80` | Minimum % coverage for ARG hits |

## Tools

- **[ABRicate](https://github.com/tseemann/abricate)** v1.4.0 — Mass screening of assemblies against multiple databases
- **[AMRFinderPlus](https://github.com/ncbi/amr)** v4.2.7 — NCBI AMR gene detection with point-mutation support

## Output Structure

```
results/
├── abricate/           # Per-sample VF and ARG reports
├── amrfinderplus/      # Per-sample AMRFinderPlus reports (if selected)
├── summary/            # Aggregated summaries
│   ├── vf_summary.tsv
│   ├── arg_summary.tsv
│   └── combined_report.tsv
└── pipeline_info/      # Execution reports
```

## Profiles

- `docker` — Run with Docker containers
- `singularity` — Run with Singularity containers
- `conda` — Run with Conda environments
- `test` — Use bundled test samplesheet

## Requirements

- Nextflow ≥ 24.04
- Docker, Singularity, or Conda