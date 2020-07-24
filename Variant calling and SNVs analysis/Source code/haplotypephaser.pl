#!usr/bin/perl

use strict; #use warnings;

## usage: perl haplotypephaser.pl <introgressions coordinates> <haplotypecreator.pl output file> <de novo mutations alleles>

#open(my $in, "<", "$ARGV[0]") or die "can't open file";
open(my $in1, "<", "$ARGV[1]") or die "can't open file"; ## open output file of haplotypecreator.pl
open(my $in2, "<", "$ARGV[2]") or die "can't open file"; ## open list of de novo mutations in the living ancestor and their de novo alleles
#open(my $in3, "<", "$ARGV[3]") or die "can't open file";

my @regions;
my $chr;
my $initpos;
my $endpos;
my %hash1;
my $nome1;
my $start1;
my $allele1;

## open and parse de novo alleles present in the living ancestor in the de novo mutations positions 
while(<$in2>) {
chomp;

($nome1, $start1, $allele1) = split(/\s+/, $_);
#print "|$nome1|\t|$start1|\t|$allele1|\n";
$hash1{$nome1}{$start1}{'allele1'}=$allele1;
#print "$nome1\t$hash1{$nome1}{$start1}{'allele1'}\n";
}

my $flag;
	
	## parse and memorize alleles present at the de novo mutations positions in the sample 
	while(<$in1>) {
		chomp;
		@regions = split(/\s+/, $_); #print "$regions[0]\t$regions[1]\t$regions[2]\n";
		open(my $in, "<", "$ARGV[0]") or die "can't open file";	## open introgression coordinates in the Alpechins (bed format)
		$flag="NA";

		## parse introgression coordinates
		while(<$in>) {
		chomp;
		($chr, $initpos, $endpos) = split(/\s+/, $_);
		#print "|$chr|\t|$initpos|\t|$endpos|\n";
		
		if ($chr eq $regions[0] && $initpos <= $regions[1] && $endpos >= $regions[1]) {#print "PI\n";
			foreach my $chromosome (sort {$a <=> $b} keys %hash1) {
				if ($regions[0] eq $chromosome) {#print "T\n";
					foreach my $haplotype (keys %{$hash1{$chromosome}}) {
						if ($regions[1] eq $haplotype) {#print "EH\n";
						if ($regions[2] eq $hash1{$chromosome}{$haplotype}{'allele1'}) {$flag=$hash1{$chromosome}{$haplotype}{'allele1'}}
						elsif ($regions[2] eq 'REF') {$flag="REF";}
						}
					}
				}
			}
		}
	}
print "$flag\n";
}
