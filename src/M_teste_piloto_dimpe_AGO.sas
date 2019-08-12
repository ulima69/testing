
%INCLUDE '/dados/infor/suporte/FuncoesInfor.sas';


DATA _NULL_;
   
    	
    DATA_INICIO = '01Jan2017'd;
	DATA_FIM = '30Dec2018'd;
	DATA_REFERENCIA = diaUtilAnterior(TODAY());
	D1 = diaUtilAnterior(TODAY());
	D2 = diaUtilAnterior(D1);
	D3 = diaUtilAnterior(D2);
	MES_ATU = IFN((D1 <= DATA_FIM), Put(D1, yymmn6.), Put(DATA_FIM, yymmn6.));
	MES_ANT = Put(INTNX('month',primeiroDiaUtilMes(D1),-1), yymmn6.) ;
	MES_G = Put(DATA_REFERENCIA, MONTH.);
	ANOMES = IFN((D1 <= DATA_FIM), Put(D1, yymmn6.), Put(DATA_FIM, yymmn6.));
	DT_INICIO_SQL="'"||put(DATA_INICIO, YYMMDDD10.)||"'";
	DT_D1_SQL="'"||put(D1, YYMMDDD10.)||"'";
	DT_1DIA_MES_SQL="'"||put(primeiroDiaUtilMes(D1), YYMMDDD10.)||"'";
	DT_ANOMES_SQL=primeiroDiaUtilMes(D1);
	PRIMEIRO_DIA_MES_SQL="'"||put(primeiroDiaMes(DATA_REFERENCIA), YYMMDDD10.)||"'";
    MMAAAA=PUT(D1,mmyyn6.);
	MES_G_2 = Put(MONTH (DATA_REFERENCIA) - 1, Z2.);
	
    
	CALL SYMPUT('DATA_HOJE',COMPRESS(TODAY(),' '));
	CALL SYMPUT('DT_1DIA_MES',COMPRESS(primeiroDiaUtilMes(D1),' '));
	CALL SYMPUT('DATA_INICIO',COMPRESS(DATA_INICIO,' '));
	CALL SYMPUT('DATA_FIM',COMPRESS(DATA_FIM,' '));
	CALL SYMPUT('D1',COMPRESS(D1,' '));
	CALL SYMPUT('D2',COMPRESS(D2,' '));
	CALL SYMPUT('D3',COMPRESS(D3,' '));
	CALL SYMPUT('MES_ATU',COMPRESS(MES_ATU,' '));
	CALL SYMPUT('MES_ANT',COMPRESS(MES_ANT,' '));
	CALL SYMPUT('ANOMES',COMPRESS(ANOMES,' '));
	CALL SYMPUT('RF',COMPRESS(ANOMES,' '));
	CALL SYMPUT('DT_ARQUIVO',put(DATA_REFERENCIA, DDMMYY10.));
	CALL SYMPUT('DT_ARQUIVO_SQL',put(DATA_REFERENCIA, YYMMDDD10.));
	CALL SYMPUT('DT_INICIO_SQL', COMPRESS(DT_INICIO_SQL,' '));
	CALL SYMPUT('DT_1DIA_MES_SQL', COMPRESS(DT_1DIA_MES_SQL,' '));
	CALL SYMPUT('DT_D1_SQL', COMPRESS(DT_D1_SQL,' '));
	CALL SYMPUT('DT_ANOMES_SQL', COMPRESS(DT_ANOMES_SQL,' '));
	CALL SYMPUT('PRIMEIRO_DIA_MES_SQL', COMPRESS(PRIMEIRO_DIA_MES_SQL,' '));
	CALL SYMPUT('MMAAAA', COMPRESS(MMAAAA,' '));

	CALL SYMPUT('MES_G', COMPRESS(MES_G_2,' '));
    CALL SYMPUT('MES_G_2', COMPRESS(MES_G_2,' '));
	 
RUN;

%PUT &MES_G_2;

%PUT &MES_G;

libname PRF '/dados/infor/producao/Piloto_MPE';

LIBNAME ATB DB2 DATABASE=BDB2P04 SCHEMA=DB2ATB AUTHDOMAIN=DB2SGCEN;

libname CBR '/dados/infor/conexao/2018/000000067';
libname CBR_QUA '/dados/infor/conexao/2018/000000118';
libname TRF '/dados/infor/conexao/2018/000000109';
libname DES '/dados/infor/conexao/2018/000000004';
libname SALDO '/dados/infor/conexao/2018/000000007';
libname I30 '/dados/infor/conexao/2018/000000112';

/*RESTRINGINDO AS TABELAS DO CONEX�O*/

PROC SQL;
CREATE TABLE CBR_1 AS
SELECT * FROM CBR.INDICADOR_000000067
WHERE CTRA not equals 0 AND COMP = 0;
QUIT;


PROC STDIZE DATA=CBR_1 OUT=CBR_1 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE CBR_QUA_1 AS
SELECT * FROM CBR_QUA.INDICADOR_000000118
WHERE CTRA not equals 0 AND COMP = 0;
QUIT;


PROC STDIZE DATA=CBR_QUA_1 OUT=CBR_QUA_1 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE TRF_1 AS
SELECT * FROM TRF.INDICADOR_000000109
WHERE CTRA not equals 0 AND COMP = 0;
QUIT;


PROC STDIZE DATA=TRF_1 OUT=TRF_1 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE DES_1 AS
SELECT * FROM DES.INDICADOR_000000004
WHERE CTRA not equals 0 AND COMP = 0;
QUIT;


PROC STDIZE DATA=DES_1 OUT=DES_1 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE SALDO_1 AS
SELECT * FROM SALDO.INDICADOR_000000007
WHERE CTRA not equals 0 AND COMP = 0;
QUIT;


PROC STDIZE DATA=SALDO_1 OUT=SALDO_1 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE I30_1 AS
SELECT * FROM I30.INDICADOR_000000112
WHERE CTRA not equals 0 AND COMP = 0;
QUIT;


PROC STDIZE DATA=I30_1 OUT=I30_1 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*FIM DA RESTRI��O DAS TABELAS DO CONEX�O*/



/*ORIGEM DB2ATB*/

/*N�o Utilizado*/
PROC SQL;
   CREATE TABLE MARGEM AS 
   SELECT *
      FROM ATB.VL_APRD_IN_UOR t1
     WHERE CD_IN_MOD_AVLC = 11699 AND MM_VL_APRD_IN = &MES_G. AND AA_VL_APRD_IN = 2018;
QUIT;


PROC STDIZE DATA=MARGEM OUT=MARGEM REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
   CREATE TABLE MARGEM_CTRA AS 
   SELECT *
      FROM ATB.VL_APRD_IN_CTRA t1
     WHERE CD_IN_MOD_AVLC = 11702 AND MM_VL_APRD_IN = &MES_G. AND AA_VL_APRD_IN = 2018;
QUIT;


PROC STDIZE DATA=MARGEM_CTRA OUT=MARGEM_CTRA REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;

/*N�o Utilizado*/
PROC SQL;
   CREATE TABLE I90 AS 
   SELECT *
      FROM ATB.VL_APRD_IN_UOR t1
     WHERE CD_IN_MOD_AVLC = 11715 AND MM_VL_APRD_IN = &MES_G. AND AA_VL_APRD_IN = 2018;
QUIT;


PROC STDIZE DATA=I90 OUT=I90 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
   CREATE TABLE I90_CTRA AS 
   SELECT *
      FROM ATB.VL_APRD_IN_CTRA t1
     WHERE CD_IN_MOD_AVLC = 11717 AND MM_VL_APRD_IN = &MES_G. AND AA_VL_APRD_IN = 2018;
QUIT;


PROC STDIZE DATA=I90_CTRA OUT=I90_CTRA REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;

/*N�o Utilizado*/
PROC SQL;
   CREATE TABLE AVALIACAO AS 
   SELECT *
      FROM ATB.VL_APRD_IN_UOR t1
     WHERE CD_IN_MOD_AVLC = 11759 AND MM_VL_APRD_IN = &MES_G. AND AA_VL_APRD_IN = 2018;
QUIT;


PROC STDIZE DATA=AVALIACAO OUT=AVALIACAO REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
   CREATE TABLE AVALIACAO_CTRA AS 
   SELECT *
      FROM ATB.VL_APRD_IN_CTRA t1
     WHERE CD_IN_MOD_AVLC = 11765 AND MM_VL_APRD_IN = &MES_G. AND AA_VL_APRD_IN = 2018;
QUIT;


PROC STDIZE DATA=AVALIACAO_CTRA OUT=AVALIACAO_CTRA REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.PRF_UOR AS 
SELECT INPUT(UOR,9.) AS UOR, INPUT(PrefDep,4.) AS PrefDep FROM IGR.IGRREDE_2018&MES_G_2.;
QUIT; 


PROC STDIZE DATA=PRF.PRF_UOR OUT=PRF.PRF_UOR REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*Piloto - base*/

/*Agrupando DB2ATB no Piloto*/

/*TRAZENDO A UOR PARA A TABELA*/

PROC SQL;
CREATE TABLE PRF.base AS 
SELECT * FROM PRF.piloto_plataformas_origem t1
LEFT JOIN  PRF.PRF_UOR t2
ON t1.CD_PRF_DEPE = t2.PrefDep;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.Diretoria AS DIR, t1.SUPER, t1.CD_PRF_DEPE as DEPE, t1.UOR AS UOR_DEPE, t1.CD_TIP_CTRA AS TIP_CTRA, t1.NR_SEQL_CTRA AS CTRA, t1.QT_CLI_CTRA,
t2.VL_RLZD_IN AS VALOR_MARGEM_CTRA
FROM  PRF.base t1
LEFT JOIN MARGEM_CTRA t2
ON t1.UOR = t2.CD_UOR_CTRA and t1.NR_SEQL_CTRA = t2.NR_SEQL_CTRA;
QUIT; 


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.DIR, t1.SUPER, t1.DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.QT_CLI_CTRA, t1.VALOR_MARGEM_CTRA, t2.VL_RLZD_IN AS VALOR_I90_CTRA
FROM  PRF.base t1
LEFT JOIN I90_CTRA t2
ON t1.UOR_DEPE = t2.CD_UOR_CTRA and t1.CTRA = t2.NR_SEQL_CTRA;
QUIT;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.DIR, t1.SUPER, t1.DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.QT_CLI_CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, t2.VL_RLZD_IN AS VALOR_AVA_CTRA
FROM  PRF.base t1
LEFT JOIN AVALIACAO_CTRA t2
ON t1.UOR_DEPE = t2.CD_UOR_CTRA and t1.CTRA = t2.NR_SEQL_CTRA;
QUIT;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*Agrupando Conex�o no Piloto*/ 


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.DIR, t1.SUPER, t1.DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.QT_CLI_CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, 
t2.RM&MES_G_2. as VALOR_CBR_CTRA 
FROM  PRF.base t1
LEFT JOIN CBR_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.DIR, t1.SUPER, t1.DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.QT_CLI_CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, VALOR_CBR_CTRA, 
t2.RM&MES_G_2. as VALOR_TRF_CTRA
FROM  PRF.base t1
LEFT JOIN TRF_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.DIR, t1.SUPER, t1.DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.QT_CLI_CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, VALOR_CBR_CTRA, 
VALOR_TRF_CTRA, t2.RM&MES_G_2. as VALOR_DES_CTRA
FROM  PRF.base t1
LEFT JOIN DES_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.DIR, t1.SUPER, t1.DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.QT_CLI_CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, VALOR_CBR_CTRA, 
VALOR_TRF_CTRA, VALOR_DES_CTRA, t2.RM&MES_G_2. as VALOR_SALDO_CTRA
FROM  PRF.base t1
LEFT JOIN SALDO_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.DIR, t1.SUPER, t1.DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.QT_CLI_CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, VALOR_CBR_CTRA, 
VALOR_TRF_CTRA, VALOR_DES_CTRA, VALOR_SALDO_CTRA, t2.RM&MES_G_2. as VALOR_I30_CTRA
FROM  PRF.base t1
LEFT JOIN I30_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT t1.DIR, t1.SUPER, t1.DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.QT_CLI_CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, VALOR_CBR_CTRA, 
VALOR_TRF_CTRA, VALOR_DES_CTRA, VALOR_SALDO_CTRA, VALOR_I30_CTRA, t2.RM&MES_G_2. as VALOR_CBR_QUA_CTRA
FROM  PRF.base t1
LEFT JOIN CBR_QUA_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base OUT=PRF.base REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


data PRF.base;
format posicao yymmdd10.;
set PRF.base;
posicao = '31aug2018'd;
run;


PROC SQL;
CREATE TABLE PRF.base AS 
SELECT posicao as POSICAO, DEPE AS PREFDEP, CTRA, VALOR_MARGEM_CTRA, VALOR_I90_CTRA, VALOR_AVA_CTRA, VALOR_CBR_CTRA, VALOR_CBR_QUA_CTRA, VALOR_TRF_CTRA, 
VALOR_DES_CTRA, VALOR_SALDO_CTRA, VALOR_I30_CTRA 
FROM  PRF.base;
QUIT;


/*TABELA COLUNAS PARA FUNCAO SUMARIZACAO*/

PROC SQL;
DROP TABLE COLUNAS_SUMARIZAR;
CREATE TABLE COLUNAS_SUMARIZAR (Coluna CHAR(50), Tipo CHAR(10));
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_MARGEM_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_I90_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_AVA_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_CBR_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_CBR_QUA_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_TRF_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_DES_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_SALDO_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_I30_CTRA', 'SUM');
QUIT;


/*FUNCAO DE SUMARIZACAO*/ 

%SumarizadorCNX( TblSASValores=PRF.base,  TblSASColunas=COLUNAS_SUMARIZAR,  NivelCTRA=1,  PAA_PARA_AGENCIA=1,  TblSaida=PRF.base_SUM, AAAAMM=&ANOMES.); 
 

PROC STDIZE DATA=PRF.base_sum OUT=PRF.base_sum REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_sum AS 
SELECT POSICAO, PREFDEP, CTRA, VALOR_MARGEM_CTRA AS VALOR_MARGEM_CTRA_AGO, VALOR_CBR_CTRA AS VALOR_CBR_CTRA_AGO, VALOR_CBR_QUA_CTRA AS VALOR_CBR_QUA_CTRA_AGO,
VALOR_TRF_CTRA AS VALOR_TRF_CTRA_AGO, VALOR_DES_CTRA AS VALOR_DES_CTRA_AGO, VALOR_SALDO_CTRA AS VALOR_SALDO_CTRA_AGO, VALOR_I30_CTRA AS VALOR_I30_CTRA_AGO, VALOR_I90_CTRA, 
VALOR_AVA_CTRA AS VALOR_AVA_CTRA_AGO
FROM  PRF.base_sum;
QUIT;



PROC STDIZE DATA=PRF.base_sum OUT=PRF.base_sum REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*******************************************************************************************************/


/*CONTROLE*/

/*Agrupando DB2ATB no controle base_2*/

/*TRAZENDO A UOR PARA A TABELA*/
PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT * FROM PRF.grupo_controle_prefixos t1
LEFT JOIN  PRF.PRF_UOR t2
ON t1.CD_PRF_DEPE = t2.PrefDep;


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.Diretoria AS DIR, t1.SUPER, t1.GEREV, t1.CD_PRF_DEPE as DEPE, t1.NM_DEPE, t1.UOR AS UOR_DEPE, t1.CD_TIP_CTRA AS TIP_CTRA, t1.NR_SEQL_CTRA AS CTRA, 
t2.VL_RLZD_IN AS VALOR_MARGEM_CTRA
FROM  PRF.base_2 t1
LEFT JOIN MARGEM_CTRA t2
ON t1.UOR = t2.CD_UOR_CTRA and t1.NR_SEQL_CTRA = t2.NR_SEQL_CTRA;
QUIT; 


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.DIR, t1.SUPER, t1.GEREV, t1.DEPE, t1.NM_DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.VALOR_MARGEM_CTRA, t2.VL_RLZD_IN AS VALOR_I90_CTRA
FROM  PRF.base_2 t1
LEFT JOIN I90_CTRA t2
ON t1.UOR_DEPE = t2.CD_UOR_CTRA and t1.CTRA = t2.NR_SEQL_CTRA;
QUIT; 


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.DIR, t1.SUPER, t1.GEREV, t1.DEPE, t1.NM_DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.VALOR_MARGEM_CTRA, t1.VALOR_I90_CTRA, 
t2.VL_RLZD_IN AS VALOR_AVA_CTRA
FROM  PRF.base_2 t1
LEFT JOIN AVALIACAO_CTRA t2
ON t1.UOR_DEPE = t2.CD_UOR_CTRA and t1.CTRA = t2.NR_SEQL_CTRA;
QUIT; 


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*Agrupando Conex�o no CONTROLE*/ 


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.DIR, t1.SUPER, t1.GEREV, t1.DEPE, t1.NM_DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, 
t2.RM&MES_G_2. as VALOR_CBR_CTRA 
FROM  PRF.base_2 t1
LEFT JOIN CBR_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.DIR, t1.SUPER, t1.GEREV, t1.DEPE, t1.NM_DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, 
t1.VALOR_CBR_CTRA, t2.RM&MES_G_2. as VALOR_TRF_CTRA 
FROM  PRF.base_2 t1
LEFT JOIN TRF_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.DIR, t1.SUPER, t1.GEREV, t1.DEPE, t1.NM_DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, 
t1.VALOR_CBR_CTRA, t1.VALOR_TRF_CTRA, t2.RM&MES_G_2. as VALOR_DES_CTRA 
FROM  PRF.base_2 t1
LEFT JOIN DES_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.DIR, t1.SUPER, t1.GEREV, t1.DEPE, t1.NM_DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, 
t1.VALOR_CBR_CTRA, t1.VALOR_TRF_CTRA, t1.VALOR_DES_CTRA, t2.RM&MES_G_2. as VALOR_SALDO_CTRA 
FROM  PRF.base_2 t1
LEFT JOIN SALDO_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.DIR, t1.SUPER, t1.GEREV, t1.DEPE, t1.NM_DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, 
t1.VALOR_CBR_CTRA, t1.VALOR_TRF_CTRA, t1.VALOR_DES_CTRA, t1.VALOR_SALDO_CTRA, t2.RM&MES_G_2. as VALOR_I30_CTRA 
FROM  PRF.base_2 t1
LEFT JOIN I30_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT t1.DIR, t1.SUPER, t1.GEREV, t1.DEPE, t1.NM_DEPE, t1.UOR_DEPE, t1.TIP_CTRA, t1.CTRA, t1.VALOR_MARGEM_CTRA, T1.VALOR_I90_CTRA, T1.VALOR_AVA_CTRA, 
t1.VALOR_CBR_CTRA, t1.VALOR_TRF_CTRA, t1.VALOR_DES_CTRA, t1.VALOR_SALDO_CTRA, t1.VALOR_I30_CTRA, t2.RM&MES_G_2. as VALOR_CBR_QUA_CTRA 
FROM  PRF.base_2 t1
LEFT JOIN CBR_QUA_1 t2
ON t1.DEPE = t2.PREFDEP and t1.CTRA = t2.CTRA;
QUIT;


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


data PRF.base_2;
format posicao yymmdd10.;
set PRF.base_2;
posicao = '31aug2018'd;
run;


PROC SQL;
CREATE TABLE PRF.base_2 AS 
SELECT posicao AS POSICAO, DEPE AS PREFDEP, CTRA, VALOR_MARGEM_CTRA, VALOR_I90_CTRA, VALOR_AVA_CTRA, VALOR_CBR_CTRA, VALOR_CBR_QUA_CTRA, 
VALOR_TRF_CTRA, VALOR_DES_CTRA, VALOR_SALDO_CTRA, VALOR_I30_CTRA
FROM  PRF.base_2;
QUIT;


PROC STDIZE DATA=PRF.base_2 OUT=PRF.base_2 REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*TABELA COLUNAS PARA FUNCAO SUMARIZACAO*/

PROC SQL;
DROP TABLE COLUNAS_SUMARIZAR;
CREATE TABLE COLUNAS_SUMARIZAR (Coluna CHAR(50), Tipo CHAR(10));
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_MARGEM_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_I90_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_AVA_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_CBR_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_CBR_QUA_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_TRF_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_DES_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_SALDO_CTRA', 'SUM');
INSERT INTO COLUNAS_SUMARIZAR VALUES ('VALOR_I30_CTRA', 'SUM');
QUIT;


/*FUNCAO DE SUMARIZACAO*/ 

%SumarizadorCNX( TblSASValores=PRF.base_2,  TblSASColunas=COLUNAS_SUMARIZAR,  NivelCTRA=1,  PAA_PARA_AGENCIA=1,  TblSaida=PRF.base_2_SUM, AAAAMM=&ANOMES.); 
 

PROC STDIZE DATA=PRF.base_2_sum OUT=PRF.base_2_sum REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


PROC SQL;
CREATE TABLE PRF.base_2_sum AS 
SELECT POSICAO, PREFDEP, CTRA, VALOR_MARGEM_CTRA AS VALOR_MARGEM_CTRA_AGO, VALOR_CBR_CTRA AS VALOR_CBR_CTRA_AGO, VALOR_CBR_QUA_CTRA AS VALOR_CBR_QUA_CTRA_AGO,
VALOR_TRF_CTRA AS VALOR_TRF_CTRA_AGO, VALOR_DES_CTRA AS VALOR_DES_CTRA_AGO, VALOR_SALDO_CTRA AS VALOR_SALDO_CTRA_AGO, VALOR_I30_CTRA AS VALOR_I30_CTRA_AGO, VALOR_I90_CTRA, 
VALOR_AVA_CTRA AS VALOR_AVA_CTRA_AGO
FROM  PRF.base_2_sum;
QUIT;


PROC STDIZE DATA=PRF.base_2_sum OUT=PRF.base_2_sum REPONLY MISSING=0;
	VAR _NUMERIC_;
QUIT;


/*FIM CONTROLE*/
/***********************************************/



/*Relat�rio 445 - Piloto*/
/************** INICIAR PROCESSO ****************/
%LET Usuario=f7176219;
%LET Keypass=wEoVL8vOJh3itAMwl2qkyBaLKkiubvVtWsKNpuzdFRjGVg75Pe;
%LET Rotina=rel-piloto-dimpe-ago;
%ProcessoIniciar();
/************************************************/



/*Relat�rio 445 - Piloto*/
/*EXPORTAR REL*/
/*#################################################################################################################*/

/*TABELA AUXILIAR DE TABELAS DE CARGA E ROTINAS DO SISTEMA REL*/
PROC SQL;
	DROP TABLE TABELAS_EXPORTAR_REL;
	CREATE TABLE TABELAS_EXPORTAR_REL (TABELA_SAS CHAR(100), ROTINA CHAR(100));
	INSERT INTO TABELAS_EXPORTAR_REL VALUES('prf.base_sum', 'rel-piloto-dimpe-ago');
   ;
QUIT;

%ProcessoCarregarEncerrar(TABELAS_EXPORTAR_REL);

/*#################################################################################################################*/




/*Relat�rio  - Piloto*/
/************** INICIAR PROCESSO **************
%LET Usuario=f7176219;
%LET Keypass=UwGDaqQEWR6PWsjWnpLtylsbpqxIBut327T0OCsmkx1JepFTSu;
%LET Rotina=rel-controle-piloto-dimpe-ago;
%ProcessoIniciar();
/***********************************************/


/*Relat�rio  - Piloto*/
/*#################################################################################################################*/

/*TABELA AUXILIAR DE TABELAS DE CARGA E ROTINAS DO SISTEMA REL
PROC SQL;
	DROP TABLE TABELAS_EXPORTAR_REL_1;
	CREATE TABLE TABELAS_EXPORTAR_REL_1 (TABELA_SAS CHAR(100), ROTINA CHAR(100));
	INSERT INTO TABELAS_EXPORTAR_REL_1 VALUES('prf.base_2_sum', 'rel-controle-piloto-dimpe-ago');
   ;
QUIT;

%ProcessoCarregarEncerrar(TABELAS_EXPORTAR_REL_1);

*/


x cd /dados/infor/producao/Piloto_MPE;
x chmod 2777 *;
