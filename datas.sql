
--modo de tratar datas

SELECT *
FROM SN_OCORRENCIA OCC
 WHERE ID_ASSINANTE = 89  
    AND  ID_USR = USER  
   AND TRUNC(OCC.DT_OCORRENCIA) =  TRUNC (SYSDATE-1)  
   
   
   --converteu data para strin para trazer apenas mes e ano
SELECT *
  FROM SN_COBRANCA
 WHERE NUM_CONTRATO  = 220855661
   AND TO_DATE(TO_CHAR(DT_VENCTO, 'MM/RRRR'), 'MM/RRRR')  = TO_DATE('01/2020', 'MM/RRRR')   
