pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "github.com/oraclize/ethereum-api/provableAPI.sol";

/*
在上述示例中，我们首先导入了oraclize提供的Solidity库，并定义了一个名为RandomNumberGenerator的合约。该合约中包含一个公共的getRandomNumber函数，用于请求一个随机数。我们在该函数中调用了provable_query函数，向oraclize发送一个HTTP请求，并指定了需要请求的数据源和查询条件。

当oraclize返回随机数时，将调用合约中的__callback函数。在该函数中，我们首先检查调用者是否为oraclize回调地址，然后使用keccak256函数将oraclize返回的结果转换为随机数，并将其存储在randomNumber变量中。

需要注意的是，oraclize服务需要支付相应的费用，因此在使用oraclize时需要进行费用评估，并确保合约有足够的余额来支付费用。
*/

contract RandomNumberGenerator is usingProvable {

    uint256 public randomNumber;

    function getRandomNumber() public payable {
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        provable_query(QUERY_EXECUTION_DELAY, "WolframAlpha", "random number between 1 and 100", GAS_FOR_CALLBACK);
    }

    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
        require(msg.sender == provable_cbAddress());
        uint256 random = uint256(keccak256(abi.encodePacked(_result))) % 100 + 1;
        randomNumber = random;
    }
}
