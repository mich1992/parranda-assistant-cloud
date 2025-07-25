# 🎵 Parranda Chat - OpenAI Integration

Aplicación de chat inteligente para **Parranda Vallenata en Santa Marta** que utiliza la API de OpenAI (GPT-4/GPT-4-mini) para proporcionar asistencia automatizada a los clientes.

## 🚀 Características

- **Chat inteligente** con GPT-4/GPT-4-mini
- **Detección automática de escalaciones** (descuentos, reservas, etc.)
- **Integración con N8N** para webhooks
- **Base de datos PostgreSQL** para persistencia
- **Interfaz web moderna** y responsiva
- **Sistema de tipos de mensajes** (usuario, asistente, escalación)

## 🏗️ Arquitectura

```
Frontend (HTML/CSS/JS) → Express Server → OpenAI API
                     ↓
                N8N Webhook → PostgreSQL Database
```

## 📁 Estructura de Archivos

```
chat-app/
├── package.json          # Dependencias y scripts
├── Dockerfile            # Imagen Docker
├── server.js             # Servidor Express principal
├── public/
│   ├── index.html        # Interfaz de chat
│   ├── style.css         # Estilos CSS
│   └── chat.js           # JavaScript del frontend
└── README.md            # Esta documentación
```

## 🔧 Configuración

### Variables de Entorno

El servidor necesita las siguientes variables:

```bash
OPENAI_API_KEY=sk-tu-api-key-aqui
DATABASE_URL=postgresql://parranda_user:parranda_pass123@postgres:5432/parranda_events
N8N_WEBHOOK_URL=http://n8n:5678/webhook/escalacion-supervisor
NODE_ENV=production
PORT=3000
```

### Dependencias

```json
{
  "openai": "^4.24.0",        // Cliente OpenAI
  "express": "^4.18.2",       // Servidor web
  "pg": "^8.11.3",            // Cliente PostgreSQL
  "axios": "^1.6.2",          // HTTP requests
  "cors": "^2.8.5",           // CORS middleware
  "dotenv": "^16.3.1"         // Variables de entorno
}
```

## 📡 API Endpoints

### `POST /api/chat`
Endpoint principal para el chat

**Request:**
```json
{
  "message": "Hola, necesito una parranda",
  "conversationHistory": [
    {"role": "user", "content": "mensaje anterior"},
    {"role": "assistant", "content": "respuesta anterior"}
  ]
}
```

**Response:**
```json
{
  "response": "¡Hola! Me da mucho gusto ayudarte...",
  "escalated": false
}
```

### `GET /api/health`
Verificación del estado del servidor

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "openai": true,
  "database": true
}
```

## 🤖 Sistema de Escalación

La aplicación detecta automáticamente cuándo el usuario:

- Solicita **descuentos** o rebajas
- Quiere **confirmar** una reserva
- Pregunta por **disponibilidad** específica
- Consulta **formas de pago**

### Palabras Clave de Escalación

```javascript
const escalationKeywords = [
    'descuento', 'rebaja', 'precio más bajo', 'más barato',
    'confirmar', 'reservar', 'reserva', 'apartar', 'confirmo',
    'disponibilidad', 'fecha libre', 'ocupado',
    'pago', 'forma de pago', 'factura', 'recibo',
    'supervisor', 'jefe', 'encargado'
];
```

### Datos de Escalación

Cuando se detecta una escalación, se envía esta información a N8N:

```json
{
  "cliente_nombre": "Cliente Web",
  "fecha": "No especificada",
  "ubicacion": "centro",
  "servicio": "Grupo Típico",
  "precio": "$450,000",
  "motivo": "solicita_descuento",
  "mensaje_original": "¿me pueden hacer descuento?",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## 💬 Sistema de Prompts

### Prompt del Sistema

El asistente utiliza un prompt detallado que incluye:

- **Información de la empresa** (ubicación, servicios, horarios)
- **Precios de servicios** (Grupo Típico, Parranda Vallenata, Grupo Completo)
- **Flujo de cotización** paso a paso
- **Tarifas y recargos** por ubicación
- **Instrucciones de escalación**

### Flujo de Conversación

1. **Saludo inicial** y consulta sobre el evento
2. **Recopilación de ubicación** específica
3. **Consulta de fecha y duración**
4. **Cálculo y presentación** de cotización
5. **Escalación automática** si es necesario

## 🎨 Interfaz de Usuario

### Características del Frontend

- **Diseño responsivo** para móviles y desktop
- **Animaciones suaves** para mensajes
- **Indicador de escritura** mientras GPT responde
- **Botones de acción rápida** para consultas comunes
- **Formato especial** para mensajes de escalación
- **Scroll automático** a nuevos mensajes

### Temas de Color

```css
:root {
    --primary-color: #2563eb;      /* Azul principal */
    --secondary-color: #f59e0b;    /* Naranja/dorado */
    --success-color: #10b981;      /* Verde éxito */
    --background: #f8fafc;         /* Fondo gris claro */
    --surface: #ffffff;            /* Superficies blancas */
}
```

## 🔄 Integración con N8N

Cuando se detecta una escalación:

1. **Extracción de datos** del contexto de conversación
2. **Clasificación del motivo** de escalación
3. **Envío a webhook** de N8N
4. **Guardado en PostgreSQL** (tabla `escalaciones`)
5. **Respuesta automática** al usuario

## 📊 Métricas y Logs

### Logs del Servidor

```bash
# Ver logs en tiempo real
docker-compose logs -f parranda-chat

# Logs con filtro
docker-compose logs parranda-chat | grep "Error"
```

### Monitoreo

- **Errores de OpenAI** (rate limits, API key inválida)
- **Fallos de conexión** a base de datos
- **Webhooks fallidos** a N8N
- **Tiempo de respuesta** de la API

## 🚀 Despliegue

### Desarrollo Local

```bash
cd chat-app
npm install
npm run dev
```

### Producción con Docker

```bash
# Desde la raíz del proyecto
./commands.sh build
./commands.sh start
```

### Variables de Entorno Requeridas

```bash
# Crear archivo .env en la raíz del proyecto
OPENAI_API_KEY=sk-tu-api-key-real
```

## 🛠️ Troubleshooting

### Problemas Comunes

**Error: Invalid OpenAI API key**
- Verificar que la API key está correcta en `.env`
- Confirmar que tiene créditos disponibles en OpenAI

**Error: Cannot connect to database**
- Verificar que PostgreSQL está corriendo
- Comprobar las credenciales de conexión

**Error: N8N webhook failed**
- Verificar que N8N está activo en puerto 5678
- Comprobar que el webhook está configurado

### Comandos de Diagnóstico

```bash
# Estado de todos los servicios
./commands.sh status

# Logs específicos del chat
./commands.sh chat-logs

# Probar conexión a la base de datos
./commands.sh db
```

## 📈 Próximas Mejoras

- [ ] **Autenticación de usuarios**
- [ ] **Dashboard administrativo**
- [ ] **Analytics de conversaciones**
- [ ] **Integración con WhatsApp**
- [ ] **Sistema de reservas online**
- [ ] **Notificaciones push**
- [ ] **Modo offline** con mensajes en cola

## 📞 Soporte

Para problemas técnicos o consultas:

- **Logs:** `./commands.sh chat-logs`
- **Database:** `./commands.sh db`
- **Health Check:** `curl http://localhost:3000/api/health` 