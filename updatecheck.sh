#!/bin/bash

# URL to scan for updates
PAGE_URL="https://www.minecraft.net/en-us/download/server/bedrock"

# File to store the last known link
LAST_LINK_FILE="/minecraft/bedrock_last_link.txt"

# Fetch the page content with user agent Mozilla
if ! PAGE_CONTENT=$(curl -fsSL -H "User-Agent: Mozilla/5.0" -H "Accept-Language: en-US,en;q=0.9" "$PAGE_URL"); then
    echo "Failed to retrieve update page from $PAGE_URL"
    exit 1
fi

# Extract the Linux bedrock server download link
CURRENT_LINK=$(echo "$PAGE_CONTENT" | grep -Eo 'https://[^" ]*bedrock-server-[0-9.]+\.zip' | head -1)

# Extract the patch number from the link for convenience
CURRENT_PATCH=$(echo "$CURRENT_LINK" | grep -Eo 'bedrock-server-[0-9.]+' | sed 's/bedrock-server-//')

# Check if the current link was successfully retrieved
if [ -z "$CURRENT_LINK" ]; then
    echo "Failed to fetch the download link. Exiting."
    exit 1
fi

# Check if the last link file exists, create if not
if [ ! -f "$LAST_LINK_FILE" ]; then
    echo "$CURRENT_LINK" > "$LAST_LINK_FILE"
    if [ -n "$CURRENT_PATCH" ]; then
        echo "Link initialized as: $CURRENT_LINK (patch $CURRENT_PATCH)"
    else
        echo "Link initialized as: $CURRENT_LINK"
    fi
    exit 0
fi

# Read the previously stored link
LAST_LINK=$(cat "$LAST_LINK_FILE")

# Compare the current link with the stored link
if [ "$CURRENT_LINK" != "$LAST_LINK" ]; then
    echo "Minecraft Bedrock Dedicated Server has updated!"
    echo "New link: $CURRENT_LINK"
    [ -n "$CURRENT_PATCH" ] && echo "Patch version: $CURRENT_PATCH"

# Email notification (assuming you have mailutils set up)
# echo -e "Subject:Minecraft Bedrock Server Updated\n\nNew link: $CURRENT_LINK" | sendmail YOUR_EMAIL@example.com

# Discord webhook
DISCORD_WEBHOOK="https://discord.com/api/webhooks/YOUR_WEBHOOK_id"

if [ -n "$CURRENT_PATCH" ]; then
    MESSAGE="📦 **Minecraft Bedrock Server Updated!**\n🔗 $CURRENT_LINK\n🧩 Patch: $CURRENT_PATCH"
else
    MESSAGE="📦 **Minecraft Bedrock Server Updated!**\n🔗 $CURRENT_LINK"
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
    if [ -n "$CURRENT_PATCH" ]; then
        echo "No change detected. Current link remains: $CURRENT_LINK (patch $CURRENT_PATCH)"
    else
        echo "No change detected. Current link remains: $CURRENT_LINK"
    fi
fi
