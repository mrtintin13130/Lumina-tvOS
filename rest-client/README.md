# Lumina API REST Client Requests

These `.http` files are grouped by API area for VS Code REST Client-compatible tooling.

Before running protected requests:

1. Start the API locally.
2. Run `00-health-auth.http` setup/status, register, or login.
3. Set `token` in each file from the login/register response.
4. Replace placeholder IDs and paths near the top of each file as your local database requires.

Streaming and scanner requests can start expensive filesystem or ffmpeg work. Run the admin-only scanner, cleanup, speed-test, refresh, and enrichment requests deliberately.
