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