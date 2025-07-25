#!/bin/bash

# Comandos útiles para el asistente de parranda con OpenAI

case $1 in
    "start")
        echo "🎵 Iniciando Asistente de Parranda Vallenata con OpenAI..."
        
        # Verificar que existe el archivo .env con la API key
        if [ ! -f .env ]; then
            echo "⚠️  IMPORTANTE: Necesitas crear un archivo .env con tu API key de OpenAI"
            echo "   Ejemplo de contenido del archivo .env:"
            echo "   OPENAI_API_KEY=sk-tu-api-key-aqui"
            echo ""
            echo "   Puedes obtener tu API key en: https://platform.openai.com/api-keys"
            echo ""
            read -p "¿Quieres continuar sin la API key? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Configuración cancelada. Crea el archivo .env primero."
                exit 1
            fi
        fi
        
        docker-compose up -d
        echo "✅ Servicios iniciados:"
        echo "   - Chat Web: http://localhost:3000"
        echo "   - N8N: http://localhost:5678 (admin/parranda2024)"
        echo "   - Base de datos: localhost:5432"
        echo ""
        echo "🔑 Asegúrate de tener configurada tu OPENAI_API_KEY en el archivo .env"
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
        if [ -z "$2" ]; then
            docker-compose logs -f
        else
            docker-compose logs -f $2
        fi
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
    "build")
        echo "🔨 Construyendo aplicación de chat..."
        docker-compose build parranda-chat
        echo "✅ Build completado"
        ;;
    "chat-logs")
        echo "📱 Logs del servicio de chat..."
        docker-compose logs -f parranda-chat
        ;;
    "n8n-logs")
        echo "⚡ Logs de N8N..."
        docker-compose logs -f n8n
        ;;
    "clean")
        echo "🧹 Limpiando contenedores y volúmenes..."
        docker-compose down -v
        docker system prune -f
        echo "⚠️  Nota: Los datos de la base de datos fueron eliminados"
        ;;
    "setup")
        echo "🚀 Configuración inicial del proyecto..."
        echo ""
        echo "1. Creando archivo .env si no existe..."
        if [ ! -f .env ]; then
            cat > .env << EOF
# Configuración requerida para OpenAI
OPENAI_API_KEY=sk-tu-api-key-aqui

# Las siguientes variables son opcionales (ya están en docker-compose.yml)
# DATABASE_URL=postgresql://parranda_user:parranda_pass123@postgres:5432/parranda_events
# N8N_WEBHOOK_URL=http://n8n:5678/webhook/escalacion-supervisor
# NODE_ENV=production
# PORT=3000
EOF
            echo "   ✅ Archivo .env creado"
            echo "   🔑 EDITA el archivo .env y agrega tu API key de OpenAI"
        else
            echo "   ✅ El archivo .env ya existe"
        fi
        echo ""
        echo "2. Obten tu API key de OpenAI:"
        echo "   🌐 https://platform.openai.com/api-keys"
        echo ""
        echo "3. Ejecuta: ./commands.sh start"
        ;;
    *)
        echo "🎵 Comandos disponibles para Parranda Vallenata Assistant (OpenAI):"
        echo ""
        echo "  🚀 setup       - Configuración inicial (crear .env)"
        echo "  ▶️  start       - Iniciar todos los servicios"
        echo "  ⏹️  stop        - Detener servicios"  
        echo "  🔄 restart     - Reiniciar servicios"
        echo "  📋 logs        - Ver logs de todos los servicios"
        echo "  📊 status      - Ver estado de contenedores"
        echo ""
        echo "  🗄️  db          - Conectar a la base de datos"
        echo "  💾 backup      - Crear backup de la base de datos"
        echo "  🔨 build       - Construir aplicación de chat"
        echo ""
        echo "  📱 chat-logs   - Ver logs del chat (parranda-chat)"
        echo "  ⚡ n8n-logs    - Ver logs de N8N"
        echo ""
        echo "  🧹 clean       - Limpiar todo (¡cuidado! elimina datos)"
        echo ""
        echo "🔑 Requisitos:"
        echo "   - API Key de OpenAI en archivo .env"
        echo "   - Docker y Docker Compose instalados"
        echo ""
        echo "📚 URLs de acceso:"
        echo "   - Chat: http://localhost:3000"
        echo "   - N8N: http://localhost:5678"
        ;;
esac
