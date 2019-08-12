%include '/dados/infor/suporte/FuncoesInfor.sas';




x cd /;
x cd /dados/infor/producao/Ourocard_cidades;
x chmod -R 2777 *; /*ALTERAR PERMIS�ES*/
x chown f9457977 -R ./; /*FIXA O FUNCI*/
x chgrp -R GSASBPA ./; /*FIXA O GRUPO*/



LIBNAME CITY "/dados/infor/producao/Ourocard_cidades";
LIBNAME REN ORACLE USER=sas_gecen PASSWORD=Gecen77 PATH="sas_dirco" SCHEMA="ren";


/*CONTROLE DE DATAS*/

DATA _NULL_;
	DATA_INICIO = '01Aug2017'd;
	DATA_FIM = '30Dec2017'd;
	DATA_REFERENCIA = diaUtilAnterior(TODAY());
	MES_ATU = IFN((D1 <= DATA_FIM), Put(D1, yymmn6.), Put(DATA_FIM, yymmn6.));
	MES_ANT = Put(INTNX('month',primeiroDiaUtilMes(D1),-1), yymmn6.) ;
	MES_G = Put(DATA_REFERENCIA, MONTH.) ;
	ANOMES = IFN((D1 <= DATA_FIM), Put(D1, yymmn6.), Put(DATA_FIM, yymmn6.));
	DT_INICIO_SQL="'"||put(DATA_INICIO, YYMMDDD10.)||"'";
	DT_D1_SQL="'"||put(D1, YYMMDDD10.)||"'";
	DT_1DIA_MES_SQL="'"||put(primeiroDiaUtilMes(D1), YYMMDDD10.)||"'";
	DT_ANOMES_SQL=primeiroDiaUtilMes(D1);
	PRIMEIRO_DIA_MES_SQL="'"||put(primeiroDiaMes(DATA_REFERENCIA), YYMMDDD10.)||"'";
	DT_FIXA_SQL="'"||put(MDY(09,01,2017), YYMMDDD10.)||"'";

	CALL SYMPUT('DATA_HOJE',COMPRESS(TODAY(),' '));
	CALL SYMPUT('DT_1DIA_MES',COMPRESS(primeiroDiaUtilMes(D1),' '));
	CALL SYMPUT('DATA_INICIO',COMPRESS(DATA_INICIO,' '));
	CALL SYMPUT('DATA_FIM',COMPRESS(DATA_FIM,' '));
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
	CALL SYMPUT('MES_G', COMPRESS(MES_G,' '));
	CALL SYMPUT('PRIMEIRO_DIA_MES_SQL', COMPRESS(PRIMEIRO_DIA_MES_SQL,' '));
	CALL SYMPUT('DT_FIXA_SQL', COMPRESS(DT_FIXA_SQL,' '));
RUN;



PROC SQL;
   CREATE TABLE WORK.CART_GOV AS 
   SELECT DISTINCT t1.CD_CLI, 
          t1.CD_PRF_DEPE, 
          T1.NR_SEQL_CTRA
      FROM COMUM.ENCARTEIRAMENTO_CONEXAO t1
	WHERE t1.cd_prf_depe IN(40,242,293,913,1040,1070,1075,1087,1119,1448,1449,1654,1758,2242,2416,2449,2614,2616,2771,4100,4176,4187,4481,4490,8267)
;
QUIT;


PROC SQL;
   CREATE TABLE  CESTA_DIGOV_AUG AS 
   SELECT DISTINCT
		t1.MCI, 
		t1.ano,
		t1.mes,
		t1.PRF_CAD as Prefdep
		sum(t1.VL_RSTD_GRNL) as VL_RSTD_GRNL
      FROM REN.VW_MCI_REN_DET_MST_DIGOV t1
      	WHERE prf_cad in (40,242,293,913,1040,1070,1075,1087,1119,1448,1449,1654,1758,2242,2416,2449,2614,2616,2771,4100,4176,4187,4481,4490,8267)
and t1.PRD IN (9,16,29,126,127,300,352,381,528,950,951,954) 
					 AND t1.NTZ_JURIDICA IN (9,36) 
					 AND t1.ANO = 2017 
					 AND t1.MES = 08
	group by 1,2,3,4;
QUIT;




PROC SQL;
   CREATE TABLE  CESTA_DIGOV_ATUAL AS 
   SELECT DISTINCT
		t1.MCI, 
		t1.ano,
		t1.mes,
		t1.PRF_CAD as Prefdep, 
		sum(t1.VL_RSTD_GRNL) as VL_RSTD_GRNL
      FROM REN.VW_MCI_REN_DET_MST_DIGOV t1
      	WHERE T1.PRF_CAD IN (40,242,293,913,1040,1070,1075,1087,1119,1448,1449,1654,1758,2242,2416,2449,2614,2616,2771,4100,4176,4187,4481,4490,8267)
AND t1.PRD IN (9,16,29,126,127,300,352,381,528,950,951,954) 
					 AND t1.NTZ_JURIDICA IN (9,36) 
					 AND t1.ANO = 2017 
					 AND t1.MES >= 09
	group by 1,2,3,4;
QUIT;



DATA CESTA;
MERGE CESTA_DIGOV_AUG CESTA_DIGOV_ATUAL;
BY MCI ANO;
RUN;



PROC SQL;
   CREATE TABLE CITY.CESTA_DIGOV_&ANOMES AS 
   SELECT 
&DATA_HOJE. FORMAT=DateMysql. as POSICAO,    
		t1.MCI, 
		t1.ano,
		t1.mes,
		t1.Prefdep, 
		t2.carteira,  
		t1.VL_RSTD_GRNL
	FROM CESTA t1
	INNER JOIN CART_GOV T2 ON (MCI=CD_CLI AND PREFDEP=CD_PRF_DEPE AND CARTEIRA=NR_SEQL_CTRA)
	;QUIT;



x cd /;
x cd /dados/infor/producao/Ourocard_cidades;
x chmod -R 2777 *; /*ALTERAR PERMIS�ES*/
x chown f9457977 -R ./; /*FIXA O FUNCI*/
x chgrp -R GSASBPA ./; /*FIXA O GRUPO*/

