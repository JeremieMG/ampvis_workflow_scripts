clear
echo ""
echo "Running: 16S V13 workflow version 4.1"
date

echo ""
echo "Finding your samples and copying them to the current folder"
while read samples
do
a="_" ;
NAME=$samples$a ;
head -n 1 $NAME*R1* | sed 's/\@/>/' >> id.txt ;
head -n 200000 $NAME*R1* >> forward.fastq
head -n 200000 $NAME*R2* >> reverse.fastq
gzip $NAME*R1* ; 
done < samples

paste -d "\t" id.txt samples > sampleid.txt
date
