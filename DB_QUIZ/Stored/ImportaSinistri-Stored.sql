USE [QUIZ]
GO

/******  StoredProcedure [dbo].[Importa_Sinistri]    ******/
/*  Lanciando exec Importa_Sinistri viene svolta tutta laprima parte dell'esercizio:
	Creare un flusso in T-SQL che a partire da un csv, depositato in una cartella chiamata input, lo sposti in una
	cartella processed, rinominando il file, e popoli la tabella SINISTRI. Le restanti tabelle possono essere
	popolate liberamente.
	Il csv dato in input potrebbe avere delle righe malformate e quindi causare un ko in fase di importazione, ad
	esempio la data potrebbe essere stata compilata con una stringa alfabetica. Generare un csv di output
	contenente l’elenco dei record malformati con il relativo messaggio di errore e annullare tutte le operazioni
	compiute.
	Per le auto coinvolte nei sinistri appena importati, rivalutare l’importo del danno del 10% se la data del
	sinistro è antecedente al 20/01/2021 e se il proprietario risiede in una città diversa rispetto alla sede
	dell’assicurazione. 
	NB. EVENTUALMENTE MODIFICARE I PERCORSI OLTRE AL NOME DEL SERVER*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--   exec Importa_Sinistri;

CREATE OR ALTER                Procedure [dbo].[Importa_Sinistri] as
DECLARE @ServerName varchar(100) = '\\DESKTOP- \'
DECLARE @InputFolder varchar(100) = 'C:\Users\Public\input\'
DECLARE @OriginalFilename varchar(100) = 'sinistri.csv'
DECLARE @ProcessFolder varchar(100) = 'C:\Users\Public\processed\'
DECLARE @ProcessFilename varchar(100) = 'processed_sinistri.csv'
DECLARE @OutputFolder varchar(500) = 'C:\Users\Public\processed\processed_sinistri.csv'
DECLARE @tsqlString nvarchar(1000)
-- permessi di xp_cmdshell 
EXECUTE [master].[dbo].sp_configure 'show advanced options', 1; RECONFIGURE;
EXECUTE [master].[dbo].sp_configure 'xp_cmdshell', 1; RECONFIGURE;
-- destinatione, crea cartella processed
exec [master].[dbo].xp_create_subdir @ProcessFolder
-- copia e rinominazione file
SET @tsqlString = 'COPY /Y /D "'+@InputFolder+@OriginalFilename+'" "'+@OutputFolder+'" ';
EXEC [master].[dbo].xp_cmdshell @tsqlString,no_output;
-- disattiva xp_cmdshell
EXECUTE [master].[dbo].sp_configure 'xp_cmdshell', 0; RECONFIGURE;
EXECUTE [master].[dbo].sp_configure 'show advanced options', 0; RECONFIGURE;
-- inserimento, FIRSTROW = 2 se il file ha l'intestazione, se no vale 1
BEGIN TRANSACTION   -- punto riferimento rollback
SET @tsqlString =	'BULK INSERT  [QUIZ].[dbo].[SINISTRI] 
					FROM  "'+@OutputFolder+'"  WITH
					(
					CODEPAGE = ''ACP'',
					FIRSTROW = 2,
					FIELDTERMINATOR = '';'',
					ROWTERMINATOR = ''\n'',
					KEEPNULLS
					)'
					EXEC (@tsqlString)
			-- auto coinvolte nei sinistri appena importati, rivalutare l’importo del danno del 10% se la data del
			-- sinistro è antecedente al 20/01/2021 e se il proprietario risiede in una città diversa rispetto alla sede
			-- dell’assicurazione
			UPDATE [QUIZ].[dbo].[AUTOCOINVOLTE] 
			SET [ImportoDelDanno]= 
			convert(decimal(10,2),ac.[ImportoDelDanno]+((ac.[ImportoDelDanno]/100)*10)) 
			from AUTOCOINVOLTE ac join sinistri s on s.CodS=ac.CodS 
			join [AUTO] a on ac.Targa=a.Targa
			join PROPRIETARI p on p.CodF=a.CodF
			join ASSICURAZIONI sic on sic.CodAss=a.CodAss
			where --ac.Targa=[AUTOCOINVOLTE].[Targa] AND ac.Cods=[AUTOCOINVOLTE].[CodS] AND 
			convert(date,cast(s.[data] as varchar)) < convert(date,'20210120') OR 
			p.Residenza <> sic.Sede ;


IF @@ERROR <> 0 
	BEGIN
		PRINT 'Esecuzione ROLLBACK – TRANSAZIONE KO'
		ROLLBACK TRAN
		DECLARE @fileName NVARCHAR(30);
		DECLARE @bcp_cmd VARCHAR(1000);
		DECLARE @Tab VARCHAR = ( 'SINISTRI' );
		DECLARE @Intestazione NVARCHAR = ( 'CodS,'+'Località,'+'Data,'+'Errore');
		
	    SET @fileName = 'processed_' + CONVERT(nvarchar(30),GETDATE(),112) ;
		RAISERROR('KO Importazione, sarà generato errors.csv contenente le righe errate',16,1)
		-- permessi di xp_cmdshell 
		EXECUTE [master].[dbo].sp_configure 'show advanced options', 1; RECONFIGURE;
		EXECUTE [master].[dbo].sp_configure 'xp_cmdshell', 1; RECONFIGURE;
		-- svuota tabella confronto (o drop e create)
		UPDATE [dbo].[TestCSVImport] SET [CodS] = NULL;UPDATE [dbo].[TestCSVImport] SET [Località]= NULL;UPDATE [dbo].[TestCSVImport] SET [Data] = NULL;
		--  inserisce tutti i dati presenti nel file nella tabella di confronto
		SET @tsqlString ='BULK INSERT  [QUIZ].[dbo].[TestCSVImport] 
					FROM  "'+@OutputFolder+'"  WITH
					(
					CODEPAGE = ''ACP'',
					FIRSTROW = 2,
					FIELDTERMINATOR = '';'',
					ROWTERMINATOR = ''\n'',
					KEEPNULLS
					)'
		EXEC (@tsqlString)	
		-- cancella righe che non sono già presenti in SINISTRI e che non siano vuote (es.quelle cancellate sopra)
		DELETE FROM [dbo].[TestCSVImport]
        WHERE CodS in (select CodS from SINISTRI) or ([CodS] is null and [Località] is null and [Data] is null)

	-- crea il csv di errori che restituisce solo le righe errate CON chiave univoca CodS NON ANCORA presente su SINISTRI
	-- tramite la vista si tiene il codice più pulito e si possono aggiungere/modificare i controlli ottenendo dei messaggi di errore più chiari
	SET @bcp_cmd= 'bcp "select  * from [QUIZ].[dbo].[Esporta_Errori] "  QUERYOUT '+@ProcessFolder+'errors.csv -t, -T -c '
	exec [master].[dbo].xp_cmdShell @bcp_cmd

	-- disattiva xp_cmdshell
	EXECUTE [master].[dbo].sp_configure 'xp_cmdshell', 0; RECONFIGURE;
	EXECUTE [master].[dbo].sp_configure 'show advanced options', 0; RECONFIGURE;

	END
ELSE 
	BEGIN
		PRINT 'Esecuzione Commit – TRANSAZIONE OK'
		COMMIT TRAN
	END 
	
GO


