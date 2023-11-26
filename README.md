# Analisador de XML NFe

![Imagem](https://i.imgur.com/CBsGVlx.png)

## Rejeição 629

Esse programa ajuda a identificar o erro no cálculo de ``<vUnCom>`` x ``<qCom>`` que deve ser igual a ``<vProd>`` _(com uma margem de 0,01 centavos de erro)_
nos itens da NFe. Caso haja diferença entre ``<vProd>`` e ``<vUnCom> x <qCom>``, é retornado a rejeição: 


> Rejeição 629: Valor do Produto difere do produto Valor Unitário de Comercialização e Quantidade Comercial 


[Referência sobre a Rejeição](https://www.oobj.com.br/bc/article/rejei%C3%A7%C3%A3o-629-valor-do-produto-difere-do-produto-valor-unit%C3%A1rio-de-comercializa%C3%A7%C3%A3o-e-quantidade-comercial-como-resolver-44.html)


## Rejeição 564
Essa rejeição ocorre quando há diferença entre o somatório de ``<vUnCom> x <qCom>`` e a tag ``<total> -> <ICMSTot> -> <vProd>`` 
é retornado a rejeição: 


> Rejeição 564: Total do Produto / Serviço difere do somatório dos itens


[Referência sobre a Rejeição](https://www.oobj.com.br/bc/article/rejei%C3%A7%C3%A3o-564-total-do-produto-servi%C3%A7o-difere-do-somat%C3%B3rio-dos-itens-como-resolver-277.html)


## O que é esperado com a utilização do Analisador

O principal objetivo é conseguir identificar com agilidade quais itens no XML da NFe, estão com divergência no totalizador do item ou no somatório dos valores de todos os itens. 


## Contribuições

O projeto é 100% Open Source. As contribuições são bem-vindas através da aba "Issues" do Github. 
