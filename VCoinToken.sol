pragma solidity ^0.4.23;

contract TokenStakerInterface {
    function receiveApproval(address _from, uint256 _amount) public returns (bool);
}

contract VCoinToken {
    string public constant name = "TronVegasCoin";
    string public constant symbol = "VCOIN";
    uint8 public constant decimals = 6;
    // Create a table so that we can map addresses to the balances associated with them
    mapping(address => uint256) balances;
    // Create a table so that we can map the addresses of contract owners to those who are allowed to utilize the owner's contract
    mapping(address => mapping (address => uint256)) allowed;
    // total amount of VCoin Token.
    uint256 _totalSupply = 100000000000000;
    // Owner of this contract
    address private owner;

    // pool address for save all the tokens.
    address internal poolAddr;

    constructor() public {
        owner = msg.sender;
    }
    
    // init and set all balances to pool.
    function initBalanceToPool(address _poolAddr) public {
        require(msg.sender == owner, "Need owner permission.");
        require(poolAddr == address(0), "Already set poolAddr.");
        poolAddr = _poolAddr;
        balances[poolAddr] = _totalSupply;  // set all token to the pool
    }
    
    function getPoolAddr() public view returns (address) {
        require(msg.sender == owner, "Need owner permission.");
        return poolAddr;
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner, "Need owner permission.");
        owner = _newOwner;
    }

    bool canApprove = true;
    // set whether can call the 'approveAndCall' function.
    function setCanApproveCall(bool _val) public {
        require(msg.sender == owner, "Need owner permission.");
        canApprove = _val;
    }
    // check whether 'approveAndCall' can be used.
    function canApproveCall() public view returns (bool) {
        return canApprove;
    }
    // Called when user want to freeze VCoin
    function approveAndCall(address _spender, uint256 _amount) public returns (bool success) {
        require(canApprove, "approveAndCall is not available for now.");
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        success = TokenStakerInterface(_spender).receiveApproval(msg.sender, _amount);
    }

    function totalSupply() public view returns (uint256 theTotalSupply) {
        theTotalSupply = _totalSupply;
        return theTotalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    // Note: This function returns a boolean value
    //			 indicating whether the transfer was successful
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(balances[msg.sender] >= _amount, "Not enough balance.");
        if (_amount > 0 && balances[_to] + _amount > balances[_to]) {

            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(allowed[_from][msg.sender] >= _amount, "Not enough allowance.");
        require(balances[_from] >= _amount, "Not enough balance.");
        if (_amount > 0 && balances[_to] + _amount > balances[_to]) {

            balances[_from] -= _amount;
            balances[_to] += _amount;
            allowed[_from][msg.sender] -= _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}