#!/usr/bin/env bash
if pgrep -f "ollama serve" > /dev/null; then
    echo "Ollama server is running"
    ps aux | grep "ollama serve" | grep -v grep
else
    echo "Ollama server is stopped"
fi
echo "Press any key to close..."
read -n 1
