#!/bin/bash
#
# Use this script to setup an environment for running VHDL test benches with
# VUnit using GHDL for simulation. Subdirectories will be created next to this
# script to contain an install of GHDL built from source and a Python virtual
# environment with VUnit installed. At the time of writing, the current stable
# release versions are VUnit v4.7.1 and GHDL v6.0.0.

set -euo pipefail

print_usage() {
    echo "
usage: ${0##*/}

Use this script to install VUnit and GHDL for VHDL simulation/testing.
"
}

die() {
    local usage=
    [ $# -gt 0 ] && [ "$1" = "-u" ] && usage="y" && shift
    [ $# -gt 0 ] && if [ -t 2 ]; then
        echo -e "\n\033[31m ** $*\033[m"
    else
        echo -e "\n ** $*"
    fi
    [ "$usage" ] && print_usage
    exit 1
} >&2

say() {
    if [ -t 1 ]; then
        echo -e "\033[30m\033[42m >>\033[m $*"
    else
        echo " >> $*"
    fi
}

warn() {
    if [ -t 1 ]; then
        echo -e "\033[30m\033[43m !!\033[m $*"
    else
        echo " !! $*"
    fi
}

while getopts ":h" opt; do
    case $opt in
    h)
        print_usage
        exit 0
        ;;
    :)
        die -u "-$OPTARG requires an argument"
        ;;
    ?)
        die -u "Invalid option given: $OPTARG"
        ;;
    esac
done

declare -ar needed_tools=(
    dirname git gnat make mkdir python3 realpath
)

say "Checking for needed tools: ${needed_tools[*]}"
type "${needed_tools[@]}" > /dev/null 2>&1 ||
    die "One or more of the needed tools are missing: ${needed_tools[*]}"

script_dir="$(dirname "$(realpath "$0")")"
readonly script_dir
say "Creating directory structure"
mkdir -p "$script_dir"/{vunit,ghdl/{build,install}}

declare -r ghdl_repo_uri=https://github.com/ghdl/ghdl.git ghdl_version=v6.0.0
declare -r ghdl_dir="$script_dir/ghdl"
declare -r ghdl_install_dir="$ghdl_dir/install"

say "Changing to $ghdl_dir"
cd "$ghdl_dir" || die "Could not change to $ghdl_dir"

say "Cloning GHDL"
git clone -b $ghdl_version $ghdl_repo_uri repo ||
    die "Had trouble cloning GHDL repository"

say "Building GHDL"
cd build || die "Could not change to build directory"
../repo/configure --prefix="$ghdl_install_dir" ||
    die "Could not configure GHDL"
make || die "Had trouble building GHDL"
make install || die "Had trouble installing GHDL to $ghdl_install_dir"

declare -r vunit_dir="$script_dir/vunit" vunit_version=4.7.1

say "Changing to $vunit_dir"
cd "$vunit_dir" || die "Could not change to $vunit_dir"

say "Setting up virtual environment"
python3 -m venv venv || die "Had trouble setting up venv"

say "Activating venv and installing vunit"
# This file is created by the venv setup above, so silence shellcheck's
# complaint about the file not being there.
# shellcheck disable=SC1091
source venv/bin/activate || die "Failed to activate venv"
pip install vunit_hdl==$vunit_version || die "Failed to install vunit"

declare -r activation="$script_dir/activate-environment.sh"
say "Creating activation script"
echo "
# Source this file to add GHDL to your path and activate venv
PATH=$ghdl_install_dir/bin:\$PATH
source $vunit_dir/venv/bin/activate
" > "$activation" || die "Had trouble writing activation script"

say "Finished setting up tools. Activate environment by sourcing $activation."
