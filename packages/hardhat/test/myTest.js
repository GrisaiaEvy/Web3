const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("My Dapp", function () {
  let myContract;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  describe("eth-gas-reporter workaround", () => {
    it("should kill time", (done) => {
      setTimeout(done, 2000);
    });
  });

  describe("斗地主合约", function () {
    it("部署合约", async function () {
      const YourContract = await ethers.getContractFactory("FightTheLandlord");

      myContract = await YourContract.deploy();
    });


    describe("createMatch()", function () {
      it("应该创建了新房间", async function () {
        const addressArr = ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "0x5D9eDc2beEbbb1b72cfa7659f903d7d8f56e3376", "0xf3b83cb1b83484BFD51720Fa73592F785603e177"];
        await myContract.createMatch("abc", addressArr);
        
      });

      it("支付房间费", async function () {

      });


      it("支付房间费", async function () {
        
      });
    });

    // describe("setPurpose()", function () {
    //   it("应该设置了新的purpose", async function () {
    //     const newPurpose = "Test Purpose";
    //     // 先调方法设置了新的purpose，然后查看是否设置成功
    //     await myContract.setPurpose(newPurpose);
    //     expect(await myContract.purpose()).to.equal(newPurpose);
    //   });

    //   it("应该提交了新的purpose事件", async function () {
    //     const [owner] = await ethers.getSigners();

    //     const newPurpose = "Another Test Purpose";

    //     expect(await myContract.setPurpose(newPurpose))
    //       .to.emit(myContract, "SetPurpose")
    //       .withArgs(owner.address, newPurpose);
    //   });
    // });
  });
});
