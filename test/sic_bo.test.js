import { Web3 } from "web3";
import ganache from "ganache";
import HDWalletProvider from "@truffle/hdwallet-provider";
import dotenv from "dotenv";
dotenv.config();
const isProduction = true;

const provider = new HDWalletProvider(
  process.env.MNEMONIC,
  "https://sepolia.infura.io/v3/" + process.env.INFURA_API_KEY,
  process.env.ACCOUNT_INDEX
);
const web3 = new Web3(isProduction ? provider : ganache.provider());

const accounts = await web3.eth.getAccounts();
console.log(accounts);

const account = accounts[0];
const recipientAddress = "0xB119D8e465A9d2282244eba9f4029F271Ed08de2";
const value = web3.utils.toWei("1", "ether");

await web3.eth.sendTransaction({
  from: account,
  to: recipientAddress,
  value: value,
});