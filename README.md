# VSD_YOSYS_TCL_WORKSHOP
5 - Days --> TCL Beginner to Advance Training Workshop by VSD 

![Screenshot 2023-11-07 104811](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/bfaced3d-c963-4ed8-8ce9-52a20df88b87)


# YOSYS TCL UI
![Static Badge](https://img.shields.io/badge/OS-linux-orange)
![Static Badge](https://img.shields.io/badge/EDA%20Tools-Yosys%2C_OpenTimer-navy)
![Static Badge](https://img.shields.io/badge/languages-verilog%2C_bash%2C_TCL-crimson)
![GitHub last commit](https://img.shields.io/github/last-commit/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP)
![GitHub language count](https://img.shields.io/github/languages/count/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP)
![GitHub top language](https://img.shields.io/github/languages/top/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP)
![GitHub repo size](https://img.shields.io/github/repo-size/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP)
![GitHub repo file count (file type)](https://img.shields.io/github/directory-file-count/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP)

> Over the course of a 5-day training workshop offered by VSD, got hands on experience on how to utilize Yosys and Opentimer, open-source EDA tools, in combination with 
  TCL scripting. The workshop's primary focus was on generating a comprehensive design report. This report is created by feeding design file paths in .csv format to a 
  TCL program. By the end of the fifth day, the ultimate goal is to provide specific design details, including design data pathways, to the "TCL BOX," a user interface 
  currently under development. The "TCL BOX" utilizes Yosys and Opentimer EDA tools to execute the design and produce a detailed design report.

## Requirements
  * Linux
  * Yosys Synthesis Suit
  * OpenTimer STA Tool
  * TCL Matrix Package

### Implementation

First we will start with creation of the *suyosys* command script and *suyosys.tcl* files.

![Screenshot 2023-11-03 184139](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/504934a9-d56c-4ede-a54d-810d4451627e)

suyosys.tcl
![Screenshot 2023-11-03 185055](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/95b48816-4b6c-42c3-ba19-308f6cfd0d00)

*Code*

```bash
#------------------------------------------------------------------#
#---------------------Tool Initialisation--------------------------#
#------------------------------------------------------------------#

if [ $# -eq 0 ]; then
	echo "Info: Please provide the csv file"
	exit 1
elif [ $# -gt 1 ] && [ $1 != *.csv ]; then
	echo "Info: Please provide only one csv file"
	exit 1
else
	if [[ $1 != *.csv ]] && [ $1 != "-help" ]; then
		echo "Info: Please provide a .csv format file"
		exit 1
	fi
fi

if [ ! -e $1 ] || [ $1 == "-help" ]; then
	if [ $1 != "-help" ]; then
		echo "Error: Cannot find csv file $1. Exiting..."
		exit 1
	else
		echo "USAGE:  ./suyosys <csv file>"
		echo
		echo "        where <csv file> consists of 2 columns, below keyword being in 1st column and is Case Sensitive. Please request Fayiz for sample csv file."
		echo
		echo "        <Design Name> is the name of top level module."
		echo
		echo "        <Output Directory> is the name of output directory where you want to dump synthesis script, synthesized netlist and timing reports."
		echo
		echo "        <Netlist Directory> is the name of directory where all RTL netlist are present."
		echo
		echo "        <Early Library Path> is the file path of the early cell library to be used for STA."
		echo
		echo "        <Late Library Path> is file path of the late cell library to be used for STA."
		echo
		echo "        <Constraints file> is csv file path of constraints to be used for STA."
		echo
	fi
else
	echo "Info: csv file $1 accepted"
	tclsh suyosys.tcl $1
fi
```

so here we are trying to make a command *suyosys* which will take one argument i.e. a file of .csv format to run eg: ./suyosys $1 [where $1 is called as argument]
our aim here is to write a script which will give us the output respectively consisting of following basic general scenerios execution of command for every scenerio is explained below.

1. What will happen when we will not provide any argument i.e. not giving any .csv file to the following command: -->
   Below code snippet checks if we have not provided any argument then it will be showing an error to provide the csv file 
   ```
   if [ $# -eq 0 ]; then
	 echo "Info: Please provide the csv file"
	 exit 1
   ```
2. What will happen if the argument provided but it is not of .csv format: --> 
   Below code snippet will check if the argument given is of .csv format or not if not then it will be giving the error
   ```
   elif [ $# -gt 1 ] && [ $1 != *.csv ]; then
	echo "Info: Please provide only one csv file"
	exit 1
   ```
3. What will happen if more than one .csv files are provided to the command: -->
   Below code explains the following scenerio
   ```
   elif [ $# -gt 1 ] && [ $1 != *.csv ]; then
	echo "Info: Please provide only one csv file"
	exit 1
   ```
4. What Will happen if a non existing .csv file is given as an argument: -->
   Below code snipet looks that if the command have any argument which is non existing or user has asked for help inplace of argument if in case none of the case are 
   satisfied it will show the error that it cannot find the csv file
   ```
   if [ ! -e $1 ] || [ $1 == "-help" ]; then
	if [ $1 != "-help" ]; then
		echo "Error: Cannot find csv file $1. Exiting..."
		exit 1
   ```
   
6. What if user wants to know how the command works: -->
    Below code snippet will show the entire USAGE of the following command.
  ```
	else
		echo "USAGE:  ./suyosys <csv file>"
		echo
		echo "        where <csv file> consists of 2 columns, below keyword being in 1st column and is Case Sensitive. Please request Fayiz for sample csv file."
		echo
		echo "        <Design Name> is the name of top level module."
		echo
		echo "        <Output Directory> is the name of output directory where you want to dump synthesis script, synthesized netlist and timing reports."
		echo
		echo "        <Netlist Directory> is the name of directory where all RTL netlist are present."
		echo
		echo "        <Early Library Path> is the file path of the early cell library to be used for STA."
		echo
		echo "        <Late Library Path> is file path of the late cell library to be used for STA."
		echo
		echo "        <Constraints file> is csv file path of constraints to be used for STA."
		echo
	fi
```
## Day 2 - Variable Creation and Processing Constraints from CSV

![Screenshot 2023-11-07 103815](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/9b7b9703-207d-4cc1-bda3-7b6c8efc8d26)

Bellow mention task to be performed

--> Creating a variable 

--> Check if directories and files mentioned in .csv exist or not if not then we will be creating those directories

--> Read all files in the "Netlist Directory"

--> Create main synthsis script in format[2] to be used by yosys

--> Pass the script to yosys

#### Creating a Variable

We will be creating a variable for information mentioned in the details.csv file which will help us to make those details independent of the location that they are in the excel sheet.

we will be converting the above excel into a matrix and the matrix with an array whith each block having its own specific index for both row and column then mapping those index with the user created variable name containing no spaces in between.


![Screenshot 2023-11-07 111204](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/a3af7ae4-3bfa-4a55-b2de-e03bb50b77ba)

we are not creating any new variable name we will be crating autovariable which will take the pre existing names

*Code* 

```tcl
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

# Storing number of rows and columns of matrix to variables
set ncdcsv [m columns]
set nrdcsv [m rows]

# Convertion of matrix to array "des_arr(column,row)"
m link des_arr

# Auto variable creation and data assignment
set i 0
while {$i < $nrdcsv} {
	puts "\nInfo: Setting $des_arr(0,$i) as '$des_arr(1,$i)'"
	if { ![string match "*/*" $des_arr(1,$i)] && ![string match "*.*" $des_arr(1,$i)] } {
		set [string map {" " "_"} $des_arr(0,$i)] $des_arr(1,$i)
	} else {
		set [string map {" " "_"} $des_arr(0,$i)] [file normalize $des_arr(1,$i)]
	}
	set i [expr {$i+1}]
}
```

#### FILE AND DIRECTORY EXISTENCE CHECK

Now we wrote a script to check the existence of all files and directories i.e. the path of the file or the file directly which we provided should be valid for the script to move forward

```tcl
# File/Directory existence check
# ------------------------------
# Checking if output directory exists if not creates one
if { ![file isdirectory $Output_Directory] } {
	puts "\nInfo: Cannot find output directory $Output_Directory. Creating $Output_Directory"
	file mkdir $Output_Directory 
} else {
	puts "\nInfo: Output directory found in path $Output_Directory"
}

# Checking if netlist directory exists if not exits
if { ![file isdirectory $Netlist_Directory] } {
	puts "\nError: Cannot find RTL netlist directory in path $Netlist_Directory. Exiting..."
	exit
} else {
	puts "\nInfo: RTL netlist directory found in path $Netlist_Directory"
}

# Checking if early cell library file exists if not exits
if { ![file exists $Early_Library_Path] } {
	puts "\nError: Cannot find early cell library in path $Early_Library_Path. Exiting..."
	exit
} else {
	puts "\nInfo: Early cell library found in path $Early_Library_Path"
}

# Checking if late cell library file exists if not exits
if { ![file exists $Late_Library_Path] } {
	puts "\nError: Cannot find late cell library in path $Late_Library_Path. Exiting..."
	exit
} else {
	puts "\nInfo: Late cell library found in path $Late_Library_Path"
}

# Checking if constraints file exists if not exits
if { ![file exists $Constraints_File] } {
	puts "\nError: Cannot find constraints file in path $Constraints_File. Exiting..."
	exit
} else {
	puts "\nInfo: Constraints file found in path $Constraints_File"
}
```
![Screenshot 2023-11-09 162422](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/0ca69e35-3a7f-43db-ac01-25294089327d)

#### Processing of the constraints openMSP430_design_constraints.csv file

*code*

```tcl
# Constraints csv file data processing for convertion to format[1] and SDC
# ------------------------------------------------------------------------
puts "\nInfo: Dumping SDC constraints for $Design_Name"
::struct::matrix m1
set f1 [open $Constraints_File]
csv::read2matrix $f1 m1 , auto
close $f1
set nrconcsv [m1 rows]
set ncconcsv [m1 columns]
# Finding row number starting for CLOCKS section
set clocks_start [lindex [lindex [m1 search all CLOCKS] 0] 1]
# Finding column number starting for CLOCKS section
set clocks_start_column [lindex [lindex [m1 search all CLOCKS] 0] 0]
# Finding row number starting for INPUTS section
set inputs_start [lindex [lindex [m1 search all INPUTS] 0] 1]
# Finding row number starting for OUTPUTS section
set outputs_start [lindex [lindex [m1 search all OUTPUTS] 0] 1]
```

![Screenshot 2023-11-09 172355](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/22387da9-6019-415a-9cf5-04172b80335d)
