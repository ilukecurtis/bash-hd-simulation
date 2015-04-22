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
sub processBlocks{
	print"Creating file and perfoming scan\n";
	sleep(1);
	#Get sim time for FCFS
	$timesTrackMoved=0;
	#Need to get to the first block with the head, starting block is 1
	$blockTravel=(abs(1-$blocks[0]));
	foreach my $i (0 .. $#blocks) {
		#get difference between the blocks
		#if last block, dont do anything, spindle finished moving
		if ($i != $#blocks){
			#calculate the time between the travel (1ms)
			#move track if needed here, get the current track, and the one needed, then move between if required (to take into account to seek)
			$trackHeadIsOn = int(($blocks[$i] / $tracksPerBlock)+0.99);
			$trackHeadNeedsToGetTo = int(($blocks[$i+1] / $tracksPerBlock) + 0.99);
			if ($trackHeadIsOn != $trackHeadNeedsToGetTo){
				$timesTrackMoved += abs($trackHeadIsOn - $trackHeadNeedsToGetTo)
			}
			#the absolute diff needs -1 so it can account for the head staying in this pos
			$diffThisRound = abs($blocks[$i]-$blocks[$i+1]);
			
			if (($blocks[$i]+1) == $blocks[$i+1]){
				$diffThisRound = 0;
			}
			else{
				$blockTravel+=((abs($blocks[$i]-$blocks[$i+1])-1) * @SSA[0]); #this is the search time in the SSA array
			}
		}
	}
	#the simTime takes the AVG block travel, adds on the access time (cumulatively) and then the seek time is also added depending how many tracks it traversed
	$simTime = $blockTravel + (($#blocks * @SSA[2])+1) + ($timesTrackMoved * @SSA[1]);
	$simTime = sprintf("%.2f", $simTime);
}
sub writeToFile{	
	# Write text to the file.
	print FILE "Results of FCFS scan:\n";
	print FILE "Original HDD inputs: @SSA\n";
	print FILE "Original block access sequence: @blocks\n";
	print FILE "Simulated block access sequence path: @sortedBlocks\n";
	print FILE "Calculted simulation time: $simTime ms \n";
	# close the file.
	close FILE;
	print "Scan completed! Please press return to exit. \n";
	$padding=<STDIN>;
}

&openFile();
&processBlocks();
&writeToFile();
