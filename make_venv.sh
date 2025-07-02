#!/bin/bash
# script: make_venv.sh
# auth: Nathan T. Stevens
# org: PNSN
# license: CC 4.0 BY
# purpose: Builds a Python3 Virtual Environment (VENV) for 
#   the codes in this repository with options to alter the 
#   VENV name

VENV=MY_VENV
devmode=false

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "-h, --help            Display this help message"
    echo "-N, --name <newname>  Overwrite default VENV name '${VENV}'"
    echo "-X, --delete          Delete VENV (can be combined with -N)"
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2"  && "$2" != -* ) ]];
}

extract_argument() {
    echo "${2:-${1#*=}}"
}

handle_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                usage
                exit 0
                ;;
            -N | --name)
                if ! has_argument $@; then
                    echo "Must specify a name for the VENV" >&2
                    usage
                    exit 1
                fi
                
                VENV=$(extract_argument $@)

                shift
                ;;
            -X | --delete)
                deletemode=true
                ;;
            *)
                echo "Invalid option: $1" >&2
                usage
                exit 1
                ;;
        esac
        shift
    done
}

handle_options "$@"

# echo "$VENV"
# echo "devmode == $devmode"

if [[ "$deletemode" == true ]]; then
    if [[ -d "$VENV" ]]; then
        echo "deleting ${VENV}"
        rm -r $VENV
        rmdir $VENV
    fi

    if [[ -f "activate_venv" ]]; then
        echo "deleting simlink 'activate_venv'"
        rm activate_venv
    fi
    echo "--- uninstall successful ---"
    exit 0
else
    # Create venv
    python3 -m venv $VENV
    # Activate venv
    source ${VENV}/bin/activate
    # Install & update pip
    python3 -m pip install --update pip
    # Install requirements
    pip install -r ./requirements.txt

    # Create simlink for convenience
    ln -s ${VENV}/bin/activate ./activate_venv

    # Add non-standard VENV name to .gitignore
    if [[ "$VENV" != "MY_VENV" ]]; then
        echo "Adding ${VENV} directory to .gitignore file"
        echo "${VENV}" >> .gitignore
    fi
    # Exit with success message
    echo "--- install successful ---"
    echo "You can activate ${VENV} by sourcing the simlink 'activate_venv'"
    echo "or by sourcing ${VENV}/bin/activate"
    exit 0
fi

