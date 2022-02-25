USE [QUIZ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/******								VISTE E ESERCIZI SVOLTI							     	******/
/*  1) Targa e Marca delle Auto di cilindrata superiore a 2000 cc o di potenza superiore a 120 CV
	2) Nome del proprietario e Targa delle Auto di cilindrata superiore a 2000 cc oppure di potenza
	superiore a 120 CV
	3) Targa e Nome del proprietario delle Auto di cilindrata superiore a 2000 cc oppure di potenza
	superiore a 120 CV, assicurate presso la “SARA”
	4) Per ciascuna auto “Fiat”, la targa dell’auto ed il numero di sinistri in cui è stata coinvolta
	5) Per ciascuna auto coinvolta in più di un sinistro, la targa dell’auto, il nome dell’Assicurazione, ed il
	totale dei danni riportati
	6) CodF e Nome di coloro che possiedono più di un’auto
	7) La targa delle auto che non sono state coinvolte in sinistri dopo il 20/01/2021
	8) Il codice dei sinistri in cui non sono state coinvolte auto con cilindrata inferiore a 2000 cc */


CREATE OR ALTER     view [dbo].[Es_1] as 
--1) Targa e Marca delle Auto di cilindrata superiore a 2000 cc o di potenza superiore a 120 CV
select ac.Targa, a.Marca
from [AUTOCOINVOLTE] ac join [AUTO] a on ac.Targa=a.Targa
WHERE a.Cilindrata>2000 OR  a.Potenza>120
GO

CREATE OR ALTER     view [dbo].[Es_2] as
--2) Nome del proprietario e Targa delle Auto di cilindrata superiore a 2000 cc oppure di potenza superiore a 120 CV
select  p.Nome,ac.Targa
from [AUTOCOINVOLTE] ac join [AUTO] a on ac.Targa=a.Targa
join PROPRIETARI p on p.CodF=a.CodF 
WHERE a.Cilindrata>2000 OR  a.Potenza>120
GO

CREATE OR ALTER     view [dbo].[Es_3] as
--3) Targa e Nome del proprietario delle Auto di cilindrata superiore a 2000 cc oppure di potenza superiore a 120 CV, assicurate presso la “SARA”
select ac.Targa, p.Nome
from [AUTOCOINVOLTE] ac join [AUTO] a on ac.Targa=a.Targa
join PROPRIETARI p on p.CodF=a.CodF 
join [ASSICURAZIONI] sic on sic.CodAss=a.CodAss 
WHERE ( a.Cilindrata>2000 OR a.Potenza>120 )
AND replace(UPPER(sic.Nome),' ','') like 'SARA'
GO

CREATE OR ALTER     view [dbo].[Es_4] as
--4) Per ciascuna auto “Fiat”, la targa dell’auto ed il numero di sinistri in cui è stata coinvolta

select a.Targa, count(s.CodS) as Num_Sinistri
from [AUTO] a join [AUTOCOINVOLTE] ac on a.Targa=ac.Targa
join [SINISTRI] s on s.CodS=ac.CodS 
WHERE  replace(UPPER(a.Marca),' ','') like 'FIAT'
group by a.Targa
GO

CREATE OR ALTER     view [dbo].[Es_5] as
--5) Per ciascuna auto coinvolta in più di un sinistro, la targa dell’auto, il nome dell’Assicurazione, ed il
--   totale dei danni riportati
select ac.Targa, sic.Nome, SUM(ac.ImportoDelDanno) as Totale_Danni
from [AUTOCOINVOLTE] ac join [AUTO] a on ac.Targa=a.Targa
join [ASSICURAZIONI] sic on sic.CodAss=a.CodAss 
group by ac.Targa, sic.Nome
HAVING count(ac.Targa)>1
GO

CREATE OR ALTER     view [dbo].[Es_6] as
--6) CodF e Nome di coloro che possiedono più di un’auto
select p.CodF, p.Nome
from [AUTO] a join PROPRIETARI p on p.CodF=a.CodF 
group by p.CodF, p.Nome
HAVING count(a.CodF)>1
GO

CREATE OR ALTER     view [dbo].[Es_7] as
--7) La targa delle auto che non sono state coinvolte in sinistri dopo il 20/01/2021
select a.Targa
from [AUTO] a where a.Targa not in ( select ac.Targa from [AUTOCOINVOLTE] ac join [SINISTRI] s on ac.CodS=s.CodS
									 WHERE convert(date,cast(s.[Data] as varchar))<=convert(date,'20210120')  )
GO

CREATE OR ALTER     view [dbo].[Es_8] as
--8) Il codice dei sinistri in cui non sono state coinvolte auto con cilindrata inferiore a 2000 cc 
select s.CodS
from [SINISTRI] s join [AUTOCOINVOLTE] ac on s.CodS=ac.CodS 
join [AUTO] a on ac.Targa=a.Targa
WHERE a.Cilindrata>2000 
GO



/****** CREAT OR ALTER View [dbo].[check_targhe] e [dbo].[Es_Facoltativo] ******/

CREATE OR ALTER   view [dbo].[check_targhe] as

select ac.Targa, a.Marca, p.Nome
from [AUTOCOINVOLTE] ac join [AUTO] a on ac.Targa=a.Targa
join PROPRIETARI p on p.CodF=a.CodF 
join [ASSICURAZIONI] sic on sic.CodAss=a.CodAss 
join [SINISTRI]s on s.CodS=ac.CodS 
WHERE convert(date,cast(s.[Data] as varchar))<convert(date,'20210120')
OR (p.Residenza <> sic.Sede )
GO

CREATE OR ALTER     View [dbo].[Es_Facoltativo] as 
		--Mostrare l’elenco delle auto (targa e marca), con relativo proprietario, che sono coinvolte in
		--sinistri, per ognuna dire se c’è stata rivalutazione o no e indicare l’importo rivalutato
		--NB. Alcuni valori possono essere leggermente diversi
	select ac.Targa, a.Marca, p.Nome,
	--(ac.[ImportoDelDanno]/100)*10 as percentuale,
	case when ac.Targa in (select Targa from [check_targhe])
			then cast(convert(decimal(10,2), (ac.[ImportoDelDanno]-((ac.[ImportoDelDanno]/100) *10) ))     as varchar)
			+' Importo Rivalutato del 10% = '+cast(ac.[ImportoDelDanno] as varchar)
			else cast (ac.ImportoDelDanno as varchar) END as Importo_Iniziale
	from [AUTOCOINVOLTE] ac join [AUTO] a on ac.Targa=a.Targa
	join PROPRIETARI p on p.CodF=a.CodF 


/****** CREAT OR ALTER View [dbo].[Esporta_Errori]   per creazione csv di errori ******/	

CREATE OR ALTER view [dbo].[Esporta_Errori] as
select x.[CodS],x.[Località],x.[Data],
		case when x.[Data] <>'0-9' and LEN(x.[Data])=10 then '' 
			else 'Formato Data Errato' END as [Errors]
FROM [QUIZ].[dbo].[TestCSVImport] x
GO

