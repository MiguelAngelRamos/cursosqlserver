-- PROCEDIMIENTO ALMACENADO VERSION INGENUA
-- Sin transaccion, sin validaciones, sin manejo de errores.

CREATE OR ALTER PROCEDURE dbo.usp_Transferir_v1_Ingenua
  @CuentaOrigenId INT,
  @CuentaDestinoId INT,
  @Monto           DECIMAL(12,2)
AS
BEGIN
  -- Saldo -= @Monto  Equivale a Saldo = Saldo - @Monto
  UPDATE dbo.Cuenta SET Saldo -= @Monto WHERE CuentaId = @CuentaOrigenId;
  -- Saldo += @Monto  Equivale a Saldo = Saldo + @Monto
  UPDATE dbo.Cuenta SET Saldo += @Monto WHERE CuentaId = @CuentaDestinoId;
END;
GO;

CREATE OR ALTER PROCEDURE dbo.usp_Transferir_v2_SinManejoErrores
  @CuentaOrigenId INT,
  @CuentaDestinoId INT,
  @Monto           DECIMAL(12,2),
  @Referencia      NVARCHAR(100) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION;
  -- Saldo -= @Monto  Equivale a Saldo = Saldo - @Monto
  UPDATE dbo.Cuenta SET Saldo -= @Monto WHERE CuentaId = @CuentaOrigenId;
  -- Saldo += @Monto  Equivale a Saldo = Saldo + @Monto
  UPDATE dbo.Cuenta SET Saldo += @Monto WHERE CuentaId = @CuentaDestinoId;

  INSERT INTO dbo.Transferencia(CuentaOrigenId, CuentaDestinoId, Monto, Referencia)
  VALUES(@CuentaOrigenId, @CuentaDestinoId, @Monto, @Referencia);
  COMMIT TRANSACTION;
END;
GO;


-- PROCEDIMIENTO FINAL: LA VERSION ROBUSTA (Mejores Practicas)
CREATE OR ALTER PROCEDURE dbo.usp_TransferirFondos
    @CuentaOrigenId  INT,
    @CuentaDestinoId INT,
    @Monto           DECIMAL(12,2),
    @Referencia      NVARCHAR(100) = NULL,
    @TransferenciaId BIGINT        = NULL OUTPUT,
    @SimularFalla    BIT           = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- La linea mas importante de todo el procedimiento, Por defecto (OFF)
    /*
    Si ocurre un error de ejecución (como no cumplir un CHECK (Saldo >=0), sql server cancela solo la instruccion
    que fallo y sigue ejecutando el lote
    */

    BEGIN TRY
        -- ---------- Validaciones que no requieren bloqueos ----------
        IF @Monto IS NULL OR @Monto <= 0
            THROW 50004, N'El monto debe ser mayor que cero.', 1;

        IF @CuentaOrigenId = @CuentaDestinoId
            THROW 50005, N'La cuenta de origen y la de destino no pueden ser la misma.', 1;

        DECLARE @SaldoOrigen   DECIMAL(12,2),
                @EstadoOrigen  CHAR(1),
                @EstadoDestino CHAR(1),
                @Msg           NVARCHAR(400);

        BEGIN TRANSACTION;

        -- ---------- Bloqueo en orden ascendente de CuentaId ----------
        DECLARE @PrimeraCuenta INT = IIF(@CuentaOrigenId < @CuentaDestinoId, @CuentaOrigenId, @CuentaDestinoId),
                @SegundaCuenta INT = IIF(@CuentaOrigenId < @CuentaDestinoId, @CuentaDestinoId, @CuentaOrigenId),
                @Bloqueo       INT;

        SELECT @Bloqueo = CuentaId FROM dbo.Cuenta WITH (UPDLOCK, HOLDLOCK) WHERE CuentaId = @PrimeraCuenta;
        SELECT @Bloqueo = CuentaId FROM dbo.Cuenta WITH (UPDLOCK, HOLDLOCK) WHERE CuentaId = @SegundaCuenta;

        -- ---------- Validaciones bajo bloqueo ----------
        SELECT @SaldoOrigen = Saldo, @EstadoOrigen = Estado
        FROM dbo.Cuenta WHERE CuentaId = @CuentaOrigenId;

        IF @@ROWCOUNT = 0
            THROW 50001, N'La cuenta de origen no existe.', 1;

        SELECT @EstadoDestino = Estado
        FROM dbo.Cuenta WHERE CuentaId = @CuentaDestinoId;

        IF @@ROWCOUNT = 0
            THROW 50006, N'La cuenta de destino no existe.', 1;

        IF @EstadoOrigen = 'B'
            THROW 50003, N'La cuenta de origen esta bloqueada.', 1;

        IF @EstadoDestino = 'B'
            THROW 50007, N'La cuenta de destino esta bloqueada.', 1;

        IF @SaldoOrigen < @Monto
        BEGIN
            SET @Msg = CONCAT(N'Saldo insuficiente. Disponible: ', @SaldoOrigen,
                              N' - Solicitado: ', @Monto);
            THROW 50002, @Msg, 1;
        END;

        -- ---------- Operacion atomica: 2 UPDATE + 1 INSERT ----------
        UPDATE dbo.Cuenta SET Saldo -= @Monto WHERE CuentaId = @CuentaOrigenId;
        UPDATE dbo.Cuenta SET Saldo += @Monto WHERE CuentaId = @CuentaDestinoId;

        INSERT INTO dbo.Transferencia (CuentaOrigenId, CuentaDestinoId, Monto, Referencia)
        VALUES (@CuentaOrigenId, @CuentaDestinoId, @Monto, @Referencia);

        SET @TransferenciaId = SCOPE_IDENTITY();

        -- ---------- Punto de falla controlada para la demo de atomicidad ----------
        IF @SimularFalla = 1
            THROW 50099, N'Falla simulada despues de aplicar los cambios (demo de ROLLBACK).', 1;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Con XACT_ABORT ON la transaccion queda condenada: XACT_STATE() = -1
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        -- La auditoria va DESPUES del rollback: si fuera antes, se desharia con el.
        INSERT INTO dbo.AuditoriaError
            (Procedimiento, NumeroError, Severidad, EstadoError, Linea, Mensaje, UsuarioBD)
        VALUES
            (ERROR_PROCEDURE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(),
             ERROR_LINE(), ERROR_MESSAGE(), SUSER_SNAME());

        SET @TransferenciaId = NULL;

        THROW;   -- relanza el error original hacia el cliente
    END CATCH;
END;
GO