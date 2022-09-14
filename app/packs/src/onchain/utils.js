import { ethers } from "ethers";
import Addresses from "./addresses.json";

export const parseAndCommify = (value, nrOfDecimals = 2) => {
  return ethers.utils.commify(parseFloat(value).toFixed(nrOfDecimals));
};

export const ipfsToURL = (ipfsAddress) => {
  return "https://ipfs.io/" + ipfsAddress.replace("://", "/");
};

export const getENSFromAddress = async (walletAddress, apiKey) => {
  let name = null;
  try {
    const provider = new ethers.providers.EtherscanProvider("mainnet", apiKey);
    name = await provider.lookupAddress(walletAddress);
  } catch (err) {
    console.log(err);
  }
  return name;
};

export const chainIdToName = (chainId, env) => {
  if (Addresses[env][chainId]) {
    return Addresses[env][chainId].chainName;
  }
};

export const chainNameToId = (chainName, env) => {
  const chainId = Object.keys(Addresses[env]).filter(
    (item) => Addresses[env][item].chainName == chainName
  );

  if (chainId.length == 0) {
    return undefined;
  }

  return Addresses[env][chainId[0]].chainId;
};

export const getAllChainOptions = (env) => {
  return Object.keys(Addresses[env]).map((chain) => ({
    name: Addresses[env][chain].chainName,
    id: Addresses[env][chain].chainId,
  }));
};
