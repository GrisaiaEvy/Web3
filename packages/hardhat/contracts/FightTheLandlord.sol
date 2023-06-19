pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FightTheLandlord is Ownable {

    using SafeMath for uint256;

    uint256 public constant PLAYER_COUNT = 3;

    event Received(address sender, uint value);

    error AlreadyInMatch(address playerAddress);

    // 比赛信息，毫无疑问是固定人数
    mapping(string => Player[PLAYER_COUNT]) public matchInfos;

    // 地址、用户
    mapping(address => Player) public playerInfos;

    // 锁定的余额
    uint public lockedBalance;

    struct Match {
        string matchId;
        Player[PLAYER_COUNT] players;
    }

    struct Player {
        address _address;
        string _matchId;
        uint256 _matchCount;
        bool _isPay;
        uint _value;
    }

    constructor() {}

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function getAddressBalance() public view onlyOwner returns (uint256 bal) {
        bal = address(this).balance;
    }

    function createMatch(
        string memory matchId,
        address[PLAYER_COUNT] memory addresses
    ) public onlyOwner {
        Player[PLAYER_COUNT] storage players = matchInfos[matchId];
        for (uint i = 0; i < PLAYER_COUNT; i++) {
            address playerAddress = addresses[i];
            Player storage p = players[i];
            if (bytes(p._matchId).length != 0) {
                revert AlreadyInMatch(playerAddress);
            }
            p._address = playerAddress;
            p._matchId = matchId;
            p._matchCount += 1;
            playerInfos[playerAddress] = p;
        }
    }

    // 1.重新调整入场费，固定即可
    // 2.防止合约调用
    // 3.发币原理
    // plus：如何防止有人退出？这个多搜索一些artical，作为feature
    function pay() public payable {
        if (msg.value < 1 gwei) {
            revert("Wrong fee");
        }
        Player storage p = playerInfos[msg.sender];
        if (bytes(p._matchId).length == 0) {
            revert("Not in match");
        }
        p._value += msg.value;
        p._isPay = true;
    }

    // 1.检查是否已付费，可能需要销毁？关键就在于退出策略怎么做，决定这部分的逻辑
    function checkPayment(string memory matchId) public onlyOwner returns (address[] memory notPayPlayer) {
        bool allReady = true;
        for (uint i = 0; i < PLAYER_COUNT; i++) {
            if (!matchInfos[matchId][i]._isPay) {
                notPayPlayer[i] = matchInfos[matchId][i]._address;
                allReady = false;
            }
        }
        if (!allReady) {
            clearMatch(matchId);
        }
        return notPayPlayer;
    }

    function clearMatch(string memory matchId) internal  {
        Player[PLAYER_COUNT] storage players = matchInfos[matchId];
        for (uint i = 0; i < PLAYER_COUNT; i++) {
            Player storage p = players[i];
            if (p._isPay) {
                playDraw[p._address] += p._value;
            }
            delete p._matchId;
            delete p._isPay;
            delete p._value;
        }
    }

    mapping(address => uint) public playDraw;

    // 转账失败
    function withDraw() public  {
        payable(msg.sender).transfer(playDraw[msg.sender]);
        playDraw[msg.sender] = 0;
    }
    
    function rewardCal(string memory matchId, address[] memory winner, address[] memory loser) public onlyOwner {
        uint totalReward = 0;
        for (uint i = 0; i < loser.length; i++ ) {
            totalReward += playerInfos[loser[i]]._value;
        }
        uint reward = totalReward.div(winner.length);
        for (uint i = 0; i < winner.length; i++) {
            Player memory p = playerInfos[winner[i]];
            playDraw[winner[i]] += (p._value + reward);
        }
        clearMatch(matchId);
    }

    function getPlayerInfo()
        public
        view
        returns (Player memory)
    {
        return playerInfos[msg.sender];
    }


}
