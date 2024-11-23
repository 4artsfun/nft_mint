import "@stdlib/deploy";
import "./message.tact";

contract NftUserUnique {
    collection_address: Address;
    wallet_address: Address;
    is_initialized: Bool;
    init(collection_address: Address, wallet: Address){
        self.collection_address = collection_address;
        self.wallet_address = wallet;
        self.is_initialized = false;
    }
    // check the user has mint this kind of NFT.
    receive(msg: MintCollectionMessage){
        if (!self.is_initialized) {
            //if not. start to send message to NFT_COLLECTION to invoke mint.
            send(SendParameters{
                    to: self.collection_address,
                    value: 0,
                    bounce: false,
                    mode: SendRemainingValue,
                    body: msg.toCell()
                }
            );
            self.is_initialized = true;
        }else{
            send(SendParameters{
                     to: msg.nftOwner,
                     value: 0,
                     bounce: false,
                     mode: SendRemainingValue,
                     body: "nft identity repeat".asComment()
            });
        }
    }
}