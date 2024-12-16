/*
 * Do something in python: generate 10 random numbers
 */

process SOME_PYTHON_PROCESS {
    tag "$input_file"
    label 'process_low'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9.5' :
        'quay.io/biocontainers/python:3.9.5' }"

    input:
    path input_file

    output:
    path "*_processed.txt", emit: processed_data
    path "versions.yml"   , emit: versions

    script:
    """
    python3 <<EOF

import sys
import random

with open("${input_file}", "r") as f:
    number = int(f.read().strip())

result = [random.randint(5, 15) for i in range(0, number)]

with open("${input_file.baseName}_processed.txt", "w") as f:
    for item in result:
        f.write(f"{item}\\n")

EOF

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}


