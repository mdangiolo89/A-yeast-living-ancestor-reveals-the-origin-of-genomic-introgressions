
bin="/home/jxyue/Programs/"
for a in *OSW_[0-9]_1_*gz; do
sample=${a/\OSW_[0-9]_1_*gz/}
run="Run3";
refseq="DBVPG6765.genome.fa"
ref=${refseq/\.genome.fa/}
echo "$refseq"
echo "$ref"
read1="$a"
read2=${a/\_1_/\_2_}
echo "$read1 $read2";
echo "sample: $sample";



#trimmomatic-0.36.jar PE -threads 4 -phred33  $read1  $read2  trimmomatic_f_paired.fq.gz trimmomatic_f_unpaired.fq.gz trimmomatic_r_paired.fq.gz trimmomatic_r_unpaired.fq.gz ILLUMINACLIP:adapter.fa:2:30:10  SLIDINGWINDOW:5:20 
#MINLEN:36

#mv trimmomatic_f_paired.fq.gz ${sample}_1_trim.fq.gz
#mv trimmomatic_r_paired.fq.gz ${sample}_2_trim.fq.gz
#rm trimmomatic_f_unpaired.fq.gz
#rm trimmomatic_r_unpaired.fq.gz 



# bwa  mapping
#ln -s $refseq refseq.fa
bwa index $refseq
bwa mem -t 4 -M $refseq $read1 $read2 > ${sample}_${ref}_${run}.sam



# ## index reference sequence

samtools faidx $refseq

java -jar picard.jar CreateSequenceDictionary  REFERENCE=$refseq OUTPUT=$refseq.dict



# # # # sort bam file by picard-tools: SortSam
mkdir tmp

#java   -jar $bin/picard/picard.jar SortSam  INPUT=${sample}_${ref}_${run}.sam OUTPUT=${sample}_${ref}_${run}.sort.bam SORT_ORDER=coordinate TMP_DIR=./tmp
samtools sort ${sample}_${ref}_${run}.sam > ${sample}_${ref}_${run}.sort.bam

# # ## fixmate

java -jar picard.jar FixMateInformation INPUT=${sample}_${ref}_${run}.sort.bam OUTPUT=${sample}_${ref}_${run}.fixmate.bam



# # ## add or replace read groups and sort

java -jar picard.jar AddOrReplaceReadGroups INPUT=${sample}_${ref}_${run}.fixmate.bam OUTPUT=${sample}_${ref}_${run}.rdgrp.bam \
    SORT_ORDER=coordinate RGID=${sample}_${ref}_${run} RGLB=${sample}_${ref}_${run} RGPL="Illumina" RGPU=${sample}_${ref}_${run} \
    RGSM=${sample} RGCN="Sanger"


# # # index the rdgrp.bam file
samtools index ${sample}_${ref}_${run}.rdgrp.bam


# # ## Picard tools remove duplicates
java -jar picard.jar MarkDuplicates INPUT=${sample}_${ref}_${run}.rdgrp.bam REMOVE_DUPLICATES=true  \
    METRICS_FILE=${sample}_${ref}_${run}.dedup.matrics  OUTPUT=${sample}_${ref}_${run}.dedup.bam 



# # # index the dedup.bam file
samtools index ${sample}_${ref}_${run}.dedup.bam


## coverage computation
samtools depth -ab DBVPG6765.markers.bed ${sample}_${ref}_${run}.dedup.bam > ${sample}_${ref}_${run}.dedup.bam.dat
#perl extractcoverage.pl >> autoextractcoverage.R
#R CMD BATCH autoextractcoverage.R

## variant calling and filtering: please fill up the sample_infoDBV.txt file before running this command
perl variantcallerSpar.pl


## annotate genotype of the sample for every marker between DBVPG6765 and CBS432
chrlist="chrI chrII chrIII chrIV chrV chrVI chrVII chrVIII chrIX chrX chrXI chrXII chrXIII chrXIV chrXV chrXVI"
for chr in $chrlist
do 
perl genotypeassignerSpar.pl ${sample}_${ref}_${run}.dedup.bam.dat ${sample}_${ref}_${run}.FreeBayes.snps.Q20.${chr}.vcf.recode.vcf DBVPG6765_CBS432_LOHmarkers.txt
done 

## annotate homozygous (C.annotation) and heterozygous (H.annotation) LOH/introgression blocks in bed format
for chr in $chrlist
do
perl annotatorC.pl ${sample}_${ref}_${run}.FreeBayes.snps.Q20.${chr}.vcf.recode.vcf.genotype
perl annotatorH.pl ${sample}_${ref}_${run}.FreeBayes.snps.Q20.${chr}.vcf.recode.vcf.genotype
done


## remove old files

rm ${sample}_${ref}_${run}.sam
rm ${sample}_${ref}_${run}.sort.bam
rm ${sample}_${ref}_${run}.fixmate.bam
rm ${sample}_${ref}_${run}.rdgrp.bam
#rm ${sample}_${ref}_${run}.dedup.bam
rm ${sample}_${ref}_${run}.dedup.matrics

rm -r ./tmp

done;
    
