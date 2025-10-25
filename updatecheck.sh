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

# Extract the Linux bedrock server download link by scanning for ZIP URLs
CURRENT_LINK=$(printf '%s' "$PAGE_CONTENT" | python3 - <<'PY'
import re
import sys

html = sys.stdin.read()

# Look for any https URLs that reference a bedrock-server zip
urls = re.findall(r'https://[^"\\s]*bedrock-server-[0-9][0-9.]*\\.zip', html)
linux_urls = [url for url in urls if 'linux' in url.lower()]

# Prefer links that explicitly point to the bin-linux directory, but fall back to any linux link
preferred = [url for url in linux_urls if 'bin-linux' in url.lower()]

link = (preferred or linux_urls or urls)

if not link:
    sys.exit(1)

print(link[0])
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
