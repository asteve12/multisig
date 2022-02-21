pragma solidity ^0.8.4;





contract MultiSignatureWallet {

  address [] public owners;

  uint public required;

  struct transaction{
      address destination;
      uint value;
      bytes data;
      bool executed;

  }

  mapping(address =>bool)public isOwner;
  uint public transactionCount;

  mapping(uint=> transaction)public transactions; 

    mapping(uint =>mapping(address=> bool))public confirmatons;

    modifier validRequirement(uint ownerCount,uint _required){
        require(_required <= ownerCount && ownerCount !=0,"there is an error");
        _;

    }

    modifier onlyCallableByOwner{
        require(isOwner[msg.sender],"sorry you are not allowed to call this function");
        _;
    }

    constructor(address [] memory _owners,uint _required)public  validRequirement(_owners.length,required){
          
             for(uint i=0;i <= _owners.length-1;i++ ){
                isOwner[_owners[i]]=true; 
        owners = _owners;
        required = _required;

    }

        }
       
    event Submission(uint indexed transactionId);

    function addTransaction(address destination,uint value,bytes memory data)internal 
    returns(uint transactionId){
        uint transactionId = transactionCount;
        transactions[transactionId] = transaction({
            destination:destination,
            value:value,
            data:data,
            executed:false
        });
          transactionCount += 1;
           emit Submission(transactionId);

    } 

    function isConfirmed(uint transactionId)public view returns(bool){
        uint count =0;
        for(uint i=0,i<owners.length-1,i++){
              if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }

    }
    event Execution(uint transactionId);
    event ExecutionFailure(uint transactionId);

    function executeTransaction(uint transactionId)public{
        require[transactions[transactionId].executed == false];
        if(isConfirmed(transactionId)){
            transaction storage t = transactions[transactionId];
            t.executed = true;
            (bool success,bytes memory status) = destination.call(t.value)(t.data);
            if(success){
                emit Execution(transactionId);
            }
            else{
                emit ExecutionFailure(transactionId);
                t.executed = false;

            }

        }
    }

    event Confirmation(address indexed sender,uint indexed transactionId);

function confirmTransaction(uint transactionId)public {
    require(isOwner[msg.sender]);
    require(transactions[transactionId].destination != address(0));
    require(confirmatons[transactionId][msg.sender]== false);
    confirmatons[transactionId][msg.sender]== true;
          emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);

}
    function submitTransaction(address destination,uint value,bytes memory data)
    public onlyCallableByOwner returns(uint transactionId){
        uint transactionId = addTransaction(destination,value,data);
         confirmTransaction(transactionId);


    }

  


}
  