Fala pessoal!

Vamos ao primeiro artigo da série que se tudo der certo sai 100%

## Já aviso que o artigo é grande mas é necessário para que seja colocado exatamente o passo a passo de como fazer!

O json para testar no postman se encontra aqui:

[POSTMAN](https://github.com/brasizza/shelf-server-v1/blob/master/postman/artigo_shelf.postman_collection.json)

Vamos iniciar explicando como será nossa api:
Iremos conectar em um banco mysql onde terá nosso banco de dados chamado de **delivery** e nele terá uma tabela chamada **orders**, e nela estarão todos nossos pedidos por provider (ifood/rappi) e os status (**Iniciado**, **Em andamento**, **Finalizado**, **Em Rota** e **Completo**) onde

- **Iniciado**: O servidor recebeu o pedido naquele momento
- **Em andamento**: Alguém iniciou a produção desse pedido
- **Finalizado**: A produção do pedido foi finalizado
- **Em rota**: O pedido saiu do restaurante e está indo para o cliente
- **Finalizado**: Pedido foi entregue

Teremos as rotas de pegar Todos os pedidos, pegar um pedido por ID, Inserir, Alterar e excluir o pedido por ID

Nossa tabela do mysql
{% gist https://gist.github.com/brasizza/7033131144b101be7a88bda056670040 %}
---


## INICIANDO O SHELF
O Dart nos traz uma facilidade absurda na criação dos nossos projetos, que são os templates. Com eles você pode já criar seu projeto de um jeito fácil e já é incluído algumas coisas automaticamente nele.

Vamos criar nosso projeto com o template do shelf mesmo assim

`dart create -t server-shel api`
Com isso ele já vai jogar nas depenências o shelf e o shelf_router  e um arquivo teste rest no seu **bin/server.dart**

podemos executar ele clicando ou no `debug` ou no `run` do server.dart e abrir o link **http://0.0.0.0:8080/**, você vai ver que ele vai aparecer um 'Hello World!' , sinal de que está tudo funcionando

## DEPENDENCIAS
Tentarei usar o mínimo de dependências possíveis no server, então iremos usar o [**get_it**] (https://pub.dev/packages/get_it) para gerenciar nossas dependências, um package de mysql que eu optei nesse projeto usar o [**mysql_client**](https://pub.dev/packages/mysql_client), pois está atualizado há pouco tempo e diz no package o suporte pro mysql8 e mariadb 10 e sabemos que o mysql1 está meio chatinho de usar então dei uma chance pra ele! e pra finalizar o [**dotenv**](https://pub.dev/packages/dotenv/example), que iremos utilizar para pegar alguns dados para iniciar nosso servidor shelf, como porta e dados do mysql, mesmo sabendo que não é o local mais seguro do mundo, como estará no server-side não vejo muito problema inicialmente. 
Para adicionar rapidamente no seu projeto todos esses packages faremos de uma vez só

`dart pub add get_it mysql_client dotenv`



## ARQUIVOS UTEIS

Iremos criar um concentrador de logs que chamaremos de 
 **developer** e iremos colocar em **lib/src/core/developer**
iremos criar o **developer.dart**

{% gist https://gist.github.com/brasizza/919ac69ee19398d969bbbc0c1d60ed3c %}

Estou também fazendo uns testes de abstração de banco de dados, portanto é **meramente experimental**, onde teoricamente eu poderia usar qualquer banco de dados (que podemos testar depois, por exemplo o hive), existem alguns métodos nele que eu ainda não implementei, pois como foi construído para o **hive**, consegui adaptar muito bem para o **mysql**

Vamos criar uma pasta em **lib/src/core/database** e colocaremos nosso database.dart e o nosso mysql_database.dart

{% gist https://gist.github.com/brasizza/19ed2277182040c06e10fff2fbf9aa8a %}


{% gist https://gist.github.com/brasizza/3c3db69b258805b4970f15619822adb6 %}


## ESTRUTURA DO PROJETO
Iremos utilizar uma estrutura de 
- Controller
  - Service 
  - Repository

Nesse projeto escolhi utilizar o service layer para que possamos ter mais liberdade para o repository, por exemplo quando atualizamos um pedido ou inserimos, a responsabilidade do repository é só inserir ou alterar, deixamos o service responsável por retornar o objeto novo ou alterado, assim dividimos as responsabilidades e deixamos o nosso repository somente para fazer a conexão entre o nosso banco e nada mais!


Para ficar mais fácil , fora da pasta bin, iremos criar uma pasta **lib**, e dentro dela a **src** onde iremos colocar nosso código isolado dos demais

## MODEL ORDER e ORDER STATUS
Primeiramente precisamos criar nosso model, e olhando a nossa tabela temos os campos que serão representados da nossa tabela.Podemos notar que os campos estão em snake_case e por padrão o flutter 'sugere' que as propriedades sejam em camelCase, então teremos que fazer algumas traduções de campos além de para ficar mais fácil iremos criar um enum para o nosso campo de **status** 

O enum do status que iremos criar na pasta **lib/src/enum/order_status.dart**
{% gist https://gist.github.com/brasizza/45a001befab9d4b8a3ca23117213d067 %}

O nosso model do Order, criei com a extensão do [Dart class generator ](https://marketplace.visualstudio.com/items?itemName=hzgood.dart-data-class-generator) , ele ajuda demais a construir rapidamente um model

Model que iremos criar na pasta **lib/src/data/model/order.dart**

{% gist https://gist.github.com/brasizza/8206a25c59ab3eddcc78d4258976ee26 %}

Pontos importantes da nossa model que foram customizados, como por exemplo o **orderId** que no nosso banco é **order_id** , e os outros, que tiveram que ser traduzidos no _fromMap_ exatamente como está na tabela

Outro ponto importante foi a criação do **toDatabase** e do **updateMap**, que no decorrer vou explicar o motivo da criação

## Módulo order
Para separar nosso projeto , iremos criar uma pasta order em
**lib/src/modules/order**  e criaremos 2 arquivos
o **order_controller.dart** e **order_route.dart**

A **order_controller** será nosso controlador de todas as ações que o nosso endpoint precisará fazer, e o **order_route** será onde iremos especificar a nossas rotas e o que efetivamente faremos nelas

Na nossa controller teremos o:

- getAll , pra pegar todos os pedidos
- getById, para pegar um pedido específico
- save, para inserir o pedido no banco de dados
- update, para atualizar um pedido específico
- delete, para deletar um pedido específico

Ta, mas como faremos isso?
Como eu havia mencionado, iremos utilizar 2 camadas acima da controller: a service e a repository.

Iremos inicialmente criar a abstração da service e depois implementar. Vamos chamar de order_service e vamos colocar ela dentro da pasta **lib/src/service/order_service.dart**

{% gist https://gist.github.com/brasizza/34e42194eb3a709bb223802fcfc85d49 %}
onde:
- **getAll** pode ou não retornar uma lista de Order,

- **getById**, pode ou não retornar um Order passando um id,
- **delete**,  deleta da sua base de dados com base em um id e te retorna o Order deletado

- **save**, salva os dados enviados para o endpoint , retornando o Order salvo

- **update** , atualiza um Order com base em um id, atualizando os campos que foram preenchidos para atualização


{% gist https://gist.github.com/brasizza/cdcab3db69a5b16f764badc1cc1252ea %}

Se olharmos no service, iremos ver que temos algumas particularidades para deixar nosso código mais limpo, como por exemplo as checagens para deletar ou atualizar um registro, além de por exemplo ele retornar um objeto Order para sua service seja com ele atualizado no caso do update ou o que foi inserido naquele momento, e no caso do delete em particular, ele te manda o registro que foi excluído!

Além disso iremos utilizar o método **updateMap** que, como pegamos o objeto antes de fazer o update, nós atualizamos o mesmo objeto com os dados vindos requisição, assim nós garantimos que só irão ser alterados os campos que forem enviados pela requisião de **UPDATE**, além de atualizar o campo de data de atualização e ai sim enviamos para o banco de dados para atualização

Também iremos criar um **repository** chamado **order_repository** na pasta
**lib/src/data/repository/order_repository.dart**

{% gist https://gist.github.com/brasizza/f43ad2e0ae4105e12c14a442723b4121 %}


A grande diferença entre o **repository** e o service estão nos métodos de inserir, deletar e atualizar, onde o **repository** só precisa entregar pro service, se deu certo ou não, e só no caso do inserir que ele precisa retornar o id inserido para que o service possa tomar as providencias necessárias.

A implementação do repository para explicação

{% gist https://gist.github.com/brasizza/365697f0fb102088761e61855f5ca702 %}

No repository fazemos a conexão com o banco de dados que por fim faz todas as ações necessárias, além de no salvar, nós utilizamos o método **toDatabase** que criamos que basicamente é para normalizar os nomes dos campos com os nomes das tabelas do banco de dados, assim facilita nosso trabalho de ter que normalizar (ou seja, colocar os mesmos nomes da tabela)


Com tudo isso criado, podemos finalmente criar nossa controller.

A controller também terá os seguintes métodos iniciais

- getAll 
- getById
- save
- update
- delete

A diferença dela para as camadas acima é que ela vai ser nossa ligação entre o shelf e o service que por sua vez se comunica com o repository

Como você deve ter notado, normalmente fazemos a inversão dependência e injetamos por exemplo o repository na service e o database no repository e por sua vez injetamos o service na controller, assim podemos fazer um código o mínimo de agregação fixa e se caso for preciso mudar a instância, mudamos somente na injeção na classe.

Uma coisa importante no nosso controller é que como estamos trabalhando com o shelf, o retorno de todos os métodos devem ser um Response, para que o shelf possa responder corretamente com 200, ou 400 ou 500 para o nosso cliente na ponta onde está acessando o endpoint específico que iremos criar logo em seguida.

{% gist https://gist.github.com/brasizza/4ed019623163b318c7cd2ee1672676c2 %}

O controller que tem o service injetado será nossa ponta para ligar diretamente no shelf, podemos ver que na maioria dos casos, faz uma logica simples e chama o service que faz toda a lógica juntamente com o controller retornando somente o objeto ou um nulo indicando erro, sempre respeitando o máximo possível das respostas http: 

- 2xx para OK 
- 4xx para dados com problemas (mas processou)
- 5xx erro crítico no nosso servidor ou banco de dados

Eu particularmente gosto de nomear minhas instâncias em constantes para ficar mais fácil a recuperação, então como sabemos que teremos que injetar o mysql, o nosso service do order e o repository, já vamos criar a nossa classe que ficará com os nomes das constantes.
{% gist https://gist.github.com/brasizza/fc7e7e00281c969966d62b89a565a9b1 %}
Eu coloco nomes grandes, porque como esta na propriedade não tem problema nenhum porque vai pegar de **Consts.mysqlInstance** por exemplo

Até agora não colocamos um dedo no código do shelf propriamente dito e provavelmente se criou um template do shelf igual descrito acima o seu server.dart vai estar parecido com algo assim
{% gist https://gist.github.com/brasizza/1b8fae896c4d24a14501b883a9e7538b %}

isso quer dizer que , se for executado esse shelf do jeito que está e entrar no seu ip:8080 ele vai mostrar na tela um **Hello world**

A primeira coisa que vamos fazer ai é criar um arquivo .env na raiz do seu projeto para que possamos colocar os dados do seu banco de dados 

{% gist https://gist.github.com/brasizza/af2d7c7b58174fb483665da1364c360d %}

Vamos usar o dotenv para carregar esse arquivo e também vamos usar o GetIt para guardar essa instância para um futuro uso. Além disso vamos no **server.dart** mesmo fazer a conexão como o mysql e também guardar essa instância.

```dart
void main(List<String> args) async {

final Env env = Env.i..load();
  GetIt.I.registerSingleton(env);

  final MysqlDatabase mysql = await MysqlDatabase.i.openDatabase(
    {
      'host': env['host'] ?? '',
      'port': env['port'] ?? '',
      'userName': env['userName'] ?? '',
      'password': env['password'] ?? '',
      'databaseName': env['databaseName'] ?? '',
      'secure': env['secure'] ?? '',
    },
  );
  GetIt.I.registerSingleton<Database>(mysql, instanceName: Consts.mysqlInstance);
....
}
``` 

Com isso teremos nossa conexão com o mysql sempre disponível no getIt.

## Criando as rotas no shelf

Criamos um **order_route.dart** que ainda está vazio e vamos criar nossas rotas nesse arquivo para deixar bem separado.

Como já criamos nosso controller, o nosso service E a nossa repository iremos iniciar a instância deles somente neste ponto , para que a responsabilidade da criação das instâncias seja somente onde ela é chamada de fato!
Iremos criar um método estático chamado routes onde iremos criar nossas chamadas de rotas como descritas abaixo
{% gist https://gist.github.com/brasizza/e8f560e708bd923045144951a9b42624 %}

podemos ver que foram criados 5 rotas bases 

- a **/orders** que é o nosso getAll
- a **/order/_id_** que é a nossa rota de pegar um order por id
- o **/order** que vai salvar o nosso objeto de order
- o **/order/_id_** que vai atualizar a nossa order com base em um id
- a **/order/_id_** que vai deletar o nosso registro com base na ID

Tudo isso mandando os verbos certos, **get** onde é requisição de informação, **post** e **put** e **delete** quando é envio de informação para o servidor

Feito isso iremos agora colocar essa rota no nosso server.dart
Colocaremos a porta do shelf padrão como vindo do .env, e se não encontrar ele assume a porta **8080**

Iremos fazer de um jeito inicialmente que só será possível incluir as rotas do order, mas caso nós formos progredindo podemos alterar para contemplar mais rotas

{% gist https://gist.github.com/brasizza/ffdfca537d48af743b34aa667e44f0ba %}


e com isso terminamos nossa primeira parte do servidor shelf. Sei que é muita informação e muito texto, mas se você se perdeu em algum lugar, você inicialmente pode tentar me chamar no [discord](https://discord.gg/Brasizza#7615) pois me ajuda demais a entender onde está o problema e ajudar a corrigir!

Ou olhar no repositório [GIT](https://github.com/brasizza/shelf-server-v1)


Espero que tenham gostado e iremos fazer nosso primeiro app utilizando esse backend no próximo artigo!






