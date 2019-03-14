#!/bin/bash
# DEFINITION: Maps and counts fastq reads to given reference sequences. Requires: bowtie2, samtools, bedtools
# USAGE:
# GetSeqCovs PrefixForOutputs /PATH/TO/sequences.fasta /PATH/TO/reads1.fast{q|a} [/PATH/TO/reads2.fast{q|a}]

GetSeqCovs () {
prefix=$1
tmpdir="TMP_"$prefix"_"$(date +"%Y%m%d%H%M")
mkdir $tmpdir
cp $2 $tmpdir"/library.fasta"
reads1=$3

if [ $# -gt 3 ]
then
reads2=$4
paired=1
else
paired=0
fi

if [ ${reads1:(-1)} == 'q' ]
then
fq=1
else
fq=0
fi

if [[ $paired -eq 1 && $fq -eq 1 ]]
then
options="--quiet -q -a -p 5 -x "$tmpdir"/library.bt2 -1 "$reads1" -2 "$reads2" -S "$tmpdir"/alingments.sam"
elif [[ $paired -eq 1 && $fq -eq 0 ]]
then
options="--quiet -f -a -p 5 -x "$tmpdir"/library.bt2 -1 "$reads1" -2 "$reads2" -S "$tmpdir"/alingments.sam"
elif [[ $paired -eq 0 && $fq -eq 1 ]]
then
options="--quiet -q -a -p 5 -x "$tmpdir"/library.bt2 -U "$reads1" -S "$tmpdir"/alingments.sam"
else
options="--quiet -f -a -p 5 -x "$tmpdir"/library.bt2 -U "$reads1" -S "$tmpdir"/alingments.sam"
fi

echo "Preparing reference fasta for "$prefix
bowtie2-build -q $tmpdir"/library.fasta" $tmpdir"/library.bt2"
samtools faidx $tmpdir"/library.fasta"

echo "Starting mapping for "$prefix" with options "$options
bowtie2 $options

echo "Converting SAM to BAM for "$prefix
samtools view -F 4 -o $tmpdir"/alingments.bam" $tmpdir"/alingments.sam"

echo "Sorting BAM file for "$prefix
samtools sort -o $prefix".bam" $tmpdir"/alingments.bam"
samtools index $prefix".bam"

echo "Preparing genome goverage file for "$prefix
bedtools genomecov -d -ibam $prefix".bam" -g $tmpdir"/library.fasta.fai" > $prefix".cov.txt"

rm -r $tmpdir
echo "Temporary directory "$tmpdir" is deleted."
echo $prefix" is processed."
}
