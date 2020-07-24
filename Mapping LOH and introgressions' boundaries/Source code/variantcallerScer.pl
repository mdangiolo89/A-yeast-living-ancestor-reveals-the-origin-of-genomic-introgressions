#!/usr/bin/perl
use warnings;
use strict;

my $bin = "/home/jxyue/Programs/GATK";
my $method = "FreeBayes";
my $refseq = "CBS432.genome.fa";
my $sample_info = "sample_infoCBS.txt";
my $sample_ploidy = 2;
my @chromosomes = ("chrI","chrII","chrIII","chrIV","chrV","chrVI","chrVII","chrVIII","chrIX","chrX","chrXI","chrXII","chrXIII","chrXIV","chrXV","chrXVI");

my $sample_info_fh = read_file($sample_info);

while (<$sample_info_fh>) {

    chomp;
   my ($sample_id, $sample_note) = split '\t', $_;
    print "sample_id = $sample_id, sample_note = $sample_note\n";
    my $sample_tag = $sample_id . "_$sample_note";
    print "$sample_tag\n";
    my $prefix = $sample_tag . "_" . "Run3";
    print "$prefix\n";
    #system("ln -s  ./../../Mapping/$sample_id\_Run2.realn.bam $sample_id\_Run2.bam");
    #system("ln -s  ./../../Mapping/$sample_id\_Run2.realn.bam.bai $sample_id\_Run2.bam.bai");
    system("freebayes -f $refseq -p $sample_ploidy $prefix.dedup.bam > $prefix.$method.snps_indels.raw.vcf");
    system("vcfallelicprimitives --keep-geno --keep-info $prefix.$method.snps_indels.raw.vcf > $prefix.$method.snps_indels.decomposed.vcf");
    system("vt normalize -r $refseq -o $prefix.$method.snps_indels.normalized.vcf $prefix.$method.snps_indels.decomposed.vcf");
    #system("java -jar $bin/GenomeAnalysisTK.jar -R $refseq -T SelectVariants -selectType SNP  --variant $prefix.$method.snps_indels.normalized.vcf  -o $prefix.$method.snps.normalized.vcf");
    #system("java -jar $bin/GenomeAnalysisTK.jar -R $refseq -T SelectVariants -selectType INDEL --variant $prefix.$method.snps_indels.normalized.vcf -o $prefix.$method.indels.normalized.vcf");
    system("vcftools --vcf $prefix.$method.snps_indels.normalized.vcf --remove-indels --recode --recode-INFO-all --out $prefix.$method.snps.normalized.vcf");
    system("vcffilter -f \"QUAL > 20 & QUAL / AO > 10 & SAF > 0 & SAR > 0 & RPR > 1 & RPL > 1\" $prefix.$method.snps.normalized.vcf.recode.vcf >$prefix.$method.snps.Q20.vcf");
    #system("/home/jxyue/Programs/vcflib/bin/vcffilter -f \"QUAL > 20 & QUAL / AO > 10 & SAF > 0 & SAR > 0 & RPR > 1 & RPL > 1\" $prefix.$method.indels.normalized.vcf >$prefix.$method.indels.Q20.vcf");
    foreach my $chr (@chromosomes) {  
    system("vcftools --vcf $prefix.$method.snps.Q20.vcf --chr $chr --recode --recode-INFO-all --out $prefix.$method.snps.Q20.$chr.vcf")} ;
    #system("vcftools --vcf $prefix.$method.indels.Q20.vcf --exclude-bed SGD_coordinatestofilter.bed --recode --recode-INFO-all --out $prefix.$method.indels.Q20.repfiltered.vcf");
    #system("sed 's/$sample_id/BB28/g' $prefix.$method.snps.Q20.vcf > $prefix.$method.snps.Q20.toBB28.vcf");
    #system("sed 's/$sample_id/BB28/g' $prefix.$method.indels.Q20.vcf > $prefix.$method.indels.Q20.toBB28.vcf");
    #system("bgzip $prefix.$method.snps.Q20.repfiltered.vcf.recode.vcf");
    #system("bgzip $prefix.$method.indels.Q20.repfiltered.vcf.recode.vcf");
    #system("tabix -p vcf $prefix.$method.snps.Q20.repfiltered.vcf.recode.vcf.gz");
    #system("tabix -p vcf $prefix.$method.indels.Q20.repfiltered.vcf.recode.vcf.gz");
    #system("/home/jxyue/local/bin/vcf-stats $prefix.$method.snps.Q20.repfiltered.vcf.recode.vcf.gz > $prefix.$method.snps.Q20.repfiltered.vcf.recode.vcf.stats");
    #system("/home/jxyue/local/bin/vcf-stats $prefix.$method.indels.Q20.repfiltered.vcf.recode.vcf.gz > $prefix.$method.indels.Q20.repfiltered.vcf.recode.vcf.stats");

# QUAL / AO > 10 additional contribution of each obs should be 10 log units (~ Q10 per read)
# SAF > 0 & SAR > 0 reads on both strands
# RPR > 1 & RPL > 1 at least two reads “balanced” to each side of the site
# DP > 20 at least coverage 16

    #system("rm $sample_tag.bam*");
    #exit;
} 


#system("/home/jxyue/local/bin/vcf-isec -n +2 BB28_Run1.ancestral.$method.snps.Q20.toBB28.vcf.gz BB65_Run1.control.$method.snps.Q20.toBB28.vcf.gz BB67_Run1.control.$method.snps.Q20.toBB28.vcf.gz BB77_Run1.rapamycin.$method.snps.Q20.toBB28.vcf.gz BB80_Run1.rapamycin.$method.snps.Q20.toBB28.vcf.gz | bgzip -c > BB28_BB65_BB67_BB77_BB80.commonvariants.snps.vcf.gz");
#system("/home/jxyue/local/bin/vcf-isec -n +2 BB28_Run1.ancestral.$method.indels.Q20.toBB28.vcf.gz BB65_Run1.control.$method.indels.Q20.toBB28.vcf.gz BB67_Run1.control.$method.indels.Q20.toBB28.vcf.gz BB77_Run1.rapamycin.$method.indels.Q20.toBB28.vcf.gz BB80_Run1.rapamycin.$method.indels.Q20.toBB28.vcf.gz | bgzip -c > BB28_BB65_BB67_BB77_BB80.commonvariants.indels.vcf.gz");
#system("tabix -p vcf BB28_BB65_BB67_BB77_BB80.commonvariants.snps.vcf.gz");
#system("tabix -p vcf BB28_BB65_BB67_BB77_BB80.commonvariants.indels.vcf.gz");
#system("cat refseq.fa | /home/jxyue/local/bin/vcf-consensus BB28_BB65_BB67_BB77_BB80.commonvariants.snps.vcf.gz > refseq.ancestral.snps.fa");
#system("cat refseq.ancestral.snps.fa | /home/jxyue/local/bin/vcf-consensus BB28_BB65_BB67_BB77_BB80.commonvariants.indels.vcf.gz > refseq.ancestral.snps_indels.fa");


sub read_file {
    my $filename = shift @_;
    my $fh;
    open($fh, $filename) or die "cannot open the input file $filename\n";
    return $fh;
}

