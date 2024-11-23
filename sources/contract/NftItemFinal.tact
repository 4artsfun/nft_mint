import "@stdlib/deploy";
import "./message.tact";
contract NftItemFinal {
    collection_address: Address;
    item_index: Int;
    is_initialized: Bool;
    owner: Address?;
    individual_content: Cell?;
    init(collection_address: Address, item_index: Int){
        require(sender() == collection_address, "not from collection");
        self.collection_address = collection_address;
        self.item_index = item_index;
        self.is_initialized = false;
    }
    receive(msg: Transfer){
        let ctx: Context = context(); // Reference: https://docs.tact-lang.org/language/ref/common#context
        let msgValue: Int = self.msgValue(ctx.value);
        if (self.is_initialized == false) {  // Initial Transfer, aka the "Minting" of the NFT
            require(ctx.sender == self.collection_address, "initialized tx need from collection");
            self.is_initialized = true;
            self.owner = msg.new_owner;
            self.individual_content = msg.custom_payload;
            send(SendParameters{
            to: msg.response_destination!!,
            value: msgValue,
            mode: SendPayGasSeparately,
            body: Excesses { query_id: msg.query_id }.toCell()
            });
        } else {
            self.reply("This NFT cannot be transferred".asComment());//The contract parameters are illegal
        }
    }

    receive(msg: GetStaticData){
        let ctx: Context = context();
        send(SendParameters {
        to: ctx.sender,
        value: 0,
        mode: 64,  // (return msg amount except gas fees)
        bounce: true,
        body: ReportStaticData{
        query_id: msg.query_id,
        index_id: self.item_index,
        collection: self.collection_address
        }.toCell()
        });
    }

    fun msgValue(value: Int): Int {
        let tonBalanceBeforeMsg: Int = myBalance() - value;
        let storageFee: Int = minTonsForStorage - min(tonBalanceBeforeMsg, minTonsForStorage);
        return value - (storageFee + gasConsumption);
    }

    // --------- Get Function  --------- //
    get fun get_nft_data(): GetNftData {
        return GetNftData {
            is_initialized: self.is_initialized,
            index: self.item_index,
            collection_address: self.collection_address,
            owner_address: self.owner!!,
            individual_content:self.individual_content!!
        };
    }
}
