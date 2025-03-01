import {ethers} from 'hardhat';

const main = async () => {
    const [] = await ethers.getSigners();

    const piggyFactory = await ethers.getContractFactory("PiggyFactory");
    console.log("Deploying Piggy Factory Contract...");  
    const piggy = await piggyFactory.deploy();

    console.log("Piggy Factory Contract deployed to:", piggy.target );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});