### Calomel.org  sanitize_filenames.sh
#
# change the space,parenthesis,square brackets into underline"_" which is easy to use on UNIX-like system.
for a in *; do
     file=$(echo $a | tr A-Z a-z | tr ' ' _ | tr '(' _ | tr ')' _ | tr ',' _  | tr '[' _ | tr ']' _ )
     [ ! -f $file ] && mv "$a" $file
done
