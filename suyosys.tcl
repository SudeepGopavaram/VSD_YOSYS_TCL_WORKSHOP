#--------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------Convert .CSV to matrix and creates initial variables "DesignName OutputDirectory NetlistDirectory EarlyLibraryPath LateLibraryPath"-----------#
#--------------------------------------------------------------------------------------------------------------------------------------------------------#

#!/bin/tclsh

# Capturing start time of the script
set start_time [clock clicks -microseconds]

# Variable Creation
# -----------------
# Setting CLI argument to variable where argv is TCL builtin variable containing CLI arguments as list
set dcsv [lindex $argv 0]

# csv file ti matrix processing package
package require csv
package require struct::matrix

# Initialisation of a matrix "m"
struct::matrix m

# Opening design details csv to file handler "f"
set f [open $dcsv]

# Parsing csv data to matrix "m"
csv::read2matrix $f m , auto

# Closing design details csv
close $f

# Command to add columns to matrix
# m add columns $columns

# Storing number of rows and columns of matrix to variables
set ncdcsv [m columns]
set nrdcsv [m rows]

puts "\nInfo: Below are the list of variable values. For user debug."
puts "\nDesign csv file total rows = $nrdcsv"
puts "Design csv file total coulmns = $ncdcsv"

# Convertion of matrix to array "des_arr(column,row)"
m link des_arr

# Auto variable creation and data assignment
set i 0
while {$i < $nrdcsv} {
	puts "\nInfo: Setting $des_arr(0,$i) as '$des_arr(1,$i)'"
	# Checking whether the value of heading is name or path and incase of path making it absolute path
	if { ![string match "*/*" $des_arr(1,$i)] && ![string match "*.*" $des_arr(1,$i)] } {
		# Auto creating variable by replacing spaces in first column with underscore and assigning design name
		set [string map {" " ""} $des_arr(0,$i)] $des_arr(1,$i)
	} else {
		# Auto creating variable by replacing spaces in first column with underscore and assigning design file/folder absolute path
		set [string map {" " ""} $des_arr(0,$i)] [file normalize $des_arr(1,$i)]
	}
	set i [expr {$i+1}]
}

puts "\nInfo: Below are the list of initial variables and their values. User can use these variables for further debug. Use 'puts <variable name>' command to query value of below variables"
#puts "DesignName       = $DesignName"
puts "OutputDirectory  = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath  = $LateLibraryPath"
puts "ConstraintsFile  = $ConstraintsFile"

#--------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------Below script checks if directories and files mentioned in csv file, exists or not-------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------------------------------------------------------------#


# File/Directory existance check
# ------------------------------
# Checking if output directory exists if not creates one
if { ![file isdirectory $OutputDirectory] } {
	puts "\nInfo: Cannot find output directory $OutputDirectory. Creating $OutputDirectory"
	# mkdir -p to create parent directories if it does not exist
	#file mkdir $OutputDirectory 
} else {
	puts "\nInfo: Output directory found in path $OutputDirectory"
}

# Checking if netlist directory exists if not exits
if { ![file isdirectory $NetlistDirectory] } {
	puts "\nError: Cannot find RTL netlist directory in path $NetlistDirectory. Exiting..."
	exit
} else {
	puts "\nInfo: RTL netlist directory found in path $NetlistDirectory"
}

# Checking if early cell library file exists if not exits
if { ![file exists $EarlyLibraryPath] } {
	puts "\nError: Cannot find early cell library in path $EarlyLibraryPath. Exiting..."
	exit
} else {
	puts "\nInfo: Early cell library found in path $EarlyLibraryPath"
}

# Checking if late cell library file exists if not exits
if { ![file exists $LateLibraryPath] } {
	puts "\nError: Cannot find late cell library in path $LateLibraryPath. Exiting..."
	exit
} else {
	puts "\nInfo: Late cell library found in path $LateLibraryPath"
}

# Checking if constraints file exists if not exits
if { ![file exists $ConstraintsFile] } {
	puts "\nError: Cannot find constraints file in path $ConstraintsFile. Exiting..."
	exit
} else {
	puts "\nInfo: Constraints file found in path $ConstraintsFile"
}

#return

#--------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------Constraints csv file data processing for convertion to format[1] and SDC----------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------------------------------------------------------------#

puts "\nInfo: Dumping SDC constraints for $DesignName"
::struct::matrix m1
set f1 [open $ConstraintsFile]
csv::read2matrix $f1 m1 , auto
close $f1
set nrconcsv [m1 rows]
set ncconcsv [m1 columns]
# Finding row number starting for CLOCKS section
set ClocksStart [lindex [lindex [m1 search all CLOCKS] 0] 1]
# Finding column number starting for CLOCKS section
set ClocksStartColumn [lindex [lindex [m1 search all CLOCKS] 0] 0]
# Finding row number starting for INPUTS section
set InputsStart [lindex [lindex [m1 search all INPUTS] 0] 1]
# Finding row number starting for OUTPUTS section
set OutputsStart [lindex [lindex [m1 search all OUTPUTS] 0] 1]

puts "\nInfo: Below are the list of variable values. For user debug."
puts "\nConstraints csv file total rows = $nrconcsv"
puts "Constraints csv file total coulmns = $ncconcsv"
puts "CLOCKS starting row in constraints csv file = $ClocksStart"
puts "CLOCKS starting column in constraints csv file = $ClocksStartColumn"
puts "INPUTS starting row in constraints csv file = $InputsStart"
puts "OUTPUTS starting row in constraints csv file = $OutputsStart"

#return

#--------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------Conversion of  constraints csv file processed data for SDC dumping----------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------------------------------------------------------------#

#CLOCKS section
#Finding column number starting for clock latency in CLOCK section only

set clocks_erd_start_column [lindex [lindex [m1 search rect $ClocksStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$InputStart-1} early_rise_delay] 0 ] 0 ]
set clocks_efd_start_column [lindex [lindex [m1 search rect $ClocksStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$INputStart-1} early_fall_delay] 0 ] 0 ]
set clocks_lrd_start_column [lindex [lindex [m1 search rect $ColumnStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$InputStart-1} late_rise_delay ] 0 ] 0 ]
set clocks_lfd_start_column [lindex [lindex [m1 search rect $ColumnStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$InputStart-1] late_fall_delay ] 0 ] 0 ]

#Finding column number starting for clock transition in CLOCK section only
set clocks_ers_start_column [lindex [lindex [m1 search rect $ClocksStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$InputStart-1} early_rise_slew] 0 ] 0 ]
set clocks_efs_start_column [lindex [lindex [m1 search rect $ClocksStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$INputStart-1} early_fall_slew] 0 ] 0 ]
set clocks_lrs_start_column [lindex [lindex [m1 search rect $ColumnStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$InputStart-1} late_rise_slew ] 0 ] 0 ]
set clocks_lfs_start_column [lindex [lindex [m1 search rect $ColumnStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$InputStart-1] late_fall_slew ] 0 ] 0 ]

#Finding column number starting for frequency and delay in CLOCK section only
set clocks_frequency_start_column [lindex [lindex [m1 search rect $ColumnStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$InputStart-1} frequency ] 0 ] 0 ]
set clocks_delay_start_column [lindex [lindex [m1 search rect $ColumnStartColumn $ClocksStart [expr {$ncconcsv-1}] [expr {$InputStart-1] duty_cycle ] 0 ] 0 ]

puts "\nInfo: Below are the list of variable values. For user debug."
puts "\nClocks early rise delay starting column in constraints.csv file = $clocks_erd_start_column"
puts "\nClocks early fall delay starting column in constraints.csv file = $clocks_efd_start_column"
puts "\nClocks late rise delay starting column in constraints.csv file = $clocks_lrd_start_column"
puts "\nClocks late fall delay starting column in constraints.csv file = $clocks_lfd_start_column"

puts "\nClocks early rise slew starting column in constraints.csv file = $clocks_ers_start_column"
puts "\nClocks early fall slew starting column in constraints.csv file = $clocks_efs_start_column"
puts "\nClocks late rise slew starting column in constraints.csv file = $clocks_lrs_start_column"
puts "\nClocks late fall slew starting column in constraints.csv file = $clocks_lfs_start_column"

puts "\nClocks frequency starting column in constraints.csv file = $clocks_frequency_start_column"
puts "\nClocks delay starting column in constraints.csv file = $clocks_delay_start_column"

#creating .sdc file with the design name in output directory and opening it in write mode.
set sdcFile [open $OutputDirectory/$DesignName.scd "w"]

#Setting variable for actual clock row start and end
set i [expr {$ClocksStart+1}]
set end_of_clock [expr {InputStart-1}]

puts "\nInfo: Below are the list of variable values. for User debug."
puts "\nClocks actual starting row in the constraints csv file = $i"
puts "\nClocks actaual ending row in the constraints csv file = $end_of_clock"

puts "\nInfo-SDC: Working on clock constraints............"


#while loop to write constraints command  to .sdc file

while { $i < $end_of_clock} { 
	puts "\nInfo: Working on clock `[m1 get cell 0 $i]`. For user debug."

	#create_clock SDC command to create clocks
puts -nonewline $sdc_file "\ncreate_clock -name [concat [m1 get cell 0 $i]_yui] -period [m1 get cell $clocks_frequency_start_column $i] -waveform \{0 [expr {[m1 get cell $clocks_frequency_start_column $i]*[m1 get cell $clocks_delay_start_column $i]/100}]\} \[get_ports [m1 get cell 0 $i]\]"

#set_clock_latency SDC command to set clock transition values
	puts -nonewline $sdcFile "\nset_clock_transition -min -rise [m1 get cell $clocks_ers_start_column $i] \[get_clocks [m1 get cell 0 $i]\]"  
	puts -nonewline $sdcFile "\nset_clock_transition -min -fall [m1 get cell $clocks_efs_start_column $i] \[get_clocks [m1 get cell 0 $i]\]"
	puts -nonewline $sdcFile "\nset_clock_transition -max -rise [m1 get cell $clocks_lrs_start_column $i] \[get_clocks [m1 get cell 0 $i]\]"
	puts -nonewline $sdcFile "\nset_clock_transition -min -fall [m1 get cell $clocks_lfs_start_column $i] \[get_clocks [m1 get cell 0 $i]\]"

#set_clock_latency SDC command to set clock latency value
	puts -nonewline $sdcFile "\nset_clock_latency -source -early -rise [m1 get cell $clocks_erd_start_column $i] \[get_clocks [m1 get cell 0 $i]\]"
	puts -nonewline $sdcFile "\nset_clock_latency -source -early -fall [m1 get cell $clocks_efd_start_column $i] \[get_clocks [m1 get cell 0 $i]\]"
	puts -nonewline $sdcFile "\nset_clock_latency -source -late -rise [m1 get cell $clocks_lrd_start_column $i] \[get_clocks [m1 get cell 0 $i]\]"
	puts -nonewline $sdcFile "\nset_clock_latency -source -late -fall [m1 get cell $clocks_lfd_start_column $i] \[get_clocks [m1 get cell 0 $i]\]"

		set i [expr {$i+1}]
}

close $sdcFile
return
