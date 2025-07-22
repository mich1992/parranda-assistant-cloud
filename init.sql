CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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
