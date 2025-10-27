# Minecraft Bedrock Server Management Scripts

Scripts to automate the management and updating of an Ubuntu Linux Minecraft Bedrock Server.

## Overview
These scripts handle automated backups, updates, and restoration of a Minecraft Bedrock server installation.

### Features
- Automated backup system (retains last 65 days)
- Server update automation
- Configuration and world restoration
- Systemd service integration
- Integration with Discord bot for version management

## Scripts Description

### backup.sh
- Creates timestamped backups of the server
- Automatically removes backups older than 65 days
- Includes worlds and server configurations
- Excludes backup directory to prevent recursive backups

### update.sh
- Handles server version updates
- Performs automatic backup before updating
- Downloads and installs new server version
- Restores worlds and configurations after update

### restore.sh
- Restores server configuration from latest backup
- Preserves world data and permissions
- Handles server restart process

## Important Notes
- These scripts are designed as supplementary backup solution (65-day retention)
- Requires proper systemd service setup for Minecraft
- Server files expected in `/minecraft/bedrock/` directory
- Backup storage in `/minecraft/backups/`

## Update Check Process
The original `updatecheck.sh` script has been archived due to difficulties with automated link extraction. The update process now utilizes the V.A.L.K.Y.R.I.E. Discord bot (see [bjans13/VALKYRIE](https://github.com/bjans13/VALKYRIE)) for version management. This provides a more reliable and controlled way to update the server version.

# V.A.L.K.Y.R.I.E. handler [bjans13/VALKYRIE](https://github.com/bjans13/VALKYRIE)
Here is the handler within the bot used to make the update process easier without tearing down the bedrock_last_link.txt method in case I find a differnt way to feed it the patch number down the road.

>     registerCommand({
>       name: 'set_minecraftpatch',
>       usage: 'set_minecraftpatch <patch>',
>       legacyKey: 'set minecraftpatch',
>       description: 'Update the Minecraft Bedrock download link to a specific patch version.',
>       category: 'Minecraft',
>       minRole: 3,
>       options: [
>           {
>               name: 'patch',
>               description: 'The Minecraft Bedrock patch version (e.g., 1.21.113.1).',
>               type: ApplicationCommandOptionType.String,
>               required: true,
>           },
>       ],
>       handler: async (interaction) => {
>         const patch = interaction.options.getString('patch', true).trim();
>         const patchRegex = /^\d+\.\d+\.\d+\.\d+$/;
>
>         if (!patchRegex.test(patch)) {
>             await respond(
>                 interaction,
>                 'Invalid patch format. Please use the format `/set_minecraftpatch 1.21.113.1`.',
>                 { ephemeral: true }
>             );
>             return;
>         }
>
>         const newLink = `https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-${patch}.zip`;
>         const command = `echo "${newLink}" | sudo tee /minecraft/bedrock_last_link.txt > /dev/null`;
>
>         await respond(interaction, 'Updating Minecraft Bedrock download link...');
>         try {
>             await runSSHCommand(config.minecraft, command);
>             await respond(interaction, `Minecraft Bedrock download link updated to version ${patch}.`);
>         } catch (error) {
>             console.error('Failed to update Minecraft download link:', error);
>             await respond(
>                 interaction,
>                 'Failed to update the download link due to insufficient permissions or other errors.'
>             );
>         }
>       },
>      });

# TODO / Recommendations
1. Add error logging to a dedicated log file
2. Implement backup verification
3. Add configuration file for paths and retention settings
4. Include backup compression level options
5. Add backup rotation strategy beyond simple date-based deletion
6. Implement notification system for successful/failed operations
7. Add checksum verification for downloaded server files
8. Create a configuration backup separate from world backups
9. Add server performance monitoring
10. Implement automatic backup testing
