#!/bin/bash

INPUT='urls.txt'

readarray -t urls < ${INPUT}

for url in "${urls[@]}"; do
        new_url="$(echo $url | cut -d '.' -f 2)"
        curl --head $url > $new_url.txt
done
