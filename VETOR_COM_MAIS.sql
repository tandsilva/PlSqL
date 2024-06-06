DECLARE

  VFILEARQ UTL_FILE.FILE_TYPE;
  TYPE T_VET_RETORNO IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  VETOR   T_VET_RETORNO;
  VNM_ARQ VARCHAR2(100) := '9680197.csv';
  VLINHA            VARCHAR2(25000);

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

BEGIN

    DELETE
     FROM PROD_JD.SN_CTRL_PROCESSO    CT
    WHERE CT.ID_PROCESSO   = 99
      AND CT.TIPO_OPERACAO = '99'
      AND CT.STATUS        = 'EXCLUSAO'
      AND CT.USR_CADASTRO  = USER;
      
   COMMIT;
     
  BEGIN
    VFILEARQ := UTL_FILE.FOPEN(LOCATION  => DIR_GEF,
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
  
    IF VLINHA IS NOT NULL AND VETOR(1) != 'BASE' THEN
      INSERT INTO SN_CTRL_PROCESSO
                  (ID_PROCESSO,
                   TIPO_OPERACAO,
                   STATUS,
                   USR_CADASTRO,
                   PARAM1,
                   PARAM2,  -- MEU Inserg
                   PARAM3,
                   RESULTADO
                   )
             VALUES
                  (99,
                   '99',
                   'EXCLUSAO',
                   USER,      
                   TRIM(REPLACE(VETOR(4), CHR(13),'')),  -- NUM_CONTRATO     
                   TRIM(REPLACE(VETOR(2), CHR(13),'')),  -- COD_OPERADORA    
                   TRIM(REPLACE(VETOR(3), CHR(13),'')),  -- ID_ITEM_EXTRATO
                   TRIM(REPLACE(VETOR(10), CHR(13),''))   -- OCORRENCIA
                   ) ;
    END IF;
  
  END LOOP;
UTL_FILE.FCLOSE(VFILEARQ);

COMMIT;
END;

/*
delete
-- select COUNT(*) 
FROM SN_CTRL_PROCESSO    CT
WHERE CT.ID_PROCESSO   = 99
   AND CT.TIPO_OPERACAO = '99'
   AND CT.STATUS        = 'EXCLUSAO'
   AND CT.USR_CADASTRO  = USER   
*/
