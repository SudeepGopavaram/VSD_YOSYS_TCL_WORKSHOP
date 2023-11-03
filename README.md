# VSD_YOSYS_TCL_WORKSHOP
5 - Days --> TCL Beginner to Advance Training Workshop by VSD 

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



   
   
