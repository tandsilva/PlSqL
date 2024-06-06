

/*Bom dia!

Thiago, segue abaixo o exercicio 3.

3)  Trazer COD_OPERADORA, NUM_CONTRATO,  CID_CONTRATO, STATUS, VENCTO_CTR, ID_ITEM_EXTRATO, ID_TIPO_ITEM_EXTRATO, DESCRICAO_TIPO_ITEM_EXTRATO, VENCTO_ITEM_EXTRATO, DT_LANCAMENTO, VALOR, ID_COBRANCA E ITEM_LF(SIM/NAO), para os contratos da planilha 02. 

Verificações:
•  Se o contrato existe na base, em caso negativo retornar a seguinte informação: ‘CONTRATO NÃO ENCONTRADO. 
•  Se o item de extrato estiver em lançamento futuro retornar ‘SIM’ na coluna ITEM_LF(SIM/NAO), senão retornar ‘NAO’.

Utilizar o metodo de carga na PROD_JD.SN_ONGOING_QUALIDADE.


*/



DECLARE

VFILEARQ UTL_FILE.FILE_TYPE;
TYPE T_VET_RETORNO IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
VETOR   T_VET_RETORNO;
VNM_ARQ VARCHAR2(100) := 'PLANILHA_023.csv';
VLINHA            VARCHAR2(25000);
V_ACHOU       VARCHAR(30);
V_CID_CONTRATO SN_CIDADE_OPERADORA.CID_CONTRATO%TYPE;
V_FILE_OUT     UTL_FILE.FILE_TYPE;
V_BASE         VARCHAR2(10);
V_CHAMADO      VARCHAR2(1000)   := 'contratos' ; 
NUMEROS       BOOLEAN;
LANCAMENTO_F VARCHAR(50);
FUNCTION DIR_GEF RETURN VARCHAR2 AS
PPARAMETRO SN_PARAMETRO.VLR_PARAMETRO_STR%TYPE;
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
   
FUNCTION RETORNA_CONTRATO(P_CID_CONTRATO VARCHAR, P_CONTRATO VARCHAR)

    RETURN BOOLEAN
   
IS
    CONTRATO VARCHAR(50);
         
BEGIN
        
        
SELECT C.NUM_CONTRATO
    INTO CONTRATO
FROM SN_CIDADE_OPERADORA OP,
    SN_CONTRATO         C
       
WHERE OP.CID_CONTRATO = P_CID_CONTRATO
    AND C.NUM_CONTRATO = P_CONTRATO;
    IF (CONTRATO IS NOT NULL) THEN
RETURN TRUE;
    ELSE 
RETURN FALSE; 
   END IF; 
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       
RETURN FALSE;

     
END;
     
FUNCTION LANCAMENTO_LF(P_CID_CONTRATO VARCHAR, P_CONTRATO VARCHAR,P_ID_ITEM_ESTRATO VARCHAR)

RETURN VARCHAR
       
    IS
            LANCAMENTO_F VARCHAR(50);
            V_ACHOU  VARCHAR(30);
BEGIN
            
            
SELECT EX.ID_ITEM_EXTRATO
    INTO LANCAMENTO_F
                  
        FROM  SN_ITEM_EXTRATO EX
                               
    WHERE EX.CID_CONTRATO = P_CID_CONTRATO
        AND EX.NUM_CONTRATO =  P_CONTRATO
        AND EX.ID_COBRANCA  IS NULL
        AND EX.ID_ITEM_EXTRATO = P_ID_ITEM_ESTRATO;
                
IF (LANCAMENTO_F IS NOT NULL) THEN
    V_ACHOU :='SIM';
ELSE 
    V_ACHOU :='NAO';
        
END IF; 
RETURN  V_ACHOU;    
         
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         V_ACHOU:='NAO';
RETURN   V_ACHOU;

       
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






---------------------------#########INICIO##########----------------------------------------------
BEGIN

    DELETE FROM PROD_JD.SN_ONGOING_QUALIDADE
    WHERE CD_CONTROLE = 'ONGOING_DADOS_CONTRATO_THIAGO';
        
COMMIT;
       
BEGIN
      
        VFILEARQ := UTL_FILE.FOPEN(LOCATION  =>'/u04',
        FILENAME  => VNM_ARQ,
        OPEN_MODE => 'R');
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
        INSERT INTO  PROD_JD.SN_ONGOING_QUALIDADE
                 
        (V2, V1, CD_CONTROLE)

        VALUES(
                         
        TRIM(REPLACE(VETOR(2), CHR(13),'')),  -- NUM_CONTRATO     
        TRIM(REPLACE(VETOR(1), CHR(13),'')),  -- COD_OPERADORA    
        'ONGOING_DADOS_CONTRATO_T800'
        ) ;
        COMMIT;   
        END IF;
      
END LOOP;
   


DBMS_OUTPUT.put_line(TRIM(REPLACE(VETOR(2), CHR(13),'')));
    
V_FILE_OUT := UTL_FILE.FOPEN('/u04',V_BASE ||'_EXTR_'||V_CHAMADO||'_L16.csv','W');
UTL_FILE.PUT_LINE(V_FILE_OUT,'COD_OPERADORA;NUM_CONTRATO;DIA_DO_VENCIMENTO;STATUS;LANCAMENTO_LF;OBS;ID_ITEM_ESTRATO;DESCRICAO_ITEM;DATA_LANCAMENTO_ITEM;VENCIMENTO_DO_ITEM;VALOR_DO_ITEM');

       
         
FOR  ONG IN (    
        SELECT OGG.V2,OGG.V1,OP.CID_CONTRATO,OGG.CD_CONTROLE
        FROM SN_ONGOING_QUALIDADE  OGG,
        SN_CIDADE_OPERADORA   OP
        WHERE OGG.CD_CONTROLE =  'ONGOING_DADOS_CONTRATO_T800' 
        AND OP.COD_OPERADORA = LPAD(OGG.V1, 3, 0))
                                   
                                   
LOOP --1
NUMEROS:= RETORNA_CONTRATO(ONG.CID_CONTRATO,ONG.V2);
     
   
IF NUMEROS THEN



    
FOR COB IN  (    
    
        SELECT OP.COD_OPERADORA,
        C.NUM_CONTRATO,
        C.CID_CONTRATO,
        ST.DESCRICAO AS STATUS,
        DIA.DIA,
        IT.ID_ITEM_EXTRATO,
        ITE.DESCRICAO,
        IT.DT_VENCTO,
        IT.DT_LANC,IT.VLR

                      


  FROM  SN_CIDADE_OPERADORA          OP,
          SN_CONTRATO                  C,
          SN_REL_STATUS_CONTRATO_AUX   AUX,
          SN_STATUS_CONTRATO           ST,
          SN_DIA_VCTO                  DIA,
          SN_ITEM_EXTRATO              IT,
          SN_TIPO_ITEM_EXTRATO         ITE
                  



WHERE  ONG.CID_CONTRATO = C.CID_CONTRATO
      AND  ONG.V2 = C.NUM_CONTRATO    
      AND  C.CID_CONTRATO = OP.CID_CONTRATO
      AND  DIA.ID_DIA_VCTO = C.ID_DIA_VCTO
      AND  AUX.NUM_CONTRATO = C.NUM_CONTRATO
      AND  AUX.CID_CONTRATO = C.CID_CONTRATO
      AND  AUX.ID_STATUS = ST.ID_STATUS_CONTRATO
      AND  C.NUM_CONTRATO = IT.NUM_CONTRATO
      AND  C.CID_CONTRATO = IT.CID_CONTRATO
      AND  IT.ID_TIPO_ITEM_EXTRATO = ITE.ID_TIPO_ITEM_EXTRATO
      AND  AUX.DT_FIM = TO_DATE('30/12/2049', 'DD/MM/RRRR')

)LOOP
LANCAMENTO_F := LANCAMENTO_LF(COB.CID_CONTRATO, COB.NUM_CONTRATO ,COB.ID_ITEM_EXTRATO ) ;    

          UTL_FILE.PUT_LINE(V_FILE_OUT,
          ONG.V1                              ||';'||
          ONG.V2                              ||';'||
          COB.DIA                             ||';'||  
          COB.STATUS                          ||';'||
          LANCAMENTO_F                        ||';'||
          ONG.CD_CONTROLE                     ||';'||
          COB.ID_ITEM_EXTRATO                 ||';'||
          COB.DESCRICAO                       ||';'||
          COB.DT_LANC                         ||';'||
          COB.DT_VENCTO                       ||';'||
          COB.VLR
                                                            
);
                                

UTL_FILE.FFLUSH(V_FILE_OUT);
                      
    
END LOOP;
ELSE 
        UTL_FILE.PUT_LINE(V_FILE_OUT,
        ONG.V1 ||';'||
        ONG.V2 ||';'|| 
        NULL || ';' ||
        'NAO ENCONTRADO'         );
UTL_FILE.FFLUSH(V_FILE_OUT);
     
          
          
          
          
END IF;
END LOOP ;--1;   
      
      UTL_FILE.FCLOSE(VFILEARQ);
      UTL_FILE.FCLOSE(V_FILE_OUT);
         
END;

