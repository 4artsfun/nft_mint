import "./message.tact";
import "./NftItemFinal.tact";
import "@stdlib/deploy";
const minTonsForStorage: Int = ton("0.02");
const gasConsumption: Int = ton("0.02");

contract NftCollection {
    next_item_index: Int as uint32 = 0;
    owner_address: Address;
    response_address: Address;
    royalty_params: RoyaltyParams?;
    collection_content: Cell;
    minterIndex:Int as int8 ;


    init(owner_address: Address, response_address:Address,collection_content: Cell, royalty_params: RoyaltyParams,minterIndex:Int){
        self.owner_address = owner_address;
        self.collection_content = collection_content;
        self.royalty_params = royalty_params;
        self.response_address = response_address;
        self.minterIndex=minterIndex;
    }
    receive(miniMsg:MintCollectionMessage){
        let ctx: Context = context(); // get sender Info
        let msgValue: Int = ctx.value;
        let tonBalanceBeforeMsg: Int = myBalance() - msgValue;
        let storageFee: Int = minTonsForStorage - min(tonBalanceBeforeMsg, minTonsForStorage);
        msgValue = msgValue - (storageFee + gasConsumption);
        self.mint(msgValue,miniMsg);
        emit(LogEventMintRecord{ minter: sender(), item_id: self.next_item_index, generate_number: nativeRandom() }.toCell());
    }

    // ===== Private Methods ===== //
    fun mint(msgValue: Int,miniMsg:MintCollectionMessage) {
        require(self.next_item_index >= 0, "non-sequential NFTs");
        let nft_init: StateInit = self.getNftItemInit(self.next_item_index);
        send(SendParameters{
        to: contractAddress(nft_init),
        value: msgValue,
        bounce: false,
        mode: SendIgnoreErrors,
        body: Transfer {
            query_id: miniMsg.queryId,
            new_owner: miniMsg.nftOwner,
            response_destination: miniMsg.nftOwner,
            custom_payload: miniMsg.metaDataFilePath,
            forward_amount: miniMsg.forward_amount,
            forward_payload: emptySlice()
            }.toCell(),
            code: nft_init.code,
            data: nft_init.data
        });
        // dump(self.next_item_index); // Reference at: https://tact-by-example.org/03-emit
        self.next_item_index = self.next_item_index + 1;
    }
    receive(msg: GetRoyaltyParams) {
        let ctx: Context = context(); // get sender Info
        send(SendParameters{
            to: ctx.sender,
            value: 0,
            mode: 64,
            bounce: false,
            body: ReportRoyaltyParams {
            query_id: msg.query_id,
            numerator:  (self.royalty_params!!).numerator,
            denominator: (self.royalty_params!!).denominator,
            destination: self.owner_address
            }.toCell()
        });
    }

    // ------------------ Get Function  ------------------ //
    get fun get_collection_data(): CollectionData {
        return CollectionData{
            next_item_index: self.next_item_index,
            collection_content:self.collection_content.asSlice().loadRef(),
            owner_address: self.owner_address
        };
    }

    get fun get_nft_address_by_index(item_index: Int): Address?{
        let initCode: StateInit = self.getNftItemInit(item_index);
        return contractAddress(initCode);
    }

    get fun getNftItemInit(item_index: Int): StateInit {
        return initOf NftItemFinal(myAddress(), item_index);
    }
    //Item会调用这个方法，用来寻找他metaData
    get fun get_nft_content(index: Int, individual_content: Cell): Cell {
     let cs:Slice=self.collection_content.beginParse();
        cs.loadRef();
     let common_content:Slice=cs.loadRef().beginParse();
      return beginCell()
        .storeUint(1, 8)
        .storeSlice(common_content)
        .storeRef(individual_content)
        .endCell();
    }

    get fun royalty_params(): RoyaltyParams {
        return self.royalty_params!!;
    }

    /*
     *  接受直接充值
     */
    receive() {

    }
    /*
   *  提现NftMinter的到拥有者
   */
    receive( msg:MintCollectionwithdrawalMessage) {
        let ctx: Context = context();
        require(ctx.sender == self.owner_address, "Invalid sender");
        send(SendParameters{
            to: msg.address,
            mode:SendRemainingBalance,
            value:myBalance(),
            body:beginString()
            .concat("withMinter")
            .toString().asComment()
        });
    }
    /*
    *  修改NftCollection的拥有者
    */
    receive( msg:MintCollectionOwnerUpdateMessage) {
        require(sender() == self.owner_address, "Invalid sender");
        self.owner_address=msg.address;
    }
}
