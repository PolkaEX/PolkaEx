/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import { Provider } from "@ethersproject/providers";
import type {
  WhitelistAdminRole,
  WhitelistAdminRoleInterface,
} from "../WhitelistAdminRole";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "WhitelistAdminAdded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "WhitelistAdminRemoved",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "addWhitelistAdmin",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "isWhitelistAdmin",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceWhitelistAdmin",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export class WhitelistAdminRole__factory {
  static readonly abi = _abi;
  static createInterface(): WhitelistAdminRoleInterface {
    return new utils.Interface(_abi) as WhitelistAdminRoleInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): WhitelistAdminRole {
    return new Contract(address, _abi, signerOrProvider) as WhitelistAdminRole;
  }
}
