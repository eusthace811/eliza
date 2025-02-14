#!/bin/sh
set -e  # Exit if any command fails

cd /app || exit

echo "Starting backend service..."
pnpm start --characters=characters/character.json &

sleep 60

echo "Starting frontend service..."
pnpm start:client --host &

sleep 30

echo "Starting Caddy..."
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
