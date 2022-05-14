#!/bin/bash
#Writed by Nicolas Le Guerroué
#####################################################################################
##
##    SETTINGS
##
#####################################################################################
#################################################
## Colors
#################################################

default="\033[0m"
black="\033[30m"
red="\033[31m"
green="\033[32m"
orange="\033[33m"
blue="\033[34m"

#################################################
## Folders
#################################################

output_dir="Output" 					#Contains all file generated by compiling project
img_dir="Images" 						#Contains all images of project
utils_dir="Utils" 						#Contains Utils library
part_dir="Parts" 						#Contains content file
git_dir=".tmp" 							#Contains content file
make_dir="Make"							#Contains make files
vscode_dir=".vscode"
src_lib=".utils_lib"					#Contains lib file
bibliography_dir="Bibliography"			#Contains bibliography
git_url_file="git-remote.txt"
#################################################
## Files
#################################################

setting_file="Settings.tex" 					#Settings file
main_file="main.tex" 							#main file
standlone="standlone.tex"						#standlone file -> compiling without any other file
version="Versions.tex"
#################################################
## Function
#################################################

function createDirectory {
	directory="$1"
	if [ -z "$directory" ]; then
		echo -e "$red"
 		echo -e "Please, give a folder name in argument of createDirectory function !"
		echo -e "$default"
	else
		if [ ! -d "$directory" ];then
			mkdir $directory 
		fi
	fi
	
}
#End createDirectory

#set var wit default value if any value is passed
function loadValue {
	default_value="$1"
	load_value="$2"
	if [ -z "$load_value" ]; then
		echo "$default_value"
	else
		echo "$load_value"
	fi
	
}
#End createDirectory


#####################################################################################
##
##    Generate Snippets project
##
#####################################################################################
if [ "$1" == "--snippet" ];then

	#################################################
	## Checking arguments
	#################################################

	#################################################
	## Saving git
	#################################################	
	php $vscode_dir/generateSnippets.php
	exit
fi

############################# IF $1 = "--update-pull" ######################################
if [ "$1" == "--update-pull" ];then

	echo -n "Do you want to erase local Utils directory ? (y/n) : "
	read answer
	
	if [ "$answer" == "y" ];then

		if [[ -d .tmp ]];then
			rm -fr .tmp
		fi
		mkdir .tmp
		remote_folder=`cat $vscode_dir/git-remote.txt`
		echo -e "Update of libraries from Git ($remote_folder)"
		git clone $remote_folder .tmp
		if [[ -d $utils_dir ]];then
			rm -fr $utils_dir
		fi
		cp -R .tmp/Utils .
		echo "Exit"
		exit
	else
		echo "Exit"
		exit
	fi

fi

############################# IF $1 = "--update-pull" ######################################
if [ "$1" == "--update-push" ];then

	echo -n "Update of libraries on Git"


		if [[ -d .tmp ]];then
			rm -fr .tmp/Utils/*
		fi

		remote_folder=`cat $vscode_dir/git-remote.txt`
		echo -e "Update of libraries on Git ($remote_folder)"
		echo -n "Commit message : "
		read answer

		cp -R $utils_dir/* .tmp/Utils/
		cd .tmp/
		git add .
		git commit -am "$answer"
		git push origin master
		exit

fi


############################# IF $1 = "--change-git-folder" ######################################
if [ "$1" == "--change-git-folder" ];then

	echo -e "Changing Git folder"

	remote_folder=`cat $vscode_dir/git-remote.txt`
	echo -e "Actual remote folder : $remote_folder"
	echo -n "New folder url : "
	read answer
	echo $answer > vscode_dir/git-remote.txt
	echo -n "Git folder changed !"
	exit

fi
#####################################################################################
##
##    GENERATE LOG LIBRARIES
##
#####################################################################################
function makeChart {

	#$1 : Directory to count 
	#$2 : Output filename
	#$3 : Title x axis
	#$4 : Title y axis 
	#$5 : Title

	echo "" > data.txt
	echo "" > graph.gnuplot
	for item in "$1"/*
	do
		name=`echo $item | cut -d'/' -f2 | cut -d'.' -f1`
		echo $name `wc -l $item | cut -d' ' -f1` >> data.txt
	done

	echo "set terminal png" >> graph.gnuplot
	echo "set output '"$2"'" >> graph.gnuplot
	echo "set title '"$5"'" >> graph.gnuplot
	echo "set xlabel '"$3"'" >> graph.gnuplot
	echo "set ylabel '"$4"'" >> graph.gnuplot
	echo "set grid" >> graph.gnuplot
	echo "" >> graph.gnuplot
	echo "set style data histogram" >> graph.gnuplot
	echo "set style histogram cluster gap 1" >> graph.gnuplot
	echo "set style fill solid border -1" >> graph.gnuplot
	echo "" >> graph.gnuplot
	echo "set xtics rotate by 60 right  " >> graph.gnuplot
	echo "plot 'data.txt' using 2:xtic(1)" >> graph.gnuplot

	gnuplot graph.gnuplot

}

function makeRecursiveChart {

	#$1 : Directory to count 
	#$2 : Output filename
	#$3 : Title x axis
	#$4 : Title y axis 
	#$5 : Title

	echo "" > data.txt
	echo "" > graph.gnuplot

	for dir in $part_dir/*
	do
		for file in $dir/*
		do
	
		name=`echo $file | cut -d'/' -f3`
		echo $name `wc -l $file | cut -d' ' -f1` >> data.txt

		done
	done

	echo "set terminal png" >> graph.gnuplot
	echo "set output '"$2"'" >> graph.gnuplot
	echo "set title '"$5"'" >> graph.gnuplot
	echo "set xlabel '"$3"'" >> graph.gnuplot
	echo "set ylabel '"$4"'" >> graph.gnuplot
	echo "set grid" >> graph.gnuplot
	echo "" >> graph.gnuplot
	echo "set style data histogram" >> graph.gnuplot
	echo "set style histogram cluster gap 1" >> graph.gnuplot
	echo "set style fill solid border -1" >> graph.gnuplot
	echo "" >> graph.gnuplot
	echo "set xtics rotate by 60 right  " >> graph.gnuplot
	echo "plot 'data.txt' using 2:xtic(1)" >> graph.gnuplot

	gnuplot graph.gnuplot

}

begin=`date +"%S"`

#####################################################################################
##
##    INIT PROJECT with --init argument in command line
##
#####################################################################################
make_chart=1
############################# IF $1 = "--init" ######################################

if [ "$2" != "" ];then  #Force to compilee after first init

	cd $2 #Select new directory (after init)
	code .
fi


automatic=0
if [ "$1" == "--init" ];then

	if [ -d "$HOME/$src_lib" ];then

		echo -n "Do you want to generate automatically the folder content ? (Y/n) : "
		read answer
		answer=`loadValue y $answer`

		if [ "$answer" == "y" ];then
			automatic=1
		fi
		
		echo -n "Project name (spaces must be replaced by '\_' as used for ID) [default='main']: "
		read project_name
		project_name=`loadValue main $project_name`
		echo -e "$project_name"
		createDirectory $project_name
		createDirectory $project_name/$utils_dir
		echo -e $green
		echo -e ">>> Library $src_lib is available in $HOME/$src_lib."
		echo -e ">>> Copying library in project folder..."
		cp $HOME/$src_lib/* $project_name/$utils_dir
		echo -e ">>> Copying library in project folder  : [ OK ]"
		echo -e ">>> Copying building script..."
		cp -r $HOME/$src_lib/$vscode_dir $project_name
		echo -e ">>> Copying library in project folder  : [ OK ]"
	else
		echo -e $red
		echo -e ">>> Library $utils_dir is not available in computer."
		echo -e ">>> Please check that '$src_lib' folder exists."
		exit
	fi
	#################################################
	## Give project name
	#################################################
	#################################################
	## Create all folders
	#################################################
	createDirectory $project_name/$img_dir
	createDirectory $project_name/$part_dir
	createDirectory $project_name/$make_dir
	createDirectory $project_name/$bibliography_dir
	createDirectory $project_name/$git_dir
	
	#################################################
	## Geneating Settings.tex file
	#################################################

	document_type=""
	font_size=""
	langage=""
	horiz_margin=""
	vert_margin=""
	chapter_name=""
	width_header=""
	width_footer=""
	toc_depth=""
	pdf_namespace=""
	pdf_link_color=""
	pdf_cite_color=""
	keyword=""
	pdf_file_color=""

	if [ "$automatic" == 1 ];then

		document_type=`loadValue report $document_type`
		font_size=`loadValue 12 $font_size`
		langage=`loadValue frenchb $langage`
		horiz_margin=`loadValue 3 $horiz_margin`
		vert_margin=`loadValue 3 $vert_margin`
		chapter_name=`loadValue Section $chapter_name`
		width_header=`loadValue 0.2 $width_header`
		width_footer=`loadValue 0.2 $width_footer`
		toc_depth=`loadValue 1 $toc_depth`
		pdf_namespace=`loadValue main $pdf_namespace`
		pdf_author=`loadValue $USER $pdf_author`
		pdf_creator=`loadValue $USER $pdf_creator`
		pdf_link_color=`loadValue blue $pdf_link_color`
		pdf_cite_color=`loadValue blue $pdf_cite_color`
		keyword=`loadValue latex $keyword`
		pdf_file_color=`loadValue green $pdf_file_color`
	
	else

		echo -e $default
		echo -e ">> Please select type of document"
		echo -e " report - article - beamer - book - utils_report - article_report [report in default]"
		echo -n ">> Your choice : "
		read document_type
		document_type=`loadValue report $document_type`

		echo -e ""
		echo -n ">> Please select the size of text [12 pts in default]: "
		read font_size	
		font_size=`loadValue 12 $font_size`

		echo -e ""
		echo -n ">> Select your langage : "
		echo -e " frenchb - english [frenchb in default]"
		read langage	
		langage=`loadValue frenchb $langage`

		echo -e ""
		echo -n ">> Select margins of documents (in cm) [3 in default] : "
		read horiz_margin	
		horiz_margin=`loadValue 3 $horiz_margin`

		echo -e ""
		echo -n ">> Select vertical margin (in cm) [3 in default] : "
		read vert_margin	
		vert_margin=`loadValue 3 $vert_margin`

		echo -e ""
		echo -n ">> Select titles of chapter levels ['Section' in default] : "
		read chapter_name	
		chapter_name=`loadValue Section $chapter_name`

		echo -e ""
		echo -n ">> Select width of header line [0.2 in default] : "
		read width_header	
		width_header=`loadValue 0.2 $width_header`

		echo -e ""
		echo -n ">> Select width of footer line [0.2 in default] : "
		read width_footer	
		width_footer=`loadValue 0.2 $width_footer`

		echo -e ""
		echo -e ">> Select deep of table of content [1 in default] : "
		echo -e " 1 : chapter, section, subsection "
		echo -e " 2 : chapter, section, subsection, subsubsection"
		read toc_depth	
		toc_depth=`loadValue 1 $toc_depth`

		echo -e ""
		echo -e ">> Select namespace of project (First folder in Parts directory) ['main' by default] : "
		read pdf_namespace	
		pdf_namespace=`loadValue main $pdf_namespace`

		echo -e ""
		echo -e ">> Select title of PDF file ('main' in default): "
		read pdf_title	
		pdf_title=`loadValue main $pdf_title`

		echo -e ""
		echo -e ">>Select author(s) [separated by comma] of files ('$USER' in default): "
		read pdf_author	
		pdf_author=`loadValue $USER $pdf_author`

		echo -e ""
		echo -e ">> Select subject of document ('' in default): "
		read pdf_subject	

		echo -e ""
		echo -e ">> Select creator name ('$USER' in default): "
		read pdf_creator
		pdf_creator=`loadValue $USER $pdf_creator`

		echo -e ""
		echo -e ">> Please select keywords ('' in default) [separated by comma]: "
		read keyword

		echo -e ""
		echo -e ">> Select link color ('blue' in default): "
		read pdf_link_color	
		pdf_link_color=`loadValue blue $pdf_link_color`

		echo -e ""
		echo -e ">> Select quote color in bibliography ('blue' in default): "
		read pdf_cite_color	
		pdf_cite_color=`loadValue blue $pdf_cite_color`

		echo -e ""
		echo -e ">> Select color file link ('green' in default): "
		read pdf_file_color	
		pdf_file_color=`loadValue green $pdf_file_color`

	fi

	#Print content
	echo -e "%#######################################################" 	>> $project_name/$setting_file
	echo -e "%### Settings file" 										>> $project_name/$setting_file
	echo -e "%### Project: $project_name" 								>> $project_name/$setting_file
	echo -e "%#######################################################" 	>> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "%Geometry" 														>> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "\geometry{hmargin="$horiz_margin"cm,vmargin="$vert_margin"cm}" 	>> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file

	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "%Rename chapter name"												>> $project_name/$setting_file														>> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "\setAliasChapter{$chapter_name}" 									>> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file

	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "%If you want to add presentation, modify the next bloc"			>> $project_name/$setting_file		
	echo -e "%The firt line is about the header:"								>> $project_name/$setting_file
	echo -e "%{left content}{center content}{right content}"					>> $project_name/$setting_file
	echo -e "%The second line is about the footer:"							>> $project_name/$setting_file	
	echo -e "%{left content}{center content}{right content}"					>> $project_name/$setting_file	
	echo -e "%####"																>> $project_name/$setting_file	
	echo -n "%to get the current chapter name, use \currentChapter command as content" >> $project_name/$setting_file	
	echo -e "" >> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -n "\addPresentation
{} {} {\currentChapter}
{} {} {\currentPage}" 									>> $project_name/$setting_file
	echo -e "" >> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file

	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "%Change the width of footer line and header line"					>> $project_name/$setting_file
	echo -e "%To delete it, set value to 0"										>> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "\setHeaderLine{$width_header}" 									>> $project_name/$setting_file
	echo -e "\setFooterLine{$width_footer}" 									>> $project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file

	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "%URL and data settings"											>> $project_name/$setting_file		
	echo -e "%#############################################################" 	>> $project_name/$setting_file
	echo -e "\setParameters{$pdf_title}{$pdf_author}{$pdf_subject}{$pdf_creator}{$pdf_productor}{$pdf_link_color}{$pdf_cite_color}{$pdf_file_color}"	>>$project_name/$setting_file
	echo -e "%#############################################################" 	>> $project_name/$setting_file	

	#################################################
	## Creating namespace folder
	#################################################
	createDirectory $project_name/$part_dir/0.$pdf_namespace
	createDirectory $project_name/$img_dir/$pdf_namespace
	touch $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex
	echo "\section{Introduction}" >> $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex
	echo "\img{Utils/universe.jpg}{Universe}{0.5}" >> $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex
	echo "\lipsum" >> $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex

	echo "\begin{items}{blue}{\Triangle}" >> $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex
	echo "\item A" >> $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex
	echo "\item B" >> $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex
	echo "\item C" >> $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex
	echo "\end{items}" >> $project_name/$part_dir/0.$pdf_namespace/$pdf_namespace.tex
	
	#################################################
	## Creating bibliography
	#################################################
	touch $project_name/$bibliography_dir/Bibliography.bib
	echo -e "@book{reference_l1,
title={Titre 1},
author={Auteur 1},
year={1990},
note={Annotations},
publisher={Editeur}
},
@book{reference_l2,
title={Titre 2},
author={Auteur 2},
year={1991},
note={Annotations},
publisher={Editeur}
}" >> $project_name/$bibliography_dir/Bibliography.bib
	

	#################################################
	## Geneating main.tex file
	#################################################

	echo -e "%#############################################################" 	>> $project_name/$main_file
	echo -e "%MAIN file for $project_name project"								>> $project_name/$main_file		
	echo -e "%#############################################################" 	>> $project_name/$main_file
	echo -e "\documentclass["$font_size"pt]{$document_type}" 					>> $project_name/$main_file
	echo -e "\usepackage[$langage]{babel} %Select langage" 						>> $project_name/$main_file
	echo -e "\usepackage{Utils/Utils} %Load $utils_dir library" 				>> $project_name/$main_file
	echo -e "\input{Output/check_import} %Check all import" 					>> $project_name/$main_file
	echo -n "\input{Settings.tex}" 												>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -e "%#############################################################" 	>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "\begin{document}" 													>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "%\setHeader{$project_name}{$pdf_author}{\today}  %simple presentation"		>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "\setHeaderImage{Utils/universe}{0.8}{$project_name}{Sous-titre}{$pdf_author}{\today \\\\ \pageref{LastPage} pages}" >> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "\tableofcontents" 													>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "\newpage" 															>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "\setcounter{page}{1}" 												>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "\input{Output/add_content.tex}" 									>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "\displayBibliography{Bibliographie}{Bibliography/Bibliography}" 	>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -n "\end{document}" 													>> $project_name/$main_file
	echo -e "" 																	>> $project_name/$main_file
	echo -e "%#############################################################" 	>> $project_name/$main_file	

	
	#################################################
	## Copy of make file
	#################################################
	cp make $project_name/
	chmod 777 $project_name/make
	echo -e "$green >>> End of generating project $default" 	
	echo -e "$green >>>Compiling projet... $default" 
	source $project_name/make --void $project_name
	echo -e "$green >>>Compiling projet : OK $default" 
	exit
fi



#####################################################################################
##
##    GENERATE LOG PART
##
#####################################################################################
if [ $make_chart != 0 ]
then
	echo -e "$green"
	echo -e ">>> generating graph..."
    makeChart "Utils" "Utils.png" "Bilbiothèque" "Nombre de lignes" "Nombre de ligne par bibliothèque"
	makeRecursiveChart "Parts" "Part.png" "Parties" "Nombre de lignes" "Nombre de ligne par fichier"
	echo -e ">>> generating graph : OK"

	rm graph.gnuplot
	rm data.txt
fi


############################# END IF ###############################################



############################# END IF ###############################################


############################# IF $1 = "--check" ######################################
if [ "$1" == "--version" ];then

	echo -e "Add update phrase..."
	echo -e "Listing of versions : $orange"
	cat $make_dir/$version
	echo -e "$default"
    echo -e "What's the date uf update (today) [mars 2021 for example] ?"
    read date

    if [ "$date" != "" ];then
		echo ""
	else
		$date="\today"
    fi

    echo -e "What's the content of update ?"
    read content

    if [ "$content" != "" ];then
		echo ""
	else
		$content="unknown"
    fi

	echo -e "" >> $make_dir/$version
	echo -e "" >> $make_dir/$version
	echo -n "\addUpdate{$date}{$content}" >> $make_dir/$version
fi

#####################################################################################
##
##    CHECK PROJECT with --check argument in command line
##
#####################################################################################

############################# IF $1 = "--check" ######################################
if [ "$1" == "--check" ];then

	echo -e "Checking content in $part_dir folder..."
	for item in $part_dir/*
	do

    if [ -d $item ]
    then
		echo -e ">>> Folder '$item' is selected !"

    	for item_s in $item/*
    	do
        	echo -e "Do you want to analyse '$item_s' file ? (y/n)"
        	read reponse

        	if [ "$reponse" = "y" ];
        	then
            	aspell --encoding=utf-8 --lang=fr_FR.UFT-8 -c "$item_s" 
        	fi
    	done
    fi
	done
	echo -e ">>> Spell checking is over !"
	exit
fi


#####################################################################################
##
##    GIT project
##
#####################################################################################

############################# IF $1 = "--init" ######################################
if [ "$1" == "--git" ];then

	#################################################
	## Checking arguments
	#################################################
	if [ "$2" == "" ];then
	
		echo -e "$red >>> Request has been abandoned because message is empty$default"
		exit
	fi

	#################################################
	## Saving git
	#################################################	
	git add .
	git commit -m "$2"
	git push origin master
	echo -e "Update of folder is empty !"
	exit
fi

#####################################################################################
##
##    Install project
##
#####################################################################################

############################# IF $1 = "--install" ######################################
if [ "$1" == "--install" ];then

	#################################################
	## Install dependencies
	#################################################	
	sudo apt-get update
	sudo apt-get -y upgrade
	echo -e "Installation of texlife-full..."
	sudo apt-get install -y texlive-full
	echo -e "Installation of git..."
	sudo apt-get install -y git
	echo -e "Installation of php..."
	sudo apt-get install -y php
	echo -e "Installation of aspell-fr..."
	sudo apt-get install -y aspell-fr
	echo -e "Installation of texlive-lang-european..."
	sudo apt-get install -y texlive-lang-european
	echo -e "Installation of okular..."
	sudo apt-get install -y okular
	exit
fi
############################# END IF ###############################################

#####################################################################################
##
##    MAKE project
##
#####################################################################################

#################################################
## Checking dir
#################################################	
createDirectory $img_dir
createDirectory $utils_dir
createDirectory $utils_dir
createDirectory $part_dir
createDirectory $output_dir

main="main" #main file
parts_dir="Parts"

#################################################
## Compilation
#################################################	
count_step=1 			#Var count of step
count_sum_full=9				#Cout total_full
count_sum_light=7
echo -e ">>> Compilation of `pwd` folder..."
echo -e "$green"
echo -e "[Step $count_step / $count_sum_full] >>> Cleaning of $output_dir folder..."
echo -e "$orange"
rm -R $output_dir/*
echo -e "$green"
echo -e "[Step $count_step / $count_sum_full] >>> Cleaning of $output_dir is over"
let count_step++
echo -e "[Step $count_step / $count_sum_full] >>> Cleaning of log files..."
echo "" > .render_report.txt
echo "" > .render_report_log.txt
echo -e "[Step $count_step / $count_sum_full] >>> Cleaning of log files is over"
let count_step++
echo -e "[Step $count_step / $count_sum_full] >>> Generating of import file (import_content.tex) and import of libraries..."
echo -e "$default"


#################################################
## check_import creating file
#################################################	
echo "\makeatletter%" > Output/check_import.tex

#################################################
## Utils writing
#################################################	
echo -e "%############################################################
%###### Package Utils 
%###### This package include Latex tools
%###### Author  : Nicolas LE GUERROUE
%###### Contact : nicolasleguerroue@gmail.com
%############################################################
%######
%###### Include packages
%######
%############################################################" > $utils_dir/Utils.sty
tmp_content=""
sum_lib=0

for item in $utils_dir/*
do
	#echo $output_dir/$item
	if [ -f "$item" ];then
		if [ `echo $item | grep Utils/Utils.sty` ];then
			echo -e "$green"
			echo -e ">>> File for adding libraries loaded !"
			echo -e "$blue"
		else
			if [ `echo $item | grep .sty` ];then  #package

				let sum_lib++
				echo -e "$blue>>> Library "$item" loaded !"
				lib_name=`echo $item | cut -d '.' -f1`
				tmp_content="$tmp_content""$(cat $item)"
				echo -n "\usepackage{$lib_name}" >> $utils_dir/Utils.sty
				echo -e "" >> $utils_dir/Utils.sty

				#get all import
				#if [ "$1" == "--full" ];then 
				#fi

			else

				echo -e "$green >>> Class '$item' is available"
			fi
		fi
	fi
done
#echo "\makeatother%" >> Output/check_import.tex
echo -e "$green>>> $sum_lib libraries loaded !"
echo -e "$default"

#################################################
## Load check import 
#################################################	


#################################################
## Warnings 
#################################################	
echo -n "\newcommand{\raiseWarning}[1]{\PackageWarning{Utils}{#1}}" >> $output_dir/add_content.tex
echo -e "" >> $output_dir/add_content.tex
echo -n "\newcommand{\raiseError}[1]{\PackageError{Utils}{#1}}" >> $output_dir/add_content.tex
echo -e "" >> $output_dir/add_content.tex
echo -n "\newcommand{\raiseMessage}[1]{\typeout{>>> Utils: #1}}" >> $output_dir/add_content.tex
echo -e "" >> $output_dir/add_content.tex
#################################################
## Images
#################################################	
#echo -n "\newcommand{\rootImages}{Images/empty}" >> $output_dir/add_content.tex
#echo -e "" >> $output_dir/add_content.tex

tmp_content=""
for item in $parts_dir/*
do	

if [ -d $item ]
then
	echo -e "$blue >>> Directory '$item' added ! $default"
	img_name=`echo $item | cut -d '.' -f2`
	#echo ">>>$img_name"
	if [ ! -d "$img_dir/$img_name" ]
	then
		echo -e "$red Directory '$img_name' doesn't exist in folder '$img_dir'. \nTous les fichiers avec des images dépendantes de ce dossier ($img_dir/$img_name) ne seront pas importées !$orange\n Dossier(s) dans le répertoire $img_dir: \n" 
		ls $img_dir
		echo -e $default
		exit
	fi
	echo -n "\renewcommand{\rootImages}{Images/$img_name}" >> $output_dir/add_content.tex
	echo -e "" >> $output_dir/add_content.tex
	
	for item_s in $item/*
	do
		tmp_content="$tmp_content$(cat $item_s)"

		echo ">>>> $item_s"
		if [ "`echo $item_s | grep part`" != "" ]
		then
			name_part=`echo $item_s | cut -d '.' -f4`
			echo "\part{"$name_part"}" >> $output_dir/add_content.tex
		fi
		echo -e "$blue >>> File '$item_s' added ! $default"
		echo "\input{"$item_s"}" >> $output_dir/add_content.tex
	done

fi
done
rm $standlone
touch $standlone
echo "$tmp_content\n" >> $standlone

echo -e "$green"
echo -e "[Step $count_step / $count_sum_full] >>> Generating of import file for parts (Parts) is over"
let count_step++

if [ "$1" == "--full" ];then 
	echo -e "[Step $count_step / $count_sum_full] >>> First compilation of '$main.tex' file..."
	let count_step++
	pdflatex --output-dir=$output_dir $main.tex >> .render_report_log.txt
	echo -e "[Step $count_step / $count_sum_full] >>> Creating of bibliography..."
	echo -e "$default"
	bibtex $output_dir/$main
	echo -e "$green"
	echo -e "[Step $count_step / $count_sum_full] >>> First compilation of '$main.tex' file over !"
	let count_step++
	echo -e "[Step $count_step / $count_sum_full] >>> Glossary compilation..."
	echo -e "$default"
	mv $output_dir/$main.xdy $main.xdy  #use to make glossaries
	makeglossaries $output_dir/$main #>> .render_report.txt
	echo -e "$green"
	echo -e "[Step $count_step / $count_sum_full] >>> Glossary compilation over !"
	let count_step++
	echo -e "[Step $count_step / $count_sum_full] >>> Compilation of nomenclature...."
	echo -e "$default"
	makeindex $output_dir/$main >> .render_report.txt
	makeindex $output_dir/$main.nlo -s nomencl.ist -o $output_dir/$main.nls >> .render_report.txt
	echo -e "$green"
	echo -e "[Step $count_step / $count_sum_full] >>> Compilation of nomenclature is over"
	let count_step++
fi
if [ "$1" == "--full" ];then 
	echo -e "[Step $count_step / $count_sum_full] >>> Second compilation of  '$main.tex' file..."
else
 	echo -e "[Step $count_step / $count_sum_full] >>> First compilation of  '$main.tex' file..."
fi

echo -e "$orange"
pdflatex --output-dir=$output_dir $main >> .render_report_log.txt
echo -e "$green"
if [ "$1" == "--full" ];then 
	echo -e "[Step $count_step / $count_sum_full] >>> Second compilation of  '$main.tex' is over"
else
 	echo -e "[Step $count_step / $count_sum_full] >>> First compilation of  '$main.tex' is over"
fi

let count_step++
echo -e "[Step $count_step / $count_sum_full] >>> Moving of $main.pdf..."
echo -e "$orange"
mv $output_dir/$main.pdf $main.pdf >> .render_report.txt
echo -e "$green"
echo -e "[Step $count_step / $count_sum_full] >>> Moving of $main.pdf to root folder..."
echo -e "$orange"
echo -e ">>> Warnings : "
echo "`cat .render_report_log.txt | grep "Package Utils"`"
echo -e "$default"
echo -e "$blue"
echo -e ">>> Messages : "
echo "`cat .render_report_log.txt | grep ">>> Utils"`"
echo -e "$default"
end=`date +"%S"`
time=`expr $end - $begin`
rm $main.xdy
echo -e ">>> Compilation over in $time s ! $default"


