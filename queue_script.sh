#!/usr/bin/env bash
#$ -N jeremie_ampvis   #Name your job <name>
#$ -M malengreau.jeremie@gmail.com   #your e-mail address
#$ -cwd  #Use the directory you're running from
#$ -l h_rt=6:0:0,h_vmem=20G   #Setting running time in hours:min:sec and the memory required for the job
#$ -j y   #Joining the output from standard out and standard error to one file
#$ -pe smp 10   #Setting the number of threads for the job to best fit for the system between 1 and N.
##### LOAD MODULE ####

#Modules are listed with the moduel avail command
module load vsearch	
######### Variables. These are just examples, please change as you see fit

## Run module
source /home/jeremie/miniconda3/bin/activate qiime1

while read samples
do
a="_" ;
NAME=$samples$a ;
head -n 1 $NAME*1* | sed 's/\@/>/' >> id.txt ;
head -n 200000 $NAME*1* >> forward.fastq
head -n 200000 $NAME*2* >> reverse.fastq
done < samples

paste -d "\t" id.txt samples > sampleid.txt

java -jar Trimmomatic-0.36/trimmomatic-0.36.jar PE forward.fastq reverse.fastq forward_qs.fastq.gz s1.fastq.gz reverse_qs.fastq.gz s2.fastq.gz SLIDINGWINDOW:1:3 MINLEN:100 2> temp.log

./FLASH-1.2.11/flash -m 25 -M 200 forward_qs.fastq.gz reverse_qs.fastq.gz -o temp > flash.log
perl 16S-analysis/scripts/trim.fastq.length.pl -i temp.extendedFrags.fastq -o merged_l.fastq -m 200 -x 300 > temp.log

split -l 10000000 merged_l.fastq splitreads
for sreads in splitreads*
do
b=".temp1";
c=".temp2";
NAMEb=$sreads$b;
NAMEc=$sreads$c;
vsearch --fastq_filter $sreads --fastaout $NAMEb --quiet
vsearch --usearch_global $NAMEb --db data/phix.fasta --strand both --id 0.97 --notmatched $NAMEc --quiet
done

cat *.temp2 > merged_ls.fasta
rm splitreads*

perl 16S-analysis/scripts/uparse.to.dereplicate.pl -i merged_ls.fasta -o uniques.fa -r reads.fa

vsearch --cluster_fast uniques.fa --centroids otus.fa --id 0.97 --quiet
./drive5_py/fasta_number.py otus.fa OTU_ > otus_file

split -l 10000000 reads.fa splitreads

for sreads in splitreads*
do
a=".uc";
NAME=$sreads$a;
vsearch --usearch_global $sreads --db otus_file --strand plus --id 0.97 --uc $NAME --quiet
done

cat *.uc > readmap
rm splitreads*
mv readmap readmap.uc

parallel_assign_taxonomy_rdp.py -c 0.8 -i otus_file -o taxonomy -r data/MiDAS_S123_2.1.3.fasta -t data/MiDAS_S123_2.1.3.tax -O 20 --rdp_max_memory 30000 --rdp_classifier_fp rdp_classifier_2.2/rdp_classifier-2.2.jar

perl 16S-analysis/scripts/uparse.to.otutable.pl -s sampleid.txt -u readmap.uc -o otutable.txt -t taxonomy/otus_file_tax_assignments.txt 

rm otus.fa
mv otus_file otus.fa
rm *.log
rm readmap.uc
rm sampleid.txt
rm reads.fa
rm uniques.fa
rm -r taxonomy/
rm reverse*
rm forward*
rm temp*
rm merged*
rm id.txt

source /home/jeremie/miniconda3/bin/deactivate
