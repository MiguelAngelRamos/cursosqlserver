-- =====================================================================================
-- BANCONEXO - Base de datos didactica para procedimientos almacenados
-- Curso: Querying Data with Microsoft Transact-SQL (DP-080)
-- Modulos cubiertos: 15 (procedimientos almacenados), 16 (programacion T-SQL),
-- 17 (manejo de errores), 18 (transacciones)
--
-- Motor: SQL Server 2016 SP1 o superior (usa CREATE OR ALTER y THROW)
--
-- Proposito: sandbox de ESCRITURA. A diferencia de BancoNova (dataset de consulta con
-- datos literales), esta base esta pensada para que los alumnos la modifiquen y la
-- rompan. El procedimiento usp_ReiniciarDemo devuelve todo al estado inicial.
--
-- INVARIANTE DEL BANCO (hilo conductor de la clase):
-- SELECT SUM(Saldo) FROM dbo.Cuenta  -->  10.045.000,00
-- Ninguna transferencia legitima puede alterar ese total. Las versiones defectuosas
-- de los procedimientos lo violan; la version final lo preserva siempre.
-- =====================================================================================


-- =====================================================================================
-- PASO 0 - CREACION DE LA BASE
-- =====================================================================================
USE master;
GO

IF DB_ID('BancoNexo') IS NOT NULL
BEGIN
    ALTER DATABASE BancoNexo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BancoNexo;
END
GO

CREATE DATABASE BancoNexo;
GO

ALTER DATABASE BancoNexo SET RECOVERY SIMPLE;
GO

USE BancoNexo;
GO


-- =====================================================================================
-- PASO 1 - TABLAS (las justas y necesarias: 4)
-- =====================================================================================

CREATE TABLE dbo.Cliente (
    ClienteId INT           NOT NULL CONSTRAINT PK_Cliente PRIMARY KEY,
    Rut       VARCHAR(12)   NOT NULL CONSTRAINT UQ_Cliente_Rut UNIQUE,  -- RUT ficticios
    Nombre    NVARCHAR(80)  NOT NULL,
    Email     NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Cuenta (
    CuentaId      INT           NOT NULL CONSTRAINT PK_Cuenta PRIMARY KEY,
    NumeroCuenta  CHAR(10)      NOT NULL CONSTRAINT UQ_Cuenta_Numero UNIQUE,
    ClienteId     INT           NOT NULL,
    TipoCuenta    NVARCHAR(10)  NOT NULL,
    Saldo         DECIMAL(12,2) NOT NULL,
    Estado        CHAR(1)       NOT NULL CONSTRAINT DF_Cuenta_Estado DEFAULT 'A',
    FechaApertura DATE          NOT NULL,
    CONSTRAINT FK_Cuenta_Cliente FOREIGN KEY (ClienteId) REFERENCES dbo.Cliente (ClienteId),
    CONSTRAINT CK_Cuenta_Tipo    CHECK (TipoCuenta IN (N'Corriente', N'Vista', N'Ahorro')),
    CONSTRAINT CK_Cuenta_Estado  CHECK (Estado IN ('A', 'B')),        -- Activa / Bloqueada
    -- Este CHECK es la fuente NATURAL de errores de la clase: un debito sin fondos
    -- dispara el error 547 sin necesidad de simular nada.
    CONSTRAINT CK_Cuenta_Saldo   CHECK (Saldo >= 0)
);

-- Libro mayor: una fila por transferencia exitosa. Nace vacio.
CREATE TABLE dbo.Transferencia (
    TransferenciaId BIGINT        NOT NULL IDENTITY(1,1) CONSTRAINT PK_Transferencia PRIMARY KEY,
    CuentaOrigenId  INT           NOT NULL,
    CuentaDestinoId INT           NOT NULL,
    Monto           DECIMAL(12,2) NOT NULL,
    FechaHora       DATETIME2(0)  NOT NULL CONSTRAINT DF_Transferencia_Fecha DEFAULT SYSDATETIME(),
    Referencia      NVARCHAR(100) NULL,
    CONSTRAINT FK_Transferencia_Origen  FOREIGN KEY (CuentaOrigenId)  REFERENCES dbo.Cuenta (CuentaId),
    CONSTRAINT FK_Transferencia_Destino FOREIGN KEY (CuentaDestinoId) REFERENCES dbo.Cuenta (CuentaId),
    CONSTRAINT CK_Transferencia_Monto   CHECK (Monto > 0)
);

-- Destino del bloque CATCH. Nace vacia.
CREATE TABLE dbo.AuditoriaError (
    ErrorId       INT            NOT NULL IDENTITY(1,1) CONSTRAINT PK_AuditoriaError PRIMARY KEY,
    FechaHora     DATETIME2(0)   NOT NULL CONSTRAINT DF_AuditoriaError_Fecha DEFAULT SYSDATETIME(),
    Procedimiento NVARCHAR(128)  NULL,
    NumeroError   INT            NOT NULL,
    Severidad     INT            NOT NULL,
    EstadoError   INT            NOT NULL,
    Linea         INT            NULL,
    Mensaje       NVARCHAR(4000) NOT NULL,
    UsuarioBD     NVARCHAR(128)  NOT NULL
);
GO


-- =====================================================================================
-- PASO 2 - DATOS INICIALES
-- 8 clientes, 12 cuentas. SUM(Saldo) inicial = 10.045.000,00
-- Casos preparados: cuenta 9 BLOQUEADA, cuenta 10 con SALDO CERO,
-- cuenta 8 con saldo minimo (para demos de fondos insuficientes).
-- =====================================================================================

INSERT INTO dbo.Cliente (ClienteId, Rut, Nombre, Email) VALUES
 (1, '12.345.678-5', N'Ana Torres'    , N'ana.torres@correo.cl'),
 (2, '9.876.543-2' , N'Bruno Herrera' , N'bruno.herrera@correo.cl'),
 (3, '15.222.333-1', N'Carla Espinoza', N'carla.espinoza@correo.cl'),
 (4, '8.111.222-9' , N'Diego Marambio', N'diego.marambio@correo.cl'),
 (5, '17.444.555-3', N'Elena Vidal'   , N'elena.vidal@correo.cl'),
 (6, '10.999.888-K', N'Franco Leiva'  , N'franco.leiva@correo.cl'),
 (7, '13.666.777-4', N'Gloria Paredes', N'gloria.paredes@correo.cl'),
 (8, '16.010.203-8', N'Hernan Zuniga' , N'hernan.zuniga@correo.cl');

INSERT INTO dbo.Cuenta (CuentaId, NumeroCuenta, ClienteId, TipoCuenta, Saldo, Estado, FechaApertura) VALUES
 (1 , '0001000101', 1, N'Corriente',  850000.00, 'A', '2020-03-15'),
 (2 , '0001000102', 1, N'Ahorro'   , 2400000.00, 'A', '2018-07-22'),
 (3 , '0001000201', 2, N'Corriente',  125000.00, 'A', '2021-01-10'),
 (4 , '0001000301', 3, N'Vista'    ,  560000.00, 'A', '2019-11-05'),
 (5 , '0001000401', 4, N'Corriente', 3200000.00, 'A', '2017-05-30'),
 (6 , '0001000501', 5, N'Ahorro'   ,   90000.00, 'A', '2022-08-18'),
 (7 , '0001000601', 6, N'Corriente',  480000.00, 'A', '2020-12-01'),
 (8 , '0001000701', 7, N'Vista'    ,   15000.00, 'A', '2023-02-14'),  -- saldo minimo
 (9 , '0001000801', 8, N'Corriente',  700000.00, 'B', '2019-04-09'),  -- BLOQUEADA
 (10, '0001000202', 2, N'Vista'    ,       0.00, 'A', '2024-06-20'),  -- saldo cero
 (11, '0001000502', 5, N'Corriente', 1350000.00, 'A', '2021-09-27'),
 (12, '0001000802', 8, N'Ahorro'   ,  275000.00, 'A', '2022-03-03');
GO
