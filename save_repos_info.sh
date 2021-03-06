#!/usr/bin/env bash

usage="$(basename "$0") [-h] [-f FILENAME] [-d DIRECTORIES]
Save a yaml file to FILENAME with a summary of all git repositories in DIRECTORIES (default current directory):
    -h  show this help text
    -f  target yaml file name
    -d  repositories basedir (can be repeated for multiple basedirs)
        default is current directory"


while getopts ":hf:d::" option
do
	case "${option}" in
	  h) echo "$usage"; exit;;
		d) DIRS+=("$OPTARG");;
    f) FILENAME=${OPTARG};;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
	esac
done

if [ ! "$FILENAME" ]; then
   echo "$usage" >&2; exit 1
fi

if [ ! "$DIRS" ]; then
  DIRS=("$(pwd)")
fi

function parse_git_dirname() {
  dirname "$(git --git-dir $1/.git rev-parse --show-toplevel 2> /dev/null | sed "s/\(.*\)/\1/")"
}

function parse_git_basename() {
  basename "$(git --git-dir $1/.git rev-parse --show-toplevel 2> /dev/null | sed "s/\(.*\)/\1/")"
}

# checks if branch has something pending
function parse_git_dirty() {
  git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ] && echo "*"
}

# gets the current git branch
function parse_git_branch() {
  git --git-dir $1/.git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1/"
}

# get last commit hash prepended with @ (i.e. @8a323d0)
function parse_git_hash() {
  git --git-dir $1/.git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)/\1/"
}

# get remote  
function get_remote_url() {
  git --git-dir $1/.git config --get remote.$2.url
}

if [[ -f "$(readlink -f "$FILENAME")" ]]; then
#  echo "WARNING: $FILENAME already exist, saving a backup before overwriting it"
#  cp "$(readlink -f "$FILENAME")" "$(readlink -f "$FILENAME")".backup
  rm "$(readlink -f "$FILENAME")"
fi

echo "repos:" >> "$(readlink -f "$FILENAME")"

for dir in "${DIRS[@]}"; do
  for f in "$dir"/*; do
    if [[ -d "$f/.git" ]]; then
      echo "  - root: $(readlink -f "$dir")
    name: $(basename "$f")
    branch: $(parse_git_branch "$f")
    commit: $(parse_git_hash "$f") 
    origin: $(get_remote_url "$f" "origin")">> "$(readlink -f "$FILENAME")"
  echo >> "$(readlink -f "$FILENAME")"
    fi
  done
done



