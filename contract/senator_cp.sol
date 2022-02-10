// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// interface Ipledge{
//     function queryNodeRank(uint256 start, uint256 end) external view returns(address[] calldata, uint256[] calldata);
// }

// interface Iconf{
//     function pledge()external view returns(address);
//     function poc()external view returns(address);
// }

contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}

contract senator is Initialize {
    uint public epochId;                       //共识周期
    uint public epochIndate;                   //本届共识集有效期
    uint public executerId;                    //执法者序号
    uint public executerIndate;                //执法者有效期
    uint public executerIndex;                 //执法者在共识集中的序号
    
    address[] public senators;                 //当前共识集
    address public admin;                      //管理员

    event UpdateSenator(uint indexed _epochId, address[] _sentors, uint _epochIndate);
    event UpdateExecuter(uint indexed _executerId, address _executer, uint _executerIndate);

    modifier onlyAdmin{
        require(msg.sender == admin);
        _;
    }

    function initialize(address _admin) external init{
        admin = _admin;
    }

    function _getExecuter() internal view returns(address) {
         return senators[executerId];
    }
    
    //查询执法者
    function getExecuter() external view returns(address){
        return _getExecuter();
    }

    function _getNextExecuter() internal view returns(address) {
        if (executerIndex == senators.length) return senators[0]; 
        return senators[executerId+1];
    }
    
    //查询执法者继任人
    function getNextSenator() external view returns(address) {
        return _getNextExecuter();
    }

    //查询是否共识成员
    function isSenator(address user) external view returns(bool) {
        for (uint i=0; i< senators.length; i++){
            if (user == senators[i] && i != executerIndex) return true;
        }
        return false;
    }

    function setSenator(address[] memory _senators, uint _epochId, uint _epochIndate, uint _executerId, uint _executerIndate) external onlyAdmin{
        (senators, epochId, epochIndate, executerId, executerIndate) = (_senators, _epochId, _epochIndate, _executerId, _executerIndate);

        executerIndex = 0;
        emit UpdateSenator(epochId, senators, epochIndate);
        emit UpdateExecuter(executerId, _getExecuter(), executerIndate);
    }

    //更新执法者
    function setExecuter(uint _executerIndex, uint _executerId, uint _executerIndate) external onlyAdmin {
        (executerIndex, _executerId, _executerIndate) = (_executerIndex, _executerId, _executerIndate);
        emit UpdateExecuter(executerId, _getNextExecuter(), executerIndate);
    }
}