#!/usr/bin/env python
#####
# Name:     CovToMetrics.py
# Author:   AyhanDH
# Description:  "Takes Bedtools genomecov output, calculates metrics, 
#               and writes output to tab delimeted file"
# Usage:    python CovToMetrics.py INPUT.cov.txt OUTPUT.txt

import sys
import numpy as np

def mad(data):
    return np.median(np.absolute(data - np.median(data)))


inCov = sys.argv[1]
IN = open(inCov, 'r')
output = sys.argv[2]

dict_seq = {}
lines = IN.readlines()
for line in lines :
	line = line.strip()
	line_list = line.split('\t')
	if line_list[0] not in dict_seq.keys() :
		dict_seq[line_list[0]] = []
	n = int(line_list[2])
	dict_seq[line_list[0]].append(n)
IN.close()

OUT = open(output, 'a')
s = '#Seq_name\tlength\ttotal_read_count\tmin_cov\tmax_cov\tmean\tstd\tmedian\tmad\n'
OUT.write(s)
for key, value in dict_seq.items() :
	length = len(value)
	total_read_count = sum(value)
	min_cov = min(value)
	max_cov = max(value)
	avg = np.mean(value)
	stdev = np.std(value)
	med = np.median(value)
	medabdev = mad(value)
	s = key + '\t' + str(length) + '\t' + str(total_read_count) + '\t' + str(min_cov) + '\t' + str(max_cov)	+ '\t' + str(avg) + '\t' + str(stdev) + '\t' + str(med) + '\t' + str(medabdev) + '\n'
	OUT.write(s)
OUT.close()