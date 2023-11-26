#!/bin/bash

# Function to remove trailing slash
remove_trailing_slash() {
    local input="$1"
    
    # Remove trailing "/"
    input="${input%/}"
    
    # Print the result
    echo "$input"
}

# Example usage
your_string="s3://us-west-2-guardian-data154316-dev/privateus-west-2:0dbfd95e-2687-4cf0-950b-6232cdc14f64phone-data/972547789125/"
result=$(remove_trailing_slash "$your_string")
echo "Result: $result"
