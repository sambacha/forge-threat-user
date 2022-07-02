/// SPDX-License-Identifier: Apache-2.0 OR MIT

pragma solidity ^0.8.15;

contract ThreatUser {
    address public owner;
    uint256 private key;
    constructor() payable {
        owner = address(0xdeadbeef);
        key = 32;
    }
    modifier onlyOwner() {
        require(msg.sender == owner,"!OWNER");
        _;
    }

    // @setKey
    function setKey(uint256 _key) public onlyOwner {
        key = _key;
    }

    // @getOwner
    function getOwner() public view returns (address) {
        return owner;
    }

    // @hack
    function hack(uint256 _key) public {
        require(key == _key, "[ERR]: Wrong Key");
        payable(address(msg.sender)).transfer(address(this).balance);
    }
    receive() external payable{}
}

pragma solidity ^0.8.15;

import "ds-test/test.sol";
import "forge-std/Vm.sol";

import "ThreatUser.sol";
contract ThreatUserTest is DSTest {
    ThreatUser public tuser;
    Vm public vm = Vm(HEVM_ADDRESS);

    function setUp() public {
        tuser = new ThreatUser{value: 10 ether}();
        vm.label(address(tuser), "tuser");
    }
    function testFail_setKey() public {
        vm.expectRevert();
        tuser.setKey(10);
    }
    function test_setKeyPrankOwner(uint256 _key) public {
        address owner = tuser.owner();
        vm.startPrank(owner);
        tuser.setKey(_key);
        vm.stopPrank();
    }
    function test_setKeyPrankOwner() public {
        address owner = tuser.owner();
        vm.startPrank(owner);
        tuser.setKey(10);
        vm.stopPrank();
    }
    
    function test_getOwner() public {
        assertEq(tuser.owner(),address(0xdeadbeef));
    }
    function test_hack() public payable {
        uint256 balanceBefore = address(this).balance;
        tuser.hack(32);
        assertEq(address(this).balance - balanceBefore, 10 ether);
    }
    receive() external payable{}
}
