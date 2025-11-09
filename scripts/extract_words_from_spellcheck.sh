#!/bin/bash

# Extract words between blocks of dashed lines (----------------),
# convert to lowercase, find unique words, sort alphabetically

# Configuration
INPUT_FILE="output.txt"
OUTPUT_FILE=".github/.wordlist.txt"

# Process the input from output.txt
# Extract only words between dashed lines that follow "Misspelled words:"
# Remove the prefix "[spellcheck/spellcheck]   | " from each line first
awk '
BEGIN { in_misspelled = 0; in_block = 0 }
{
    # Remove the prefix if it exists
    sub(/^\[spellcheck\/spellcheck\]   \| /, "")
}
/Misspelled words:/ { 
    in_misspelled = 1
    next
}
in_misspelled && /^-{10,}$/ { 
    if (!in_block) {
        in_block = 1
    } else {
        in_block = 0
        in_misspelled = 0
    }
    next
}
in_block { print }
' "$INPUT_FILE" | \
tr '[:upper:]' '[:lower:]' | \
tr -s '[:space:]' '\n' | \
grep -v '^$' | \
sort -u > "$OUTPUT_FILE"

# Count and print the number of unique words found
word_count=$(wc -l < "$OUTPUT_FILE")
echo "Words extracted and saved to $OUTPUT_FILE"
echo "Total unique words found: $word_count"
