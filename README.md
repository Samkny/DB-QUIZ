Creare un database in SQL Server contenente le seguenti tabelle:
AUTO (Targa, Marca, Cilindrata, Potenza, CodF*, CodAss*)
PROPRIETARI (CodF, Nome, Residenza)
ASSICURAZIONI (CodAss, Nome, Sede)
SINISTRI (CodS, Località, Data)
AUTOCOINVOLTE (CodS*, Targa*, ImportoDelDanno)

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

FACOLTATIVO: Mostrare l’elenco delle auto (targa e marca), con relativo proprietario, che sono coinvolte in
sinistri, per ognuna dire se c’è stata rivalutazione o no e indicare l’importo rivalutato.
Eseguire le seguenti query:
  1) Targa e Marca delle Auto di cilindrata superiore a 2000 cc o di potenza superiore a 120 CV
  2) Nome del proprietario e Targa delle Auto di cilindrata superiore a 2000 cc oppure di potenza
  superiore a 120 CV
  3) Targa e Nome del proprietario delle Auto di cilindrata superiore a 2000 cc oppure di potenza
  superiore a 120 CV, assicurate presso la “SARA”
  4) Per ciascuna auto “Fiat”, la targa dell’auto ed il numero di sinistri in cui è stata coinvolta
  5) Per ciascuna auto coinvolta in più di un sinistro, la targa dell’auto, il nome dell’Assicurazione, ed il
  totale dei danni riportati
  6) CodF e Nome di coloro che possiedono più di un’auto
  7) La targa delle auto che non sono state coinvolte in sinistri dopo il 20/01/2021
  8) Il codice dei sinistri in cui non sono state coinvolte auto con cilindrata inferiore a 2000 cc
