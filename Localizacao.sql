/*Caros,
                                                               cobrancas
Favor retornar os itens de mensalidade principal que estão em Titilos  emitidas e lançamentos Futuros, para os contratos da planilha anexa.
 Retornar os seguintes campos

•  COD_OPERADORA
•  ID_ITEM_EXTRATO
•  DESCRICAO_ITEM_EXTRATO
•  ID_PONTO
•  TIPO_PONTO
•  VALOR DO ITEM
•  OBS_PROPORCIONALIDADE
•  DT_VENCTO DO CONTRATO
•  NOME_PRODUTO
•  ID_PRODUTO*/
--cobrança nao emitida id = 10--PAGAMENTO EM ABERTO JA FOI EMITIDA


DECLARE

  V_CHAMADO      VARCHAR2(1000)   := '9557403' ;    -- NÃºmero do chamado
  VNM_ARQ        VARCHAR2(1000)   := 'PLANILHA_023.csv'; -- Nome da carga
  
  VFILEARQ       UTL_FILE.FILE_TYPE;
  V_FILE_OUT     UTL_FILE.FILE_TYPE;
  TYPE T_VET_RETORNO IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  VETOR          T_VET_RETORNO;  
  VLINHA         VARCHAR2(25000);
  V_ID_PRODUTO   PROD_JD.SN_PRODUTO.ID_PRODUTO%TYPE;
  V_ACHOU        NUMBER;
  V_PRECO        VARCHAR(100);
  V_DESCONTO     VARCHAR(100);
  V_BASE         VARCHAR2(10);
  V_ENCONTROU    NUMBER;  
  V_CID_CONTRATO SN_CIDADE_OPERADORA.CID_CONTRATO%TYPE;
  CONTRATO VARCHAR (50);
  PROPORCIONALIDADE   VARCHAR(500);
  V_VLR_TOTAL    PROD_JD.SN_COBRANCA.VLR_TOTAL%TYPE;
  V_NUM_CONTRATO     PROD_JD.SN_CONTRATO.NUM_CONTRATO%TYPE;

  FUNCTION DIR_GEF RETURN VARCHAR2 AS
    PPARAMETRO SN_PARAMETRO.VLR_PARAMETRO_STR%TYPE;--
    
    BEGIN
      SELECT VLR_PARAMETRO_STR
        INTO PPARAMETRO
        FROM SN_PARAMETRO
       WHERE NOME_PARAMETRO = 'DIR_EDS_GEF'
         AND ROWNUM = 1;
    
      RETURN PPARAMETRO;
    END;




  FUNCTION NOME_BASE RETURN VARCHAR2 AS
    PPARAMETRO SN_PARAMETRO.VLR_PARAMETRO_STR%TYPE;
    
    BEGIN
      SELECT VLR_PARAMETRO_STR
        INTO PPARAMETRO
        FROM SN_PARAMETRO
       WHERE NOME_PARAMETRO = 'NOME_BASE'
         AND ROWNUM = 1;
  
    RETURN PPARAMETRO;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT GLOBAL_NAME INTO PPARAMETRO FROM GLOBAL_NAME;
      RETURN PPARAMETRO;
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'ERRO BUSCA NOME BASE. ' || SQLERRM);
  END;

  PROCEDURE MONTA_VETOR(P_CARACTER  IN VARCHAR2,
                        P_STRING    IN VARCHAR2,
                        VET_RETORNO OUT T_VET_RETORNO) IS
    V_DS_RESTO VARCHAR2(32000);
    V_COUNT    NUMBER;
  BEGIN
    V_DS_RESTO := P_STRING;
    V_COUNT    := 0;
    VET_RETORNO.DELETE;
    WHILE V_DS_RESTO IS NOT NULL LOOP
      V_COUNT := V_COUNT + 1;
      IF INSTR(V_DS_RESTO, P_CARACTER) > 0 THEN
        VET_RETORNO(V_COUNT) := SUBSTR(V_DS_RESTO,
                                       1,
                                       (INSTR(V_DS_RESTO, P_CARACTER) - 1));
        V_DS_RESTO := SUBSTR(V_DS_RESTO,
                             (INSTR(V_DS_RESTO, P_CARACTER) + 1));
      ELSE
        VET_RETORNO(V_COUNT) := V_DS_RESTO;
        EXIT;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('ERRO MONTA VETOR: ' || P_STRING || ' - ' ||
                           SQLERRM);
    
  END MONTA_VETOR;
  
  FUNCTION IDENTIFICA_BASE RETURN VARCHAR2 IS

    VBASE         VARCHAR2(10);
    
    BEGIN
      SELECT DECODE (GLOBAL_NAME ,'BHPR.NET' ,'BHZ' -- UMA FUNÇAO QUE INDENTIFICA AS BASES
                     ,'DB09'     ,'BRA'
                     ,'ISP.NET'  ,'ISP'
                     ,'DB09S.NET','SOC'
                     ,'SPO'      ,'SPO'
                     ,'SUL.NET'  ,'SUL'
                     ,'ABC.NET'  ,'BRI'
                           ,'TESTE') AS BASE
     INTO VBASE
     FROM GLOBAL_NAME;

      RETURN VBASE;
    END IDENTIFICA_BASE;  
    
    
 --   
  FUNCTION BUSCA_PROPOR(FID_ITEM_EXTRATO IN PROD_JD.SN_ITEM_PROPORCIONALIDADE.ID_ITEM_EXTRATO%TYPE)
    RETURN VARCHAR2 AS
    PMSG PROD_JD.SN_ITEM_PROPORCIONALIDADE.MSG%TYPE;
  
  BEGIN
    SELECT IP.MSG
      INTO PMSG
      FROM PROD_JD.SN_ITEM_PROPORCIONALIDADE IP
     WHERE IP.ID_ITEM_EXTRATO = FID_ITEM_EXTRATO;
    RETURN PMSG;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      PMSG := 'ITEM SEM PROPORCIONALIDADE';
      RETURN PMSG;
  END;



BEGIN
  BEGIN

      V_BASE  := IDENTIFICA_BASE;
      V_FILE_OUT := UTL_FILE.FOPEN('/u04',V_BASE ||'_EXTR_'||V_CHAMADO||'_ITENS_MENS_PRINCIPAL.csv','W');
      UTL_FILE.PUT_LINE(V_FILE_OUT,'COD_OPERADORA;NUM_CONTRATO;VALOR;ID_ITEM_EXTRATO;DESCRICAO_ITEM_MENS_PRINCIPAL;ID_PONTO;DT_VENCTO_CONTRATO;ID_PRODUTO;DESCRICAO_DO_PRODUTO;PROPORCIONALIDADE;TIPO_PONTO;OBS');
    
     
    

      VFILEARQ := UTL_FILE.FOPEN(LOCATION  =>'/u04',
                                 FILENAME  => VNM_ARQ,
                                 OPEN_MODE => 'R');--marcando qual a variavel de dentro da funcao que vai receber os parametros
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('ERROR OPEN FILE: ' || VNM_ARQ || ' - ' ||
                               SQLERRM);
          RAISE_APPLICATION_ERROR(-20002,
                                  'ERROR OPEN FILE: ' || VNM_ARQ || ' - ' ||
                                  SQLERRM);
    
  END;

  LOOP
    BEGIN
      UTL_FILE.GET_LINE(VFILEARQ, VLINHA);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        UTL_FILE.FCLOSE(VFILEARQ);
        EXIT;
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERRO GET: ' || VLINHA || ' - ' || SQLERRM);
        EXIT;
    END;
  
    MONTA_VETOR(';', VLINHA, VETOR);
  
    IF VLINHA IS NOT NULL AND VETOR(1) != 'COD_OPERADORA' THEN
  
  
  
  BEGIN
    SELECT OPE.CID_CONTRATO 
      INTO V_CID_CONTRATO
      FROM SN_CIDADE_OPERADORA OPE
     WHERE OPE.COD_OPERADORA =  LPAD(TRIM(REPLACE(VETOR(1), CHR(13),'')), 3,0)
       AND OPE.COD_OPE_JDE IS NOT NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_CID_CONTRATO := NULL;
  END;    
    
  IF V_CID_CONTRATO IS NOT NULL THEN
    
  


  
            -------------REGRAS DE NEGOCIO------------------------------ nao necessita sempre ter um cursor um select pode fazer esta funcao
V_ACHOU := 0;        
FOR X IN  (     

 SELECT ITE.ID_ITEM_EXTRATO,
         ITE.ID_PONTO,
         ITE.CODIGO,
         TPITE.DESCRICAO AS DESCRICAO_DO_ITEM,
         ITE.VLR,
         ITE.DT_VENCTO,
         ITE.ID_PRODUTO,
         
      
  (SELECT  P.DESCRICAO 
       FROM SN_PRODUTO  P
       WHERE ITE.ID_PRODUTO = P.ID_PRODUTO) AS DESCRICAO_PRODUTO,
       
       
       
       (SELECT  TP.DESCRICAO AS DESCRICAO_PONTO
              FROM       SN_TIPO_PONTO        TP
              WHERE  ITE.ID_TIPO_PONTO = TP.ID_TIPO_PONTO)AS TIPO_PONTO
              
              
  
    
    FROM SN_ITEM_EXTRATO ITE,
         SN_TIPO_ITEM_EXTRATO TPITE,
     /*    SN_CIDADE_OPERADORA  OP*/
     
 

     WHERE  ITE.CID_CONTRATO = V_CID_CONTRATO
        AND TPITE.ID_TIPO_ITEM_EXTRATO = ITE.ID_TIPO_ITEM_EXTRATO
        AND ITE.NUM_CONTRATO = TRIM(REPLACE(VETOR(2), CHR(13),''))              
        AND ITE.ID_COBRANCA  IS NULL   
        AND TPITE.DESCRICAO LIKE ('%MENS%PRIN%')   
      


UNION ALL--TENQ TER O MESMO NUMERO DE CAMPOS NO SELECT
  SELECT ITE.ID_ITEM_EXTRATO,
       ITE.ID_PONTO,
        ITE.CODIGO,
       TPITE.DESCRICAO AS DESCRICAO_DO_ITEM,
       ITE.VLR,
       ITE.DT_VENCTO,
       ITE.ID_PRODUTO,
       
       
 (SELECT  P.DESCRICAO 
       FROM SN_PRODUTO  P
       WHERE ITE.ID_PRODUTO = P.ID_PRODUTO) AS DESCRICAO_PRODUTO,
  
(SELECT  TP.DESCRICAO AS DESCRICAO_PONTO
              FROM       SN_TIPO_PONTO        TP
              WHERE  ITE.ID_TIPO_PONTO = TP.ID_TIPO_PONTO)AS TIPO_PONTO
              


  FROM SN_ITEM_EXTRATO ITE,
       SN_COBRANCA     COB,
       SN_TIPO_ITEM_EXTRATO TPITE,
      
   
 WHERE ITE.ID_COBRANCA = COB.ID_COBRANCA
    AND ITE.CID_CONTRATO = V_CID_CONTRATO
    AND TPITE.ID_TIPO_ITEM_EXTRATO = ITE.ID_TIPO_ITEM_EXTRATO
    AND ITE.NUM_CONTRATO =   TRIM(REPLACE(VETOR(2), CHR(13),''))
    AND COB.ID_SIT_COBRANCA = 10 -- EM ABERTO
    AND TPITE.DESCRICAO LIKE ('%MENS%PRIN%'))

  
  LOOP
                 V_ACHOU := 1;
                    IF V_ACHOU = 1 THEN --f3
PROPORCIONALIDADE := BUSCA_PROPOR(X.ID_ITEM_EXTRATO);
    
                    UTL_FILE.PUT_LINE(V_FILE_OUT,
                              TRIM(REPLACE(VETOR(1), CHR(13),'')) ||';'|| --COD_OPERADORA
                              TRIM(REPLACE(VETOR(2), CHR(13),'')) ||';'||  --NUM_CONTRATO
                              X.VLR                               ||';'|| --VLR_COBRANCA
                              X.ID_ITEM_EXTRATO                   ||';'||
                              X.DESCRICAO_DO_ITEM                 ||';'||
                              X.ID_PONTO                          ||';'||
                              X.DT_VENCTO                         ||';'||
                              X.ID_PRODUTO                        ||';'||
                              X.DESCRICAO_PRODUTO                 ||';'||
                              PROPORCIONALIDADE                   ||';'||
                              X.TIPO_PONTO                   
                            
                           
                              );
                    UTL_FILE.FFLUSH(V_FILE_OUT);
                    
                        END IF;--f3*/

 
        END LOOP;
 
IF V_ACHOU = 0 THEN
                  UTL_FILE.PUT_LINE(V_FILE_OUT,
                              TRIM(REPLACE(VETOR(1), CHR(13),'')) ||';'|| --COD_OPERADORA
                              TRIM(REPLACE(VETOR(2), CHR(13),'')) ||';'||  --NUM_CONTRATO
                               NULL || ';' ||
                               NULL || ';' ||
                               NULL || ';' || 
                               NULL || ';' ||
                               NULL || ';' ||
                               NULL || ';' ||
                               NULL || ';' ||
                                  NULL || ';' ||
                                     NULL || ';' ||
                                      
                                          
                              'NAO ENCONTRADO'         );
                               UTL_FILE.FFLUSH(V_FILE_OUT);
        
        
        
        
        
        END IF;
        END IF; --CID_CONTRATO     

    END IF; -- <> COD_OPERADORA
  
    END LOOP;
    UTL_FILE.FCLOSE(VFILEARQ);
    UTL_FILE.FCLOSE(V_FILE_OUT);
  
END;

   
 
