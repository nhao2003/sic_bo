import path from "path";
import fs from "fs";
import solc from "solc";
import url from "url";

// Get the current file and directory paths
const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Define input for Solidity compilation
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

// Compile the Solidity code and retrieve the compiled contract
const compiledContract = JSON.parse(solc.compile(JSON.stringify(input)));
const SicBo = compiledContract.contracts["SicBo.sol"]["SicBo"];

// Write the ABI to a JSON file
fs.writeFileSync(
  path.resolve(__dirname, "../contracts", "SicBo.json"),
  JSON.stringify(SicBo, null, 2)
);

// Export the compiled contract
export default SicBo;
