import path from "path";
import fs from "fs";
const solc = require("solc");

const input = {
  language: "Solidity",
  sources: {
    "SicBo.sol": {
      content: fs.readFileSync(
        path.resolve(__dirname, "contracts", "SicBo.sol"),
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
export { SicBo };
