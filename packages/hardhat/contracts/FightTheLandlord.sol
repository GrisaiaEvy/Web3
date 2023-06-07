pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract FightTheLandlord {

    using SafeMath for uint256;

    // 54 张牌
    uint256 public constant DECK_SIZE = 54;

    uint256 public constant PLAYER_COUNT = 3;

    uint256 public constant CARDS_PER_PLAYER = 17;

    uint256 public constant BOTTOM_CARD_NUM = 3;

    event DealCard(address to, uint256[CARDS_PER_PLAYER] card);

    event Received(address sender, uint value);

    error AlreadyInMatch(address playerAddress);

    // 前端 -》 合约 -》 发牌到每个用户手上 -》 不经过服务器存储手牌
    // 出牌仅通过后端做传统webscoket服务
    // 需要一些校验规则，确保每个用户的发牌都是拥有的牌
    // 也就是说，不可逆、可局部验证的算法

    // map1 matchId -》 三个用户
    // map2 address -》 单个用户
    // map3 matchid -》 底牌

    // 比赛信息，毫无疑问是固定人数
    mapping(string => Player[PLAYER_COUNT]) public matchInfos;

    // 地址、用户
    mapping(address => uint256[CARDS_PER_PLAYER]) public playerInfos;

    // 比赛id、底牌
    mapping(string => uint256[BOTTOM_CARD_NUM]) bottomCards;

    // 锁定的余额
    uint public lockedBalance;

    struct Player {
        address _address;
        string _matchId;
        bool _isPay;
        bool _isLandlord;
        uint _value;
        uint256[] hands;
    }

    constructor() {}

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function getAddressBalance() public view onlyOwner returns (uint256 bal) {
        bal = address(this).balance;
    }

    // 1.如果有人已经在一场比赛中，则不能创建对局（无论如何也会用for循环）
    // plus：入场费能否根据配置文件动态加载？
    function createMatch(
        string memory matchId,
        address[PLAYER_COUNT] memory addresses
    ) external onlyOwner {
        Player[PLAYER_COUNT] storage players = matchInfos[matchId];
        for (uint i = 0; i < PLAYER_COUNT; i++) {
            address memory playerAddress = addresses[i];
            if (playerInfos[playerAddress] != nil) {
                revert(AlreadyInMatch(playerAddress));
            }
            Player storage p = players[i];
            p._address = playerAddress;
            p._matchId = matchId;
        }
    }

    // 1.重新调整入场费，固定即可
    // plus：如何防止有人退出？这个多搜索一些artical，作为feature
    function pay(string memory matchId) public payable {
        address player = msg.sender;
        if (msg.value < 1 gwei) {
            revert("Wrong fee");
        }
        Player storage p = playerInfos[player];
        if (p._matchId == "") {
            revert("Not in match");
        }
        p._value = p.value + msg.value;
        p._isPay = true;
    }

    // 1.检查是否已付费，可能需要销毁？关键就在于退出策略怎么做，决定这部分的逻辑
    function checkPayment(string memory matchId) public view onlyOwner returns (address[PLAYER_COUNT] memory notPayPlayer) {
        if (matchInfos[matchId].length == 0) {
            revert("Match not found!");
        }
        for (uint i = 0; i < PLAYER_COUNT; i++) {
            if (!matchInfos[matchId][i]._isPay) {
                notPayPlayer[i] = matchInfos[matchId][i]._address;
            }
        }
        // slice
        clearMatch;
        return notPayPlayer;
    }

    function clearMatch(string memory matchId) private {
        matchInfos[]
    }

    mapping(address => uint) public playDraw;

    function withDraw()  {

    }

    // 1.长期维护提取金额的数组，如果取完了则移除这个对象，节省内存
    // 2.拆分为两个函数 决定胜者、提取金额
    // 3.决定胜者：销毁对局，记录日志，分配金额
    // 4.这部分需要后端调用
    function rewardCal(string memory matchId) public {
        uint total;

        for (uint i = 0; i < PLAYER_COUNT; i++) {
            total += matchInfos[matchId][i]._value;
        }

        // 收5％
        total = total - total.mul(5).div(100);

        if (winner.length == 1) {
            payable(winner[0]).transfer(total);
        } else if (winner.length == 2) {
            payable(winner[0]).transfer(total.div(2));
            payable(winner[1]).transfer(total.div(2));
        }
    }

    // 1.随机数算法更改 预言机、kca函数、外部随机数
    // 2. owner
    // 3. heyu
    function shuffleCards() private returns (uint256[DECK_SIZE] memory) {
        uint256[DECK_SIZE] memory cards;
        // 洗牌算法
        // 倒序
        for (uint256 i = 0; i < DECK_SIZE; i++) {
            cards[i] = i;
        }
        // todo 不要使用blockhash
        for (uint256 i = 0; i < DECK_SIZE; i++) {
            uint256 j = i.add(uint256(blockhash(block.number - 1))) % DECK_SIZE;
            (cards[i], cards[j]) = (cards[j], cards[i]);
        }
        return cards;
    }

    function deal(string memory matchId) public onlyOwner {
        p1 = matchInfos[matchId][0];
        p2 = matchInfos[matchId][0];
        p3 = palyers[2];

        uint256[DECK_SIZE] memory cards = shuffleCards();

        uint256 cardIndex = 0;
        for (uint256 i = 0; i < PLAYER_COUNT; i++) {
            for (uint256 j = 0; j < CARDS_PER_PLAYER; j++) {
                playerHands[palyers[i]][j] = cards[cardIndex];
                cardIndex++;
            }
        }
        for (uint256 i = 51; i < DECK_SIZE; i++) {
            bottomCards[i - 51] = cards[i];
        }
        for (uint256 i = 0; i < PLAYER_COUNT; i++) {
            // ？？ 怎么保存对局的手牌信息？公钥加密？
            emit DealCard(palyers[i], playerHands[palyers[i]]);
        }
    }

    // 根据对局UUID和地址获取卡牌
    // 1.确实是view函数
    function getPlayerInfo()
        public
        view
        returns (Player memory)
    {
        return playerInfos[msg.sender];
    }

    // 1.不是view
    // 2.获取的用户会成为地主
    // 3.如何快速索引到地主？swap数组位置
    function getBottomCards(string memory matchId)
        public
        view
        onlyOwner
        returns (uint256[BOTTOM_CARD_NUM] memory)
    {
        return bottomCards[matchId];
    }
}
