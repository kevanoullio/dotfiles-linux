# How to check for an ssh key and upload it to github

### 1. Check if an SSH Key Exists on Your Linux Machine Using Bash
- Open a terminal.
- Navigate to the .ssh directory:

```bash
cd ~/.ssh
```

- List the files in the directory:

```bash
ls
```

- Look for files named id_rsa.pub, id_ecdsa.pub, or id_ed25519.pub. If any of these files exist, you have an SSH key.

### 2. Generate an Ed25519 SSH Key
- Generate the SSH key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

- Follow the prompts to save the key in the default location and set a passphrase (optional).

### 3. Upload the Public Key to GitHub

- Copy the public key to the clipboard:

```bash
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
```

- Go to GitHub and log in.
- Navigate to Settings > SSH and GPG keys > New SSH key.
- Paste the public key into the "Key" field and give it a title.
- Select "Authentication" as the key type.
- Click Add SSH key.

### 4. Start the ssh-agent and Add Your SSH Key
- Start the ssh-agent in the background:

```bash
eval "$(ssh-agent -s)"
```

- Add your SSH private key to the ssh-agent:

```bash
ssh-add ~/.ssh/id_ed25519
```

### 5. Test if the SSH Key Works
- Test the SSH key by running the following command in the terminal:

```bash
ssh -T git@github.com
```

- You should see a message like:

```
"Hi username! You've successfully authenticated, but GitHub does not provide shell access."
```

