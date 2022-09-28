pragma solidity 0.8.17;

contract TaskManager {
    uint256 public nTasks;

    enum TaskPhase {
        ToDo,
        InProgress,
        Done,
        Blocked,
        Review,
        Postponed,
        Canceled
    }

    // Estrutura de dados (assim como um objeto no js)
    struct TaskStruct {
        address owner;
        string name;
        TaskPhase phase;
        uint256 priority;
    }

    TaskStruct[] private tasks;

    // Chave (unico) => Valor (pode ser multiplo como um array)
    // - Complementa a struct, ou seja, eu tenho um objeto e tento acessar
    // o valor dele a partir da chave, por exemplo obj.x
    // - Com isso, eu tenho o owner, um endereço unico, que aponta para
    // seu array de indexes, que são os index das suas respectivas tasks no
    // array de tasks
    mapping(address => uint256[]) private myTasks;

    // Definicao de um evento, que tem um nome e como parametro são as informacoes
    // que quero divulgar para todos que estiverem ouvindo os eventos da rede
    event TaskAdded(
        address owner,
        string name,
        TaskPhase phase,
        uint256 priority
    );

    // Modificador, é como uma validacao que ocorre antes de algo,
    // - Se a validacao passar, que é representado pelo underscore "_",
    // ele continua a execucao do codigo, que é representado.
    // - Se falhar, ele retorna um erro dizendo o motivo.
    modifier onlyOwner(uint256 _taskIndex) {
        if (tasks[_taskIndex].owner == msg.sender) {
            _; // libera a execução do restante do codigo apos o modificador
        }
    }

    constructor() {
        nTasks = 0;
        addTask("Create Task Manager", TaskPhase.ToDo, 1);
    }

    // - Essa funcao é do tipo publica e apenas de visualizao
    // - Uma das formas de uma funcao retornar dados,
    // no returns eu passo o nome e o tipo das variaveis que quero retornar
    // e no corpo da funcao eu atribuo o valor das variaveis passada para o returns
    // - Esse tipo de retorno é chamado de retorno nomeado
    function getTask(uint256 _taskIndex)
        public
        view
        returns (
            address owner,
            string memory name,
            TaskPhase phase,
            uint256 priority
        )
    {
        owner = tasks[_taskIndex].owner;
        name = tasks[_taskIndex].name;
        phase = tasks[_taskIndex].phase;
        priority = tasks[_taskIndex].priority;
    }

    // - Esse tipo de retorno é chamado de retorno direto
    // onde eu apenas falo o tipo do retorno e utilzo o "return" dentro
    // do corpo da funcao que recebe um valor do mesmo tipo definido no returns
    // - Quando eu uso o memory, quer dizer que o retorno vai ser direto para a
    // memoria do browser e não vai ficar persistido no contrato
    function listMyTasks() public view returns (uint256[] memory) {
        return myTasks[msg.sender];
    }

    // - Esse é um tipo de funcao onde é possível executar acoes, nao é só view,
    // e retorna um valor, que nesse caso é o index onde foi inserido a task
    function addTask(
        string memory _name,
        TaskPhase _phase,
        uint256 _priority
    ) public returns (uint256 index) {
        // - É como um modifier, porém definido no escopo da propria funcao
        // - Existe também:
        //  -> Assert: Usado muito para testes de erros internos e verificar invariantes;
        //  -> Require: Garante que as condicoes sejam atendidas ou valida os
        //  valores de retorno de uma saida de um smart contract externo;
        //  -> Revert: Avisa de erros inesperados e revert tudo que foi feito;
        // - Um gasta mais gás que outro:
        //  -> Assert usa todo o gás fornecido;
        //  -> Require praticamente nao usa gás;
        //  -> Revert usa uma parte e retorna o que sobrou;
        require(
            (_priority >= 1 && _priority <= 5),
            "priority must be between 1 and 5"
        );

        TaskStruct memory taskAux = TaskStruct({
            owner: msg.sender,
            name: _name,
            phase: _phase,
            priority: _priority
        });

        tasks.push(taskAux);

        index = tasks.length - 1;

        nTasks++;
        myTasks[msg.sender].push(index);

        // - Emissao do evento, passando os mesmos parametros definidos na criacao
        // do evento.
        emit TaskAdded(msg.sender, _name, _phase, _priority);
    }

    // - Esse é um tipo de funcao onde não há retorno e apenas executa acoes
    function updateTask(uint256 _taskIndex, TaskPhase _phase)
        public
        onlyOwner(_taskIndex)
    {
        tasks[_taskIndex].phase = _phase;
    }
}
