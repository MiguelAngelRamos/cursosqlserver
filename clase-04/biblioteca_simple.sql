-- Crear la base de datos
CREATE DATABASE Biblioteca_Simple;
GO

-- Seleccionar la base de datos
USE Biblioteca_Simple;
GO


-- Tabla: Libros
CREATE TABLE Libros
(
    IDLibro INT IDENTITY(1,1) NOT NULL,
    Titulo NVARCHAR(200) NOT NULL,
    Autor NVARCHAR(150) NOT NULL,

    CONSTRAINT PK_Libros
        PRIMARY KEY (IDLibro)
);
GO


-- Tabla: Usuarios
CREATE TABLE Usuarios
(
    IDUsuario INT IDENTITY(100,1) NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,

    CONSTRAINT PK_Usuarios
        PRIMARY KEY (IDUsuario)
);
GO


-- Tabla: Prestamos
CREATE TABLE Prestamos
(
    IDPrestamo INT IDENTITY(1,1) NOT NULL,
    IDLibro INT NOT NULL,
    IDUsuario INT NOT NULL,
    FechaPrestamo DATE NOT NULL,

    CONSTRAINT PK_Prestamos
        PRIMARY KEY (IDPrestamo),

    CONSTRAINT FK_Prestamos_Libros
        FOREIGN KEY (IDLibro)
        REFERENCES Libros(IDLibro),

    CONSTRAINT FK_Prestamos_Usuarios
        FOREIGN KEY (IDUsuario)
        REFERENCES Usuarios(IDUsuario)
);
GO