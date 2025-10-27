# AI Agent Integration Documentation

This document describes the AI agent integration used in this Minecraft server management system.

## V.A.L.K.Y.R.I.E. Discord Bot

### Overview
V.A.L.K.Y.R.I.E. is a Discord bot that assists in managing the Minecraft Bedrock server updates. It serves as a crucial component in the update process by managing the version information and update links.

### Integration Points
The primary integration point is through the `bedrock_last_link.txt` file, which the bot manages to facilitate server updates.

### Command Interface
The bot provides the following command for server management:

```
/set_minecraftpatch <patch>
```

#### Parameters
- `patch`: The Minecraft Bedrock patch version (format: x.xx.xxx.x)
  - Example: 1.21.113.1

#### Validation
- The command includes version format validation
- Follows pattern: ^\d+\.\d+\.\d+\.\d+$
- Example of valid format: 1.21.113.1

### Update Process Flow
1. Administrator identifies new Minecraft Bedrock server version
2. Command `/set_minecraftpatch` is issued with new version number
3. Bot validates version format
4. On successful validation:
   - Generates download URL
   - Updates `/minecraft/bedrock_last_link.txt`
5. Update script (`update.sh`) uses the link file for server updates

### Security
- Command access is restricted by role (minimum role level: 3)
- Uses SSH for server file modifications
- All operations are logged and monitored

### Error Handling
- Invalid version format triggers user notification
- SSH command failures are logged and reported
- Permission issues are caught and reported to user

### Integration Benefits
- Simplified version management
- Reduced human error in URL handling
- Centralized control through Discord
- Audit trail of version updates
- Automated validation of version numbers

## Future Enhancements
Potential improvements for the agent integration:

1. Version availability checking
2. Automatic version detection
3. Scheduled update notifications
4. Update success/failure notifications
5. Backup confirmation messages
6. Server status monitoring
7. Performance metrics reporting

## Troubleshooting
If the agent integration fails:
1. Check Discord bot status
2. Verify SSH connectivity
3. Confirm file permissions
4. Review Discord role assignments
5. Check server connectivity
6. Verify file system access