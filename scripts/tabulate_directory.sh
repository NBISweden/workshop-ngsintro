# Function to recursively count files and folders in directories
tabulate_directory() {
    # Check if a directory is provided, otherwise use current directory
    local search_path="${1:-.}"
    
    # Ensure the path exists and is a directory
    [[ ! -d "$search_path" ]] && {
        echo "Error: $search_path is not a valid directory" >&2
        return 1
    }
    
    # Print header
    printf "%-20s %-10s %-10s\n" "Folder" "Files" "Folders"
    printf "%-20s %-10s %-10s\n" "------" "-----" "-------"
    
    # Function to process individual directories
    process_directory() {
        local dir="$1"
        
        # Count files recursively (excluding directories)
        local file_count=$(find "$dir" -type f | wc -l)
        
        # Count directories recursively 
        # Subtract 1 to exclude the base directory itself
        local folder_count=$(find "$dir" -type d | wc -l)
        ((folder_count--))
        
        # Print formatted output
        printf "%-20s %-10s %-10s\n" "$dir" "$file_count" "$folder_count"
    }
    
    # If a specific directory is provided, process just that directory
    if [[ "$search_path" != "." ]]; then
        process_directory "$search_path"
        return 0
    fi
    
    # Otherwise, process all subdirectories in the current directory
    for dir in */; do
        # Remove trailing slash
        dir=${dir%/}
        
        # Skip if not a directory
        [[ ! -d "$dir" ]] && continue
        
        # Process the directory
        process_directory "$dir"
    done
}
