## Solution

Greedy Sad Man is a Cairo challenge that presents a simple contract representing a person accepting donations.
As the description states, the objective is to set a `sadness` storage member to false.

Looking at the contract source code, we see that the implementation is short and simple, containing only three external
methods, of which only one seems to modify the state, the `donate` one. Since we have another file in the challenge where
a `StorageArray` type is implemented, and this type is used for the donations register, we can assume the clue should
be there. In this file, at line 59 in the `read_at` implementation we see something weird, which is a `TStore::write`
in a method that is supposed to read, we have our clue. The method is writing to storage the default value of the
generic `T` in the `index` position.

Back to our main contract, we see that the method using `read_at` is `get_donation_by_index`, and we can set the index.
We also see that `donations` is a `StorageArray<felt252>`, and since the default for `felt252` is `0`, if we pass
the position of the `sadness` storage member as `index`, the value of it will be set to `0`, which is `false` in
bool representation. All we have left is to find what is the right index to pass, which as mentioned is the storage
address of `sadness`, being this the `sn_keccak('sadness')`, which can be computed in Cairo using the `selector!` macro.

The solution is then calling `get_donation_by_index(selector!('sadness'))`.

Note that in Cairo, storage can be written to, even when the external function seems to be readonly (having `self: @ContractState` as first parameter).