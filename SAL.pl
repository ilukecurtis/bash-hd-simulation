#!/usr/bin/perl
#Luke Curtis
my ($SSAtemp, $blocksTemp) = @ARGV;
@SSA = split(/,/, $SSAtemp);
@blocks = split(/,/, $blocksTemp);
@sortedBlocks;
$blockTravel;
$simTime;
$tracksPerBlock=5;

@readInBlocks;

sub openFile{
	print "Please enter name of file you wish to write to (leave blank for default output a.out)\n";
	$outputName = <STDIN>;
	chomp $outputName;
	if ($outputName eq "")
	{
		$outputName="a.out";	
	}
	unless(open FILE, '>'.$outputName) {
	 die "\nUnable to open file, do you have the right permissions?\n";
	}
}
sub arrangeBlocks{
	#SCAN AND LOOK ALGORITHMS
		$baseline = 0;
		@ascendingBlocks;
		@decendingBlocks;

		#iterate each array element, sort into blocks to process ahead, and blocks to process behind starting point

		foreach my $x (0 .. $#blocks){
			if ($blocks[$x] > $baseline){
				#process it and add to sorted array
				push (@ascendingBlocks, $blocks[$x]);
			}
			else{
				 push (@decendingBlocks, $blocks[$x]);
				#put on to a temporary array for reverse ordering
			}
			$baseline = $blocks[$x];
		}
		#sort the ascending blocks from lowest to highest and push
		@ascendingBlocks = sort { $a <=> $b } @ascendingBlocks;
		push (@sortedBlocks, @ascendingBlocks);
		#sort the decending blocks from highest to lowest and push
		@decendingBlocks = sort { $a <=> $b } @decendingBlocks;
		@decendingBlocks = reverse(@decendingBlocks);
		push (@sortedBlocks, @decendingBlocks);

}
sub processBlocks{
	print"Creating file and perfoming scan\n";
	sleep(1);
	#Get sim time for FCFS
	$timesTrackMoved=0;
	#Need to get to the first block with the head
	$blockTravel=(abs(1-$sortedBlocks[0]));
	foreach my $i (0 .. $#sortedBlocks) {
		#get difference between the blocks
		#if last block, dont do anything, spindle finished moving
		if ($i != $#blocks){
			#calculate the time between the travel (1ms)
			#move track if needed here, get the current track, and the one needed, then move between if required (to take into account to seek)
			$trackHeadIsOn = int(($sortedBlocks[$i] / $tracksPerBlock)+0.99);
			$trackHeadNeedsToGetTo = int(($sortedBlocks[$i+1] / $tracksPerBlock) + 0.99);
			if ($trackHeadIsOn != $trackHeadNeedsToGetTo){
				$timesTrackMoved += abs($trackHeadIsOn - $trackHeadNeedsToGetTo)
			}
			#the absolute diff needs -1 so it can account for the head staying in this pos
			$diffThisRound = abs($sortedBlocks[$i]-$sortedBlocks[$i+1]);
			
			if (($sortedBlocks[$i]+1) == $sortedBlocks[$i+1]){
				$diffThisRound = 0;
			}
			else{
				$blockTravel+=((abs($sortedBlocks[$i]-$sortedBlocks[$i+1])-1) * @SSA[0]); #this is the search time in the SSA array
			}
		}
	}
	#the simTime takes the AVG block travel, adds on the access time (cumulatively) and then the seek time is also added depending how many tracks it traversed
	$simTime = $blockTravel + (($#sortedBlocks * @SSA[2])+1) + ($timesTrackMoved * @SSA[1]);
	$simTime = sprintf("%.2f", $simTime);
}
sub writeToFile{	
	# Write text to the file.
	print FILE "Results of Scan and Look:\n";
	print FILE "Original HDD inputs: @SSA\n";
	print FILE "Original block access sequence: @blocks\n";
	print FILE "Simulated block access sequence path: @sortedBlocks\n";
	print FILE "Calculted simulation time: $simTime ms \n";
	# close the file.
	close FILE;
	print"Scan completed! Please press return to exit. \n";
	$padding=<STDIN>;
}

&openFile();
&arrangeBlocks();
&processBlocks();
&writeToFile();