--V_CONTAS_PAGAR
--CONTAS_PAGAR,FORNECEDORES
--SELECT * FROM V_CONTAS_PAGAR

CREATE OR REPLACE VIEW V_CONTAS_PAGAR as
    SELECT A.cod_empresa,A.id_doc,A.id_for,B.razao_fornec,A.parc,A.data_venc,A.data_pagto,A.valor,
    CASE WHEN A.data_pagto IS NULL THEN 'ABERTO' 
         ELSE 'PAGO' END SITUACAO,
         
    CASE WHEN A.data_venc>SYSDATE THEN 'NORMAL' 
         WHEN A.data_pagto>A.data_venc THEN 'PAGTO EF COM ATRASO'
         ELSE 'VENCIDO' END MSG
         
    FROM CONTAS_PAGAR A
    INNER JOIN FORNECEDORES B
    ON A.id_for=B.id_for AND A.cod_empresa=B.cod_empresa;
 
SELECT * FROM V_CONTAS_PAGAR;

CREATE OR REPLACE VIEW V_CONTAS_RECEBER as
    SELECT A.cod_empresa,A.id_doc,A.id_cliente,B.razao_cliente,A.parc,A.data_venc,A.data_pagto,A.valor,
    CASE WHEN A.Data_Pagto is null THEN 'ABERTO' ELSE 'PAGO' END SITUACAO,
    CASE WHEN A.data_venc>SYSDATE THEN 'NORMAL' 
         WHEN A.data_pagto>A.data_venc THEN 'PAGTO EM COM ATRASO'
         ELSE 'VENCIDO' END MSG,
         
    CASE WHEN A.data_venc=A.Data_Pagto THEN 0
         WHEN A.data_pagto>A.data_venc THEN CAST(CAST(A.data_pagto AS DATE)-CAST(A.data_venc AS DATE) AS int )
         ELSE CAST(SYSDATE-CAST(A.data_venc AS DATE) AS INT ) END DIAS_ATRASO
         
    FROM CONTAS_RECEBER A
    INNER JOIN CLIENTES B
    ON A.id_cliente=B.id_cliente AND A.cod_empresa=B.cod_empresa;

SELECT * FROM V_CONTAS_RECEBER;
