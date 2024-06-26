/*
CCRIAR UM PROCEDURE
 DE CARGA QUE LEIA O COD OPERADORA E 
 NUM CONTRATO EFETUE A CARGA NA ONGOEN QUALIDADE 
 ALTERAR O STATUS DO CONTRATO DE AIVO PARA
 CANCELADO AUTERANDO TAMBEM A DT FIM DE 30/12/2049/PARA ATUAL*\*/
 
DECLARE
    V_FILE UTL_FILE.FILE_TYPE;
 /*   STATUSS NUMBER*/
CURSOR DADOS IS
    
    
       SELECT OP.COD_OPERADORA,
              C.NUM_CONTRATO,
              ST.DESCRICAO ,
              AUX.DT_FIM
 


      FROM SN_CIDADE_OPERADORA OP,
           SN_CONTRATO C,
           
           
           SN_REL_STATUS_CONTRATO_AUX AUX,
           SN_STATUS_CONTRATO ST
   

     WHERE OP.CID_CONTRATO = C.CID_CONTRATO
           AND C.NUM_CONTRATO = AUX.NUM_CONTRATO
           AND C.CID_CONTRATO = AUX.CID_CONTRATO
           AND AUX.ID_STATUS = ST.ID_STATUS_CONTRATO
           AND ST.DESCRICAO = 'CONECTADO'
           AND C.NUM_CONTRATO IN ('64','109','110')
           AND AUX.DT_FIM = TO_DATE('30/12/2049','DD/MM/RRRR')

FUNCTION ALTERA_STATUS(P_ID_STATUS_CONTRATO NUMBER,P_NUM_CONTRATO,P_CID_CONTRATO) 
         RETURN NUMBER

 IS
  STATUSS VARCHAR(50)
BEGIN

 
    UPDATE  SN_REL_STATUS_CONTRATO_AUX AUX
       SET  AUX.ID_STATUS_CONTRATO = P_ID_STAUTS_CONTRATO
     WHERE  C.NUM_CONTRATO = P_NUM_CONTRATO
       AND  C.CID_CONTRATO = P_CID_CONTRATO;
       AND  AUX.DT_FIM = TO_DATE(SYSDATE, 'DD/MM/RRRR');
      
       
    INSERT INTO SN_REL_STATUS_CONTRATO_AUX (NUM_CONTRATO,CID_COTRATO,DT_INI,DT_FIM,ID_STATUS,DT_FIM,DT_ALTERACAO,COD_OS,HORA_STATUS_INI)
           VALUE (P_NUM_CONTRATO,P_CID_CONTRATO,6,
    
    
  RETURN STATUSS;
END;
      
BEGIN 
    V_FILE := UTL_FILE.FOPEN('/u04', 'jr.csv', 'w');
  
    UTL_FILE.PUT_LINE(V_FILE, 'COD_OPERADORA;NUMERO_DO_CONTRATO ; DESCRICAO ; DATA_INICIO ;DATA_FINAL; DIA_DO_VENCIMENTO');
  
    FOR X IN DADOS LOOP       
    
        UTL_FILE.PUT_LINE(V_FILE, 
                               X.COD_OPERADORA ||';'||
                               X.NUM_CONTRATO ||';'||
                               X.DESCRICAO ||';'||
                               to_char (X.DT_FIM ,'dd/mm/yyyy')
                                  
                                
                                
                         );
    
  END LOOP;
  
    UTL_FILE.FCLOSE(V_FILE);
  
END;
/*SELECT * FROM SN_REL_CONTRATO_AUX
SELECT * FROM SN_REL_STATUS_CONTRATO_AUX */
