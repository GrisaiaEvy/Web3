import React, { useCallback, useState } from "react";
import CardRoom from "../components/CardRoom/App";
import { SiweMessage } from "siwe";

// 加密消息用
const domain = window.location.host;
const origin = window.location.origin;

export default function FightTheLandlord({ address, signer }) {
  const [selectedButton, setSelectedButton] = useState("");
  const [roomNumber, setRoomNumber] = useState("");
  const [inRoom, setInRoom] = useState(false);

  const handleCreateRoom = () => {
    // handle logic for creating new room
    setInRoom(true);
  };

  const handleReturn = () => {
    setInRoom(false);
  };

  const createSiweMessage = (address, statement) => {
    const message = new SiweMessage({
      domain: domain,
      address: address,
      statement: statement,
      uri: origin,
      version: "1",
      chainId: 31337,
      nonce: "j8IJgpOJtIDKqVuj",
    });
    return message.prepareMessage();
  };

  const signInWithEthereum = useCallback(async () => {
    const message = createSiweMessage(await address, "Sign in with Ethereum to the app.");
    console.log("私钥签名后的消息为");
    let signature = await signer.signMessage(message);
    console.log(signature);
    console.log(message);
    console.log(JSON.stringify({ message, signature }));
  }, [address, signer, createSiweMessage]);

  return (
    <div>
      {!inRoom && (
        <>
          <button onClick={() => setSelectedButton("匹配赛")}>匹配赛</button>
          <button onClick={() => setSelectedButton("房间赛")}>房间赛</button>
          <button onClick={() => setSelectedButton("周赛")}>周赛</button>
          <button onClick={signInWithEthereum}>签名</button>
          <br />
        </>
      )}
      {selectedButton === "房间赛" && !inRoom && (
        <>
          <br />
          <input
            type="text"
            value={roomNumber}
            onChange={e => setRoomNumber(e.target.value)}
            placeholder="输入房间号"
          />
          <br />
          <button style={{ marginRight: "10px" }} onClick={handleCreateRoom}>
            创建新房间
          </button>
          <button>加入房间</button>
        </>
      )}
      {inRoom && (
        <>
          <CardRoom />
          <button onClick={handleReturn}>返回</button>
        </>
      )}
      {!inRoom && <p>当前选择的按钮是：{selectedButton}</p>}
    </div>
  );
}
