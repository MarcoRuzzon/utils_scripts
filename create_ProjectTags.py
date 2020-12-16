#!/usr/bin/env python

import argparse
import yaml

parser = argparse.ArgumentParser(description="Create a ProjectTags.cmake from the yaml config file \
 generated by save_repos_info.py script. Then substitute this file in the cmake dir of the superbuild. This will \
 checkout repos to the corresponding commits as specified in the yaml file")
parser.add_argument('FILENAME', help="the yaml file containing git repos info")
args = parser.parse_args()

with open(args.FILENAME) as file:
    try:
        info = yaml.safe_load(file)

    except Exception as e:
        raise Exception('error in yaml parsing')

template = "set({}_TAG {})\n"
with open('ProjectsTags.cmake', "w") as f:
    for item in info['repos']:
        f.write(template.format(item['name'], item['commit']))
