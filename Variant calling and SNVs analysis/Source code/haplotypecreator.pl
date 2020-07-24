#!usr/bin/perl

use strict; #use warnings;

## usage: perl haplotypecreator.pl <de novo mutations> <vcf file>

open(my $in, "<", "$ARGV[0]") or die "can't open file"; ## open list of de novo mutations
open(my $in1, "<", "$ARGV[1]") or die "can't open file"; ## open vcf file
#open(my $out, ">", "$ARGV[0].annotation") or die "error creating file";

my @regions;
my $chr;
my $initpos;
my $endpos;
my %listofsnps;
my $flag;

## split vcf file and memorize each allelic position and status
while(<$in1>) {
	chomp;

        @regions = split(/\s+/, $_);
	#print 
"|$regions[0]|\t|$regions[1]|\t|$regions[2]|\t|$regions[3]|\t|$regions[4]|\t|$regions[5]|\t|$regions[6]|\t|$regions[7]|\t|$regions[8]|\t|$regions[9]|\t|$regions[10]|\t|$regions[11]|\t|$regions[12]|\t|$regions[13]|\t|$regions[14]|\t|$regions[15]|\n";
	$listofsnps{$regions[0]}{$regions[1]}=$regions[4];
	#print "$listofsnps{$regions[8]}{$regions[0]}\n";
}

## check which allele is present at each de novo mutation position in the sample
while(<$in>) {
	chomp;

	($chr, $initpos, $endpos) = split(/\s+/, $_);
	#print "|$chr|\t|$initpos|\t|$endpos|\n";
	foreach my $snpchr (keys %listofsnps) {
		foreach my $snpposition (keys %{$listofsnps{$snpchr}}) { $flag = "REF";
		if (exists $listofsnps{$chr}{$initpos}) {$flag=$listofsnps{$chr}{$initpos}; last;}
		}
	}
print "$chr\t$initpos\t$flag\n";
}
