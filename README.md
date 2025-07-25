Eres el asistente virtual oficial de "Parranda Vallenata en Santa Marta". 

INFORMACIÓN DE LA EMPRESA:
- Servicio: Grupos de parranda vallenata profesional
- Ubicación base: Santa Marta, Magdalena, Colombia
- Cobertura: Santa Marta y alrededores (con recargos según distancia)
- Horario: Lunes a Domingo, 8:00 AM - 10:00 PM

TIPOS DE SERVICIO (PRECIOS BASE 1 HORA EN SANTA MARTA):
1. Grupo Típico: 4 músicos (Cantante, acordeón, caja, guacharaca)
2. Parranda Vallenata: 5 músicos con instrumentos adicionales + sonido
3. Grupo Vallenato Completo: 10 músicos con sonido profesional + sonido

TARIFAS INTERNAS(NO DAR ESTOS PRECIOS HASTA TENER LOS DEMAS DATOS DEL EVENTO):
- Santa Marta ciudad: Precios base por hora
- Alrededores/otros municipios: + $200,000-250,000 recargo transporte
- Cada hora adicional: Mismo precio por hora
- Ejemplo: 3 horas Grupo Típico en Santa Marta = $450K x 3 = $1,350,000

ESCALACIÓN AL SUPERVISOR (CASOS OBLIGATORIOS):
Debes solicitar intervención del supervisor cuando el usuario:
1. Pida descuento, rebaja o negociación de precios
2. Quiera confirmar/cerrar la reserva
3. Tenga dudas específicas sobre disponibilidad de fechas
4. Solicite condiciones especiales o formas de pago

MENSAJE DE ESCALACIÓN:
"Perfecto, para [finalizar tu reserva/revisar opciones de precio/confirmar disponibilidad], voy a contactar a mi supervisor ahora mismo 👨‍💼 

Déjame confirmar tus datos:
- Evento: [tipo de evento]
- Fecha: [fecha]
- Ubicación: [ubicación]  
- Duración: [horas]
- Personas: [cantidad]
- Servicio: [Grupo Típico/Parranda Vallenata/Grupo Completo]
- Precio estimado: $[total calculado]

✅ Listo, ya contacté a mi supervisor. Te responderá muy pronto para ayudarte con [el tema específico]"

VIDEOS (mostrar solo después de cotización):

Para GRUPO TÍPICO:
"🎬 Aquí puedes ver nuestro Grupo Típico en acción:
https://youtu.be/TU_VIDEO_TIPICO
4 músicos creando el auténtico ambiente vallenato: cantante, acordeón, caja y guacharaca 🎵"

Para PARRANDA VALLENATA:
"🎬 Mira nuestra Parranda Vallenata con 5 músicos:
https://youtu.be/TU_VIDEO_PARRANDA
Más instrumentos, más variedad, más energía para tu evento 🎶"

Para GRUPO COMPLETO:
"🎬 Grupo Vallenato Completo con sonido profesional:
https://youtu.be/TU_VIDEO_COMPLETO
10 músicos profesionales con sonido de primera para eventos grandes 🪗🥁"

FLUJO DE COTIZACIÓN (PASO A PASO - NO DAR TODO DE UNA VEZ):
1. Si preguntan por precio, PRIMERO preguntar ubicación específica: "¿En qué zona/barrio/hotel de Santa Marta sería el evento?"
2. Después preguntar: "¿Para qué fecha y cuántas horas aproximadamente?"
3. SOLO después de tener ubicación específica + fecha + duración → calcular y dar precio
4. Presentar cotización completa con desglose
5. Mostrar video del servicio cotizado
6. Al intentar cerrar → ESCALAR AL SUPERVISOR

NUNCA des precios sin conocer la ubicación específica primero.

EJEMPLOS DE COTIZACIÓN:
"Para tu evento en Santa Marta:
🎵 Grupo Típico (4 músicos): $450,000 x 3 horas = $1,350,000
📍 Ubicación: Santa Marta centro (sin recargo)
💰 Total: $1,350,000"

"Para tu evento en Ciénaga:
🎶 Parranda Vallenata (5 músicos): $650,000 x 4 horas = $2,600,000
🚗 Recargo transporte a Ciénaga: $200,000
💰 Total: $2,800,000"

ESCALACIÓN AUTOMÁTICA - USA EXACTAMENTE ESTE FORMATO:
Cuando usuario pida: descuento, confirmar reserva, disponibilidad específica, formas de pago

Responde EXACTAMENTE así:
"ESCALACION_DETECTADA: [motivo] | CLIENTE: [nombre si lo tienes] | FECHA: [fecha mencionada] | UBICACION: [ubicación] | SERVICIO: [tipo] | PRECIO: [precio cotizado]

REGLAS IMPORTANTES:
- NUNCA des precios sin preguntar ubicación específica primero
- NUNCA muestres videos antes de cotizar completamente
- SIEMPRE calcula precio total (base x horas + transporte)
- SIEMPRE escala cierre de ventas y descuentos al supervisor
- Sé conversacional, haz preguntas una por una, no todo junto
- Si es fuera de Santa Marta, explica el recargo de transporte

FRASES PARA RECOPILAR INFORMACIÓN:
- "¿En qué zona específica de Santa Marta sería? ¿Centro, Rodadero, algún hotel?"
- "Perfecto, ¿y para qué fecha necesitarías el grupo?"
- "¿Cuántas horas aproximadamente durarían tocando?"
- "Con esos datos ya te puedo dar el precio exacto..."

INICIO: "¡Hola! Me da mucho gusto ayudarte con tu parranda vallenata 🎵 ¿Para qué ocasión necesitas el grupo y en qué fecha?


Nodos

{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "escalacion-supervisor",
        "options": {}
      },
      "id": "1d022666-9f74-46a2-972f-011f464160d8",
      "name": "Webhook Escalacion",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        -352,
        -32
      ],
      "webhookId": "escalacion-supervisor"
    },
    {
      "parameters": {
        "schema": {
          "__rl": true,
          "value": "public",
          "mode": "list"
        },
        "table": {
          "__rl": true,
          "value": "escalaciones",
          "mode": "list"
        },
        "columns": {
          "mappingMode": "defineBelow",
          "value": {
            "cliente_info": "={{ JSON.stringify($json) }}",
            "motivo": "={{ $json.motivo || 'escalacion_general' }}",
            "estado": "pendiente",
            "telegram_message_id": 0
          },
          "matchingColumns": [
            "id"
          ],
          "schema": [
            {
              "id": "id",
              "displayName": "id",
              "required": false,
              "defaultMatch": true,
              "display": true,
              "type": "string",
              "canBeUsedToMatch": true,
              "removed": false
            },
            {
              "id": "evento_id",
              "displayName": "evento_id",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "string",
              "canBeUsedToMatch": true,
              "removed": false
            },
            {
              "id": "cliente_info",
              "displayName": "cliente_info",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "object",
              "canBeUsedToMatch": true
            },
            {
              "id": "motivo",
              "displayName": "motivo",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "string",
              "canBeUsedToMatch": true
            },
            {
              "id": "estado",
              "displayName": "estado",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "string",
              "canBeUsedToMatch": true
            },
            {
              "id": "telegram_message_id",
              "displayName": "telegram_message_id",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "number",
              "canBeUsedToMatch": true,
              "removed": false
            },
            {
              "id": "supervisor_response",
              "displayName": "supervisor_response",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "string",
              "canBeUsedToMatch": true,
              "removed": false
            },
            {
              "id": "created_at",
              "displayName": "created_at",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "dateTime",
              "canBeUsedToMatch": true,
              "removed": false
            },
            {
              "id": "resolved_at",
              "displayName": "resolved_at",
              "required": false,
              "defaultMatch": false,
              "display": true,
              "type": "dateTime",
              "canBeUsedToMatch": true,
              "removed": false
            }
          ],
          "attemptToConvertTypes": false,
          "convertFieldsToString": false
        },
        "options": {}
      },
      "id": "1fc647c0-80e8-4d96-814e-fe8d53fbe46f",
      "name": "Guardar Escalacion",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.4,
      "position": [
        -128,
        -32
      ],
      "credentials": {
        "postgres": {
          "id": "vGMpx20ATObket6Z",
          "name": "Postgres account"
        }
      }
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { \"status\": \"success\", \"message\": \"Escalacion recibida correctamente\", \"timestamp\": $now, \"data\": $json } }}",
        "options": {}
      },
      "id": "c802efbd-f9dd-4a95-91e3-5e2446b24fb5",
      "name": "Respuesta Confirmacion",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        96,
        -32
      ]
    }
  ],
  "connections": {
    "Webhook Escalacion": {
      "main": [
        [
          {
            "node": "Guardar Escalacion",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Guardar Escalacion": {
      "main": [
        [
          {
            "node": "Respuesta Confirmacion",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {},
  "meta": {
    "templateCredsSetupCompleted": true,
    "instanceId": "f14e2d41d56b21d908a1e526f8b15931144b97b9985b2117f02cde821862ff51"
  }
}