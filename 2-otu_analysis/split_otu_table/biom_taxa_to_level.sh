# echo the help if not input all the options
help()
{
cat <<HELP
USAGE: $0 input_otu_table output_dir if_relative_abundance[n or y]
    or $0 ‐h # show this message
EXAMPLE:
    $0 otu_table.biom final_myshu_results n #修改
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help

in=$1 # otu_table.biom
outdir=$2
tag=$3
pro_dir=$(dirname $0)
#echo $pro_dir
if [ $tag == "y" ]; then
  tag=""
else 
  tag="-a"
fi
#echo $tag
# summarize_taxa
summarize_taxa.py -i $in -o $outdir -L 1,2,3,4,5,6 $tag

for i in $outdir/*_L*.txt
do
	name=$(basename $i .txt)
	# rm header
	sed -i '1,2d' $i
	cat $i | awk -F'_' '{print $NF}' > $name.tmp.txt
	perl $pro_dir/biom_taxa_to_level.pl -in $name.tmp.txt -out $outdir/$name.final.out
done
rm *_L*.tmp.txt

# summarize_taxa
summarize_taxa.py -i $in -o $outdir -L 7 $tag

for i in $outdir/*_L7.txt
do
	name=$(basename $i .txt)
	# rm header
	sed -i '1,2d' $i
	cat $i | awk -F'g__' '{print $NF}' > $name.tmp.txt
	perl -p -i -e 's/;s__/ /g' $name.tmp.txt
	perl $pro_dir/biom_taxa_to_level.pl -in $name.tmp.txt -out $outdir/$name.final.out
done
rm *_L*.tmp.txt

