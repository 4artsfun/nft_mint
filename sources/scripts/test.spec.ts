import { toNano, beginCell, Cell } from "@ton/ton";
import {
    Blockchain,
    SandboxContract,
    TreasuryContract,
    printTransactionFees,
    prettyLogTransactions,
} from "@ton/sandbox";
import "@ton/test-utils";
// import { printSeparator } from "./utils/print";
import { CreateNftCollection, MintIdentity, NftCollection, RoyaltyParams, loadLogEventMintRecord } from "../output/sample_NftCollection";
import { ServiceNftMinter } from "../output/sample_ServiceNftMinter";
import { NftItemFinal } from "../output/sample_NftItemFinal";
import { NftUserUnique } from "../output/sample_NftUserUnique";

describe("contract", () => {
    const OFFCHAIN_CONTENT_PREFIX = 0x01;
    const string_first = "https://s.getgems.io/nft-staging/c/628f6ab8077060a7a8d52d63/";
    let newContent = beginCell().storeInt(OFFCHAIN_CONTENT_PREFIX, 8).storeStringRefTail(string_first).endCell();
    let identityFilePath = beginCell().storeInt(OFFCHAIN_CONTENT_PREFIX, 8).storeStringRefTail("https://Google.com").endCell();

    let blockchain: Blockchain;
    let user: SandboxContract<TreasuryContract>;
    let owner: SandboxContract<TreasuryContract>;
    let nftUserUnique: SandboxContract<NftUserUnique>;
    let serviceNftMinter: SandboxContract<ServiceNftMinter>;

    beforeAll(async () => {
        blockchain = await Blockchain.create();
        user = await blockchain.treasury("deployer");
        owner = await blockchain.treasury("onwner");

        let royaltiesParam: RoyaltyParams = {
            $$type: "RoyaltyParams",
            numerator: 350n, // 350n = 35%
            denominator: 1000n,
            destination: user.address,
        };

        let createNftCollection: CreateNftCollection = {
            $$type: "CreateNftCollection",
            royalty_params:royaltiesParam,
            collectionContent: newContent,
            identityFilePath: new Cell(),
        }

        serviceNftMinter = blockchain.openContract(
            await ServiceNftMinter.fromInit(owner.address)
        );

        

        // message(0x0000016) CreateNftCollection {
        //     royalty_params: RoyaltyParams;
        //     collectionContent:Cell;
        //     identityFilePath:Cell;
        // }

        // mint user NFT nftCollection 
        const deploy_result0 = await serviceNftMinter.send(owner.getSender(), { value: toNano(100) }, createNftCollection);
        expect(deploy_result0.transactions).toHaveTransaction({
            from: owner.address,
            to: serviceNftMinter.address,
            deploy: true,
            success: true,
        });
        const deploy_result1 = await serviceNftMinter.send(owner.getSender(), { value: toNano(100) }, createNftCollection);
        expect(deploy_result1.transactions).toHaveTransaction({
            from: owner.address,
            to: serviceNftMinter.address,
            deploy: false,
            success: true,
        });
        const deploy_result2 = await serviceNftMinter.send(owner.getSender(), { value: toNano(100) }, createNftCollection);
        expect(deploy_result2.transactions).toHaveTransaction({
            from: owner.address,
            to: serviceNftMinter.address,
            deploy: false,
            success: true,
        });

        let collectionAddress = await serviceNftMinter.getGetAddressByIndex(1n);

        nftUserUnique = blockchain.openContract(
            await NftUserUnique.fromInit(collectionAddress,user.address)
        );

        console.log("nftUserUnique Address: " + nftUserUnique.address.toString());


    });

    it("Test", async () => {
        let mintIdentity:MintIdentity = {
            $$type: 'MintIdentity',
            collectionIndex: 1n,
            queryId: 0n
        };
        let mintResult1 = await serviceNftMinter.send(user.getSender(), { value: toNano(1) }, mintIdentity);
        expect(mintResult1.transactions).toHaveTransaction({
            from: user.address,
            to: serviceNftMinter.address,
            success: true,
        });
        let mintResult2 = await serviceNftMinter.send(user.getSender(), { value: toNano(1) }, mintIdentity);
        // console.log(NftUserUnique.address.toString());
        expect(mintResult2.transactions).toHaveTransaction({
            from: serviceNftMinter.address,
            to: nftUserUnique.address,
            success: false,
            exitCode:4159
        });
        // console.log("Next IndexID: " + (await collection.getGetCollectionData()).next_item_index);
        // console.log("Collection Address: " + collection.address);
    });

    // it("Test Mint Record in detail", async () => {
    //     const deploy_result = await collection.send(user.getSender(), { value: toNano(1) }, "Mint"); // Send Mint Transaction
    //     printTransactionFees(deploy_result.transactions);
    //     prettyLogTransactions(deploy_result.transactions);
    // });

    // it("should deploy correctly", async () => {
    //     await collection.send(user.getSender(), { value: toNano(2) }, "Mint");

    //     let current_index = (await collection.getGetCollectionData()).next_item_index;
    //     const deploy_result = await collection.send(user.getSender(), { value: toNano(1) }, "Mint"); // Send Mint Transaction
    //     expect(deploy_result.transactions).toHaveTransaction({
    //         from: user.address,
    //         to: collection.address,
    //         success: true,
    //     });
    //     let next_index = (await collection.getGetCollectionData()).next_item_index;
    //     expect(next_index).toEqual(current_index + 1n);
    //     // printSeparator();

    //     console.log("External Message(string - base64): " + deploy_result.externals[0].body.toBoc().toString("base64"));
    //     console.log("External Message(string - hex): " + deploy_result.externals[0].body.toBoc().toString("hex"));
    //     // printSeparator();

    //     // Print the Log Event of the Mint Record
    //     let loadEvent = loadLogEventMintRecord(deploy_result.externals[0].body.asSlice());
    //     console.log("ItemId: " + loadEvent.item_id);
    //     console.log("The Random Number: " + loadEvent.generate_number);
    // });
});
