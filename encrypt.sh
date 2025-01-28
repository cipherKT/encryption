#!/bin/bash

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
}

decrypt_text() {
    echo "Enter the encrypted text:"
    read -r encrypted_text
    echo "Enter the salt:"
    read -r salt
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
