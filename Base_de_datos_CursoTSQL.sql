/*
===============================================================================
  CURSO: QUERYING DATA WITH MICROSOFT TRANSACT-SQL
  ARCHIVO: Base_de_datos_CursoTSQL.sql

  PROPOSITO
  ---------
  Crear una base de datos sencilla para practicar consultas T-SQL.

  CARACTERISTICAS DEL SCRIPT
  --------------------------
  - Los nombres de tablas y columnas están escritos de forma completa.
  - No se utilizan abreviaciones difíciles de interpretar.
  - No se realizan multiplicaciones para calcular totales.
  - Los totales de las ventas ya están escritos explícitamente.
  - Cada sección contiene comentarios explicativos para estudiantes.

  IMPORTANTE
  ----------
  Este script elimina la base de datos CursoTSQL si ya existe y luego vuelve
  a crearla. Por esta razón, se perderán los cambios realizados anteriormente
  dentro de esa base de datos.
===============================================================================
*/

-- La base master se utiliza para poder crear o eliminar otras bases de datos.
USE master;
GO

-- Si la base de datos CursoTSQL ya existe, primero la eliminamos.
IF DB_ID(N'CursoTSQL') IS NOT NULL
BEGIN
    ALTER DATABASE CursoTSQL SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CursoTSQL;
END;
GO

-- Creamos la base de datos que se utilizará durante el curso.
CREATE DATABASE CursoTSQL;
GO

-- Seleccionamos CursoTSQL como la base de datos de trabajo.
USE CursoTSQL;
GO

/*
===============================================================================
  CREACION DE LAS TABLAS
===============================================================================
*/

-- Esta tabla almacena las categorías a las que pertenecen los productos.
CREATE TABLE dbo.Categorias
(
    CategoriaIdentificador INT IDENTITY(1,1) NOT NULL,
    NombreCategoria NVARCHAR(100) NOT NULL,
    DescripcionCategoria NVARCHAR(300) NULL,

    CONSTRAINT ClavePrimaria_Categorias
        PRIMARY KEY (CategoriaIdentificador),

    CONSTRAINT NombreCategoria_Unico
        UNIQUE (NombreCategoria)
);
GO

-- Esta tabla almacena la información de los clientes de la empresa.
CREATE TABLE dbo.Clientes
(
    ClienteIdentificador INT IDENTITY(1,1) NOT NULL,
    NumeroDocumento NVARCHAR(20) NOT NULL,
    NombreCompleto NVARCHAR(150) NOT NULL,
    CorreoElectronico NVARCHAR(150) NULL,
    NumeroTelefono NVARCHAR(30) NULL,
    Ciudad NVARCHAR(100) NOT NULL,
    Region NVARCHAR(100) NOT NULL,
    FechaRegistro DATE NOT NULL,
    ClienteActivo BIT NOT NULL,

    CONSTRAINT ClavePrimaria_Clientes
        PRIMARY KEY (ClienteIdentificador),

    CONSTRAINT NumeroDocumentoCliente_Unico
        UNIQUE (NumeroDocumento)
);
GO

-- Esta tabla almacena la información de los empleados que registran pedidos.
CREATE TABLE dbo.Empleados
(
    EmpleadoIdentificador INT IDENTITY(1,1) NOT NULL,
    NumeroDocumento NVARCHAR(20) NOT NULL,
    NombreCompleto NVARCHAR(150) NOT NULL,
    Cargo NVARCHAR(100) NOT NULL,
    FechaContratacion DATE NOT NULL,
    SalarioMensual DECIMAL(12,2) NOT NULL,
    EmpleadoActivo BIT NOT NULL,

    CONSTRAINT ClavePrimaria_Empleados
        PRIMARY KEY (EmpleadoIdentificador),

    CONSTRAINT NumeroDocumentoEmpleado_Unico
        UNIQUE (NumeroDocumento),

    CONSTRAINT SalarioMensual_ValorValido
        CHECK (SalarioMensual > 0)
);
GO

-- Esta tabla almacena los productos disponibles para la venta.
CREATE TABLE dbo.Productos
(
    ProductoIdentificador INT IDENTITY(1,1) NOT NULL,
    CategoriaIdentificador INT NOT NULL,
    NombreProducto NVARCHAR(150) NOT NULL,
    DescripcionProducto NVARCHAR(300) NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    CantidadDisponible INT NOT NULL,
    ProductoActivo BIT NOT NULL,

    CONSTRAINT ClavePrimaria_Productos
        PRIMARY KEY (ProductoIdentificador),

    CONSTRAINT PrecioUnitario_ValorValido
        CHECK (PrecioUnitario > 0),

    CONSTRAINT CantidadDisponible_ValorValido
        CHECK (CantidadDisponible >= 0),

    CONSTRAINT ClaveForanea_Productos_Categorias
        FOREIGN KEY (CategoriaIdentificador)
        REFERENCES dbo.Categorias (CategoriaIdentificador)
);
GO

-- Esta tabla almacena la información general de cada pedido.
CREATE TABLE dbo.Pedidos
(
    PedidoIdentificador INT IDENTITY(1,1) NOT NULL,
    ClienteIdentificador INT NOT NULL,
    EmpleadoIdentificador INT NOT NULL,
    FechaPedido DATE NOT NULL,
    EstadoPedido NVARCHAR(30) NOT NULL,
    DireccionEntrega NVARCHAR(200) NOT NULL,
    CiudadEntrega NVARCHAR(100) NOT NULL,
    TotalPedido DECIMAL(12,2) NOT NULL,

    CONSTRAINT ClavePrimaria_Pedidos
        PRIMARY KEY (PedidoIdentificador),

    CONSTRAINT EstadoPedido_ValorValido
        CHECK (EstadoPedido IN
            (N'Pendiente', N'En preparación', N'Enviado', N'Entregado', N'Cancelado')),

    CONSTRAINT TotalPedido_ValorValido
        CHECK (TotalPedido >= 0),

    CONSTRAINT ClaveForanea_Pedidos_Clientes
        FOREIGN KEY (ClienteIdentificador)
        REFERENCES dbo.Clientes (ClienteIdentificador),

    CONSTRAINT ClaveForanea_Pedidos_Empleados
        FOREIGN KEY (EmpleadoIdentificador)
        REFERENCES dbo.Empleados (EmpleadoIdentificador)
);
GO

-- Esta tabla almacena los productos que forman parte de cada pedido.
-- PrecioUnitarioVenta conserva el precio que tenía el producto al venderse.
-- TotalDetalle está escrito directamente; no se calcula con una multiplicación.
CREATE TABLE dbo.DetallesPedidos
(
    DetallePedidoIdentificador INT IDENTITY(1,1) NOT NULL,
    PedidoIdentificador INT NOT NULL,
    ProductoIdentificador INT NOT NULL,
    CantidadComprada INT NOT NULL,
    PrecioUnitarioVenta DECIMAL(12,2) NOT NULL,
    TotalDetalle DECIMAL(12,2) NOT NULL,

    CONSTRAINT ClavePrimaria_DetallesPedidos
        PRIMARY KEY (DetallePedidoIdentificador),

    CONSTRAINT CantidadComprada_ValorValido
        CHECK (CantidadComprada > 0),

    CONSTRAINT PrecioUnitarioVenta_ValorValido
        CHECK (PrecioUnitarioVenta > 0),

    CONSTRAINT TotalDetalle_ValorValido
        CHECK (TotalDetalle > 0),

    CONSTRAINT ClaveForanea_DetallesPedidos_Pedidos
        FOREIGN KEY (PedidoIdentificador)
        REFERENCES dbo.Pedidos (PedidoIdentificador),

    CONSTRAINT ClaveForanea_DetallesPedidos_Productos
        FOREIGN KEY (ProductoIdentificador)
        REFERENCES dbo.Productos (ProductoIdentificador)
);
GO

/*
===============================================================================
  INSERCION DE DATOS DE EJEMPLO
===============================================================================
*/

-- Insertamos las categorías de productos.
INSERT INTO dbo.Categorias
(
    NombreCategoria,
    DescripcionCategoria
)
VALUES
    (N'Computadores', N'Computadores portátiles y de escritorio.'),
    (N'Periféricos', N'Dispositivos utilizados junto a un computador.'),
    (N'Almacenamiento', N'Dispositivos destinados a guardar información.'),
    (N'Redes', N'Equipos para conexión y comunicación de datos.'),
    (N'Accesorios', N'Artículos complementarios para equipos tecnológicos.');
GO

-- Insertamos los clientes.
-- Los documentos utilizados son ficticios y se incluyen solo con fines educativos.
INSERT INTO dbo.Clientes
(
    NumeroDocumento,
    NombreCompleto,
    CorreoElectronico,
    NumeroTelefono,
    Ciudad,
    Region,
    FechaRegistro,
    ClienteActivo
)
VALUES
    (N'DOCUMENTO-001', N'Ana Martínez Soto', N'ana.martinez@example.com', N'+56 9 5000 0001', N'Iquique', N'Tarapacá', '2025-01-15', 1),
    (N'DOCUMENTO-002', N'Benjamín Rojas Pérez', N'benjamin.rojas@example.com', N'+56 9 5000 0002', N'Alto Hospicio', N'Tarapacá', '2025-02-08', 1),
    (N'DOCUMENTO-003', N'Carolina Fuentes Díaz', N'carolina.fuentes@example.com', N'+56 9 5000 0003', N'Antofagasta', N'Antofagasta', '2025-03-12', 1),
    (N'DOCUMENTO-004', N'Diego González Silva', N'diego.gonzalez@example.com', N'+56 9 5000 0004', N'Calama', N'Antofagasta', '2025-04-20', 1),
    (N'DOCUMENTO-005', N'Elena Contreras López', N'elena.contreras@example.com', NULL, N'Arica', N'Arica y Parinacota', '2025-05-03', 1),
    (N'DOCUMENTO-006', N'Felipe Morales Castro', N'felipe.morales@example.com', N'+56 9 5000 0006', N'La Serena', N'Coquimbo', '2025-06-17', 0),
    (N'DOCUMENTO-007', N'Gabriela Torres Muñoz', N'gabriela.torres@example.com', N'+56 9 5000 0007', N'Santiago', N'Metropolitana de Santiago', '2025-07-09', 1),
    (N'DOCUMENTO-008', N'Héctor Ramírez Vega', NULL, N'+56 9 5000 0008', N'Valparaíso', N'Valparaíso', '2025-08-25', 1),
    (N'DOCUMENTO-009', N'Isidora Navarro Reyes', N'isidora.navarro@example.com', N'+56 9 5000 0009', N'Concepción', N'Biobío', '2025-09-14', 1),
    (N'DOCUMENTO-010', N'Javier Sepúlveda Ortiz', N'javier.sepulveda@example.com', N'+56 9 5000 0010', N'Puerto Montt', N'Los Lagos', '2025-10-02', 0);
GO

-- Insertamos los empleados.
INSERT INTO dbo.Empleados
(
    NumeroDocumento,
    NombreCompleto,
    Cargo,
    FechaContratacion,
    SalarioMensual,
    EmpleadoActivo
)
VALUES
    (N'EMPLEADO-001', N'Paula Herrera Rojas', N'Vendedora', '2022-03-01', 850000.00, 1),
    (N'EMPLEADO-002', N'Ricardo Salinas Soto', N'Vendedor', '2023-07-10', 830000.00, 1),
    (N'EMPLEADO-003', N'Sofía Castillo Pérez', N'Supervisora de ventas', '2021-11-15', 1150000.00, 1),
    (N'EMPLEADO-004', N'Tomás Aguilera Díaz', N'Vendedor', '2024-02-05', 790000.00, 0);
GO

-- Insertamos los productos.
INSERT INTO dbo.Productos
(
    CategoriaIdentificador,
    NombreProducto,
    DescripcionProducto,
    PrecioUnitario,
    CantidadDisponible,
    ProductoActivo
)
VALUES
    (1, N'Computador portátil de oficina', N'Computador portátil con 16 GB de memoria.', 649990.00, 12, 1),
    (1, N'Computador portátil profesional', N'Computador portátil con 32 GB de memoria.', 1099990.00, 6, 1),
    (1, N'Computador de escritorio compacto', N'Equipo compacto para tareas administrativas.', 529990.00, 8, 1),
    (2, N'Teclado mecánico', N'Teclado mecánico con conexión por cable.', 59990.00, 25, 1),
    (2, N'Ratón inalámbrico', N'Ratón inalámbrico de uso diario.', 24990.00, 40, 1),
    (2, N'Monitor de 24 pulgadas', N'Monitor con resolución Full HD.', 139990.00, 15, 1),
    (2, N'Cámara web', N'Cámara web con resolución Full HD.', 44990.00, 0, 0),
    (3, N'Unidad de estado sólido de 500 GB', N'Unidad interna de almacenamiento.', 49990.00, 30, 1),
    (3, N'Disco duro externo de 2 TB', N'Disco externo con conexión USB.', 74990.00, 18, 1),
    (3, N'Memoria USB de 64 GB', N'Memoria portátil con conexión USB.', 9990.00, 50, 1),
    (4, N'Enrutador inalámbrico', N'Enrutador para redes domésticas y pequeñas oficinas.', 89990.00, 10, 1),
    (4, N'Conmutador de red de 8 puertos', N'Conmutador para conexión de equipos mediante cable.', 39990.00, 14, 1),
    (5, N'Mochila para computador portátil', N'Mochila acolchada para equipos de hasta 15 pulgadas.', 34990.00, 20, 1),
    (5, N'Soporte ajustable para computador portátil', N'Soporte metálico de altura ajustable.', 29990.00, 22, 1),
    (5, N'Adaptador de conexión múltiple', N'Adaptador con conexiones USB, HDMI y red.', 54990.00, 16, 1);
GO

-- Insertamos los pedidos.
-- TotalPedido ya contiene el total final; en este script no se calcula.
INSERT INTO dbo.Pedidos
(
    ClienteIdentificador,
    EmpleadoIdentificador,
    FechaPedido,
    EstadoPedido,
    DireccionEntrega,
    CiudadEntrega,
    TotalPedido
)
VALUES
    (1, 1, '2026-01-12', N'Entregado', N'Avenida Costanera 1200', N'Iquique', 709980.00),
    (2, 2, '2026-01-18', N'Entregado', N'Avenida Los Álamos 450', N'Alto Hospicio', 79960.00),
    (3, 1, '2026-02-03', N'Enviado', N'Calle Prat 780', N'Antofagasta', 139990.00),
    (4, 3, '2026-02-15', N'Entregado', N'Avenida Granaderos 3400', N'Calama', 1099990.00),
    (5, 2, '2026-03-02', N'Cancelado', N'Calle Colón 625', N'Arica', 74990.00),
    (7, 1, '2026-03-19', N'En preparación', N'Avenida Providencia 1500', N'Santiago', 144970.00),
    (8, 3, '2026-04-08', N'Pendiente', N'Calle Independencia 910', N'Valparaíso', 529990.00),
    (9, 2, '2026-04-21', N'Entregado', N'Avenida Los Carrera 1700', N'Concepción', 99900.00),
    (1, 3, '2026-05-05', N'Enviado', N'Avenida Costanera 1200', N'Iquique', 229970.00),
    (3, 1, '2026-05-22', N'Pendiente', N'Calle Prat 780', N'Antofagasta', 89990.00);
GO

-- Insertamos los productos incluidos en cada pedido.
-- CantidadComprada, PrecioUnitarioVenta y TotalDetalle están escritos de forma
-- explícita para que esta carga inicial no requiera operaciones matemáticas.
INSERT INTO dbo.DetallesPedidos
(
    PedidoIdentificador,
    ProductoIdentificador,
    CantidadComprada,
    PrecioUnitarioVenta,
    TotalDetalle
)
VALUES
    (1, 1, 1, 649990.00, 649990.00),
    (1, 4, 1, 59990.00, 59990.00),
    (2, 5, 2, 24990.00, 49980.00),
    (2, 14, 1, 29990.00, 29990.00),
    (3, 6, 1, 139990.00, 139990.00),
    (4, 2, 1, 1099990.00, 1099990.00),
    (5, 9, 1, 74990.00, 74990.00),
    (6, 11, 1, 89990.00, 89990.00),
    (6, 15, 1, 54990.00, 54990.00),
    (7, 3, 1, 529990.00, 529990.00),
    (8, 10, 10, 9990.00, 99900.00),
    (9, 6, 1, 139990.00, 139990.00),
    (9, 4, 1, 59990.00, 59990.00),
    (9, 14, 1, 29990.00, 29990.00),
    (10, 11, 1, 89990.00, 89990.00);
GO

/*
===============================================================================
  CONSULTAS SENCILLAS PARA COMPROBAR EL RESULTADO
===============================================================================
*/

-- Muestra el nombre de la base de datos que está seleccionada actualmente.
SELECT DB_NAME() AS NombreBaseDatosActual;
GO

-- Muestra todas las categorías.
SELECT
    CategoriaIdentificador,
    NombreCategoria,
    DescripcionCategoria
FROM dbo.Categorias;
GO

-- Muestra todos los clientes.
SELECT
    ClienteIdentificador,
    NumeroDocumento,
    NombreCompleto,
    CorreoElectronico,
    NumeroTelefono,
    Ciudad,
    Region,
    FechaRegistro,
    ClienteActivo
FROM dbo.Clientes;
GO

-- Muestra todos los productos, ordenados desde el precio más bajo al más alto.
SELECT
    ProductoIdentificador,
    CategoriaIdentificador,
    NombreProducto,
    DescripcionProducto,
    PrecioUnitario,
    CantidadDisponible,
    ProductoActivo
FROM dbo.Productos
ORDER BY PrecioUnitario ASC;
GO

-- Muestra solamente los productos que se encuentran activos.
SELECT
    NombreProducto,
    PrecioUnitario,
    CantidadDisponible
FROM dbo.Productos
WHERE ProductoActivo = 1
ORDER BY NombreProducto ASC;
GO

-- Muestra todos los pedidos.
SELECT
    PedidoIdentificador,
    ClienteIdentificador,
    EmpleadoIdentificador,
    FechaPedido,
    EstadoPedido,
    DireccionEntrega,
    CiudadEntrega,
    TotalPedido
FROM dbo.Pedidos
ORDER BY FechaPedido ASC;
GO

-- Mensaje final que confirma que el script llegó hasta su última instrucción.
PRINT N'La base de datos CursoTSQL fue creada correctamente.';
GO

