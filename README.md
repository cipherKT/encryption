# Text Encryptor/Decryptor (Archived)

> **⚠️ This repository is archived.**  
> It is no longer maintained and is kept only for historical/reference purposes.

A simple interactive Bash script for encrypting and decrypting text using **AES-256-CBC** via OpenSSL.

## Features

- Encrypt arbitrary text with a passphrase
- Generate a random salt for each encryption
- Optionally save encrypted content + salt to a file
- Decrypt from a file or by pasting the ciphertext + salt
- SHA-256 hash of the original/decrypted text (for integrity checking)
- Simple menu-driven interface

## Requirements

- Bash
- OpenSSL (`openssl` command available in your PATH)

## Usage

```bash
chmod +x encrypt_decrypt.sh   # or whatever you named the script
./encrypt_decrypt.sh
```
Then choose an option:
Encrypt text – enter plaintext + passphrase
Decrypt text – load from file or paste ciphertext + salt + passphrase
Exit
Encrypted files are stored in the encrypted_files/ directory in this format:
```
===ENCRYPTED_CONTENT===
<base64 ciphertext>
===SALT===
<hex salt>
```
Notes
The salt is required for decryption — keep it safe along with the ciphertext.
Passphrases are entered silently (no echo).
This is a basic personal tool, not a production-grade encryption solution.

Feel free to use or modify as you like. No warranty provided.