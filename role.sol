// SPDX-License-Identifier: Apache-2.0
pragma solidity^0.8.7;

//用户结构体
struct Person {
    string name;   //姓名
    string gender; //性别 用于后续的同步信号量设置
}

//角色结构体
struct UserRole {
    mapping(address => bool) isExistent; //当前用户是否存在(已经注册)
    mapping(address => Person) user;     //用户
    mapping(address => bool) islocked;   //当前用户是否已经被锁定
    mapping(address => uint256) account; //每个人的独立账户 记录有多少金额
    address[] isSigned;                  //是否已经单方签名
    uint256 NoPerson;
}
contract Role {

    //角色是否存在
    function isRole(UserRole storage m_role,  address m_person) internal view returns (bool) {
        if(m_person == address(0)) {
            return false;
        }
        return m_role.isExistent[m_person];
    }

    //添加角色 用户前端发起注册后，后端触发合约执行，系统完成角色信息填充
    function addRole(UserRole storage m_role, address m_person, string memory m_name, string memory m_gender) internal returns(bool) {
        if(isRole(m_role, m_person)) {
            return false;
        }
        m_role.isExistent[m_person] = true;
        m_role.user[m_person].name = m_name;
        m_role.user[m_person].gender = m_gender;
        m_role.islocked[m_person] = false;
        m_role.account[m_person] = 0;
        m_role.NoPerson += 1;
        return true;
    }

    //删除角色 用户前端发起注销账户后，后端触发合约执行，系统完成角色信息清除
    function removeRole(UserRole storage m_role,  address m_person) internal returns (bool) {
        if(!isRole(m_role, m_person)) {
            return false;
        }
        //清空信息
        delete m_role.isExistent[m_person];
        delete m_role.user[m_person];
        delete m_role.islocked[m_person];
        delete m_role.account[m_person];
        m_role.NoPerson -= 1;
        return true;
    }
    
}
