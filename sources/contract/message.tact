import "./message.tact";

message LogEventMintRecord {
    minter: Address;
    item_id: Int;
    generate_number: Int;
}


message(0x693d3950) GetRoyaltyParams {
    query_id: Int as uint64;
}
message(0xa8cb00ad) ReportRoyaltyParams {
    query_id: Int as uint64;
    numerator: Int as uint16;
    denominator: Int as uint16;
    destination: Address;
}
struct CollectionData {
    next_item_index: Int;
    collection_content: Cell;
    owner_address: Address;
}
struct RoyaltyParams {
    numerator: Int;
    denominator: Int;
    destination: Address;
}
message(0x5fcc3d14) Transfer {
    query_id: Int as uint64;
    new_owner: Address;
    response_destination: Address?;
    custom_payload: Cell?;
    forward_amount: Int as coins;
    forward_payload: Slice as remaining;

}
message(0x05138d91) OwnershipAssigned {
    query_id: Int as uint64;
    prev_owner: Address;
    forward_payload: Slice as remaining;
}
message(0xd53276db) Excesses {
    query_id: Int as uint64;
}
message(0x2fcb26a2) GetStaticData {
    query_id: Int as uint64;
}
message(0x8b771735) ReportStaticData {
    query_id: Int as uint64;
    index_id: Int;
    collection: Address;
}
struct GetNftData {
    is_initialized: Bool;
    index: Int;
    collection_address: Address;
    owner_address: Address;
    individual_content: Cell;
}



message CreateJettonRoot {
    init_data: Slice;
}
message(0x0000016) CreateNftCollection {
    royalty_params: RoyaltyParams;
    collectionContent:Cell;
    identityFilePath:Cell;
}
message UpdateNftCollection {
    index:Int as int8;
    identityFilePath:Cell;
}
message CollectionOwnerUpdate {
    index:Int as int8;
    address:Address;
}
message MinterOwnerUpdate {
    address:Address;
}
message WithCollection {
    index:Int as int8;
}
message MintIdentity {
    collectionIndex: Int as int8;
    queryId:Int as  uint64;
}
message(0x0000014)MintWorks {
    queryId:Int as  uint64;
    collectionIndex: Int as int8;
    metaDataFilePath: Cell;
}
message(0x0000015) MintCollectionMessage{
    queryId:Int as uint64;
    nftOwner:Address;
    metaDataFilePath:Cell;
    forward_amount: Int as coins;
}
message(0x0000017) MintCollectionOwnerUpdateMessage{
    address:Address;
}
message(0x0000018) MintCollectionwithdrawalMessage{
    address:Address;
}

