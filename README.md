# ampvis_workflow_scripts
Scripts and notes to generate data for the shiny_ampvis application (http://albertsenlab.org/shinyampvis/)

## REWORK_16S.V13.workflow_v4.1.sh
Orignial script: https://github.com/MadsAlbertsen/16S-analysis/blob/master/data.generation/16S.V13.workflow_v4.1.sh 
- Run this script to generates the otu_table needed for the shiny_ampvis application

### Before run this script
Make sure to have the following softwares (the download links are in the script):
- trimmomatic-0.36
- FLASH-1.2.11
- GitHub branch "16S-analysis/scripts/" (https://github.com/MadsAlbertsen/16S-analysis/tree/master/scripts)
- vsearch
- fasta_number script from http://drive5.com/python/python_scripts.tar.gz
- rdp_classifer
- QIIME 

Replace 16S-analysis/scripts/uparse.to.otutable.pl script by:
- REWORK_uparse.to.otutable.pl (https://github.com/JeremieMG/ampvis_workflow_scripts)

Import your 16S data (paired_end fastq) in the main reposotory or change the directory.

Create/Modify the "samples" file as explained in the script.

## Use this script on the server
Just run the following command:
```
qsub queue_script.sh
```

### Informations about this queue script:
QQIME is not a module loaded on the server, it was installed from MiniConda.
Remove the next commands if qiime is working on a module:
```
source activate/deactivate qiime1
```

## Another informations
- Make sure to get the right paths for each software
- Don't use their webserver, install shiny-ampvis on your own computer (version is different)
- Create a metadata file
