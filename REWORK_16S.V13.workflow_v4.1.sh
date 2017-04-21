clear
echo ""
echo "Running: 16S V13 workflow version 4.1"
date

echo ""
echo "Finding your samples and copying them to the current folder"
while read samples
do
a="_";
NAME=$samples$a;
