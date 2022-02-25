USE [QUIZ]
GO


--****** NB. Inserire i valori nella tabella AUTOCOINVOLTE solo dopo aver popolato SINISTRI tramite Stored procedure ********

INSERT INTO [dbo].[ASSICURAZIONI]
           ([CodAss]
           ,[Nome]
           ,[Sede])
     VALUES
			('A00010G','SARA','Milano'),
			('A00011T','TITANIUM','Brescia'),
			('A00209M','TITANIUM','Mantova'),
			('A00209N','TITANIUM','Mantova'),
			('B00057R','SARA','Bari'),
			('F00861G','SARA','Firenze'),
			('LC09817','GENERALI','Lecce'),
			('NT04571','GENERALI','Como')
GO

INSERT INTO [dbo].[AUTO]
           ([Targa]
           ,[Marca]
           ,[Cilindrata]
           ,[Potenza]
           ,[CodF]
           ,[CodAss])
     VALUES
            ('BR343NC','LANCIA','2000','120','BNCSLV70S87T711W','B00057R'),
			('BR541ZZ','AUDI','1700','100','RSSLUC75A17F706N','A00011T'),
			('CM123ST','PEUGEOT','2500','130','FMGPAL90C36R710L','NT04571'),
			('FZ040RC','POLO','1700','100','VRDMTT91T12V606Z','F00861G'),
			('LC432GH','MATIZ','1500','80','GRBMRT99G34F703D','LC09817'),
			('MI345YX','FIAT','2100','120','ZCCRSS66M16F705R','A00010G'),
			('MN040ST','POLO','1700','130','GSTGLA00B11T701B','A00209N'),
			('MN778LJ','RENAULT','1500','130','GSTGLA00B11T701B','A00209M')
GO

INSERT INTO [dbo].[PROPRIETARI]
           ([CodF]
           ,[Nome]
           ,[Residenza])
     VALUES
            ('BNCSLV70S87T711W','Silvia Bianchi','Bari'),
			('FMGPAL90C36R710L','Paolo Fumagalli','Como'),
			('GRBMRT99G34F703D','Marta Garibaldi','Lecce'),
			('GSTGLA00B11T701B','Giulia Agostini','Mantova'),
			('RSSLUC75A17F706N','Luca Rossi','Brescia'),
			('VRDMTT91T12V606Z','Matteo Verdi','Firenze'),
			('ZCCRSS66M16F705R','Rossana Zucchi','Milano')
GO


-- da popolare successivamente a sinistri per non creare conflitti con la chiave CodS
INSERT INTO [dbo].[AUTOCOINVOLTE]
           ([CodS]
           ,[Targa]
           ,[ImportoDelDanno])
     VALUES
            ('A01B02C03','BR541ZZ',650.00),
			('A01B02C03','MI345YX',50.00),
			('A01B02C04','BR541ZZ',330.00),
			('A01B02C04','CM123ST',517.00),
			('A01B02C05','BR343NC',200.00),
			('A01B02C05','LC432GH',540.00),
			('A01B02C06','FZ040RC',85.00),
			('A01B02C06','MN778LJ',110.00),
			('A01B02C07','BR541ZZ',320.00),
			('A01B02C07','FZ040RC',460.00),
			('A01B02C08','BR343NC',250.00),
			('A01B02C08','MN778LJ',880.00)
GO