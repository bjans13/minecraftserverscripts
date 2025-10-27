# NOT WORKING SEE UPDATECHECK.MD FOR DETAILS

# !/bin/bash

# URL to scan for updates
PAGE_URL="https://www.minecraft.net/en-us/download/server/bedrock"

# File to store the last known link
LAST_LINK_FILE="/minecraft/bedrock_last_link.txt"

# Fetch the page content with user agent Mozilla
PAGE_CONTENT=$(wget -qO- --header="User-Agent: Mozilla/5.0" "$PAGE_URL")

# Extract the Linux bedrock server download link
CURRENT_LINK=$(echo "$PAGE_CONTENT" | grep -Eo 'https://www\.minecraft\.net/bedrockdedicatedserver/bin-linux/bedrock-server-[0-9.]+\.zip' | head -1)

# Check if the current link was successfully retrieved
if [ -z "$CURRENT_LINK" ]; then
    echo "Failed to fetch the download link. Exiting."
    exit 1
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

# Email notification (assuming you have mailutils set up)
# echo -e "Subject:Minecraft Bedrock Server Updated\n\nNew link: $CURRENT_LINK" | sendmail YOUR_EMAIL@example.com

# Discord webhook
DISCORD_WEBHOOK="https://discord.com/api/webhooks/YOUR_WEBHOOK_id"

MESSAGE="📦 **Minecraft Bedrock Server Updated!**\n🔗 $CURRENT_LINK"

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
