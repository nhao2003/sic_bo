import path from "path";
import fs from "fs";
import solc from "solc";
import url from 'url';

const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const input = {
  language: "Solidity",
  sources: {
    "SicBo.sol": {
      content: fs.readFileSync(
        path.resolve(__dirname, "../contracts/SicBo.sol"),
        "utf8"
      ),
    },
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
};

const SicBo = JSON.parse(solc.compile(JSON.stringify(input))).contracts[
  "SicBo.sol"
]["SicBo"];

fs.writeFileSync(
  path.resolve(__dirname, "../contracts", "SicBo.json"),
  JSON.stringify(SicBo.abi, null, 2)
);

export default SicBo;
