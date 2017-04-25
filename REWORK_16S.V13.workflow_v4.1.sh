clear
echo ""
echo "Running: 16S V13 workflow version 4.1"
date

echo ""
echo "Finding your samples and copying them to the current folder"

#Just write in a text file (ref: samples) your samples prefix-names (ex: SRR1656520 from SRR1656520_R1.fastq), separate by a new-line

while read data/samples
do
a="_" ;
NAME=$samples$a ;
head -n 1 data/$NAME*1* | sed 's/\@/>/' >> id.txt ;
head -n data/200000 $NAME*1* >> forward.fastq
head -n data/200000 $NAME*2* >> reverse.fastq
gzip $NAME*R1* ; 
done < data/samples

paste -d "\t" id.txt data/samples > sampleid.txt
date

echo ""
echo "Removing bad quality reads"

#Download: wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.36.zip
##########CHECK JAVA -JAR OR NOT##########
java Trimmomatic-0.36/trimmomatic-0.36.jar PE forward.fastq reverse.fastq forward_qs.fastq.gz s1.fastq.gz reverse_qs.fastq.gz s2.fastq.gz SLIDINGWINDOW:1:3 MINLEN:275 2> temp.log
date

echo ""
echo "Merging reads"

#Download: wget https://sourceforge.net/projects/flashpage/files/FLASH-1.2.11.tar.gz/download
#Read The README text file to TAR the file !!!

./FLASH-1.2.11/flash -m 25 -M 200 forward_qs.fastq.gz reverse_qs.fastq.gz -o temp > flash.log
perl 16S-analysis/scripts/trim.fastq.length.pl -i temp.extendedFrags.fastq -o merged_l.fastq -m 425 -x 525 > temp.log
date

#Download: git clone https://github.com/torognes/vsearch.git
#PhiX file: wget http://bcb.dfci.harvard.edu/~vwang/phix.fasta

echo ""
echo "Removing potential phiX contamination"
split -l 10000000 merged_l.fastq splitreads
for sreads in splitreads*
do
b=".temp1";
c=".temp2";
NAMEb=$sreads$b;
NAMEc=$sreads$c;
./vsearch-2.4.3-macos-x86_64/bin/vsearch --fastq_filter $sreads --fastaout $NAMEb -quiet
./vsearch-2.4.3-macos-x86_64/bin/vsearch --usearch_global $NAMEb --db data/phix.fasta --strand both --id 0.97 --notmatched $NAMEc --quiet
done

cat *.temp2 > merged_ls.fasta
rm splitreads*
date

#Download scripts: git clone https://github.com/MadsAlbertsen/16S-analysis.git

echo ""
echo "Dereplicating reads"
perl 16S-analysis/scripts/uparse.to.dereplicate.pl -i merged_ls.fasta -o uniques.fa -r reads.fa
date

#Download fasta_number: wget http://drive5.com/python/python_scripts.tar.gz

echo ""
echo "Clustering into OTUs"
./vsearch-2.4.3-macos-x86_64/bin/vsearch --cluster_fast uniques.fa --centroids otus.fa --quiet
python drive5/fasta_number.py otus.fa OTU_ > otus_named.fa
date

echo ""
echo "Mapping reads to the OTUs"
split -l 10000000 reads.fa splitreads

for sreads in splitreads*
do
a=".uc";
NAME=$sreads$a;
./vsearch-2.4.3-macos-x86_64/bin/vsearch --usearch_global $sreads --db otus_named.fa --strand plus --id 0.97 --uc $NAME --quiet
done

cat *.uc > readmap
rm splitreads*
mv readmap readmap.uc
date

#Download database: wget http://www.midasfieldguide.org/download/midas_v2_13/midas_s123_213tar.gz
#tar xzvf midas_s123_213tar
#Download rdp_classifer on https://sourceforge.net/projects/rdp-classifier/files/rdp-classifier/ ; only version 2.2
#QIIME script, don't forget the command: 'source activate qiime1'

echo ""
echo "Classifying the OTUs"
parallel_assign_taxonomy_rdp.py -c 0.8 -i otus_named.fa -o taxonomy -r data/MiDAS_S123_2.1.3.fasta -t data/MiDAS_S123_2.1.3.tax -O 10 --rdp_max_memory 3000 --rdp_classifier_fp rdp_classifier_2.2/rdp_classifier-2.2.jar
date
