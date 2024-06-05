/*Thiago, 

                Favor complementar para os contratos em anexo as seguintes informa��es.

o  VENCTO DO CONTRATO
o  TIPO COBRANCA DO CONTRATO
o  STATUS ATUAL DO CONTRATO

                
                                                                                      

*\*/

DECLARE

  V_CHAMADO      VARCHAR2(1000)   := 'contratos' ;    -- Número do chamado
  VNM_ARQ        VARCHAR2(1000)   := 'contratos.csv'; -- Nome da carga
  
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
      SELECT DECODE (GLOBAL_NAME ,'BHPR.NET' ,'BHZ' -- UMA FUN�AO QUE INDENTIFICA AS BASES
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
  

BEGIN
  BEGIN

      V_BASE  := IDENTIFICA_BASE;
      V_FILE_OUT := UTL_FILE.FOPEN('/u04',V_BASE ||'_EXTR_'||V_CHAMADO||'_L11.csv','W');
      UTL_FILE.PUT_LINE(V_FILE_OUT,'COD_OPERADORA;NUM_CONTRATO;DIA_DO_VENCIMENTO;TIPO_COBRANCA;STATUS;INFORMACOES');
    
                                    /* ctv_extr_123_lancamentos_desconto.csv*/
    
    

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
    
  


  
            ---------ao
V_ACHOU := 0;        
FOR COB IN  (     
 
   SELECT  DIA.DIA,ST.DESCRICAO AS STATUS, 
   
   (SELECT   TC.DESCRICAO 
        FROM SN_REL_TIPO_COBRANCA_CONTRATO  CC,
             SN_TIPO_COBRANCA               TC
  
      WHERE C.NUM_CONTRATO = CC.NUM_CONTRATO
        AND C.CID_CONTRATO = CC.CID_CONTRATO
        AND CC.ID_TIPO_COBRANCA = TC.ID_TIPO_COBRANCA
        AND CC.DT_FIM = TO_DATE('30/12/2049','DD/MM/RRRR') 
        AND OP.CID_CONTRATO = V_CID_CONTRATO 
        AND C.NUM_CONTRATO = TRIM(REPLACE(VETOR(2), CHR(13),'')))AS FORMA_DE_PAGAMENTO
        

    FROM SN_CIDADE_OPERADORA            OP,
         SN_CONTRATO                    C,
         SN_REL_STATUS_CONTRATO_AUX     AUX,
         SN_STATUS_CONTRATO             ST,
         SN_DIA_VCTO                    DIA
         
   
               
         
     

      WHERE OP.CID_CONTRATO = C.CID_CONTRATO
        AND C.NUM_CONTRATO = AUX.NUM_CONTRATO
        AND C.CID_CONTRATO = AUX.CID_CONTRATO
        AND AUX.ID_STATUS = ST.ID_STATUS_CONTRATO
        AND C.ID_DIA_VCTO = DIA.ID_DIA_VCTO
        AND AUX.DT_FIM = TO_DATE('30/12/2049','DD/MM/RRRR') 
        AND OP.CID_CONTRATO = V_CID_CONTRATO 
        AND C.NUM_CONTRATO = TRIM(REPLACE(VETOR(2), CHR(13),'')))
          
  
  LOOP

                    V_ACHOU := 1;
                    IF V_ACHOU = 1 THEN --f3
                    UTL_FILE.PUT_LINE(V_FILE_OUT,
                              TRIM(REPLACE(VETOR(1), CHR(13),'')) ||';'|| --COD_OPERADORA
                              TRIM(REPLACE(VETOR(2), CHR(13),'')) ||';'||  --NUM_CONTRATO
                            /*  COB.ID_COBRANCA                   ||';'|| --ID_COBRANCA
                              COB.VLR_TOTAL                       ||';'|| --VLR_COBRANCA*/
                              COB.DIA                             ||';'||
                              COB.FORMA_DE_PAGAMENTO              ||';'||
                              COB.STATUS                          ||';'||  
                              'ok'
                              );
                    UTL_FILE.FFLUSH(V_FILE_OUT);
                    

                        
         END IF;--f3
        END LOOP;
        
        IF V_ACHOU = 0 THEN
                  UTL_FILE.PUT_LINE(V_FILE_OUT,
                              TRIM(REPLACE(VETOR(1), CHR(13),'')) ||';'|| --COD_OPERADORA
                              TRIM(REPLACE(VETOR(2), CHR(13),'')) ||';'||  --NUM_CONTRATO
                               NULL || ';' ||
                               NULL || ';' ||
                               NULL || ';' || 
                              'NAO ENCONTRADO'         );
                               UTL_FILE.FFLUSH(V_FILE_OUT);
        
        
        
        
        
        END IF;
        END IF; --CID_CONTRATO     

    END IF; -- <> COD_OPERADORA
  
    END LOOP;
 /*   DBMS_OUTPUT.put_line('OLA');*/
    UTL_FILE.FCLOSE(VFILEARQ);
    UTL_FILE.FCLOSE(V_FILE_OUT);
  
END;
 

   
 
