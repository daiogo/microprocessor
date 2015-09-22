#!/usr/bin/perl -w

#----------------------------OPTIONS AND FILE HANDLING----------------------------

@files = ();

foreach $arg (@ARGV)
{
	if ($arg eq "--credits")		#Display credits
	{
		print "Assembler for Computer Architecture project at UTFPR\n";
		print "Version: 1.0\n";
		print "Author: Diogo Freitas\n";
		exit(0);
	}
	else
	{
		push @files, $arg;			#Push arguments to @files array
	}
}

foreach $f (@files)
{
	open(F,"<$f") or die "$0: Can't open $f: $!\n";
	
	while(<F>) 						#Stores file lines in array separate array indexes
	{
		$_ =~ s/\n//;				#Remove line break
		$_ =~ s/;.*$//g;			#Remove comments
		push @lines, $_;			#Push every line on file to @lines array
	}
}

#----------------------------ASSEMBLER----------------------------

@binary = ();
%labels = ();
@error_log = ();
$line_number = 0;

foreach $line (@lines)								#Loops through lines in file searching for labels
{
	if ($line !~ /^\s*$/)							#If it isn't an empty line
	{
		$line_number++;
		if ($line =~ /^\w+:\s*\w+/)
		{
			$label = $line;
			$label =~ s/:.*$//;
			$labels{$label} = $line_number-1;		#CHECK ITS CORRECTNESS!
		}
	}
}

$line_number = 0;

foreach $line (@lines)								#Loops through lines in file searching for instructions
{
	if ($line !~ /^\s*$/)							#If it isn't an empty line
	{
		$line_number++;

		if ($line =~ /nop\s*$/)						#NOP
		{
			$str = "000000000000000";
		}
		elsif ($line =~ /add\s+/)					#ADD
		{
			$str = "0001";
			$reg1 = extract_operand1($line, $line_number);
			$str = $str.$reg1."00000000";
		}
		elsif ($line =~ /sub\s+/)					#SUB
		{
			$str = "0010";
			$reg1 = extract_operand1($line, $line_number);
			$str = $str.$reg1."00000000";
		}
		elsif ($line =~ /slt\s+/)					#SLT
		{
			$str = "0011";
			$reg1 = extract_operand1($line, $line_number);
			$str = $str.$reg1."00000000";
		}
		elsif ($line =~ /sneg\s*$/)					#SNEG
		{
			$str = "010000000000000";
		}
		elsif ($line =~ /cmp\s+/)					#CMP
		{
			$str = "0101";
			$reg1 = extract_operand1($line, $line_number);
			$str = $str.$reg1."00000000";
		}
		elsif ($line =~ /bra\s+/)					#BRA
		{
			$str = "0110";
			$offset = extract_offset($line, "bra", $line_number);
			$offset = sprintf "%.11b" , $offset;
			$str = $str.$offset;
		}
		elsif ($line =~ /beq\s+/)					#BEQ
		{
			$str = "0111";
			$offset = extract_offset($line, "beq", $line_number);
			$offset = sprintf "%.11b" , $offset;
			$str = $str.$offset;
		}
		elsif ($line =~ /jmp\s+/)					#JMP
		{
			$str = "1000";
			$label = $line;
			$label =~ s/.*jmp\s+//;
			$address = $labels{$label};
			$address = sprintf "%.11b" , $address;
			$str = $str.$address;
		}
		elsif ($line =~ /mov\s+/)					#MOV
		{
			$str = "1001";
			$reg1 = extract_operand1($line, $line_number);
			$str = $str.$reg1;
			$reg2 = extract_operand2($line, $line_number);
			$str = $str.$reg2."00000";
		}
		elsif ($line =~ /lda\s*/)					#LDA
		{
			$str = "1010";
			if ($line =~ /#-*\d+/)					#If LDA is meant to load an immediate
			{
				$str = $str."1";					#Set load immediate bit
				$immediate = extract_immediate($line, $line_number);
				$str = $str.$immediate;				#Attach immediate in binary to complete instruction
			}
			elsif ($line =~ /lda\s*$/)				#If LDA is meant to load a word from memory
			{
				$str = $str."0";					#Clear load immediate bit
				$str = $str."0000000000";			#Clear irrelevant bits
			}
			else
			{
				push @error_log, "Line $line_number | Invalid LDA format";
			}
		}
		elsif ($line =~ /sta\s*$/)					#STA
		{
			$str = "1011";
		}
		elsif ($line =~ /blt\s+/)					#BLT
		{
			$str = "1100";
			$offset = extract_offset($line, "blt", $line_number);
			$offset = sprintf "%.11b" , $offset;
			$str = $str.$offset;
		}
		elsif ($line =~ /bmi\s+/)					#BMI
		{
			$str = "1101";
			$offset = extract_offset($line, "bmi", $line_number);
			$offset = sprintf "%.11b" , $offset;
			$str = $str.$offset;
		}
		else										#Invalid instruction
		{
			push @error_log, "Line $line_number | Invalid instruction";
		}

		push @binary, "$line_number => ".$str;
	}
}

#----------------------------DISPLAY OUTPUT----------------------------

foreach $l (@binary)			#Display assembled program
{
	print "$l\n";
}

if (scalar @error_log > 0)		#If there is an error
{
	print "\nERROR log:\n";

	foreach $e (@error_log)		#Display error log
	{
		print "$e\n";
	}
}

#----------------------------SUBROUTINES----------------------------

sub extract_offset
{
	my $label = $_[0];
	my $branch_type = $_[1]; 
	$label =~ s/.*$branch_type\s+//;
	my $branch_to = $labels{$label};

	if ($line_number >= $branch_to)
	{
		return $line_number - $branch_to;
	}
	elsif ($line_number < $branch_to)
	{
		return $line_number + $branch_to;
	}
	else
	{
		push @error_log, "Line $_[2] | Invalid branch instruction";
	}
}

sub extract_immediate
{
	my $imm = $_[0];
	$imm =~ s/[^\-*\d+]//g;
	if ($imm >= 0 && $imm <= 511)
	{
		$imm = sprintf "%.10b" , $imm;
		return $imm;
	}
	elsif ($imm >= -512 && $imm < 0)
	{
		$imm = sprintf "%.10b" , $imm;
		$imm = substr $imm, 54;
		return $imm;
	}
	else
	{
		push @error_log, "Line $_[1] | Especified immediate doesn't fit in 10 bits";
	}
}

sub extract_operand1
{
	my $reg = $_[0];
	if ($reg =~ /[a-z]\s+r[0-5]((\s*$)|(\s*,))/)
	{
		$reg =~ s/,.*//g;							#Get rid of second operand, if present
		$reg =~ s/^\w+://;							#Get rid of label, if present
		$reg =~ s/\D//g;							#Get rid of any other non-digit character
		$reg = sprintf "%.3b" , $reg;
		return $reg;
	}
	elsif ($reg =~ /[a-z]\s+A((\s*$)|(\s*,))/)
	{
		$reg = "111";
		return $reg;
	}
	else
	{
		push @error_log, "Line $_[1] | Invalid register used on operand 1";
	}
}

sub extract_operand2
{
	my $reg = $_[0];
	if ($reg =~ /,\s*r[0-5]\s*$/)
	{
		$reg =~ s/.*,//g;							#Get rid of second operand, if present
		$reg =~ s/^\w+://;							#Get rid of label, if present
		$reg =~ s/\D//g;							#Get rid of any other non-digit character
		$reg = sprintf "%.3b" , $reg;
		return $reg;
	}
	elsif ($reg =~ /,\s*A\s*$/)
	{
		$reg = "111";
		return $reg;
	}
	else
	{
		push @error_log, "Line $_[1] | Invalid register used on operand 2";
	}
}

