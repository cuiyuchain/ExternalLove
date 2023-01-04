// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.7;
import "./evidence.sol";
contract ExternalLove {
    EternalLockEvidence eternalEvid;
    address admin;
    constructor() {     
        admin = msg.sender;
        eternalEvid = new EternalLockEvidence(admin);
    }

    //签名 ==> 用户触发
    function sign() public returns (bool) {
        eternalEvid.sign(msg.sender);
        return true;
    }

    //开启山海珈锁
    function lockEternal(address _m_pk, address _f_pk, uint256 _m_sum, uint256 _f_sum, uint256 m_date, uint256 m_Date) public returns (bool){
        return eternalEvid.lockEternal(_m_pk, _f_pk, _m_sum, _f_sum, m_date, m_Date);
    }
    
    //提前开锁，则需要支付金额，末参数动态处理
    function breakContract(uint8 choice, address _m_pk, address _f_pk, uint256 t) public {
        if(choice == 0) {
            eternalEvid.payAmount(_m_pk, _f_pk, t);
        }else if(choice == 1) {
            eternalEvid.delay(_m_pk, _f_pk, t);
        }
    }

    //拉黑
    function putIntoBlackList(address m_person) public {
        eternalEvid.putIntoBlackList(m_person);
    }

    //查询爱情哈希值
    function getHashLove(address _m_pk, address _f_pk) public view returns (bytes32) {
        bytes32 hash = eternalEvid.getEvidence( _m_pk, _f_pk);
        require(hash != bytes32(0), "invalid hash!");
        return hash;
    }

    //成功提供结婚信息，发放奖励，返回所有支付金额
    function giveRewards(address _m_pk, address _f_pk, uint256 time) public returns (bool) {
         require(msg.sender == admin, "must be adminer!");
         return eternalEvid.giveRewards(_m_pk, _f_pk, time);
    }

    //将奖励用于兑换景区纪念品
    function purchaseSouvenirs(uint256 price) public returns (bool) {
         return eternalEvid.purchaseSouvenirs(price, msg.sender);
    }

    //注册用户
    //规定合约参数 m_gender: male or female
    function registerNewUser(string memory m_name, string memory m_gender) public returns (bool) {
        return eternalEvid.registerUser(m_name, m_gender, msg.sender);
    }

    //注销用户
    function cancelUser(address m_person) public returns (bool) {
        eternalEvid.cancelUser(m_person);
        return true;
    }

    //查询用户
    function queryUser(address m_person) public view returns (string memory, string memory) {
        return eternalEvid.queryUser(m_person);       
    }

    //查询已注册总人数
    function queryNoUser() public view returns (uint256) {
        return eternalEvid.queryNoUser();
    }

    //查询用户获取的奖励
    function queryUserAwards() public view returns (uint256) {
        return eternalEvid.queryUserAwards(msg.sender);
    }

    //查看链上总金额
    function querySumChain() public view returns (uint256) {
        require(msg.sender == admin, "must be adminer");
        return eternalEvid.querySumChain();
    }

}
//admin 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//test: 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678 cuiyu
 //     0xdD870fA1b7C4700F2BD7f44238821C26f7392148 ding
