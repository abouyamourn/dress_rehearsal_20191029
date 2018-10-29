#!/bin/bash
for i in $( ls scrapers );
do
    Rscript scrapers/$i &
done
