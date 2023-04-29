import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { expect } from "chai";

describe("RES4Token", function () {
  let RES4Token: ContractFactory;
  let res4Token: Contract;

  beforeEach(async function () {
    RES4Token = await ethers.getContractFactory("RES4Token");
    res4Token = await RES4Token.deploy();
    await res4Token.deployed();
  });

  it("Should add an asset", async function () {
    expect(0).to.equal(0);
    await res4Token.addAsset("123 Main St", "", "Anytown", "CA", "USA", ethers.constants.AddressZero);
    const asset = await res4Token.getAsset(0);
    expect(asset.owner).to.equal(ethers.constants.AddressZero);
    expect(asset.address1).to.equal("123 Main St");
    expect(asset.city).to.equal("Anytown");
  });

  it("Should add value to an asset", async function () {
    await res4Token.addAsset("456 Oak St", "", "Anytown", "CA", "USA", ethers.constants.AddressZero);
    await res4Token.addValue(0, ethers.utils.parseEther("10"));
    const asset = await res4Token.getAsset(0);
    expect(asset.value).to.equal(ethers.utils.parseEther("10"));
  });

  it("Should approve an asset for sale", async function () {
    await res4Token.addAsset("789 Pine St", "", "Anytown", "CA", "USA", ethers.constants.AddressZero);
    await res4Token.approveSale(0, ethers.constants.AddressZero);
    const asset = await res4Token.getAsset(0);
    expect(asset.approvedBuyer).to.equal(ethers.constants.AddressZero);
  });

  it("Should purchase an asset", async function () {
    const [owner1, owner2] = await ethers.getSigners();
    const value = ethers.utils.parseEther("100");
    await res4Token.addAsset("101 Elm St", "", "Anytown", "CA", "USA", owner1.address);
    await res4Token.addValue(0, value);
    await res4Token.approveSale(0, owner2.address);

    const previousOwnerBalance = await ethers.provider.getBalance(owner1.address);
    await res4Token.connect(owner2).purchaseAsset(0, { value });
    const asset = await res4Token.getAsset(0);
    const newOwnerBalance = await ethers.provider.getBalance(owner2.address);

    expect(asset.owner).to.equal(owner2.address);
    expect(asset.value).to.equal(ethers.constants.Zero);
    expect(asset.approvedBuyer).to.equal(ethers.constants.AddressZero);
    expect(await res4Token.ownerToAsset(owner1.address, 0)).to.equal(false);
    expect(await res4Token.ownerToAsset(owner2.address, 0)).to.equal(true);
    expect(newOwnerBalance).to.equal(previousOwnerBalance.add(value));
  });
});
