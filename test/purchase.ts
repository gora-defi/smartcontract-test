import { expect } from "chai";
import { ethers } from "hardhat";
import hre from "hardhat";
import { Contract, Signer } from "ethers";

describe("Purchase Contract", function () {
  let owner: Signer;
  let Admin: Signer;
  let addr1: Signer;
  let addr2: Signer;
  let usdt: Contract;
  let gora: Contract;
  let lp: Contract;
  let purchase: Contract;

  //Deploy contracts once before running all tests
  before(async () => {
    [owner, Admin,addr1, addr2] = await hre.ethers.getSigners();

    const USDT = await hre.ethers.getContractFactory("USDT");
    usdt = await USDT.deploy(await Admin.getAddress());

    const GORA = await hre.ethers.getContractFactory("GORA");
    gora = await GORA.deploy(await Admin.getAddress());

    const LP = await hre.ethers.getContractFactory("GORALP");
    lp = await LP.deploy(usdt.target, gora.target, await Admin.getAddress());

    const Purchase = await hre.ethers.getContractFactory("Purchase");
    purchase = await Purchase.deploy(
      await Admin.getAddress(),
      lp.target,
      usdt.target,
      gora.target
    );
    //
    const CONTROLLER_ROLE = await gora.CONTROLLER_ROLE();

    await gora.connect(Admin).grantRole(CONTROLLER_ROLE, purchase.target);
    await lp.connect(Admin).grantRole(CONTROLLER_ROLE, purchase.target);
    await lp.connect(Admin).setController(purchase.target);

    console.log("GORA:", gora.target);
    console.log("USDT:", usdt.target);
    console.log("lp:", lp.target);
    console.log("pruchase:", purchase.target);


  });

  describe("GORA-User Features", function () {
  //   it("LP deployment and initial price check", async function () {
  //       const price = await lp.getPrice();
  //       expect(price).to.equal(ethers.parseEther("0.01"));
  //   });

  //   it("GORA deployment and admin check", async function () {
  //       const admin = await gora.Admin();
  //       expect(admin).to.equal(await Admin.getAddress());
  //   });

  //   it("Buy tokens with USDT", async function () {

  //     let amount = await ethers.parseEther("100000");
  //     //usdt transfer
  //      await usdt.connect(Admin).transfer(await addr1.getAddress(), amount);
  //     //usdt approval to purchaseContract
  //       await usdt.connect(addr1).approve(purchase.target, amount);
  //     //Buy token
  //       await purchase.connect(addr1).Buy(await ethers.parseEther("1000"));


  //     //calculation

  //     let balance = (100000 /0.01)*1e18;
  //     let expected_balance = await ethers.parseEther("500");

  //     //tokenPrice

  //     let reserveA = parseInt(await usdt.balanceOf(lp.target));
  //     let reserveB = parseInt((await gora.totalSupply()));

  //     let price = (reserveA/reserveB)*1e18;

  //     //get UserDetails
  //     let result = await purchase.getUserDetails(await addr1.getAddress());
  //     expect(parseInt(result[4])).to.equal(balance);
  //     expect(await usdt.balanceOf(lp.target)).to.equal(expected_balance);
  //     expect(await usdt.balanceOf(purchase.target)).to.equal(expected_balance);
  //     expect(parseInt(await lp.getPrice())).to.equal(price)
  //   })

  //   it("reBuy tokens with USDT", async function () {

  //     let amount = await ethers.parseEther("100");
  //     //usdt transfer
  //      await usdt.connect(Admin).transfer(await addr1.getAddress(), amount);
  //     //usdt approval to purchaseContract
  //       await usdt.connect(addr1).approve(purchase.target, amount);
  //     //Buy token
  //       await purchase.connect(addr1).reBuy(amount);

  //     //tokenPrice

  //     let reserveA = parseInt(await usdt.balanceOf(lp.target));
  //     let reserveB = parseInt((await gora.totalSupply()));

  //     let price = (reserveA/reserveB)*1e18;

  //     let expected_balance = await ethers.parseEther("100");

  //     //get UserDetails
  //     expect(parseInt(await lp.getPrice())).to.equal(price)
  //     expect(await usdt.balanceOf(lp.target)).to.equal(expected_balance);
  //     expect(await usdt.balanceOf(purchase.target)).to.equal(expected_balance);
  //   })

  // it("sell tokens -> USDT", async function () {

  //     let amount = await ethers.parseEther("60000");

  //     //usdt approval to purchaseContract
  //     await gora.connect(addr1).approve(purchase.target, amount);
  //     //Buy token
  //     await expect(purchase.connect(addr1).sell(amount)).to.emit(gora, "Burn")
  //         .withArgs(purchase.target, await ethers.ZeroAddress, amount);

  //     //tokenPrice

  //     let reserveA = parseInt(await usdt.balanceOf(lp.target));
  //     let reserveB = parseInt((await gora.totalSupply()));

  //     let price = (reserveA/reserveB)*1e18;
  //     console.log("PRICE:", price)

  //     let expected_balance = await ethers.parseEther("22.5");

  //     expect(await usdt.balanceOf(await addr1.getAddress())).to.equal(expected_balance);
  //     expect(await usdt.balanceOf(purchase.target)).to.equal(await ethers.parseEther("100"));

  //   })
  // });

  // describe("GORA-Admin Features", function() {

  //   it("add Liquidity-Admin", async function() {
  //       let amount = await ethers.parseEther("2500");
  //       //usdt approval to purchaseContract
  //       await usdt.connect(Admin).approve(purchase.target, amount);

  //       await purchase.connect(Admin).addLiquidity(amount);

  //       //tokenPrice

  //       let reserveA = parseInt(await usdt.balanceOf(lp.target));
  //       let reserveB = parseInt((await gora.totalSupply()));

  //       let price = (reserveA/reserveB)*1e18;
  //       console.log("PRICE:", price)
  //   })

  //   it("withdraw-Shares", async function(){
  //     await purchase.connect(Admin).withdrawShare();
  //   })


    it("scenario", async function () {
            let amount = await ethers.parseEther("1000");
            //usdt transfer
            await usdt.connect(Admin).transfer(await addr2.getAddress(), amount);
            //usdt approval to purchaseContract
            await usdt.connect(addr2).approve(purchase.target, amount);
            //Buy token
            await purchase.connect(addr2).Buy(await ethers.parseEther("1000"));


            amount = await ethers.parseEther("25000");
            //usdt approval to purchaseContract
            await usdt.connect(Admin).approve(purchase.target, amount);

            await purchase.connect(Admin).addLiquidity(amount);

            //tokenPrice

            let reserveA = parseInt(await usdt.balanceOf(lp.target));
            let reserveB = parseInt((await gora.totalSupply()));

            let price = (reserveA/reserveB);
            console.log(price)
            let  cprice = (await purchase.getUserDetails(await addr2.getAddress()));
            console.log(cprice);
              
            let volume:number = Math.floor((2000/(price * 82 /100)));
            console.log(volume);


            amount = await ethers.parseEther(volume.toString());

            //usdt approval to purchaseContract
            await gora.connect(addr2).approve(purchase.target, amount);

            let c_voume = (await purchase.getSellTokenAmount(await ethers.parseEther(volume.toString())));
            console.log(c_voume)
            //Buy token
            await expect(purchase.connect(addr2).sell(amount)).to.emit(gora, "Burn")
                .withArgs(purchase.target, await ethers.ZeroAddress, amount);

            cprice = (await purchase.getUserDetails(await addr2.getAddress()));
            console.log(cprice);

            amount = await ethers.parseEther("100");
            //usdt transfer
            await usdt.connect(Admin).transfer(await addr2.getAddress(), amount);
            //usdt approval to purchaseContract
            await usdt.connect(addr2).approve(purchase.target, amount);
            //Buy token
            await purchase.connect(addr2).reBuy(amount);

            amount = await ethers.parseEther("25000");
            //usdt approval to purchaseContract
            await usdt.connect(Admin).approve(purchase.target, amount);

            await purchase.connect(Admin).addLiquidity(amount);

            //tokenPrice

             reserveA = parseInt(await usdt.balanceOf(lp.target));
             reserveB = parseInt((await gora.totalSupply()));

             price = (reserveA/reserveB);
            console.log(price)
              cprice = (await purchase.getUserDetails(await addr2.getAddress()));
            console.log(cprice);
              
             volume = Math.floor((200/(price * 82 /100)));
             console.log(volume);


            amount = await ethers.parseEther(volume.toString());

            //usdt approval to purchaseContract
            await gora.connect(addr2).approve(purchase.target, amount);

             c_voume = (await purchase.getSellTokenAmount(await ethers.parseEther(volume.toString())));
            console.log(c_voume)
            //Buy token
            await expect(purchase.connect(addr2).sell(amount)).to.emit(gora, "Burn")
                .withArgs(purchase.target, await ethers.ZeroAddress, amount);

                              cprice = (await purchase.getUserDetails(await addr2.getAddress()));
            console.log(cprice);
    })
})

});
