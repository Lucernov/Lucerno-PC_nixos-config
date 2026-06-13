#!/usr/bin/env bash
# Запускает сервер Ollama в фоне, если он ещё не запущен
if pgrep -f "ollama serve" > /dev/null; then
    echo "Ollama server already running"
else
    nohup ollama serve > /tmp/ollama.log 2>&1 &
    echo "Ollama server started (PID: $!)"
fi
