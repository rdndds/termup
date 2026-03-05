# termup-mini Installation Guide

## 🚀 Quick Install (One-Liner)

### With wget (recommended):
```bash
wget -q https://raw.githubusercontent.com/rdndds/termup/main/termup-mini.sh -O ~/termup && chmod +x ~/termup && echo 'alias termup="~/termup"' >> ~/.bashrc && source ~/.bashrc && termup --help
```

### With curl:
```bash
curl -fsSL https://raw.githubusercontent.com/rdndds/termup/main/termup-mini.sh -o ~/termup && chmod +x ~/termup && echo 'alias termup="~/termup"' >> ~/.bashrc && source ~/.bashrc && termup --help
```

**What this does:**
1. Downloads `termup-mini.sh` to `~/termup`
2. Makes it executable
3. Creates an alias in `~/.bashrc`
4. Reloads your shell config
5. Runs `termup --help` to verify

**After installation**, just run:
```bash
termup YOUR_FILE
```

---

## Alternative Installation Methods

### System-Wide Installation (Requires sudo)

```bash
curl -fsSL https://raw.githubusercontent.com/rdndds/termup/main/termup-mini.sh | sudo tee /usr/local/bin/termup >/dev/null && sudo chmod +x /usr/local/bin/termup && termup --help
```

### Manual Installation

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/rdndds/termup/main/termup-mini.sh -o termup

# Make it executable
chmod +x termup

# Move to a directory in your PATH
sudo mv termup /usr/local/bin/
# OR for user-only:
mkdir -p ~/.local/bin && mv termup ~/.local/bin/

# Test it
termup --help
```

---

## For Zsh Users

Replace `~/.bashrc` with `~/.zshrc`:

```bash
wget -q https://raw.githubusercontent.com/rdndds/termup/main/termup-mini.sh -O ~/termup && chmod +x ~/termup && echo 'alias termup="~/termup"' >> ~/.zshrc && source ~/.zshrc && termup --help
```

---

## Verification

After installation, verify it works:

```bash
# Check version/help
termup --help

# Test with a small file
echo "test" > test.txt
termup test.txt
rm test.txt
```

---

## Dependencies

- **curl** (required) - Usually pre-installed
- **jq** (optional) - For JSON parsing (has grep fallback)

Install dependencies if needed:
```bash
# Debian/Ubuntu
sudo apt install curl jq

# Fedora/RHEL
sudo dnf install curl jq

# Arch Linux
sudo pacman -S curl jq

# macOS
brew install curl jq
```

---

## Uninstall

```bash
rm ~/termup
sed -i '/alias termup=/d' ~/.bashrc
source ~/.bashrc
```

---

## Usage

```bash
# Upload a file (dual upload: fastest + pixeldrain)
termup myfile.zip

# Show help
termup --help

# Examples
termup ~/Downloads/video.mp4
termup /path/to/large-file.iso
termup screenshot.png
```

---

## What Gets Uploaded?

The script uses a **smart dual-upload strategy**:
1. Probes 4 free services in parallel (temp.sh, sendit.sh, gofile.io, filebin.net)
2. Finds the fastest responding service
3. Uploads to **fastest service + Pixeldrain** simultaneously
4. Shows progress bars for both uploads
5. Returns 2 URLs for redundancy

---

## Troubleshooting

### Command not found after installation
```bash
# Reload your shell config
source ~/.bashrc  # or source ~/.zshrc
```

### Alias not working
```bash
# Check if alias was added
grep termup ~/.bashrc

# Manually add it
echo 'alias termup="~/termup"' >> ~/.bashrc
source ~/.bashrc
```

### Progress bar not showing
Make sure you're uploading a file, not piping to termup. Progress bars work with actual file uploads.

### Upload fails
- Check internet connection
- Try a smaller file first
- Some services have size limits (usually 100MB-5GB)

---

## Features

✅ 126 lines of clean bash code  
✅ Uploads to 5 services  
✅ Smart dual-upload (fastest + Pixeldrain)  
✅ Real-time progress bars  
✅ Parallel service probing  
✅ Works with or without jq  
✅ Hardcoded Pixeldrain API key  
✅ No configuration needed  

---

## Repository

GitHub: https://github.com/rdndds/android_device_itel_P13001L

Report issues or contribute improvements on GitHub!
