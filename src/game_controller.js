import { Web3 } from "web3";
import ganache from "ganache";
import HDWalletProvider from "@truffle/hdwallet-provider";
import SicBo from "../src/compile.js";
const { abi, evm } = SicBo;
import dotenv from "dotenv";
dotenv.config();
const isProduction = true;
class GameController {
  constructor() {
    const provider = new HDWalletProvider(
      process.env.MNEMONIC,
      "https://sepolia.infura.io/v3/" + process.env.INFURA_API_KEY
    );
    this.web3 = new Web3(isProduction ? provider : ganache.provider());
  }

  async start() {
    this.accounts = await this.web3.eth.getAccounts();
    this.sicBo = await new this.web3.eth.Contract(abi)
      .deploy({
        data: evm.bytecode.object,
      })
      .send({
        from: this.accounts[0],
        gas: "3000000",
        value: this.web3.utils.toWei("0.1", "ether"),
      });
  }

  async settle(onSettling, onSettled) {
    if (!this.sicBo) {
      throw new Error("The game has not started yet");
    }
    const isFinished = await this.sicBo.methods.isFinished().call({
      from: this.accounts[0],
    });
    if (isFinished) {
      return;
    }
    try {
      if (!isProduction)
        await new Promise((resolve) => setTimeout(resolve, 4000));
      const nonce = await this.web3.eth.getTransactionCount(this.accounts[0]);
      await this.sicBo.methods.settle().send({
        from: this.accounts[0],
        gas: "3000000",
        nonce,
      });
    } catch (error) {
      throw error;
    } finally {
      this.isSettling = false;
    }
  }

  async getGameState() {
    if (!this.sicBo) {
      return null;
    }
    const address = this.sicBo.options.address;
    const getIsFinished = this.sicBo.methods.isFinished().call({
      from: this.accounts[0],
    });
    let getDices = this.sicBo.methods.getDices().call({
      from: this.accounts[0],
    });
    let [isFinished, dices] = await Promise.all([getIsFinished, getDices]);
    dices = dices.map((dice) => parseInt(dice));
    return {
      address,
      isFinished,
      dices: isFinished ? dices : [],
    };
  }

  bet() {
    if (!this.sicBo) {
      throw new Error("The game has not started yet");
    }
    return this.sicBo.methods.bet(Math.random() > 0.5).send({
      from: this.accounts[0],
      gas: "3000000",
      value: this.web3.utils.toWei("0.001", "ether"),
    });
  }

  reset() {
    this.sicBo = null;
  }
}

export default GameController;
