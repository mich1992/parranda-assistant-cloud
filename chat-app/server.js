const express = require('express');
const { OpenAI } = require('openai');
const { Pool } = require('pg');
const axios = require('axios');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Configurar middlewares
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Configurar OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Configurar PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Sistema de mensajes para OpenAI
const SYSTEM_PROMPT = `
Eres el asistente virtual oficial de "Parranda Vallenata en Santa Marta".

INFORMACIÓN DE LA EMPRESA:
- Servicio: Grupos de parranda vallenata profesional
- Ubicación base: Santa Marta, Magdalena, Colombia
- Cobertura: Santa Marta y alrededores (con recargos según distancia)
- Horario: Lunes a Domingo, 8:00 AM - 10:00 PM

TIPOS DE SERVICIO (PRECIOS BASE 1 HORA EN SANTA MARTA):
1. Grupo Típico: 4 músicos (Cantante, acordeón, caja, guacharaca) - $450,000/hora
2. Parranda Vallenata: 5 músicos con instrumentos adicionales + sonido - $650,000/hora
3. Grupo Vallenato Completo: 10 músicos con sonido profesional - $1,500,000/hora

TARIFAS:
- Santa Marta ciudad: Precios base por hora
- Alrededores/otros municipios: + $200,000-250,000 recargo transporte
- Cada hora adicional: Mismo precio por hora

FLUJO DE COTIZACIÓN (PASO A PASO):
1. Si preguntan por precio, PRIMERO preguntar ubicación específica
2. Después preguntar fecha y duración
3. SOLO después calcular y dar precio completo
4. Al intentar cerrar venta → INDICAR que contactarás supervisor

NUNCA des precios sin conocer la ubicación específica primero.

RESPONDE SIEMPRE en español, de manera amigable y profesional.
`;

// Función para detectar escalaciones
function needsEscalation(message) {
  const escalationKeywords = [
    'descuento', 'rebaja', 'precio más bajo', 'más barato',
    'confirmar', 'reservar', 'reserva', 'apartar', 'confirmo',
    'disponibilidad', 'fecha libre', 'ocupado',
    'pago', 'forma de pago', 'factura', 'recibo',
    'supervisor', 'jefe', 'encargado', 'hablar con alguien'
  ];
  
  return escalationKeywords.some(keyword => 
    message.toLowerCase().includes(keyword)
  );
}

// Función para extraer información del contexto
function extractInfo(messages) {
  const fullText = messages.map(m => m.content).join(' ').toLowerCase();
  
  const extractPrice = (text) => {
    const priceMatch = text.match(/\$[\d,]+/g);
    return priceMatch ? priceMatch[priceMatch.length - 1] : 'No calculado';
  };
  
  const extractLocation = (text) => {
    const locations = ['centro', 'rodadero', 'santa marta', 'ciénaga', 'barranquilla'];
    const found = locations.find(loc => text.includes(loc));
    return found || 'No especificada';
  };
  
  const extractService = (text) => {
    if (text.includes('grupo típico')) return 'Grupo Típico';
    if (text.includes('parranda vallenata')) return 'Parranda Vallenata';
    if (text.includes('grupo completo')) return 'Grupo Completo';
    return 'No especificado';
  };
  
  return {
    price: extractPrice(fullText),
    location: extractLocation(fullText),
    service: extractService(fullText)
  };
}

// Función para enviar escalación a N8N
async function sendEscalation(escalationData) {
  try {
    const response = await axios.post(process.env.N8N_WEBHOOK_URL, escalationData, {
      timeout: 5000
    });
    return response.status === 200;
  } catch (error) {
    console.error('Error enviando escalación:', error.message);
    return false;
  }
}

// Endpoint principal de chat
app.post('/api/chat', async (req, res) => {
  try {
    const { message, conversationHistory = [] } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'Mensaje requerido' });
    }
    
    // Preparar mensajes para OpenAI
    const messages = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...conversationHistory,
      { role: 'user', content: message }
    ];
    
    // Detectar escalación
    const needsEscalationFlag = needsEscalation(message);
    
    if (needsEscalationFlag) {
      // Extraer información del contexto
      const info = extractInfo(conversationHistory);
      
      const escalationData = {
        cliente_nombre: 'Cliente Web',
        fecha: 'No especificada',
        ubicacion: info.location,
        servicio: info.service,
        precio: info.price,
        motivo: needsEscalation(message) ? 'escalacion_general' : 'consulta',
        mensaje_original: message,
        timestamp: new Date().toISOString()
      };
      
      // Enviar escalación a N8N
      const escalationSent = await sendEscalation(escalationData);
      
      // Respuesta de escalación
      const escalationResponse = `
Perfecto, para ayudarte mejor con ${message.toLowerCase().includes('confirmar') || message.toLowerCase().includes('reservar') ? 'finalizar tu reserva' : 'tu consulta'}, voy a contactar a mi supervisor ahora mismo 👨‍💼

📋 Resumen de tu consulta:
- Ubicación: ${info.location}
- Servicio: ${info.service}
- Precio estimado: ${info.price}
- Motivo: ${escalationData.motivo}

${escalationSent ? '✅ Listo, ya contacté a mi supervisor. Te responderá muy pronto para ayudarte.' : '⚠️ Hubo un problema contactando al supervisor, pero tu consulta fue registrada.'}
      `.trim();
      
      return res.json({ 
        response: escalationResponse,
        escalated: true 
      });
    }
    
    // Chat normal con OpenAI
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini', // Usar gpt-4 si prefieres calidad superior
      messages: messages,
      max_tokens: 500,
      temperature: 0.7,
    });
    
    const aiResponse = completion.choices[0].message.content;
    
    res.json({ 
      response: aiResponse,
      escalated: false 
    });
    
  } catch (error) {
    console.error('Error en chat:', error);
    res.status(500).json({ 
      error: 'Error procesando mensaje',
      details: error.message 
    });
  }
});

// Endpoint de salud
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    openai: !!process.env.OPENAI_API_KEY,
    database: !!process.env.DATABASE_URL 
  });
});

// Servir la aplicación web
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Iniciar servidor
app.listen(port, '0.0.0.0', () => {
  console.log(`🎵 Servidor de Parranda Chat ejecutándose en puerto ${port}`);
  console.log(`🌐 Acceso web: http://localhost:${port}`);
  console.log(`🤖 OpenAI configurado: ${!!process.env.OPENAI_API_KEY}`);
  console.log(`🗄️ Base de datos configurada: ${!!process.env.DATABASE_URL}`);
}); 