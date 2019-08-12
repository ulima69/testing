
%INCLUDE '/dados/infor/suporte/FuncoesInfor.sas';

libname chip "/dados/infor/producao/Dimep/chipamento_inss";

LIBNAME DEB DB2 DATABASE=BDB2P04 SCHEMA=DB2DEB AUTHDOMAIN=DB2SGCEN;
LIBNAME MCI DB2 DATABASE=BDB2P04 SCHEMA=DB2MCI AUTHDOMAIN=DB2SGCEN;
LIBNAME CDE DB2 DATABASE=BDB2P04 SCHEMA=DB2CDE AUTHDOMAIN=DB2SGCEN;

DATA _NULL_;
	
	D1 = diaUtilAnterior(TODAY());
	ANOMES = Put(D1, yymmn6.);
	
	CALL SYMPUT('D1',COMPRESS(D1,' '));
	CALL SYMPUT('ANOMES',COMPRESS(ANOMES,' '));
	
RUN;

%PUT &ANOMES.;


/*PROC SQL;
   CREATE TABLE chip.BASETOTAL_INSS AS 
   SELECT t1.Prefixo, 
          t1.Beneficio
      FROM WORK.BASETOTAL_INSS t1
      ORDER BY t1.Prefixo;
QUIT;*/


PROC SQL;
   CONNECT TO DB2 (AUTHDOMAIN='DB2SGCEN' DATABASE=BDB2P04);
   CREATE TABLE work.CHIPAMENTO_NR_CARTAO AS SELECT * FROM CONNECTION TO DB2(       
   SELECT 
          CONCAT(CAST(t1.CDE650WNROCART AS VARCHAR(15)), t1.CDE650WDGVCART) AS PLASTICO, 
	      t1.CDE650WNROAGEN, 
          t1.CDE650WDGVAGEN, 
          t1.CDE650WNROCNTA, 
          t1.CDE650WDGVCNTA, 
          t1.CDE650WCODTITL, 
          t1.CDE650WGRPSETX, 
          t1.CDE650WNOMTITL, 
          t1.CDE650WNMROCPF, 
          t1.CDE650WDATNASC, 
		  (SUBSTR(LPAD(t1.CDE650WDATNASC, 6, '0'), 1, 2)||'/'|| SUBSTR(LPAD(t1.CDE650WDATNASC, 6, '0'), 3, 2)||'/'||SUBSTR(LPAD(t1.CDE650WDATNASC, 6, '0'), 5,2)) AS NASCIMENTO,  
          t1.CDE650WDATEMSS, 
		  (SUBSTR(LPAD(t1.CDE650WDATEMSS, 6, '0'), 1, 2)||'/'|| SUBSTR(LPAD(t1.CDE650WDATEMSS, 6, '0'), 3, 2)||'/'||SUBSTR(LPAD(t1.CDE650WDATEMSS, 6, '0'), 5,2)) AS EMISSAO,  
		  t1.CDE650WDATVENC, 
		  (SUBSTR(LPAD(t1.CDE650WDATVENC, 6, '0'), 1, 2)||'/'|| SUBSTR(LPAD(t1.CDE650WDATVENC, 6, '0'), 3, 2)||'/'||SUBSTR(LPAD(t1.CDE650WDATVENC, 6, '0'), 5,2))  AS VENCIMENTO,            
          t1.CDE650WTIPCART, 
          t1.CDE650WSTACART,
		  CURRENT DATE AS ATUALIZACAO
      FROM DB2CDE.TCDE650 t1);
QUIT;


PROC SQL;
   CREATE TABLE work.CartaoChipamento AS 
   SELECT t1.Prefixo, 
          t1.Beneficio, 
          t2.PLASTICO, 
          t2.CDE650WNROAGEN, 
          t2.CDE650WDGVAGEN, 
          t2.CDE650WNROCNTA, 
          t2.CDE650WDGVCNTA, 
          t2.CDE650WCODTITL, 
          t2.CDE650WGRPSETX, 
          t2.CDE650WNOMTITL, 
          t2.CDE650WNMROCPF, 
          t2.CDE650WDATNASC, 
          t2.CDE650WDATEMSS, 
          t2.EMISSAO, 
          t2.CDE650WDATVENC, 
          t2.VENCIMENTO, 
          t2.CDE650WTIPCART, 
          t2.CDE650WSTACART, 
          t2.ATUALIZACAO
      FROM chip.BASETOTAL_INSS t1
           LEFT JOIN work.CHIPAMENTO_NR_CARTAO t2 ON (t1.Prefixo = t2.CDE650WNROAGEN) AND (t1.Beneficio = 
          t2.CDE650WNROCNTA);
QUIT;


PROC SQL;
   CREATE TABLE WORK.CARTOES_CHIPAMENTO_ANT AS 
   SELECT 
          t1.Prefixo, 
          t1.Beneficio, 
          t1.PLASTICO, 
          t1.CDE650WNROAGEN, 
          t1.CDE650WDGVAGEN, 
          t1.CDE650WNROCNTA, 
          t1.CDE650WDGVCNTA, 
          t1.CDE650WCODTITL, 
          t1.CDE650WGRPSETX, 
          t1.CDE650WNOMTITL, 
          t1.CDE650WNMROCPF, 
          t1.CDE650WDATNASC,           
          t1.CDE650WDATEMSS, 
		  INPUT(t1.EMISSAO, ddmmyy8.) AS EMISSAO, 
          t1.CDE650WDATVENC, 
		  INPUT(t1.VENCIMENTO, ddmmyy8.) AS VENCIMENTO,          
          t1.CDE650WTIPCART, 
          t1.CDE650WSTACART, 
          t1.ATUALIZACAO, 
          t2.STATUS, 
          CASE 
            WHEN t2.STATUS IN (70,71) THEN 'PENDENTE LIBERA��O' 
            ELSE t2.DESCRICAO
		  END AS DESCRICAO
      FROM work.CARTAOCHIPAMENTO t1
           LEFT JOIN  chip.STATUS_CARTAO_CDE t2 ON (t1.CDE650WSTACART = t2.STATUS)
	  /*WHERE (CALCULATED EMISSAO) >= '30JUL2018'D*/
	  ORDER BY 
        t1.Prefixo, 
        t1.Beneficio;
QUIT;


PROC SQL;
   CREATE TABLE WORK.CARTOES_CHIPAMENTO AS 
   SELECT 
          t1.Prefixo, 
          t1.Beneficio, 
          t1.PLASTICO, 
          t1.CDE650WNROAGEN, 
          t1.CDE650WDGVAGEN, 
          t1.CDE650WNROCNTA, 
          t1.CDE650WDGVCNTA, 
          t1.CDE650WCODTITL, 
          t1.CDE650WGRPSETX, 
          t1.CDE650WNOMTITL, 
          t1.CDE650WNMROCPF, 
          t1.CDE650WDATNASC,           
          t1.CDE650WDATEMSS, 
		  t1.EMISSAO FORMAT ddmmyy8. AS EMISSAO, 
          t1.CDE650WDATVENC, 
		  t1.VENCIMENTO FORMAT ddmmyy8. AS VENCIMENTO,          
          t1.CDE650WTIPCART, 
          t1.CDE650WSTACART, 
          t1.ATUALIZACAO, 
          t1.STATUS, 
          t1.DESCRICAO

      FROM WORK.CARTOES_CHIPAMENTO_ANT t1
           
	    ORDER BY 
        t1.Prefixo, 
        t1.Beneficio;
QUIT;


PROC SQL;
   CREATE TABLE WORK.CARTOES_CHIPAMENTO_2 AS 
   SELECT DISTINCT t1.Prefixo, 
          t1.Beneficio, 
          INPUT(t1.PLASTICO, 16.) as NR_PLST,
          t1.PLASTICO, 
          t1.CDE650WNROAGEN, 
          t1.CDE650WDGVAGEN, 
          t1.CDE650WNROCNTA, 
          t1.CDE650WDGVCNTA, 
          t1.CDE650WCODTITL, 
          t1.CDE650WGRPSETX, 
          t1.CDE650WNOMTITL, 
          t1.CDE650WNMROCPF, 
          t1.CDE650WDATNASC, 
          t1.CDE650WDATEMSS, 
          t1.EMISSAO, 
          t1.CDE650WDATVENC, 
          t1.VENCIMENTO, 
          t1.CDE650WTIPCART, 
          t1.CDE650WSTACART, 
          t1.ATUALIZACAO, 
          t1.STATUS, 
          t1.DESCRICAO
      FROM WORK.CARTOES_CHIPAMENTO t1
      WHERE t1.EMISSAO >= '30Jul2018'd;
QUIT;


data WORK.CARTOES_CHIPAMENTO_2;
format NR_PLST 16.;
set WORK.CARTOES_CHIPAMENTO_2;
;
run;


PROC SQL;
   CONNECT TO DB2 (AUTHDOMAIN='DB2SGCEN' DATABASE=BDB2P04);   
   CREATE TABLE work.TRACKING_CHIPAMENTO AS SELECT * FROM CONNECTION TO DB2(  
   SELECT t1.NR_RMS_PLST, 
          t1.NR_LT_PLST, 
          t1.NR_SEQL_PLST, 
		  t2.NR_AR_TR, 
          t2.NR_PLST, 
		  t2.CD_EST AS COD_ULTIMO_ESTADO,
          CASE 
			WHEN t2.CD_EST = '1' THEN 'GERADO' 
			WHEN t2.CD_EST = '2' THEN 'EXPEDIDO' 
			WHEN t2.CD_EST = '3' THEN 'ENTREGA ESPECIAL' 
			WHEN t2.CD_EST = '4' THEN 'NAO PROCESSADO' 
			WHEN t2.CD_EST = '5' THEN 'EXTRAVIADO/DEVOLVIDO'
			WHEN t2.CD_EST = '6' THEN 'CONF. POSITIVA'
			WHEN t2.CD_EST = '7' THEN 'CONF. NEGATIVA'
			WHEN t2.CD_EST = '8' THEN 'DEVOLVIDO/CORREIO'
			WHEN t2.CD_EST = '9' THEN 'ENTREGUE CLIENTE'
			WHEN t2.CD_EST = 'A' THEN 'ATUALIZADO BAT'
			WHEN t2.CD_EST = 'B' THEN 'EXPED.JURIDISCIONANTE'
			WHEN t2.CD_EST = 'C' THEN 'PREPARADO JURISDICIONANTE'
			WHEN t2.CD_EST = 'D' THEN 'SOLCITADO DESTRUICAO'
			WHEN t2.CD_EST = 'G' THEN 'AR ENTREGUE'
			WHEN t2.CD_EST = 'P' THEN 'PRONTO EXPED. JURIS'
			WHEN t2.CD_EST = 'Q' THEN 'SOLICITACAO BLOQUEIO Q'
			WHEN t2.CD_EST = 'R' THEN 'REENVIO AGENCIA'
			WHEN t2.CD_EST = 'T' THEN 'TELEMARKETING CONCLUIDO'
			WHEN t2.CD_EST = 'V' THEN 'SOLICITADO 2 VIA'
			WHEN t2.CD_EST = 'X' THEN 'ENTREGUE C/ AR EXTRAVIADO'
			WHEN t2.CD_EST = 'Y' THEN 'SOLIC. BLOQUEIO Q ALTERADO'
			WHEN t2.CD_EST = 'Z' THEN 'SOLIC. 2 VIA ALTERADO'
			ELSE t2.CD_EST
		  END AS ULTIMO_ESTADO,
          t2.DT_EST,           
		  MAX(CASE WHEN t1.CD_EST_PLST = '1' THEN t1.DT_ALT_PLST END) AS DT_GERACAO,
		  MAX(CASE WHEN t1.CD_EST_PLST = '2' THEN t1.DT_ALT_PLST END) AS DT_EXPEDICAO,
		  MAX(CASE WHEN t1.CD_EST_PLST = '3' THEN t1.DT_ALT_PLST END) AS DT_ENTREGA_ESPECIAL,
		  /*MAX(CASE WHEN t1.CD_EST_PLST = '4' THEN t1.DT_ALT_PLST END) AS DT_NAO_PROCESSADO,*/
		  MAX(CASE WHEN t1.CD_EST_PLST = '5' THEN t1.DT_ALT_PLST END) AS DT_EXTRAVIADO_DEVOLVIDO,
		  MAX(CASE WHEN t1.CD_EST_PLST = '6' THEN t1.DT_ALT_PLST END) AS DT_CONF_POSITIVA,
		  MAX(CASE WHEN t1.CD_EST_PLST = '7' THEN t1.DT_ALT_PLST END) AS DT_CONF_NEGATIVA,
		  MAX(CASE WHEN t1.CD_EST_PLST = '8' THEN t1.DT_ALT_PLST END) AS DT_DEVOLVIDO_CORREIO,
		  MAX(CASE WHEN t1.CD_EST_PLST = '9' THEN t1.DT_ALT_PLST END) AS DT_ENTREGUE_CLIENTE,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'A' THEN t1.DT_ALT_PLST END) AS DT_ATUALIZADO_BAT,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'B' THEN t1.DT_ALT_PLST END) AS DT_EXPED_JURISDICIONANTE,
		  /*MAX(CASE WHEN t1.CD_EST_PLST = 'C' THEN t1.DT_ALT_PLST END) AS DT_PREPARADO_JURDISC,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'D' THEN t1.DT_ALT_PLST END) AS DT_SOLICITADO_DESTRUICAO,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'G' THEN t1.DT_ALT_PLST END) AS DT_AR_ENTREGUE,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'P' THEN t1.DT_ALT_PLST END) AS DT_PRONTO_EXPED,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'Q' THEN t1.DT_ALT_PLST END) AS DT_SOLICITACAO_BLOQUEIO,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'R' THEN t1.DT_ALT_PLST END) AS DT_REENVIO_AGENCIA,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'T' THEN t1.DT_ALT_PLST END) AS DT_TELEMARKETING,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'V' THEN t1.DT_ALT_PLST END) AS DT_SOLICITACAO_2VIA,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'X' THEN t1.DT_ALT_PLST END) AS DT_ENTREGUE_AR_EXTRAVIADO,	
		  MAX(CASE WHEN t1.CD_EST_PLST = 'Y' THEN t1.DT_ALT_PLST END) AS DT_SOLICITADO_BLOQUEIO_ALTERADO,
		  MAX(CASE WHEN t1.CD_EST_PLST = 'Z' THEN t1.DT_ALT_PLST END) AS DT_SOLICITADO_2VIA_ALTERADO   */    
         DATE(CURRENT DATE) AS ATUALIZADO
      FROM DB2VIP.ENVP_PLST_CTL t1
	  INNER JOIN DB2VIP.ENVP_PLASTICO t2 ON (t1.NR_RMS_PLST = t2.NR_REMESSA 
          								 AND t1.NR_LT_PLST = t2.NR_LOTE
										 AND t1.NR_SEQL_PLST = t2.NR_SEQL )

    WHERE NR_RMS_PLST >= 277950/* AND t1.CD_EST_PLST IN ('1', '2', '3', '5', '6', '7', '8', '9', 'A', 'B')*/

	GROUP BY t1.NR_RMS_PLST, 
          t1.NR_LT_PLST, 
          t1.NR_SEQL_PLST, 
		  t2.NR_AR_TR, 
          t2.NR_PLST, 
          t2.CD_EST, 
          t2.DT_EST    

);
QUIT;


PROC SQL;
   CREATE TABLE WORK.CARTOES_CHIPAMENTO_FINAL AS 
   SELECT t3.PrefDir,
          t3.PrefSuper as PrefixoSuper,
          t3.PrefSureg as PrefixoGerev,
          t1.Prefixo AS PrefDep, 
          t3.UF, 
          t3.Municipio as NomeMunicipioBB, 
          t1.Beneficio, 
		  t1.NR_PLST, 
          t1.PLASTICO, 
          t1.CDE650WNROAGEN AS AgenciaCartao, 
          t1.CDE650WDGVAGEN AS DV_AgenciaCartao, 
          t1.CDE650WNROCNTA AS NR_Conta, 
          t1.CDE650WDGVCNTA AS DV_Conta, 
          t1.CDE650WCODTITL AS Titular, 
          t1.CDE650WGRPSETX AS Setex, 
          t1.CDE650WNOMTITL AS NomeTitularCartao, 
          t1.CDE650WNMROCPF AS CPF, 
          t1.CDE650WDATNASC AS DATNASC, 
          t1.CDE650WDATEMSS AS DATEMSS, 
          t1.EMISSAO, 
          t1.CDE650WDATVENC AS DATVENC, 
          t1.VENCIMENTO, 
          t1.CDE650WTIPCART AS TIPCART, 
          t1.CDE650WSTACART AS STACART, 
          t1.ATUALIZACAO, 
          t1.STATUS, 
          t1.DESCRICAO, 
          t2.NR_RMS_PLST AS REMESSA, 
          t2.NR_LT_PLST AS LOTE, 
          t2.NR_SEQL_PLST AS SEQUENCIAL, 
          t2.NR_AR_TR AS AR, 
          t2.NR_PLST AS NR_PLST1, 
          t2.COD_ULTIMO_ESTADO, 
          t2.ULTIMO_ESTADO, 
          t2.DT_EST, 
          t2.DT_GERACAO, 
          t2.DT_EXPEDICAO, 
          t2.DT_ENTREGA_ESPECIAL, 
          t2.DT_EXTRAVIADO_DEVOLVIDO, 
          t2.DT_CONF_POSITIVA, 
          t2.DT_CONF_NEGATIVA, 
          t2.DT_DEVOLVIDO_CORREIO, 
          t2.DT_ENTREGUE_CLIENTE, 
          t2.DT_ATUALIZADO_BAT, 
          t2.DT_EXPED_JURISDICIONANTE, 
          t2.ATUALIZADO
      FROM WORK.CARTOES_CHIPAMENTO_2 t1
           LEFT JOIN work.TRACKING_CHIPAMENTO t2 ON (t1.NR_PLST = t2.NR_PLST)
           LEFT JOIN IGR.DEPENDENCIAS_&ANOMES. t3 ON (t1.Prefixo = INPUT(t3.PrefDep , 4.))
		   WHERE t3.SB = '00';
QUIT;


/***************************************/
/***************************************/
/***************************************/
/***************************************/


PROC SQL;
	CREATE TABLE WORK.BASE_CPF_ANT AS
	SELECT DISTINCT CPF, DATNASC
	FROM WORK.CARTOES_CHIPAMENTO_FINAL 
	WHERE CPF <> 0
	ORDER BY 1;
QUIT;


PROC SQL;
	CREATE TABLE work.BASE_MCI_ANT AS
	SELECT DISTINCT B.COD AS MCI, A.CPF, B.COD_TTDD_CPF, B.DTA_NASC_CSNT, A.DATNASC 
	FROM WORK.BASE_CPF_ANT A 
	INNER JOIN MCI.CLIENTE B ON (A.CPF = B.COD_CPF_CGC)
	GROUP BY 1, 2
    ORDER BY 1;
QUIT;


PROC SQL;
	CREATE TABLE WORK.BASE_MCI_2_ANT AS
	SELECT DISTINCT CPF, MIN(COD_TTDD_CPF) AS COD_TTDD_CPF
	FROM WORK.BASE_MCI_ANT 
	GROUP BY 1
    ORDER BY 1;
QUIT;


PROC SQL;
	CREATE TABLE WORK.BASE_MCI_3_ANT AS
	SELECT DISTINCT t1.CPF, t2.MCI, T1.COD_TTDD_CPF
	FROM WORK.BASE_MCI_2_ANT t1
	INNER JOIN work.BASE_MCI_ANT t2 ON (T1.CPF = T2.CPF AND T1.COD_TTDD_CPF = T2.COD_TTDD_CPF)
	GROUP BY 1,2
    ORDER BY 1;  
 QUIT;


 PROC SQL;
	CREATE TABLE WORK.BASE_MCI_4_ANT AS
	SELECT DISTINCT CPF, MCI, COUNT(COD_TTDD_CPF) AS CONTAGEM
	FROM WORK.BASE_MCI_3_ANT
	GROUP BY 1
    ORDER BY 1;  
 QUIT;


PROC SQL;
	CREATE TABLE WORK.BASE_MCI_5_ANT AS
	SELECT DISTINCT CPF, MCI
	FROM WORK.BASE_MCI_4_ANT
	WHERE CONTAGEM = 1
    ORDER BY 1;  
 QUIT;


PROC SQL;
   CREATE TABLE WORK.CARTOES_CHIPAMENTO_FINAL AS 
   SELECT t1.PrefDir,
          t1.PrefixoSuper,
          t1.PrefixoGerev,
          t1.PrefDep, 
          t1.UF, 
          t1.NomeMunicipioBB, 
          t1.Beneficio, 
		  t1.NR_PLST, 
          t1.PLASTICO, 
          t1.AgenciaCartao, 
          t1.DV_AgenciaCartao, 
          t1.NR_Conta, 
          t1.DV_Conta, 
          t1.Titular, 
          t1.Setex, 
          t1.NomeTitularCartao, 
          t1.CPF, 
          t1.DATNASC, 
          t1.DATEMSS, 
          t1.EMISSAO, 
          t1.DATVENC, 
          t1.VENCIMENTO, 
          t1.TIPCART, 
          t1.STACART, 
          t1.ATUALIZACAO, 
          t1.STATUS, 
          t1.DESCRICAO, 
          t1.REMESSA, 
          t1.LOTE, 
          t1.SEQUENCIAL, 
          t1.AR, 
          t1.NR_PLST1, 
          t1.COD_ULTIMO_ESTADO, 
          t1.ULTIMO_ESTADO, 
          t1.DT_EST, 
          t1.DT_GERACAO, 
          t1.DT_EXPEDICAO, 
          t1.DT_ENTREGA_ESPECIAL, 
          t1.DT_EXTRAVIADO_DEVOLVIDO, 
          t1.DT_CONF_POSITIVA, 
          t1.DT_CONF_NEGATIVA, 
          t1.DT_DEVOLVIDO_CORREIO, 
          t1.DT_ENTREGUE_CLIENTE, 
          t1.DT_ATUALIZADO_BAT, 
          t1.DT_EXPED_JURISDICIONANTE, 
          t1.ATUALIZADO,
          IFC(t3.MCI IS NOT MISSING, "Sim", "N�o") AS IND_BLOQ,
          IFC(t3.MCI IS NOT MISSING AND ULTIMO_ESTADO = 'ENTREGUE CLIENTE', "Sim", "N�o") AS IB_ENTREG


      FROM WORK.CARTOES_CHIPAMENTO_FINAL t1 
      LEFT JOIN WORK.BASE_MCI_5_ANT t2 ON (t1.CPF = t2.CPF)
	  LEFT JOIN CHIP.IND_BLOQ_XLSX t3 ON (t2.MCI = t3.MCI)

 
		   ;
QUIT;


data WORK.CARTOES_CHIPAMENTO_FINAL;
format posicao yymmdd10.;
set WORK.CARTOES_CHIPAMENTO_FINAL;
posicao = &D1;
run;


PROC SQL;
	CREATE TABLE WORK.CARTOES_CHIPAMENTO_FINAL_2 AS
	SELECT 
	posicao,
	PrefDep,
    1 as QTDE_TOTAL,
    IFN(ULTIMO_ESTADO = 'CONF. NEGATIVA', 1, 0) AS CONF_NEGATIVA,
	IFN(ULTIMO_ESTADO = 'CONF. POSITIVA', 1, 0) AS CONF_POSITIVA,
	IFN(ULTIMO_ESTADO = 'ENTREGUE CLIENTE', 1, 0) AS ENTREGUE_CLIENTE,
	IFN(ULTIMO_ESTADO = 'EXPED.JURIDISCIONANTE', 1, 0) AS EXPED_JURIDISCIONANTE,
	IFN(ULTIMO_ESTADO = 'EXPEDIDO', 1, 0) AS EXPEDIDO,
	IFN(ULTIMO_ESTADO = 'GERADO', 1, 0) AS GERADO,
	IFN(IND_BLOQ = 'Sim', 1, 0) AS IND_BLOQ,
	IFN(IB_ENTREG = 'Sim', 1, 0) AS IB_ENTREG

    FROM WORK.CARTOES_CHIPAMENTO_FINAL
    ORDER BY 1;
QUIT;


PROC SQL;
	CREATE TABLE WORK.CARTOES_CHIPAMENTO_FINAL_3 AS
	SELECT 
	posicao,
	PrefDep,
    QTDE_TOTAL,
    CONF_NEGATIVA,
	CONF_POSITIVA,
	ENTREGUE_CLIENTE,
	EXPED_JURIDISCIONANTE,
	EXPEDIDO,
	GERADO,
	IFN(CONF_NEGATIVA = 0 and CONF_POSITIVA = 0 and ENTREGUE_CLIENTE = 0 and EXPED_JURIDISCIONANTE = 0 and EXPEDIDO = 0 and GERADO = 0,1,0) as OUTRO_STATUS,
    IND_BLOQ,
    IB_ENTREG

    FROM WORK.CARTOES_CHIPAMENTO_FINAL_2
    ORDER BY 1;
QUIT;


PROC SQL;
   CREATE TABLE WORK.CARTOES_CHIPAMENTO_FINAL_4 AS 
   SELECT t1.posicao, 
          t1.PrefDep, 
            (SUM(t1.QTDE_TOTAL)) AS QTDE_TOTAL, 
            (SUM(t1.CONF_NEGATIVA)) AS CONF_NEGATIVA, 
            (SUM(t1.CONF_POSITIVA)) AS CONF_POSITIVA, 
            (SUM(t1.ENTREGUE_CLIENTE)) AS ENTREGUE_CLIENTE, 
            (SUM(t1.EXPED_JURIDISCIONANTE)) AS EXPED_JURIDISCIONANTE, 
            (SUM(t1.EXPEDIDO)) AS EXPEDIDO, 
            (SUM(t1.GERADO)) AS GERADO,
			(SUM(t1.OUTRO_STATUS)) AS OUTRO_STATUS,
			(SUM(t1.IND_BLOQ)) AS IND_BLOQ,
			(SUM(t1.IB_ENTREG)) AS IB_ENTREG

      FROM WORK.CARTOES_CHIPAMENTO_FINAL_3 t1
      GROUP BY t1.posicao,
               t1.PrefDep;
QUIT;


PROC SQL;
DROP TABLE COLUNAS_SUMARIZAR;
CREATE TABLE COLUNAS_SUMARIZAR (Coluna CHAR(50), Tipo CHAR(10));
INSERT INTO COLUNAS_SUMARIZAR VALUES ('QTDE_TOTAL', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('CONF_NEGATIVA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('CONF_POSITIVA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('ENTREGUE_CLIENTE', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('EXPED_JURIDISCIONANTE', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('EXPEDIDO', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('GERADO', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('OUTRO_STATUS', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('IND_BLOQ', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('IB_ENTREG', 'SUM');
QUIT;


%SumarizadorCNX( TblSASValores=CARTOES_CHIPAMENTO_FINAL_4,  TblSASColunas=COLUNAS_SUMARIZAR,  NivelCTRA=0,  PAA_PARA_AGENCIA=0,  TblSaida=CARTOES_CHIPAMENTO_FINAL_4, AAAAMM=&ANOMES.); 
 

PROC SQL;
   CREATE TABLE WORK.CARTOES_CHIPAMENTO_FINAL_5 AS 
   SELECT posicao, 
          PrefDep as prefixo, 
          QTDE_TOTAL, 
          CONF_NEGATIVA, 
          (CONF_POSITIVA + ENTREGUE_CLIENTE) as CONF_POSITIVA, 
          ENTREGUE_CLIENTE, 
          EXPED_JURIDISCIONANTE, 
          EXPEDIDO, 
          GERADO,
		  OUTRO_STATUS, 
		  (ENTREGUE_CLIENTE/(CONF_POSITIVA+ENTREGUE_CLIENTE))*100 AS ATINGIMENTO,
		  (CONF_POSITIVA) AS FALTA_ENTREGAR,
          IND_BLOQ,
		  IB_ENTREG
 
      FROM WORK.CARTOES_CHIPAMENTO_FINAL_4 t1
      GROUP BY t1.posicao,
               t1.PrefDep;
QUIT;


PROC STDIZE OUT=WORK.CARTOES_CHIPAMENTO_FINAL_5 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*detalhe*/
/*detalhe*/
/*detalhe*/
/*detalhe*/


PROC SQL;
	CREATE TABLE WORK.BASE_CPF AS
	SELECT DISTINCT CPF, DATNASC
	FROM WORK.CARTOES_CHIPAMENTO_FINAL 
	WHERE CPF <> 0
	ORDER BY 1;
QUIT;


PROC SQL;
	CREATE TABLE work.BASE_MCI AS
	SELECT DISTINCT B.COD AS MCI, A.CPF, B.COD_TTDD_CPF, B.DTA_NASC_CSNT, A.DATNASC 
	FROM WORK.BASE_CPF A 
	INNER JOIN MCI.CLIENTE B ON (A.CPF = B.COD_CPF_CGC)
	GROUP BY 1, 2
    ORDER BY 1;
QUIT;


PROC SQL;
	CREATE TABLE WORK.BASE_MCI_2 AS
	SELECT DISTINCT CPF, MIN(COD_TTDD_CPF) AS COD_TTDD_CPF
	FROM work.BASE_MCI 
	GROUP BY 1
    ORDER BY 1;
QUIT;


PROC SQL;
	CREATE TABLE WORK.BASE_MCI_3 AS
	SELECT DISTINCT t1.CPF, t2.MCI, T1.COD_TTDD_CPF
	FROM WORK.BASE_MCI_2 t1
	INNER JOIN work.BASE_MCI t2 ON (T1.CPF = T2.CPF AND T1.COD_TTDD_CPF = T2.COD_TTDD_CPF)
	GROUP BY 1,2
    ORDER BY 1;  
 QUIT;


 PROC SQL;
	CREATE TABLE WORK.BASE_MCI_4 AS
	SELECT DISTINCT CPF, MCI, COUNT(COD_TTDD_CPF) AS CONTAGEM
	FROM WORK.BASE_MCI_3
	GROUP BY 1
    ORDER BY 1;  
 QUIT;


PROC SQL;
	CREATE TABLE WORK.BASE_MCI_5 AS
	SELECT DISTINCT CPF, MCI
	FROM WORK.BASE_MCI_4
	WHERE CONTAGEM = 1
    ORDER BY 1;  
 QUIT;


PROC SQL;
   CREATE TABLE WORK.DETALHES AS 
   SELECT T1.PrefDep as prefixo, 
		  T1.NomeMunicipioBB AS MUNICIPIO, 
		  T1.UF, 
		  T1.NR_PLST AS NR_PLASTICO,
		  T2.MCI,
          T1.EMISSAO AS DT_EMISSAO,
          T1.VENCIMENTO AS DT_VENCIMENTO,
		  T1.DESCRICAO AS STATUS, 
		  T1.ULTIMO_ESTADO AS ESTADO, 
          T1.REMESSA, 
          T1.LOTE, 
          T1.SEQUENCIAL,
          T1.DT_GERACAO,
          T1.DT_EXPEDICAO, 
          IFC(T1.DT_CONF_POSITIVA >= '01JUL2018'd, PUT(T1.DT_CONF_POSITIVA, ddmmyy10.), "") AS DT_CONF_POSITIVA,
          IFN(t3.MCI IS NOT MISSING, 1, 0) AS IND_BLOQ
		  
          
     FROM WORK.CARTOES_CHIPAMENTO_FINAL T1
     LEFT JOIN WORK.BASE_MCI_5 T2 ON T1.CPF = T2.CPF
     LEFT JOIN CHIP.IND_BLOQ_XLSX t3 ON (t2.MCI = t3.MCI)
     GROUP BY 5;
QUIT;


PROC STDIZE OUT=WORK.DETALHES REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*rel 487*/
%LET Usuario=f7176219;
%LET Keypass=F7176219-chipamento-inss-kDxVUOkhFtIgTzFsvvLva8w3AX4aglrkEZTtwMXHwwQSVftFxQ;
%LET Rotina=chipamento-inss;
%ProcessoIniciar();


PROC SQL;
	DROP TABLE TABELAS_EXPORTAR_REL;
	CREATE TABLE TABELAS_EXPORTAR_REL (TABELA_SAS CHAR(100), ROTINA CHAR(100));
	INSERT INTO TABELAS_EXPORTAR_REL VALUES('WORK.CARTOES_CHIPAMENTO_FINAL_5', 'chipamento-inss');
	INSERT INTO TABELAS_EXPORTAR_REL VALUES('WORK.DETALHES', 'detalhe-inss');
QUIT;


%ProcessoCarregarEncerrar(TABELAS_EXPORTAR_REL);


x cd /dados/infor/producao/Dimep/chipamento_inss;
x chmod 2777 *;

/*************************************************/;
/* TRECHO DE C�DIGO INCLU�DO PELO FF */;

%include "/dados/gestao/rotinas/_macros/macros_uteis.sas";
 
%processCheckOut(
    uor_resp = 341556
    ,funci_resp = &sysuserid
    /*,tipo = Indicador
    ,sistema = Indicador
    ,rotina = I0123 Indicador de Alguma Coisa*/
    ,mailto= 'F8369937' 'F2986408' 'F6794004' 'F7176219' 'F8176496' 'F9457977' 'F9631159'
);