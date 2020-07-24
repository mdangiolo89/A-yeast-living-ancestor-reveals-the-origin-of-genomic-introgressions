#!usr/bin/perl

use strict; #use warnings;

## usage: perl genotypeassignerScer.pl <coverage file> <vcf file> <markers list>

open(my $in, "<", "$ARGV[0]") or die "can't open file"; ## open coverage file
open(my $in1, "<", "$ARGV[1]") or die "can't open file"; ## open vcf file (by chromosome)
open(my $in2, "<", "$ARGV[2]") or die "can't open file"; ## open list of markers
open(my $out, ">", "$ARGV[1].genotype") or die "can't open file"; ## write genotype/marker in the output file (it has the suffix ".genotype")

my $chr;
my $position;
my $coverage;
my %covlist;
my %snplist;
my %possiblesnplist;
my $nameofchr; 
my $snpposition;
my $balance;
my $frequency;
my $snpcoverage;
my $id;
my $bp1;
my $bp2;
my $quality;
my $info;
my $format;
my $sample;
my $filter;

## open and parse coverage file to find the coverage of each marker
while (<$in>) {
chomp;
($chr,$position,$coverage)=split(/\s+/,$_);
if ($position =~ m/"/) {$position =~ s/"//g}
#print "|$position|\t|$coverage|\n";
$covlist{$chr}{$position}=$coverage;
}

## open and parse vcf file to memorize the presence of a reference/alternative allele at each marker position
while (<$in1>) {
chomp;
if ($_ =~ m/^#/) {next;}
($nameofchr,$snpposition,$id,$bp1,$bp2,$quality,$filter,$info,$format,$sample) = split(/\s+/, $_);
my @infostretch = split(/;/, $info);
my ($falsesnpfrequency,$realsnpfrequency) = split("=", $infostretch[3]);
#my ($falsesnpcoverage,$realsnpcoverage) = split("=", $infostretch[7]);
#print "|$nameofchr|\t|$snpposition|\t|$realsnpfrequency|\n";
$snplist{$snpposition}{'freq'}=$realsnpfrequency;
$snplist{$snpposition}{'ref'}=$bp1;
$snplist{$snpposition}{'alt'}=$bp2;
}


## open list of markers to memorize chromosome/position in a hash for further retrieval of these positions in the vcf and coverage files
while (<$in2>) {
chomp;
my ($possnpcorr, $base1,$base2,$possnpstart,$b,$c,$d,$e,$chrcorr, $chrstart) = split(/\s+/, $_); 
#print "|$possnpcorr|\t|$base1|\t|$base2|\t|$possnpstart\l|\t|$b|\t|$c|\t|$d|\t|$e|\t|$chrcorr|\t|$chrstart|\n";
$possiblesnplist{$chrstart}{$possnpstart}{'DBV'}=$base1;
$possiblesnplist{$chrstart}{$possnpstart}{'CBS'}=$base2;
}

## genotype assignment at each marker position based on allele frequency and coverage (C for homozygous CBS432, D for homozygous DBVPG6765, H for heterozygous CBS432/DBVPG6765). If coverage <50 no genotype assignment is done.
foreach my $chrname (sort {$a <=> $b} keys %possiblesnplist) {
	if ($chrname eq $nameofchr) {
foreach my $possiblesnpposition (sort {$a <=> $b} keys %{$possiblesnplist{$chrname}}) {
		if ($covlist{$nameofchr}{$possiblesnpposition}>=50) {
                if (exists $snplist{$possiblesnpposition}{'ref'}) {
			if ($snplist{$possiblesnpposition}{'freq'}==1) {print $out "$possiblesnpposition,D\n"}
			elsif ($snplist{$possiblesnpposition}{'freq'}==0) {print $out "$possiblesnpposition,C\n"}
			else {print $out "$possiblesnpposition,H\n"}
		}
                else {print $out "$possiblesnpposition,C\n"}
		}
else {print $out  "$possiblesnpposition,-\n"}
}
	}
}


