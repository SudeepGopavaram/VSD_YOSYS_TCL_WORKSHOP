#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------Converts .csv to matrix and creates initial variables "DesginName OutputDirectory NetlistDirectory EarlylibraryPath LateLibraryPath"-------------------------#
#---------------If you are modifying this script, please use above variables as starting point. Use "puts" command to report above variable----------------------------------#

#set FileName [lindex $argv 0] #--> Merging this line with line no  15

#csv file to matrix processing packages
package require csv
package require struct::matrix

#Initialization of a matrix "m"
struct::matrix m

#Opening of design details csv file to handle "f" and setting CLI argument to variable where argv is TCL built in variable containing CLI arguments as list
set f [open [lindex $argv 0]]

#Parsing csv data to matrix "m"
csv::read2matrix $f m , auto

#Closing design details csv
close $f

#converting of matrix to array "my_array(column,row)"
m link my_array

#storing number of rows and columns of matrix to variables
set num_of_cols [m columns]
set num_of_rows [m rows]
puts "\nInfo :: List of variables values."
puts "\Total number of rows in Design_Name     = $num_of_rows"
puts "\Total number of columns in Design_Name  = $num_of_cols"

#auto variable creation and data assignment
set i 0

#//auto checker path or name 

#while {$i < $nrdcsv} {
#	puts "\nInfo: Setting $des_arr(0,$i) as '$des_arr(1,$i)'"
	# Checking whether the value of heading is name or path and incase of path making it absolute path
#	if { ![string match "*/*" $des_arr(1,$i)] && ![string match "*.*" $des_arr(1,$i)] } {
		# Auto creating variable by replacing spaces in first column with underscore and assigning design name
#		set [string map {" " "_"} $des_arr(0,$i)] $des_arr(1,$i)
#	} else {
		# Auto creating variable by replacing spaces in first column with underscore and assigning design file/folder absolute path
#		set [string map {" " "_"} $des_arr(0,$i)] [file normalize $des_arr(1,$i)]
#	}
#	set i [expr {$i+1}]
#}



while { $i < $num_of_rows } {
    puts "\nInfo :: Setting $my_array(0,$i) as `$my_array(1,$i)`"  
	#auto creating variable by replacing spaces in first column with underscore and assigning design name
   if { $i == 0 } {
        set [string map {" " "_" } $my_array(0,$i)] $my_array(1,$i)
    } else {	
	#auto creating variable by replacing spaces in first column with underscore and assigning design file/folder absolute path 
        set [string map {" " "_"} $my_array(0,$i)]  [file normalize $my_array(1,$i)]
    }
    set i [expr {$i+1}]
}

puts "\nInfo :: Below are the list of initial variables and their values. User can use these variables for further debug. Use `puts <variable name>` command to query value of below variables"
puts "Design_Name        = $Design_Name"
puts "Output_Directory   = $Output_Directory"
puts "Netlist_Directory  = $Netlist_Directory"
puts "Early_Library_Path = $Early_Library_Path"
puts "Late_Library_Path  = $Late_Library_Path"
puts "Constraints_File   = $Constraints_File"

#return

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------Below script checks whether File/Directory mentioned in csv file exist or not---------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#Checking if output directory is present or not........
if { ![file isdirectory $Output_Directory] } {
		puts "\nInfo :: Cannot find output directory $Output_Directory. Creating $Output_Directory"
		file mkdir $Output_Directory
	} else { 
			puts "\nInfo :: Output directory found in path $Output_Directory"
	}


#Checking if early cell library cell exists or not......
if { ![file exists $Early_Library_Path] } {
		puts "\nInfo :: Cannot find early cell library path $Early_Library_Path. Exiting........"
	    exit
	} else { 
			puts "\nInfo :: Early cell library found in path $Early_Library_Path"
	}


#Checking if late cell library exixsts or not.......
if { ![file exists $Late_Library_Path] } {
		puts "\nInfo :: Cannot find late cell libraryin path $Late_Library_Path. Exiting........"
	    exit
	} else { 
			puts "\nInfo :: Late cell library found in path $Late_Library_Path"
	}


#Checking if netlist directory is present or not.........
if { ![file isdirectory $Netlist_Directory] } {
		puts "\nInfo :: Cannot find RTL netlist directory $Netlist_Directory. Exiting........."
	    exit
	} else { 
			puts "\nInfo :: Netlist  directory found in path $Netlist_Directory"
	}


#Checking if constraints file exists or not..........
if { ![file exists $Constraints_File] } {
		puts "\nInfo :: Cannot find constraints file in path $Constraints_File. Exiting........"
		exit
	} else { 
			puts "\nInfo :: Constraints file found in path $Constraints_File"
	}

#return

#-------------------------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------Constraints File creation-------------------------------------------------------------------------#
#-----------------------------------------------------------SDC Format----------------------------------------------------------------------------------#

puts "\nInfo :: Dumping SDC constraints for $Design_Name"
::struct::matrix constraints
set f1 [open $Constraints_File]
csv::read2matrix $f1 constraints , auto
close $f1

set nrconcsv [constraints rows]
set ncconcsv [constraints columns]

puts "\nTotal number of rows in $Constraints_File    = $nrconcsv"
puts "\nTotal number of columns in $Constraints_File = $ncconcsv"

#Finding row number starting for CLOCKS section
set clock_start_row  [lindex [lindex [constraints search all CLOCKS] 0] 1] 
#Finding column number starting for CLOCKS section
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0] 
puts "\nIndex number for CLOCKS section  --> Row:Column   = $clock_start_row:$clock_start_column"


#Finding row number starting for INPUTS section
set input_start_row [lindex [lindex [constraints search all INPUTS] 0] 1]
#Finding column number starting for INPUTS section
set input_start_column [lindex [lindex [constraints search all INPUTS] 0] 0]
puts "\nIndex number for INPUT section   --> Row:Column   = $input_start_row:$input_start_column"



#Finding row number starting for OUTPUTS section
set output_start_row [lindex [lindex [constraints search all OUTPUTS] 0] 1]
#Finding coulmn number starting for OUTPUTS section
set output_start_column [lindex [lindex [constraints search all OUTPUTS] 0] 0]
puts "\nIndex number for OUTPUT section  --> Row:Column   = $output_start_row:$output_start_column"

#return

#-----------------------------------------------------------------------------------------------------------------------------------------------------------#
#-------------------------------------------------------------Clock Constraints-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------#


#-----------------------------------------------------clock latency constraints-----------------------------------------------------------------------------#

set early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start_row [expr {$ncconcsv - 1}] [expr {$input_start_row - 1}]  early_rise_delay] 0 ] 0]
set early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start_row [expr {$ncconcsv - 1}] [expr {$input_start_row - 1}]  early_fall_delay] 0 ] 0]
set late_rise_delay_start  [lindex [lindex [constraints search rect $clock_start_column $clock_start_row [expr {$ncconcsv - 1}] [expr {$input_start_row - 1}]  late_rise_delay] 0 ] 0]
set late_fall_delay_start  [lindex [lindex [constraints search rect $clock_start_column $clock_start_row [expr {$ncconcsv - 1}] [expr {$input_start_row - 1}]  late_fall_delay] 0 ] 0]

#-----------------------------------------------clock transition constraints-------------------------------------------------------------------------------#

set early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start_row [expr {$ncconcsv - 1}] [expr {$input_start_row - 1}] early_rise_slew] 0] 0]
set early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start_row [expr {$ncconcsv - 1}] [expr {$input_start_row - 1}] early_fall_slew] 0] 0]
set late_rise_slew_start  [lindex [lindex [constraints search rect $clock_start_column $clock_start_row [expr {$ncconcsv - 1}] [expr {$input_start_row - 1}] late_rise_slew] 0] 0]
set late_fall_slew_start  [lindex [lindex [constraints search rect $clock_start_column $clock_start_row [expr {$ncconcsv - 1}] [expr {$input_start_row - 1}] late_fall_slew] 0] 0]

puts "\nColumn number for CLOCK CONSTRAINTS"
puts "\nColumn number for early_rise_delay = $early_rise_delay_start"
puts "\nColumn number for early_fall_delay = $early_fall_delay_start"
puts "\nColumn number for late_rise_delay  = $late_rise_delay_start"
puts "\nColumn number for late_fall_delay  = $late_fall_delay_start"

puts "\nColumn number for early_rise_slew  = $early_rise_slew_start"
puts "\nColumn number for early_fall_slew  = $early_fall_slew_start"
puts "\nColumn number for late_rise_slew   = $late_rise_slew_start"
puts "\nColumn number for late_fall_slew   = $late_fall_slew_start"

set sdc_file [open $Output_Directory/$Design_Name.sdc "w"]
set i [expr {$clock_start_row + 1}]
set end_of_ports [expr {$input_start_row - 1}]

puts "\nInfo :: SDC :: Working on clock constraints......."
while { $i < $end_of_ports } {
		puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]\} \[get_ports [constraints get cell 0 $i]\]"
		puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $early_rise_slew_start $i]  \[get_clock [constraints get cell 0 $i]\]"
		puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $early_fall_slew_start $i]  \[get_clock [constraints get cell 0 $i]\]"
		puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $late_rise_slew_start  $i]  \[get_clock [constraints get cell 0 $i]\]"
		puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $late_fall_slew_start  $i]  \[get_clock [constraints get cell 0 $i]\]"


		puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $early_rise_delay_start $i]  \[get_clocks [constraints get cell 0 $i]\]"
		puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $early_fall_delay_start $i]  \[get_clocks [constraints get cell 0 $i]\]"
		puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise  [constraints get cell $late_rise_delay_start  $i]  \[get_clocks [constraints get cell 0 $i]\]"
		puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall  [constraints get cell $late_fall_delay_start  $i]  \[get_clocks [constraints get cell 0 $i]\]"
		set i [expr {$i+1}]
}
#return


#----------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------Input Constraints--------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------Input Latency Constraints----------------------------------------------------------------------------#

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_start_row [expr {$ncconcsv-1}] [expr {$output_start_row-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_start_row [expr {$ncconcsv-1}] [expr {$output_start_row-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start  [lindex [lindex [constraints search rect $clock_start_column $input_start_row [expr {$ncconcsv-1}] [expr {$output_start_row-1}] late_rise_delay]  0] 0] 
set input_late_fall_delay_start  [lindex [lindex [constraints search rect $clock_start_column $input_start_row [expr {$ncconcsv-1}] [expr {$output_start_row-1}] late_fall_delay]  0] 0]


#---------------------------------------------------------Input Latency Constraints------------------------------------------------------------------------------#

set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_start_row  [expr {$ncconcsv-1}] [expr {$output_start_row-1}] early_rise_slew] 0] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_start_row  [expr {$ncconcsv-1}] [expr {$output_start_row-1}] early_fall_slew] 0] 0]
set input_late_rise_slew_start  [lindex [lindex [constraints search rect $clock_start_column $input_start_row  [expr {$ncconcsv-1}] [expr {$output_start_row-1}] late_rise_slew] 0] 0]
set input_late_fall_slew_start  [lindex [lindex [constraints search rect $clock_start_column $input_start_row  [expr {$ncconcsv-1}] [expr {$output_start_row-1}] late_fall_slew] 0] 0]


set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_start_row  [expr {$ncconcsv-1}] [expr {$output_start_row-1}] clocks] 0] 0]

puts "\nColumn number for INPUT CONSTRAINTS"
puts "\nColumn number for early_rise_delay   = $input_early_rise_delay_start"
puts "\nColumn number for early_fall_delay   = $input_early_fall_delay_start"
puts "\nColumn number for late_rise_delay    = $input_late_rise_delay_start"
puts "\nColumn number for late_fall_delay    = $input_late_fall_delay_start"

puts "\nColumn number for early_rise_slew    = $input_early_rise_slew_start"
puts "\nColumn number for early_fall_slew    = $input_early_fall_slew_start"
puts "\nColumn number for late_rise_slew     = $input_late_rise_slew_start"
puts "\nColumn number for late_fall_slew     = $input_late_fall_slew_start"

puts "\nColumn number for clocks   			 = $input_late_fall_slew_start"

set i [expr {$input_start_row+1}]
set end_of_inputs [expr {$output_start_row-1}]
puts "\nInfo-SDC: Working on IO constraints....................."
puts "\nInfo-SDC: Categorizing input ports as bits and bussed"


while { $i < $end_of_inputs } { 

#globing(searching) all the available .v files in netlist directory
		set netlist [glob -dir $Netlist_Directory *.v]

#opening a temporary file named 1 in write mode
		set tmp_file [open /tmp/1 w]

#setting up channel identifier as f for each .v files in netlisdirectory
		foreach f $netlist {

#opening each file in read mode
				set fd [open $f]
				puts "reading file $f"
#reading the file till the end of line
				while { [gets $fd line] != -1 } {

#setting pattern1 starting with space to make it unique
						set pattern1 " [constraints get cell 0 $i];"
#looping through all the .v file using regular expression and finding pattern1 in each line
						if { [regexp -- -all $pattern1 $line] } {
#on successful finding of pattern1 setting 
						puts "pattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
								set pattern2 [lindex [split $line ";"] 0]
								puts "creating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\"2"
								if { [regexp -all {input} [lindex [split $pattern2 "\S+"]  0]] } {
								puts "out of all patterns, \"$pattern2\" has matching string \"input\" . sxo preserving this line and ignoring others"
										set s1 "[lindex [split $pattern2 "S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
										puts "printing first 3 elements of pattern2 as \"$s1\" using space as delimiter"

#replacing multiple spaces with single spaces and storing in the temp file
										puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
										puts "replace multiple spaces in s1 by single space and reformat as \"[regsub -all {\s+} $s1 " "]\""
								}
						}	
				}	 
close $fd
}
}
close $tmp_file
set tmp_file [open /tmp/1 r]
#puts "reading [read stmp_file]"
#puts "reading /tmp/1 file as [split [read $tmp file] \n]"
#puts "sorting /tmp/1 contents as [lsort -unique [split [read $tmp_fie] \n ]]"
#puts "joining /tmp/1 as [join [lsort -unique [split [read $tmp_file] \n]] \n]"
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
#puts "count is [llenght [read $tmp2_file]] "
set count [llength [read $tmp2_file]]
puts "splitting content of tmp_2 using space and counting number of elements as $count"
#close $tmp2_file
if {$count > 2} {
		set inp_ports [concat [constraints get cell 0 $i]*]
		puts "bussed"
} else {
		set inp_ports [constraints get cell 0 $i]
		puts "not bussed"
}
		puts "input port name is $inp_ports since count is $count\n"
		puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
		puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
		puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
		puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

		puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
		puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
		puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
		puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"


		set i [expr {$i+1}}]
}
#close $sdc_file
close $tmp2_file
return

#----------------------------------------------------------------------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------Output Constraints--------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------#

set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_start_row  [expr {$ncconcsv-1}] [expr {$nrconcsv-1}] early_rise_delay] 0] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_start_row  [expr {$ncconcsv-1}] [expr {$nrconcsv-1}] early_fall_delay] 0] 0]
set output_late_rise_delay_start  [lindex [lindex [constraints search rect $clock_start_column $output_start_row  [expr {$ncconcsv-1}] [expr {$nrconcsv-1}] late_rise_delay] 0] 0]
set output_late_fall_delay_start  [lindex [lindex [constraints search rect $clock_start_column $output_start_row  [expr {$ncconcsv-1}] [expr {$nrconcsv-1}] late_fall_delay] 0] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_start_row [expr {$ncconcsv-1}] [expr {$nrconcsv-1}] load 0] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_start_row [expr {$ncconcsv-1}] [expr {$nrconcsv-1}] load 0] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_start_row  [expr {$ncconcsv-1}] [expr {$nrconcsv-1}] clocks] 0] 0]

set i [expr {$outptu_ports_start+1}]
end_of_ports [expr{$nrconcsv}]
puts "\nInfo-SDC: Working on IO constraints........."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while { $i < $end_of_ports } {

set netlist [glob -dir $Netlist_Directory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
		set fd [open $f]
		while {[gets $fd line] != -1} {
				set pattern2 [lindex [split $line ":"] 0]
				if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
						set s1 "[lindex [split $pattern "\S+"] 0] [lindex [split $pattern2 "\S+"] 2]"
						puts -nonewline $tmp_file "\n[regsub -all {\S+} $s1 " "]"
						}
				}
		}
close $fd
}
close $tmp_file
set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [split [llenght [read [$tmp2_file]] " "]
if {$count > 2} {
		set op_ports [concat [constraints get cell 0 $i]*]
} else {
		set op_ports [concat [constraints get cell 0 $i]
}
		puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clocks $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
		puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clocks $i]\] -min -fall -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
		puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clocks $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
		puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clocks $i]\] -max -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
		puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clocks $i]\] -max -fall -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
		puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $top_ports\]"
		set i [expr {$i+1}]
}
close $tmp2_file
close $sdc_file

puts "\nInfo: SDC created, Please use constraints in path $Output_Directory/$Design_Name.sdc"
#return

######################succesfully converted all inputs to format[1] & SDC format, and pass to synthesis tool yosys############

#--------------------------------------------------------##---------------------Hierarchy Check--------------------##--------------------------------------------------------#

puts "\nInfo: Creating hierarchy checck script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibertyPath}"
set fileId [open $Output_Directory/$filename "w"]
set -nonewline $fileId $data

set netlist [glob -dir $Netlist_Directory *.v]
foreach f $netlist {
		set data $f
		puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -check"
close $fileId
#return

puts "\nclose \"$Output_Directory/$filename\"\n"
puts "\nChecking hierarchy........."
set my_err [catch { exec yosys -s $Output_Directory/$Design_Name.hier.ys >& $Output_Directory/$Design_Name.hierarchy_check.log} msg]
puts "err flag is $my_err"
#return

if { $my_err } {
		set filename "$Output_Directory/$Design_Name.hierarchy_check.log"
		puts "log filename is $filename"
		set pattern {referenced in module}
		puts "pattern is $pattern"
		set count 0
		set fid [open $filename r]
		while {[gets $fid line] != -1} {
				incr count [regexpr -all -- $pattern $line]
				if {[regexp -all -- $pattern $line]} {
						puts "\nError: module [lindex $line 2] is not part of design $Design_Name. Please correct RTL in the path `$Netlist_Directory`"
						puts "\nInfo: Hierarchy check FAIL"
				}
		}
		close $fid
} else { 
		puts "\nInfo: Hierarchy check PASS"
}
puts "\nInfo: Please find hierarchy check details in [file normalize $Output_Directory/$Design_Name.hierarchy_check.log] for more info"
cd $working_dir

#------------------------------------------------------------------------------------------#
#------------------------------------Main synthesis script---------------------------------#
#------------------------------------------------------------------------------------------#

puts "\nInfo: Creating main synthesis script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${Late_Library_Path}"
set filename "$Design_Name.ys"
set fileId [open $Output_Directory/$filename "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $Netlist_Directory *.v]
foreach f $netlist {
		set data $f
		puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -top $Design_Name"
puts -nonewline $fileId "\nsynth -top $Design_Name"
puts -nonewline $fileId "\nsplitnets -ports -format ___\ndfflibmap -liberty ${Late_Library_Path}\nopt"
puts -nonewline $fileId "\nabc -liberty ${Late_Library_Path}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileId "\nwrite_verilog $Output_Directory/$Design_Name.synth.v"
close $fileId
puts "\nInfo: Synthesis Script Created and can be accessed from path $Output_Directory/$Desgn_Name.ys"

puts "\nInfo: Running synthesis............."

#----------------------------------------------------------------------------------#
#--------------------Run synthesis script using yosys------------------------------#
#----------------------------------------------------------------------------------#

if {[catch { exec yosys -s $Output_Directory/$Design_name.ys >& $Output_Directory/$Design_Name.synthesis.log} msg]} {
puts "\nError: Synthesis finished succesfully"
}
puts "\nInfo: Please refer to log $Output_Directory/$Design_Name.synthesis.log"

#-----------------------------------------------------------------------------------#
#-----------------Edit synth.v to be usable by Opentimer----------------------------#
#-----------------------------------------------------------------------------------#

set fileID [open /tmp/1 "w"]
puts -nonewline $fileId [exec grep -v -w "*" $Output_Directory/$Design_Name.synth.v]
close $fileId

set output [open $Output_Directory/$Design_Name.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
		while {[gets $fid line] != -1} {
		puts -nonewline $output [string map {"\\" ""} $line]
		puts -nonewline $output "\n"
}
close $fid
close $output

puts "\nInfo: Please find the synthesized netlist for $Design_Name at below path. You can use this netlist for STA or PNR"
puts "\n$Output_Directory/$Design_Name.final.synth.v"

#------------------------------------------------------------------------------------#
#---------------------Static timing analysis using Opentimer-------------------------#
#------------------------------------------------------------------------------------#

puts "\nInfo: Timing Analysis Started......"
puts "\nInfo: initializing number of threads, libraries, sdc, verilog netlist path..."
source /home/kunal/Desktop/vsdflow/procs/reopenStdout.proc
source /home/kunal/Desktop/vsdflow/proc/procs/set_num_threads.proc
reopenStdout $Output_Directory/$Design_Name.conf
set_multi_cpu_usage -localCpu 4
#return

source /home/kunal/Desktop/vsdflow/procs/read_lib.proc
read_lib -early /home/kunal/Desktop/work/openmsp430/osu018_stdcells.lib

read_lib -late /home/kunalg/Desktop/work/openmsp430/openmsp430/osu018_stdcells.lib

source /home/kunalg/Desktop/vsdflow/procs/read_verilog.proc
read_verilog $Output_Directory/$Design_name.final.synth.v

source /home/kunalg/Desktop/vsdflow/procs/read_sdc.proc
read_sdc $Output_Directory/$Design_Name.sdc
reopenStdout /dev/tty

if {$enable_prelayout_timing == 1} {
		puts "\nInfo: enable_prelayout_timimg is $enable_prelayout_timing. Enabling zero-wire load parasitics"
		set spef_file [open $Output_Directory/$Design_name.spef w]
puts $spef_file "*SPEF \"IEEE 1481-1998\" "
puts $spef_file "*DESIGN \"$Design_Name\" "
puts
