#!usr/bin/perl

use strict; #use warnings;

## usage: perl annotatorH.pl <genotype file>

open(my $in, "<", "$ARGV[0]") or die "can't open file"; ## open genotype file 
my @inp=<$in>;
close $in;

my $lastfrequency=0;
my $frequency;
my $position;
my $count=0;
my $count2=25;

## memorize first and last chromosome position
my @chromosomes = `head -1 $ARGV[0]`;
my ($firstposition, $v) = split(/,/ , "$chromosomes[0]");
my @chromosomeends = `tail -1 $ARGV[0]`;
my ($realend, $f) = split(/,/ , "$chromosomeends[0]");
my ($chromosomename) = $ARGV[0] =~ m/.*(chr.*?)\./;
#print "$chromosomename\n";

## start counting how many consecutive markers carry the same genotype: note that the type of markers counted can be changed commenting/discommenting the following 3 lines. Example: if countletters("C") is discommented the script will count how many consecutive markers have the C genotype (homozygous CBS432)
#countletters("D");
#countletters("C");
countletters("H");

## subroutine containing the counter script
sub countletters {
my ($letter)=shift;
#print "$letter\n";
my %regions;
my %regions05;
my $c=0;
my $d=0;

foreach my $element (@inp) {
	chomp $element;

my %chrends;
$chrends{$realend}=$realend;

($position,$frequency) = split(/,/, $element);
#print "|$position|\t|$frequency|\n";

        if ($position == $firstposition){

                if ($frequency eq $letter) {$count++;
                        $regions{$c}{'init'}=$position; $regions{$c}{'counter'} = $count;
                        #print "$regions{$c}{'init'}\t$regions{$c}{'counter'}\n";         
			}

               if ($frequency ne $letter && $frequency ne "-") {$count2++; $regions05{$d}{'init'}=$position;
                       next;
		}        
	}
	
	 elsif ($position == $realend){

                if ($frequency eq $letter && $lastfrequency eq $letter) {$count++;
                        $regions{$c}{'end'}=$position;
                                  }
		if ($frequency eq $letter && $lastfrequency ne $letter) {$count=1; $c++; $regions{$c}{'counter'} = $count;
                        $regions{$c}{'end'}=$position; $regions{$c}{'init'}=$position;
                                  }

               if ($frequency ne $letter && $lastfrequency eq $letter) {$count2=1; $d++; $regions05{$d}{'init'}=$position; 
			$regions{$c}{'end'}=$regions05{$d}{'init'}; $regions{$c}{'counter'} = $count;
                       }
	       if ($frequency ne $letter && $lastfrequency ne $letter) {$count2++; $regions{$c}{'end'}=$regions05{$d}{'init'};
                       }
	}
	
	else {  
			if ($frequency eq $letter) {                                           
                       if ($lastfrequency eq $letter){$count++;
			next;
                        }
			

## this chunk of code ensures that a few number of markers containing a genotype different than the one counted (in this case C is counted, so D and H are the different ones) will not split the LOH/introgression block annotation. If the number of different markers interspacing a stretch of C markers is <10, the LOH/introgression block will continue. If this number is >=10, the annotation will stop and a new block will start. Markers with - (coverage <50) will be ignored.
                        if ($lastfrequency ne $letter && $lastfrequency ne "-"){
				if ($count2>9) {$regions{$c}{'end'}= $regions05{$d}{'init'};
						#print "$regions{$c}{'end'}\n";
						#print "$count2\n";
						$count=1;
                                		$c++;
                                		$regions{$c}{'init'} = $position;
                                		$regions{$c}{'end'} = $chrends{$realend};
						$regions{$c}{'counter'} = $count;
						#print "$regions{$c}{'counter'}\n";
						}
				else {$count++; $regions{$c}{'end'} = $chrends{$realend}}
						}
                	if ($lastfrequency eq "-"){$regions{$c}{'counter'} = $count;$regions{$c}{'end'} = $chrends{$realend};
                        }
		}

                if ($frequency ne $letter && $frequency ne "-") {
                        if ($lastfrequency eq $letter){$count2=1; $d++;
				$regions05{$d}{'init'} = $position;
                                $regions{$c}{'counter'} = $count;
				#print "$regions{$c}{'counter'}\n";
		                }

			if ($lastfrequency ne $letter && $lastfrequency ne "-"){$count2++;
                            next
                        	}
                	if ($lastfrequency eq "-"){$regions05{$d}{'counter'} = $count2;
                        }

		}
        

		 if ($frequency eq "-") {
                       if ($lastfrequency eq $letter){$regions{$c}{'counter'} = $count;$regions{$c}{'end'} = $chrends{$realend};
                        next;
                        }
		if ($lastfrequency ne $letter && $lastfrequency ne "-"){$regions05{$d}{'counter'} = $count2;
                        next;
                        }
		if ($lastfrequency eq "-"){$regions05{$d}{'counter'} = $count2;$regions{$c}{'counter'} = $count;$regions{$c}{'end'} = $chrends{$realend};
                        next;
                        }

		}

$lastfrequency=$frequency;
 }               
        }


## if the number of consecutive markers with C genotype is >=10, the region will be annotated as LOH/introgression in the output file in bed format.
foreach my $keysregions (sort {$a <=> $b} keys %regions){
	if ($regions{$keysregions}{'counter'} > 9) { open(my $out, ">>", "$ARGV[0]\.$letter\.annotation") or die "error creating file"; 	
	print $out "$chromosomename\t$regions{$keysregions}{'init'}\t$regions{$keysregions}{'end'}\n";
	}                                                    
  }
}

#close $in;
#close $out;
