import { Card } from "antd";
import { useContractExistsAtAddress, useContractLoader } from "eth-hooks";
import React, { useMemo, useState } from "react";
import Address from "../Address";
import Balance from "../Balance";
import DisplayVariable from "./DisplayVariable";
import FunctionForm from "./FunctionForm";

const noContractDisplay = (
  <div>
    Loading...{" "}
    <div style={{ padding: 32 }}>
      You need to run{" "}
      <span
        className="highlight"
        style={{ marginLeft: 4, /* backgroundColor: "#f1f1f1", */ padding: 4, borderRadius: 4, fontWeight: "bolder" }}
      >
        yarn run chain
      </span>{" "}
      and{" "}
      <span
        className="highlight"
        style={{ marginLeft: 4, /* backgroundColor: "#f1f1f1", */ padding: 4, borderRadius: 4, fontWeight: "bolder" }}
      >
        yarn run deploy
      </span>{" "}
      to see your contract here.
    </div>
    <div style={{ padding: 32 }}>
      <span style={{ marginRight: 4 }} role="img" aria-label="warning">
        ☢️
      </span>
      Warning: You might need to run
      <span
        className="highlight"
        style={{ marginLeft: 4, /* backgroundColor: "#f1f1f1", */ padding: 4, borderRadius: 4, fontWeight: "bolder" }}
      >
        yarn run deploy
      </span>{" "}
      <i>again</i> after the frontend comes up!
    </div>
  </div>
);

const isQueryable = fn => (fn.stateMutability === "view" || fn.stateMutability === "pure") && fn.inputs.length === 0;

// 显示合约接口
export default function Contract({
  customContract,
  account,
  gasPrice,
  signer,
  provider,
  name,
  show,
  price,
  blockExplorer,
  chainId,
  contractConfig,
}) {
  // 拿到区块链上的合约列表，通过provider获取
  const contracts = useContractLoader(provider, contractConfig, chainId);

  // 合约
  let contract;
  // 是否为自定义合约
  if (!customContract) {
    // 根据名称拿到合约
    contract = contracts ? contracts[name] : "";
  } else {
    contract = customContract;
  }

  const address = contract ? contract.address : "";
  const contractIsDeployed = useContractExistsAtAddress(provider, address);

  // 这里的合约接口来自ethers.js
  const displayedContractFunctions = useMemo(() => {
    const results = contract
      ? Object.entries(contract.interface.functions).filter(
          // 只显示函数，且函数名称大于0
          fn => fn[1]["type"] === "function" && !(show && show.indexOf(fn[1]["name"]) < 0),
        )
      : [];
    return results;
  }, [contract, show]);

  const [refreshRequired, triggerRefresh] = useState(false);

  // 每一个合约接口的逻辑
  const contractDisplay = displayedContractFunctions.map(contractFuncInfo => {
    // 如果为只读函数，那么直接获取，否则要通过signer链接获取
    // const contractFunc =
    //   contractFuncInfo[1].stateMutability === "view" || contractFuncInfo[1].stateMutability === "pure"
    //     ? contract[contractFuncInfo[0]]
    //     : contract.connect(signer)[contractFuncInfo[0]];

    // 无论如何都签名调用
    const contractFunc = contract.connect(signer)[contractFuncInfo[0]];

    //
    if (typeof contractFunc === "function") {
      if (isQueryable(contractFuncInfo[1])) {
        // 如果无需输入参数，则直接返回结果
        return (
          <DisplayVariable
            key={contractFuncInfo[1].name}
            contractFunction={contractFunc}
            functionInfo={contractFuncInfo[1]}
            refreshRequired={refreshRequired}
            triggerRefresh={triggerRefresh}
            blockExplorer={blockExplorer}
          />
        );
      }

      // 如果需要参数，则让用户进行输入
      return (
        <FunctionForm
          key={"FF" + contractFuncInfo[0]}
          contractFunction={contractFunc}
          functionInfo={contractFuncInfo[1]}
          provider={provider}
          gasPrice={gasPrice}
          triggerRefresh={triggerRefresh}
        />
      );
    }
    return null;
  });

  return (
    <div style={{ margin: "auto", width: "70vw" }}>
      <Card
        title={
          <div style={{ fontSize: 24 }}>
            {name}
            <div style={{ float: "right" }}>
              <Address value={address} blockExplorer={blockExplorer} />
              <Balance address={address} provider={provider} price={price} />
            </div>
          </div>
        }
        size="large"
        style={{ marginTop: 25, width: "100%" }}
        loading={contractDisplay && contractDisplay.length <= 0}
      >
        {contractIsDeployed ? contractDisplay : noContractDisplay}
      </Card>
    </div>
  );
}
