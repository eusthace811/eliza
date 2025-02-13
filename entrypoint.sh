#!/bin/sh

#!/bin/sh
cd /app || exit

# Start backend service in the background
echo "Starting backend service..."
pnpm start --characters=characters/character.json &

# Start frontend client in the background
echo "Starting frontend service..."
pnpm start:client --host &

# Start Caddy immediately
echo "Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
