#!/bin/sh

# Start the backend service in the background
echo "Starting backend service..."
pnpm start --characters=characters/character.json &

# Start the frontend client in the background
echo "Starting frontend service..."
pnpm start:client &

# Wait for backend (port 3000) to be ready
while ! nc -z localhost 3000; do
  echo "Waiting for backend service on port 3000..."
  sleep 2
done
echo "Backend service is ready!"

# Wait for frontend (port 5173) to be ready
while ! nc -z localhost 5173; do
  echo "Waiting for frontend service on port 5173..."
  sleep 2
done
echo "Frontend service is ready!"

# Start Caddy
echo "Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
