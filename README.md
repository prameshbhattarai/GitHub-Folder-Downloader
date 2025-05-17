# 📦 GitHub Folder Downloader (No Cloning Required)

A lightweight Bash script to **download a specific folder, single file, or entire repository** from GitHub — without the need to clone the whole project. Perfect for grabbing just the parts of a repo you actually need.

---

## ✨ Features

- 📁 Download specific folders from any **public GitHub repository**
- 📄 Download individual files
- 📦 Optionally download the full repository
- 🔐 Uses a **GitHub Personal Access Token** (via `.env`) for authenticated API access
- 🧠 Smart URL parsing — automatically detects folder, file, or repo URL

---

## 🔧 Requirements

Make sure the following tools are installed:

- Bash shell
- [`curl`](https://curl.se/)
- [`jq`](https://stedolan.github.io/jq/)
- A [GitHub Personal Access Token](https://github.com/settings/tokens)

---

## 🛠️ Setup

### 1. Copy the Script

Copy the script from this URL:

```text
https://github.com/prameshbhattarai/GitHub-Folder-Downloader/blob/main/github-download.sh
```

Save it locally (e.g., as `github-download.sh`).

### 2. Create a `.env` File

In the same directory as the script, create a `.env` file to store your GitHub token:

```bash
touch .env
```

Add the following line to the file (replace with your actual token):

```dotenv
GITHUB_TOKEN=ghp_your_token_here
```

> ⚠️ Keep your `.env` file private. Do **not** commit it to version control.

---

## 🚀 Usage

Run the script with any GitHub URL (folder, file, or repository):

```bash
sh github-download.sh <GitHub URL>
```

---

## 🧪 Examples

### 1. 📁 Download a Folder

> ⚠️ **Note:** Downloading large folder may exceed GitHub API rate limits.

```bash
sh github-download.sh https://github.com/owner/repo-name/tree/main/path/to/folder
```

### 2. 📄 Download a File

```bash
sh github-download.sh https://github.com/owner/repo-name/blob/main/path/to/file.txt
```

### 3. 📦 Download the Entire Repository

> ⚠️ **Note:** Downloading large repositories may exceed GitHub API rate limits.

```bash
sh github-download.sh https://github.com/owner/repo-name
```

---

## 📌 Tips

- Works with **public repositories** only.
- For better performance and to avoid rate-limiting, use a **GitHub token**.
- Use `.gitignore` to avoid committing `.env`.

---
