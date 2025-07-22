-- Base de datos optimizada para Parranda Vallenata
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de eventos/reservas
CREATE TABLE IF NOT EXISTS eventos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fecha_evento TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    cliente_nombre VARCHAR(255) NOT NULL,
    cliente_telefono VARCHAR(20),
    cliente_email VARCHAR(255),
    ubicacion VARCHAR(500) NOT NULL,
    direccion_especifica TEXT,
    tipo_servicio VARCHAR(50) NOT NULL CHECK (tipo_servicio IN ('grupo_tipico', 'parranda_vallenata', 'grupo_completo')),
    duracion_horas INTEGER NOT NULL DEFAULT 1,
    precio_base DECIMAL(10,2) NOT NULL,
    recargo_transporte DECIMAL(10,2) DEFAULT 0,
    precio_total DECIMAL(10,2) NOT NULL,
    numero_personas INTEGER DEFAULT 1,
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'confirmado', 'cancelado', 'completado')),
    notas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de servicios con precios actuales
CREATE TABLE IF NOT EXISTS servicios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio_por_hora DECIMAL(10,2) NOT NULL,
    numero_musicos INTEGER NOT NULL,
    instrumentos TEXT[],
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de escalaciones al supervisor
CREATE TABLE IF NOT EXISTS escalaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    evento_id UUID REFERENCES eventos(id),
    cliente_info JSONB,
    motivo VARCHAR(255),
    estado VARCHAR(50) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'en_proceso', 'resuelto')),
    telegram_message_id BIGINT,
    supervisor_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Tabla de configuración del bot
CREATE TABLE IF NOT EXISTS bot_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT,
    descripcion TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar servicios actualizados
INSERT INTO servicios (codigo, nombre, descripcion, precio_por_hora, numero_musicos, instrumentos) VALUES 
('grupo_tipico', 'Grupo Típico', '4 músicos profesionales con instrumentos tradicionales', 450000, 4, ARRAY['Cantante', 'Acordeón', 'Caja vallenata', 'Guacharaca']),
('parranda_vallenata', 'Parranda Vallenata', '5 músicos con instrumentos adicionales para mayor variedad', 650000, 5, ARRAY['Cantante', 'Acordeón', 'Caja vallenata', 'Guacharaca', 'Bajo/Guitarra']),
('grupo_completo', 'Grupo Vallenato Completo', '10 músicos profesionales con sonido completo', 1500000, 10, ARRAY['Grupo completo', 'Sonido profesional', 'Iluminación básica', 'Repertorio amplio']);

-- Configuración del bot
INSERT INTO bot_config (clave, valor, descripcion) VALUES 
('empresa_nombre', 'Parranda Vallenata en Santa Marta', 'Nombre de la empresa'),
('empresa_telefono', '+57-300-XXXXXXX', 'Teléfono principal'),
('empresa_email', 'info@parrandavallenataensantamarta.com', 'Email de contacto'),
('zona_cobertura', 'Santa Marta, Magdalena y alrededores', 'Zona de cobertura del servicio'),
('horario_atencion', 'Lunes a Domingo: 8:00 AM - 10:00 PM', 'Horario de atención'),
('recargo_transporte_min', '200000', 'Recargo mínimo de transporte'),
('recargo_transporte_max', '250000', 'Recargo máximo de transporte'),
('mensaje_bienvenida', '¡Hola! Me da mucho gusto ayudarte con tu parranda vallenata 🎵 ¿Para qué ocasión necesitas el grupo y en qué fecha?', 'Mensaje de bienvenida del bot');

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_eventos_updated_at BEFORE UPDATE ON eventos 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bot_config_updated_at BEFORE UPDATE ON bot_config 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Índices para mejor performance
CREATE INDEX idx_eventos_fecha ON eventos(fecha_evento);
CREATE INDEX idx_eventos_estado ON eventos(estado);
CREATE INDEX idx_eventos_tipo_servicio ON eventos(tipo_servicio);
CREATE INDEX idx_servicios_codigo ON servicios(codigo);
CREATE INDEX idx_servicios_activo ON servicios(activo);
CREATE INDEX idx_escalaciones_estado ON escalaciones(estado);

-- Vista para reportes rápidos
CREATE VIEW vista_eventos_resumen AS
SELECT 
    e.id,
    e.fecha_evento,
    e.cliente_nombre,
    e.ubicacion,
    s.nombre as servicio,
    e.duracion_horas,
    e.precio_total,
    e.estado,
    e.created_at
FROM eventos e
JOIN servicios s ON s.codigo = e.tipo_servicio;CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS eventos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fecha_evento TIMESTAMP NOT NULL,
    cliente_nombre VARCHAR(255) NOT NULL,
    cliente_telefono VARCHAR(20),
    ubicacion VARCHAR(500) NOT NULL,
    precio DECIMAL(10,2),
    estado VARCHAR(20) DEFAULT 'pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS servicios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio_base DECIMAL(10,2) NOT NULL,
    duracion_horas INTEGER DEFAULT 4,
    activo BOOLEAN DEFAULT true
);

INSERT INTO servicios (nombre, descripcion, precio_base, duracion_horas) VALUES 
('Parranda Tipica', 'Grupo de 4 musicos', 450000', 1),
('Parranda Vallenata', 'Grupo de 5 músicos', 650000, 1),
('Grupo completo', 'Grupo completo con sonido', 150000, 1);
