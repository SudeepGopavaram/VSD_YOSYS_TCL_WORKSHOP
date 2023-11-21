# VSD_YOSYS_TCL_WORKSHOP
5 - Days --> TCL Beginner to Advance Training Workshop by VSD Building an user interface (TCL BOX) which will take an excel sheet as an input and provide an output as a datasheet
SUDEEP GOPAVARAM 
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

> This repo consist of following tasks-:
1. create command (eg. suyosys) and pass .csv from UNIX shell to TCL script.
2. convert all the inputs to format [1] & SDC format and pass to synthesis tool 'Yosys'.
3. Convert format [1] & SDC to format [2] and pass to timing tool 'opentimer'.
4. Generate the output report.

## Requirements
  * Linux
  * Yosys Synthesis Suit
  * OpenTimer STA Tool
  * TCL Matrix Package


## Day 1 Introduction to TCL and VSDSYNTH Toolbox Usage

Create command and pass .csv from UNIX shell to TCL script

General Scenerios - 
1. Not provide .csv file as input
2. Provide a .csv file, which doesn't exist
3. type "-help" to find out usage



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

#Checking if user has provided with only one .csv file or not.
if [ "$#" != 1 ]; then
    echo -e "\nInfo :: Please provide only one .csv file. Exiting........."
    exit 1
fi

#Cheking whether the user has provided  with the file or for command usage help. 
if [ ! -f "$1" ] || [ "$1" == "-help" ]; then
    if [ "$1" != "-help" ]; then
        echo "Error :: Cannot find the csv file $1. Exiting..........."
        exit 1
    else
        echo "USAGE: ./suyosys1 <csv file>"
        echo
        echo "Where <csv file> consists of 2 columns, below keyword being in 1st column and is Case Sensitive. Please request the designer for the sample csv file."
        echo
        echo "<Design Name> is the name of the top level module."
        echo
        echo "<Output Directory> is the name of the output directory where you want to dump synthesis script, synthesized netlist and timing reports."
        echo
        echo "<Netlist Directory> is the name of  directory where all RTL netlist are present."
        echo
        echo "<Early Library Path> is the file path of the early cell library to be used for STA."
        echo
        echo "<Late Library Path> is the file path of the late cell library to be used for STA."
        echo
        echo "<Constraints File> is csv file path of constraints to be used for STA."
        echo
        exit 1
    fi

#Checking if user has provided only with one file and if that file is  of .csv format only or not    
elif [ "${1##*.}" == "csv" ] && [ "$#" -eq 1 ]; then
    echo "Info :: csv file accepted :))"
    tclsh suyosys1.tcl "$1"
fi

```

## Day 2 - Variable Creation and Processing Constraints from CSV

![Screenshot 2023-11-07 103815](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/9b7b9703-207d-4cc1-bda3-7b6c8efc8d26)

Now we will proceed with following tasks:-

--> Creating a variable 

--> Check if directories and files mentioned in .csv exist or not if not then we will be creating those directories

--> Read all files in the "Netlist Directory"

--> Create main synthsis script in format[2] to be used by yosys

--> Pass the script to yosys

#### Creating a Variable

We will be creating a variable for information mentioned in the openMSP430_design_details.csv file which will help us to make those details independent of the location that they are in the excel sheet.

we will be converting the above excel into a matrix and then link this matrix with an array whith each block having its own specific index for both row and column then mapping those index with the user created variable name containing underscore in place of spaces.


![Screenshot 2023-11-07 111204](https://github.com/SudeepGopavaram/VSD_YOSYS_TCL_WORKSHOP/assets/57873021/a3af7ae4-3bfa-4a55-b2de-e03bb50b77ba)

we are not creating any new variable name we will be crating autovariable which will take the pre existing names that are given in excel 

*Code* 

```tcl
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
puts "\Total number of rows num_of_rows = $num_of_rows"
puts "\Total number of cols num_of_cols = $num_of_cols"

#auto variable creation and data assignment
set i 0

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
puts "DesignName         = $Design_Name"
puts "Output_Directory   = $Output_Directory"
puts "Netlist_Directory  = $Netlist_Directory"
puts "Early_Library_Path = $Early_Library_Path"
puts "Late_Library_Path  = $Late_Library_Path"
puts "Constraints_File   = $Constraints_File"

#return

```

#### FILE AND DIRECTORY EXISTENCE CHECK

Now we write a script to check the existence of all files and directories i.e. the path of the file or the file directly which we provided should be valid for the script to move forward


```tcl
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
			puts "\nInfo ::  Late cell library found in path $Late_Library_Path"
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
