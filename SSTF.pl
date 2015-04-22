#!/usr/bin/perl
#Luke Curtis
my ($SSAtemp, $blocksTemp) = @ARGV;
@SSA = split(/,/, $SSAtemp);
@blocks = split(/,/, $blocksTemp);
@sortedBlocks=@blocks;
$blockTravel;
$simTime;
$tracksPerBlock=5;
sub openFile{
	print "Please enter name of file you wish to write to (leave blank for default output a.out)\n";
	$outputName = <STDIN>;
	chomp $outputName;
	if ($outputName eq "")
	{
		$outputName="a.out";	
	}
	unless(open FILE, '>'.$outputName) {
	 die "\nCreating file name and popualting\n";
	}
}
sub arrangeBlocks{
	#SSTF
	#Loop through each array element (this SIMULATES the track movement)
	#For the time calculation, need time taken to get to the winning block, then compare with each block after 1ms interval to see if its a better fit?
	foreach my $x (0 .. $#sortedBlocks){
		#set two variables, one for the index of the 'win' index (with the shortest difference)
		$winnerIndex;
		#and one for the difference to compare to the other array elements
		$winnerDifference=10000;
		#if not last array variable
		if ($x != $#blocks){
			$tempIndex = $x+1; #set it +1 so it doesn't compare/replace against itself
			#grabs the next block past the point we are already at, find the difference, if its the shortest, it wins
			foreach my $y ($tempIndex .. $#blocks){ 
				$differenceThisLoop = abs($sortedBlocks[$x] - $sortedBlocks[$y]); 
				if(($differenceThisLoop < $winnerDifference) && ($differenceThisLoop != 0 )) {
					$winnerIndex=$y;
					$winnerDifference = $differenceThisLoop;
				}
			}
			#switch the elements over and run again for the next index
			$tempBlockStore = $sortedBlocks[$tempIndex];
			$sortedBlocks[$tempIndex] = $sortedBlocks[$winnerIndex];
			$sortedBlocks[$winnerIndex] = $tempBlockStore;
		}
	}
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
		if ($i != $#sortedBlocks){
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
	print FILE "Results of SSTF scan:\n";
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