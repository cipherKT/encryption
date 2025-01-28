#!/bin/bash

save_to_file() {
    local content=$1
    local salt=$2
    
    echo "Enter filename to save the encrypted data:"
    read -r filename
    
    # Create directory if it doesn't exist
    mkdir -p "encrypted_files"
    
    # Full path for the file
    filepath="encrypted_files/$filename"
    
    if [ -f "$filepath" ]; then
        echo "File already exists. Do you want to overwrite it? (y/n)"
        read -r response
        if [[ ! $response =~ ^[Yy]$ ]]; then
            echo "Operation cancelled"
            return 1
        fi
    fi
    
    # Save encrypted content and salt to file
    echo "===ENCRYPTED_CONTENT===" > "$filepath"
    echo "$content" >> "$filepath"
    echo "===SALT===" >> "$filepath"
    echo "$salt" >> "$filepath"
    
    echo "Data saved successfully to $filepath"
}

read_from_file() {
    echo "Enter filename to read encrypted data:"
    read -r filename
    
    filepath="encrypted_files/$filename"
    
    if [ ! -f "$filepath" ]; then
        echo "Error: File does not exist"
        return 1
    fi
    
    local content=""
    local salt=""
    local reading_content=false
    local reading_salt=false
    
    while IFS= read -r line; do
        if [[ "$line" == "===ENCRYPTED_CONTENT===" ]]; then
            reading_content=true
            reading_salt=false
            continue
        elif [[ "$line" == "===SALT===" ]]; then
            reading_content=false
            reading_salt=true
            continue
        fi
        
        if [ "$reading_content" = true ]; then
            content=$line
        elif [ "$reading_salt" = true ]; then
            salt=$line
        fi
    done < "$filepath"
    
    echo "$content:$salt"
}

encrypt_text() {
    echo "Enter the text to encrypt:"
    read -r text
    echo "Enter the passphrase:"
    read -s passphrase
    echo
    
    # Create a salt for additional security
    salt=$(openssl rand -hex 8)
    
    # Create hash of the original text (using SHA-256)
    original_hash=$(echo -n "$text" | sha256sum | cut -d' ' -f1)
    
    # Encrypt the text using AES-256-CBC
    encrypted=$(echo -n "$text" | openssl enc -aes-256-cbc -a -salt -pass "pass:$passphrase" -S "$salt" 2>/dev/null)
    
    echo "Encrypted text: $encrypted"
    echo "Salt (save this): $salt"
    echo "Original text hash: $original_hash"
    
    echo "Do you want to save this to a file? (y/n)"
    read -r save_choice
    if [[ $save_choice =~ ^[Yy]$ ]]; then
        save_to_file "$encrypted" "$salt"
    fi
}

decrypt_text() {
    local encrypted_text=""
    local salt=""
    
    echo "Do you want to read from a file? (y/n)"
    read -r read_choice
    
    if [[ $read_choice =~ ^[Yy]$ ]]; then
        IFS=':' read -r encrypted_text salt <<< "$(read_from_file)"
        if [ -z "$encrypted_text" ] || [ -z "$salt" ]; then
            echo "Error reading from file"
            return 1
        fi
    else
        echo "Enter the encrypted text:"
        read -r encrypted_text
        echo "Enter the salt:"
        read -r salt
    fi
    
    echo "Enter the passphrase:"
    read -s passphrase
    echo
    
    # Decrypt the text
    decrypted=$(echo "$encrypted_text" | openssl enc -aes-256-cbc -a -d -salt -pass "pass:$passphrase" -S "$salt" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "Decrypted text: $decrypted"
        
        # Calculate hash of decrypted text
        decrypted_hash=$(echo -n "$decrypted" | sha256sum | cut -d' ' -f1)
        echo "Decrypted text hash: $decrypted_hash"
    else
        echo "Error: Decryption failed. Please check your passphrase and salt."
    fi
}

while true; do
    echo "Choose an option:"
    echo "1) Encrypt text"
    echo "2) Decrypt text"
    echo "3) Exit"
    read -r choice
    
    case $choice in
        1) encrypt_text ;;
        2) decrypt_text ;;
        3) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
    
    echo
done
