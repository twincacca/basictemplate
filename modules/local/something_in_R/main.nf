process SOME_R_PROCESS {
    tag "$input_file"
    label 'process_low'

    conda "conda-forge::r-base=4.1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-base:4.1.0' :
        'quay.io/biocontainers/r-base:4.1.0' }"

    input:
    path input_file

    output:
    path "*_analyzed.txt", emit: analyzed_data
    path "versions.yml"  , emit: versions

    script:
    """
    #!/usr/bin/env Rscript
    input_data <- read.table("${input_file}", header=FALSE, col.names=c("value"))
    summary_stats <- summary(input_data\$value)
    sink("${input_file.baseName}_analyzed.txt")
    cat("Summary Statistics:\\n")
    print(summary_stats)
    cat("\\nSum:", sum(input_data\$value))
    sink()

    writeLines(c(
        '"${task.process}":',
        paste0('    r-base: ', R.version.string)
    ), 'versions.yml')
    """
}


