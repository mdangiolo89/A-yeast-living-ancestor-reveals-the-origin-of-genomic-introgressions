# A-yeast-living-ancestor-reveals-the-origin-of-genomic-introgressions

This repository contains supporting material for the manuscript:

"A yeast living ancestor reveals the origin of genomic introgressions"

Melania D’Angiolo, Matteo De Chiara, Jia-Xing Yue, Agurtzane Irizar, Simon Stenberg, Karl Persson, Agnès Llored, Benjamin Barré, Joseph Schacherer, Roberto Marangoni, Eric Gilson, Jonas Warringer, Gianni Liti


To clone this repository, run the following command in a local directory:

$ git clone https://github.com/mdangiolo89/A-yeast-living-ancestor-reveals-the-origin-of-genomic-introgressions.git


# Manuscript
This folder contains main figures and supplementary figures, supplementary tables and source data files underlying each plot. The alignment used to build figure 1a is available upon request.


# Sequence data
Sequence data for the strains belonging to the Alpechin, Brazilian bioethanol, Mexican agave and French Guyana clades were part of another study and were previously submitted to the Sequence Read Archive (SRA) NCBI under the accession number ERP014555. The genome sequences generated in this study are available at Sequence Read Archive (SRA), NCBI under the accession codes BioProject ID PRJNA594913, Biosample ID SAMN13540515 - SAMN13540586.


# Sequencing and de novo assembly of the living ancestor’s genome
This folder contains genome assemblies of the living ancestor based on short- (Illumina) and long-read (PacBio) sequencing.


# Mapping LOH and introgressions’ boundaries
This dataset comprises the reference genomes used in this paragraph of the manuscript, their subtelomeric coordinates and a list of reliable markers used to define loss-of-heterozygosity (LOH) regions in the living ancestor and introgression regions in the Alpechin, Brazilian bioethanol, Mexican agave and French Guyana clades.
Files and scripts needed to reproduce the analyses performed in the paper are contained in the subfolders "Base files" and "Source code", respectively.
A set of Illumina reads to reproduce the analyses performed in the paper is provided in the subfolder "Example". 

Usage:

Please download all the files in this folder, including the reads, the base files and the scripts, and put them all in the same local directory on your computer. Prior to start the analysis, ensure that the file "sample_infoDBV.txt" contains the prefix of the example reads (BCM_AQF) and the prefix of the reference genome on which you want to perform the mapping and variant calling (DBVPG6765 in this case). If you want to perform this analysis on other samples included in the paper, ensure to change the corresponding strings in the file "sample_infoDBV.txt".
In addition, before starting the analysis it is necessary to decompress the file "DBVPG6765_CBS432_LOHmarkers.txt.tar.gz" and name it "DBVPG6765_CBS432_LOHmarkers.txt".

To launch the analysis, type on the command line:

$ sh annotateLOHintrogressions.sh

Since the analysis might take long to perform, it is recommended to use the options "nohup" to ensure that the process keeps running if the connection with the server is lost, and "&" to launch the process in background.
The pipeline will produce many intermediate files, including bam files, vcf files and coverage files. The final files have the suffix "[CH].annotation and contain coordinates of LOH (in case the living ancestor is analysed, as in this example) or introgressions (in case Alpechin strains are analysed), in bed format. The file "$sample....C.annotation" contains coordinates in which the sample presents consecutive CBS432 (S. paradoxus) markers in homozygous state. The file "$sample....H.annotation" contains coordinates in which the sample presents consecutive CBS432 (S. paradoxus) markers in heterozygous state. For a correct interpretation of the results, it is essential to consider the genomic background of your sample. In the case of the hybrid genome of the living ancestor and its derived clones, the coordinates included in the "$sample....C.annotation" file must be considered as homozygous S. paradoxus LOH, and the coordinates included in the "$sample....H.annotation" file must be considered as heterozygous regions of the genome.
In the case of the Alpechins, the coordinates included in the "$sample....C.annotation" file must be annotated as homozygous introgressions, and the coordinates included in the "$sample....H.annotation" file must be annotated as heterozygous introgressions.

Please note that the same set of scripts has been used to annotate LOH and introgression regions in other samples included in the paper, which have a different structure in the name of their reads. For these additional samples, a modified version of the pipeline must be used and is available upon request.

Pan-introgression maps for all the introgressed clades (Alpechin, Brazilian bioethanol, Mexican agave and French Guyana) are provided in a separate subfolder.


# Variant calling and SNVs analysis
This folder contains the reference genome used in this paragraph of the manuscript, as well as a list of heterozygous de novo mutations present in the living ancestor's S. paradoxus and S. cerevisiae LOH blocks. Tables indicating the allele present at each of these sites for all the Alpechin strains and the 25 living ancestor's gametes are also provided. Additional files contain the list of alleles present in the S. paradoxus and the S. cerevisiae haplotypes of the living ancestor's genome.


# Estimation of the living ancestor's base substitution rate and phenotypic impact
This folder contains a list of de novo mutations occurred during the return-to-growth (RTG) and mutation accumulation lines (MAL) experiments. 


# Molecular dating of genome instability and Alpechin emergence
The list of synonymous sites used for the estimation based on the strict molecular clock model is provided, along with the fasta sequences used for the estimation based on the random, local molecular clock model.


# GO term analysis and annotation of LOH and introgressed genes
We provide a complete list of introgressed genes present in the Alpechin, Brazilian bioethanol, Mexican agave and French Guyana clades.
