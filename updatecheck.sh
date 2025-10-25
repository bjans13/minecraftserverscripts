#!/bin/bash

# URL to scan for updates
PAGE_URL="https://www.minecraft.net/en-us/download/server/bedrock"

# File to store the last known link
LAST_LINK_FILE="/minecraft/bedrock_last_link.txt"

# Fetch the page content with a desktop browser user agent
PAGE_CONTENT=$(curl -fsSL --compressed \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.9" \
    "$PAGE_URL" 2>/dev/null)

if [ -z "$PAGE_CONTENT" ]; then
    echo "Failed to fetch the download page content. Exiting."
    exit 1
fi

# Extract the Linux bedrock server download link from the embedded Next.js data
CURRENT_LINK=$(printf '%s' "$PAGE_CONTENT" | python3 - <<'PY'
import json
import sys

html = sys.stdin.read()
start_tag = '<script id="__NEXT_DATA__" type="application/json">'
end_tag = '</script>'
start = html.find(start_tag)
if start == -1:
    sys.exit(1)
start += len(start_tag)
end = html.find(end_tag, start)
if end == -1:
    sys.exit(1)
try:
    data = json.loads(html[start:end])
except json.JSONDecodeError:
    sys.exit(1)

def find_download(value):
    if isinstance(value, str):
        if "bedrockdedicatedserver" in value and "bin-linux" in value and value.endswith('.zip'):
            return value
        return None
    if isinstance(value, dict):
        for item in value.values():
            result = find_download(item)
            if result:
                return result
    elif isinstance(value, list):
        for item in value:
            result = find_download(item)
            if result:
                return result
    return None

link = find_download(data)
if not link:
    sys.exit(1)
print(link)
PY
)

# Check if the current link was successfully retrieved
if [ -z "$CURRENT_LINK" ]; then
    echo "Failed to parse the download link. Exiting."
    exit 1
fi

CURRENT_VERSION=$(echo "$CURRENT_LINK" | sed -n 's/.*bedrock-server-\([0-9.]*\)\.zip/\1/p')

if [ -z "$CURRENT_VERSION" ]; then
    echo "Failed to extract the version number from the download link."
else
    echo "Detected Bedrock Dedicated Server version: $CURRENT_VERSION"
fi

# Check if the last link file exists, create if not
if [ ! -f "$LAST_LINK_FILE" ]; then
    echo "$CURRENT_LINK" > "$LAST_LINK_FILE"
    echo "Link initialized as: $CURRENT_LINK"
    exit 0
fi

# Read the previously stored link
LAST_LINK=$(cat "$LAST_LINK_FILE")

# Compare the current link with the stored link
if [ "$CURRENT_LINK" != "$LAST_LINK" ]; then
    echo "Minecraft Bedrock Dedicated Server has updated!"
    echo "New link: $CURRENT_LINK"

    # Discord webhook
    DISCORD_WEBHOOK="https://discord.com/api/webhooks/YOUR_WEBHOOK_id"

    MESSAGE="📦 **Minecraft Bedrock Server Updated!**\\n🔗 $CURRENT_LINK"
    if [ -n "$CURRENT_VERSION" ]; then
        MESSAGE="${MESSAGE}\\n🧩 Version: $CURRENT_VERSION"
    fi

    curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\": \"$MESSAGE\"}" \
        "$DISCORD_WEBHOOK"

    # Update the stored link
    echo "$CURRENT_LINK" > "$LAST_LINK_FILE"

    # Run the update script
    bash /minecraft/update.sh
else
    echo "No change detected. Current link remains: $CURRENT_LINK"
fi
