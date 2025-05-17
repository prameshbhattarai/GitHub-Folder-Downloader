#!/bin/bash

# Load environment variables from .env file
if [ -f ".env" ]; then
    source .env
else
    echo "❌ .env file not found. Please create one with GITHUB_TOKEN=your_token"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN is not set. Please set it in the .env file."
    exit 1
fi

INPUT_URL="$1"

if [ -z "$INPUT_URL" ]; then
    echo "Usage: $0 <GitHub folder, file, or repo URL>"
    exit 1
fi

# Download a single file
download_single_file() {
    local user="$1"
    local repo="$2"
    local branch="$3"
    local path="$4"

    api_url="https://api.github.com/repos/$user/$repo/contents/$path?ref=$branch"
    echo "📄 Fetching file metadata: $api_url"

    response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$api_url")
    download_url=$(echo "$response" | jq -r '.download_url')
    filename="$(basename "$path")"

    if [ "$download_url" == "null" ]; then
        echo "❌ Failed to get download URL for $path"
        return 1
    fi

    echo "📥 Downloading single file: $filename"
    curl -s -L -H "Authorization: Bearer $GITHUB_TOKEN" "$download_url" -o "$filename"

    if [ $? -eq 0 ]; then
        echo "✅ Done: $filename"
    else
        echo "❌ Failed to download $filename"
    fi
}

# Recursive folder download
download_recursive() {
    local api_url="$1"
    local base_dir="$2"

    echo "api_url = $api_url"
    echo "base_dir = $base_dir"

    curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$api_url" | jq -c '.[]' | while read -r item; do
        type=$(echo "$item" | jq -r '.type // "null"')
        download_url=$(echo "$item" | jq -r '.download_url // "null"')
        name=$(echo "$item" | jq -r '.name // "null"')
        url=$(echo "$item" | jq -r '.url // "null"')

        echo "Type: $type, Download URL: ${download_url}, Name: $name, URL: $url"

        if [ "$type" = "file" ]; then
            echo "📥 Downloading: $base_dir/$name"
            mkdir -p "$base_dir"
            curl -s -L -H "Authorization: Bearer $GITHUB_TOKEN" "$download_url" -o "$base_dir/$name"
        elif [ "$type" = "dir" ]; then
            echo "📁 Entering: $base_dir/$name"
            mkdir -p "$base_dir/$name"
            download_recursive "$url" "$base_dir/$name"
        fi
    done
}

# Get default branch of a repo
get_default_branch() {
    local user="$1"
    local repo="$2"

    curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$user/$repo" | jq -r '.default_branch // empty'
}

# Main logic
if [[ "$INPUT_URL" =~ github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.*) ]]; then
    USER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    BRANCH="${BASH_REMATCH[3]}"
    FOLDER_PATH="${BASH_REMATCH[4]}"
    BASE_DIR="$(basename "$FOLDER_PATH")"
    API_URL="https://api.github.com/repos/$USER/$REPO/contents/$FOLDER_PATH?ref=$BRANCH"

    echo "📁 Detected folder URL. Downloading contents into: $BASE_DIR"
    download_recursive "$API_URL" "$BASE_DIR"

elif [[ "$INPUT_URL" =~ github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.*) ]]; then
    USER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    BRANCH="${BASH_REMATCH[3]}"
    FILE_PATH="${BASH_REMATCH[4]}"

    echo "📄 Detected single file URL. Downloading to current directory..."
    download_single_file "$USER" "$REPO" "$BRANCH" "$FILE_PATH"

elif [[ "$INPUT_URL" =~ github\.com/([^/]+)/([^/]+)/?$ ]]; then
    USER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"

    echo "📦 Detected full repo URL. Getting default branch..."
    BRANCH=$(get_default_branch "$USER" "$REPO")
    if [ -z "$BRANCH" ]; then
        echo "❌ Failed to retrieve the default branch for $USER/$REPO."
        exit 1
    fi

    API_URL="https://api.github.com/repos/$USER/$REPO/contents?ref=$BRANCH"
    BASE_DIR="$REPO"

    echo "📁 Downloading entire repository into: $BASE_DIR"
    download_recursive "$API_URL" "$BASE_DIR"

else
    echo "❌ Unrecognized GitHub URL format."
    exit 1
fi
