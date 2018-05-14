#!/bin/bash

bn="sdt-chart"

xelatex "$bn".tex

for ext in aux log; do
	if [ -f "$bn.$ext" ]; then
		rm "$bn.$ext"
	fi
done