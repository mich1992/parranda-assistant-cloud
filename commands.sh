#!/bin/bash

# Comandos útiles para el asistente de parranda

case $1 in
    "start")
        echo "🎵 Iniciando Asistente de Parranda Vallenata..."
        docker-compose up -d
        echo "✅ Servicios iniciados:"
        echo "   - n8n: http://localhost:5678"
        echo "   - Chat: http://localhost:3000" 
        echo "   - Base de datos: localhost:5432"
        ;;
    "stop")
        echo "🛑 Deteniendo servicios..."
        docker-compose down
        ;;
    "restart")
        echo "🔄 Reiniciando servicios..."
        docker-compose restart
        ;;
    "logs")
        docker-compose logs -f
        ;;
    "status")
        docker-compose ps
        ;;
    "db")
        echo "🗄️  Conectando a la base de datos..."
        docker-compose exec postgres psql -U parranda_user -d parranda_events
        ;;
    "backup")
        echo "💾 Creando backup de la base de datos..."
        docker-compose exec postgres pg_dump -U parranda_user parranda_events > backup_$(date +%Y%m%d_%H%M%S).sql
        echo "Backup creado: backup_$(date +%Y%m%d_%H%M%S).sql"
        ;;
    "install-model")
        echo "🤖 Instalando modelo de IA..."
        docker-compose exec ollama ollama pull llama3.1:8b
        echo "✅ Modelo llama3.1:8b instalado"
        ;;
    "clean")
        echo "🧹 Limpiando contenedores y volúmenes..."
        docker-compose down -v
        docker system prune -f
        ;;
    *)
        echo "🎵 Comandos disponibles para Parranda Vallenata Assistant:"
        echo "  start       - Iniciar todos los servicios"
        echo "  stop        - Detener servicios"  
        echo "  restart     - Reiniciar servicios"
        echo "  logs        - Ver logs en tiempo real"
        echo "  status      - Ver estado de contenedores"
        echo "  db          - Conectar a la base de datos"
        echo "  backup      - Crear backup de la base de datos"
        echo "  install-model - Instalar modelo de IA"
        echo "  clean       - Limpiar todo (¡cuidado!)"
        ;;
esac
