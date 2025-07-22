#!/bin/bash

case $1 in
    "start")
        echo "🎵 Iniciando Parranda Assistant..."
        docker-compose up -d
        ;;
    "stop")
        docker-compose down
        ;;
    "logs")
        docker-compose logs -f
        ;;
    "status")
        docker-compose ps
        ;;
    "urls")
        echo "📱 Chat: $(gp url 3000)"
        echo "🔧 n8n: $(gp url 5678)"
        ;;
    "install-model")
        docker-compose exec ollama ollama pull llama3.1:8b
        ;;
    *)
        echo "Comandos: start, stop, logs, status, urls, install-model"
        ;;
esac
