#[starknet::contract]
mod GreedySadMan {
    use ctf::storage_array::{StorageArray, StorageArrayTrait};

    #[storage]
    struct Storage {
        donations: StorageArray<felt252>,
        sadness: bool
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let mut donations = self.donations.read();
        donations.append(1);

        // :(
        self.sadness.write(true);
    }

    #[abi(embed_v0)]
    impl IGreedySadManImpl of super::IGreedySadMan<ContractState> {
        fn donate(ref self: ContractState, amount: felt252) {
            let mut donations = self.donations.read();
            donations.append(amount);
        }

        fn get_donation_by_index(self: @ContractState, index: felt252) -> felt252 {
            let donations = self.donations.read();
            donations.read_at(index)
        }

        fn get_sadness(self: @ContractState) -> bool {
            self.sadness.read()
        }
    }
}

#[starknet::interface]
trait IGreedySadMan<TContractState> {
    fn donate(ref self: TContractState, amount: felt252);
    fn get_donation_by_index(self: @TContractState, index: felt252) -> felt252;
    fn get_sadness(self: @TContractState) -> bool;
}
