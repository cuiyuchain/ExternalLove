// SPDX-License-Identifier: Apache-2.0
pragma solidity^0.8.7;
import "./role.sol";

struct EternalLock {
        bytes32 hashLove; //爱情哈希
        uint256 date;
        uint256 Date;
        uint256 m_sum; //男方设定金额
        uint256 f_sum; //女方设定金额
        address m_pk;
        address f_pk;
    }

contract EternalLockEvidence is Role{
 
    uint256 sumChain;   //链上总金额
    
    address[] blackList;    //黑名单
    address admin;      //管理员地址
    UserRole userRole;
    EternalLock[] eternalLock;
    mapping(address => mapping(address => EternalLock)) locked; //已锁定者列表 双方绑定一个标识

    event AddSignaturesEvidence(address _sender);

    constructor(address m_admin) {
        sumChain = 10000; //创始人自掏腰包
        admin = m_admin;
    }
    //判断是否在黑名单里
    function judgeIsInBlackList(address m_user) public view returns (bool) {
        for(uint256 i = 0; i < blackList.length; i++) {
            if(blackList[i] == m_user) {
                return true;
            }
        }
        return false;
    }

    //单方签名 
    function sign(address m_signer) external returns(bool) {
        require(isRole(userRole, m_signer), "the Signer is not existent!");
        require(m_signer != admin, "the Signer is not valid!");
        require(!judgeIsSigned(m_signer), "the user has already signed!");
        
        userRole.isSigned.push(m_signer);  //将公钥地址放入已签名列表
        emit AddSignaturesEvidence(m_signer);

        return true;
    }

    //判重
    function verify(address m_signer) internal view returns (bool) {
        for(uint256 i = 0; i < userRole.isSigned.length; i ++) {
            if (userRole.isSigned[i] == m_signer) {
                return true;
            }
        }       
        return false;
    }

    //山海珈锁
    function lockEternal(address _m_pk, address _f_pk, uint256 _m_sum, uint256 _f_sum, uint256 m_date, uint256 m_Date) public returns (bool) {
        //判断是否均签名
        if(judgeIsSigned(_m_pk) && judgeIsSigned(_f_pk) && !userRole.islocked[_m_pk] && !userRole.islocked[_f_pk]) {
 
        //用户是否初次使用(未实现)

            bytes32 m_hash = keccak256(abi.encode(_m_pk,  _f_pk, _m_sum, _f_sum, m_date, m_Date));
            EternalLock memory el = EternalLock(m_hash, m_date, m_Date, _m_sum, _f_sum, _m_pk,  _f_pk);
            locked[_m_pk][_f_pk] = el;

            userRole.islocked[_m_pk] = true;
            userRole.islocked[_m_pk] = true;//互斥
            return true;

        } else {

            return false;
        }
        
    }

    //查询爱情哈希值
    function getEvidence(address _m_pk, address _f_pk) external view returns (bytes32 h) {
        
        return locked[_m_pk][_f_pk].hashLove;
    }

    //返回山海珈锁结构体
    function retEternalLock(address _m_pk, address _f_pk) public view returns (EternalLock memory h) {
        
        return locked[_m_pk][_f_pk];
    }

    //判断是否已经签名
    function judgeIsSigned(address m_person) public view returns (bool) {      
        for(uint256 i = 0; i < userRole.isSigned.length; i++) {
            if(userRole.isSigned[i] == m_person) {
                return true;
            }
        }

        return false;
    }

    //清除签名 相当于解锁 解开互斥
    function deleteLock(address m_person) public returns (bool) {
        for(uint256 i = 0; i < userRole.isSigned.length; i++) {
            if(userRole.isSigned[i] == m_person) {
                delete userRole.isSigned[i];
                return true;
            }
        }
        return false;
    }

    //修改date值
    function changeDataLock(address _m_pk, address _f_pk, uint256 n_date) public returns (bool) {
        locked[_m_pk][_f_pk].date = n_date;
        return true;
    }

    //换取景区纪念品
    function purchaseSouvenirs(uint256 price, address m_buyer) public returns (bool) {
        //余额不足
        require((userRole.account[m_buyer] >= price), "Insufficient Balance!");
        userRole.account[m_buyer] -= price; //低版本则需要SafeMath
        return true;
    }

    //用户获取奖励
    function getAwards(uint256 sum, address m_person) public returns (bool) {
        userRole.account[m_person] += sum;
        return true;
    } 

    //拉黑
    function putIntoBlackList(address m_person) public {
        blackList.push(m_person);
    }

    //注册用户
    function registerUser(string memory m_name, string memory m_gender, address m_person) public returns (bool) {
        return addRole(userRole, m_person, m_name, m_gender);
    }

    //注销用户
    function cancelUser(address m_person) public {
        removeRole(userRole, m_person);  
    }

    //查询用户
    function queryUser(address m_person) public view returns (string memory, string memory) {
        return (userRole.user[m_person].name, userRole.user[m_person].gender);
    }

    //查询已注册总人数
    function queryNoUser() public view returns (uint256) {
        return userRole.NoPerson;
    }
    //违约 ==> 选择1 ==> 支付金额 ==> 系统触发
    //违约 ==> 选择2 ==> 延期 ==> 系统触发
    //违约 ==> 选择2 ==> 拉黑 ==> 系统触发
    
    //提前异常开锁 / 超期 ==> 后端完成付费，合约中只计算金额
    function payAmount(address _m_pk, address _f_pk, uint256 time) public returns (bool, uint256) {
        require(judgeIsSigned(_m_pk) && judgeIsSigned(_f_pk), "not locked yet!");
        EternalLock memory e = retEternalLock(_m_pk, _f_pk);
        
        uint256 d = e.date;
        uint256 D = e.Date;
        uint256 key = (e.m_sum + e.f_sum) * (d - D) / (time - D);
        sumChain += key * 2; 
        //解锁
        deleteLock(_m_pk);
        deleteLock(_f_pk);
        return (true, key);
    }
    
    //延期
    function delay(address _m_pk, address _f_pk, uint256 new_date) public returns (bool, uint256) {
        require(judgeIsSigned(_m_pk) && judgeIsSigned(_f_pk), "not locked yet!");
        EternalLock memory e = retEternalLock(_m_pk, _f_pk);
        uint256 d = e.date;
        uint256 D = e.Date;
        uint256 key = (e.m_sum + e.f_sum) * (new_date - D) / (d - D) / 100 ; 
        sumChain += key * 2;
        changeDataLock(_m_pk, _f_pk, new_date); 
        return (true, key);
    }
   
    //后端认证结婚信息后，触发奖励合约
    function giveRewards(address _m_pk, address _f_pk, uint256 time) public returns (bool) {
        require(judgeIsSigned(_m_pk) && judgeIsSigned(_f_pk), "not locked yet!");
        EternalLock memory e = retEternalLock(_m_pk, _f_pk);
        uint256 d = e.date;
        uint256 D = e.Date;
        uint256 key = sumChain * (time - D) / (d - D) / 100; 
        sumChain -= (key * 2);
        getAwards(key, _m_pk);
        getAwards(key, _f_pk);
        return true;
    }

    //查询用户获取的奖励
    function queryUserAwards(address m_person) public view returns (uint256) {
        return userRole.account[m_person];
    } 
    
    //查看链上总金额
    function querySumChain() public view returns (uint256) {
        return sumChain;
    }
}
