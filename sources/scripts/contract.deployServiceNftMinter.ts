import { beginCell, contractAddress, toNano, TonClient4, WalletContractV4, internal, fromNano } from "@ton/ton";
import { mnemonicToPrivateKey } from "ton-crypto";
import { ServiceNftMinter } from "../output/sample_ServiceNftMinter";
(async () => {
    //create client for testnet sandboxv4 API - alternative endpoint
    const client4 = new TonClient4({
        // endpoint: "https://sandbox-v4.tonhubapi.com",
        timeout: 500000,
        endpoint: "https://mainnet-v4.tonhubapi.com",
    });
    let mnemonics ="duck lyrics aim material decade park tube spider airport price swim error reopen scorpion beauty favorite crumble gas aspect february awake slim country able"
    // let mnemonics = "test razor park gesture thank enemy bachelor change switch witness engage swing amount cradle cruise old teach lift replace drum dignity dilemma joy vicious"; // 🔴 Change to your own, by creating .env file!
    console.log(mnemonics)
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" "));
    let secretKey = keyPair.secretKey;
    let workchain = 0; //we are working in basechain.
    let deployer_wallet = WalletContractV4.create({ workchain, publicKey: keyPair.publicKey });
    let deployer_wallet_contract = client4.open(deployer_wallet);
    let init = await ServiceNftMinter.init(deployer_wallet_contract.address);
    let contactAddress = contractAddress(workchain, init);
    let deployAmount = toNano("0.05");
    let seqno: number = await deployer_wallet_contract.getSeqno();
    let balance: bigint = await deployer_wallet_contract.getBalance();
    console.log(balance)
    console.log("Your contact owner wallet address  " + keyPair.publicKey);
    console.log("Your contact owner wallet contact address  " + deployer_wallet_contract.address);
    console.log("Your contact Seqno: ", seqno + "\n");
    console.log("Your wallet balance: ", fromNano(balance).toString(), "💎TON");
    console.log("Your contactAddress address: ", contactAddress);
    await deployer_wallet_contract.sendTransfer({
        seqno,
        secretKey,
        messages: [
            internal({
                to: contactAddress,
                value: deployAmount,
                init: {
                    code: init.code,
                    data: init.data,
                },
                body: null,
            }),
        ],
    });
    console.log("Your contactAddress deploy Done:", contactAddress);
})();
