# echo the help if not input all the options
help()
{
cat <<HELP
USAGE: $0 class output_dir otu_table map_file
    or $0 ‐h # show this message
EXAMPLE:
    $0 Type split_otu_table_by_Type otu_table.biom map_file.txt
HELP
exit 0
}
[ -z "$1" ] && help
[ "$1" = "-h" ] && help


class=$1 # map file class
output=$2
otu_table=$3 # biom format
map_file=$4

if [ ! -d "$output" ]; then
  mkdir $output
fi
pro=$(dirname $0)
split_otu_table.py -i $otu_table -m $map_file -f $class -o $output
for i in $output/*.biom
do
	name=$(basename $i .biom)
	$pro/biom_taxa_to_level.sh $i $output/$name\_final_out
done
