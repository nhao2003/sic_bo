import { beforeEach, describe, it } from "node:test";

import assert from "assert";
import ganache from "ganache";
import { Web3 } from "web3";
import SicBo  from "../src/compile.js";
const web3 = new Web3(ganache.provider());

const { abi, evm } = SicBo;

let accounts;
let sicBo;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
  sicBo = await new web3.eth.Contract(abi)
    .deploy({ data: evm.bytecode.object })
    .send({
      from: accounts[0],
      gas: "2000000",
      gasPrice: "10000000000",
      value: web3.utils.toWei("2", "ether"),
    });
});

describe("SicBo", () => {
  it("deploys a contract", () => {
    assert.ok(sicBo.options.address);
  });

  it("allows one account to bet", async () => {
    sicBo.methods.bet(true).send({
      from: accounts[0],
      value: web3.utils.toWei("0.001", "ether"),
    }).then((result) => {
      console.log(result);
    }).catch((err) => {
      console.log(err);
    });
    // const players = await sicBo.methods.getPlayers().call({
    //   from: accounts[0],
    // });
    // assert.equal(accounts[0], players[0]);

  });

  
});

