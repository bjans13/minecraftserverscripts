# SCRIPT updatecheck.sh NOT WORKING! - Movded to archive
unable to pull the correct download link from the page and surrendered. I resorted to handeling this task paired with my V.A.L.K.Y.R.I.E. discord bot, in my valkyrie repo. I find the new patch number and give to V.A.L.K.Y.R.I.E. on discord to update bedrock_last_link.txt

## V.A.L.K.Y.R.I.E. handler
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