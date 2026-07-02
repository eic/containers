## Container Environment: Available MCP Servers

This session is running inside a container that has the following MCP servers
pre-installed and ready to use. They are **not active by default** — the user
must add them to their personal configuration once.

### Available servers

| Name | Description |
|------|-------------|
| `eic-xrootd-mcp-server` | Access EIC data via XRootD from the JLab data transfer node (`root://dtn-eic.jlab.org`) |
| `eic-zenodo-mcp-server` | Browse and retrieve EIC datasets and publications from Zenodo (`https://zenodo.org`) |

### How to enable

If the user asks about EIC data, simulation inputs, published datasets, or anything
that would benefit from remote file or repository access, suggest they enable the
relevant server(s) by editing `~/.copilot/mcp-config.json`.

If the file does not exist, create it. Add or merge the following:

```json
{
  "mcpServers": {
    "eic-xrootd-mcp-server": {
      "command": "/opt/local/bin/xrootd-mcp-server",
      "env": {
        "XROOTD_SERVER": "root://dtn-eic.jlab.org"
      }
    },
    "eic-zenodo-mcp-server": {
      "command": "/opt/local/bin/zenodo-mcp-server",
      "env": {
        "ZENODO_BASE_URL": "https://zenodo.org"
      }
    }
  }
}
```

After saving the file, run /mcp show to confirm the servers are active. The configuration persists across
sessions in the user's home directory.
