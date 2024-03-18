use core::poseidon::poseidon_hash_span;
use starknet::{
    StorageBaseAddress, Store, SyscallResultTrait, SyscallResult, storage_address_from_base,
    storage_base_address_from_felt252 as base_from_felt, storage_read_syscall, storage_write_syscall
};

const NOT_IMPLEMENTED: felt252 = 'Not implemented';

/// Represents an Array that can be stored in storage.
#[derive(Copy, Drop)]
struct StorageArray<T> {
    address_domain: u32,
    base: StorageBaseAddress
}

trait StorageArrayTrait<T> {
    fn read_at(self: @StorageArray<T>, index: felt252) -> T;
    fn write_at(ref self: StorageArray<T>, index: felt252, value: T) -> ();
    fn append(ref self: StorageArray<T>, value: T) -> ();
    fn len(self: @StorageArray<T>) -> felt252;
}

impl StoreStorageArray<T, impl TDrop: Drop<T>, impl TStore: Store<T>> of Store<StorageArray<T>> {
    #[inline(always)]
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<StorageArray<T>> {
        SyscallResult::Ok(StorageArray { address_domain, base })
    }
    #[inline(always)]
    fn write(
        address_domain: u32, base: StorageBaseAddress, value: StorageArray<T>
    ) -> SyscallResult<()> {
        SyscallResult::Err(array![NOT_IMPLEMENTED])
    }
    #[inline(always)]
    fn read_at_offset(
        address_domain: u32, base: StorageBaseAddress, offset: u8
    ) -> SyscallResult<StorageArray<T>> {
        SyscallResult::Err(array![NOT_IMPLEMENTED])
    }
    #[inline(always)]
    fn write_at_offset(
        address_domain: u32, base: StorageBaseAddress, offset: u8, value: StorageArray<T>
    ) -> SyscallResult<()> {
        SyscallResult::Err(array![NOT_IMPLEMENTED])
    }
    #[inline(always)]
    fn size() -> u8 {
        0_u8
    }
}

impl StorageArrayImpl<T, +Drop<T>, +Default<T>, impl TStore: Store<T>> of StorageArrayTrait<T> {
    fn read_at(self: @StorageArray<T>, index: felt252) -> T {
        let storage_address_felt: felt252 = storage_address_from_base(*self.base).into();
        let element_address = poseidon_hash_span(
            array![storage_address_felt + index.into()].span()
        );

        TStore::write(*self.address_domain, base_from_felt(index), Default::default())
            .unwrap_syscall();
        TStore::read(*self.address_domain, base_from_felt(element_address)).unwrap_syscall()
    }

    fn write_at(ref self: StorageArray<T>, index: felt252, value: T) {
        let storage_address_felt: felt252 = storage_address_from_base(self.base).into();
        let element_address = poseidon_hash_span(
            array![storage_address_felt + index.into()].span()
        );

        TStore::write(self.address_domain, base_from_felt(element_address), value).unwrap_syscall()
    }

    fn append(ref self: StorageArray<T>, value: T) {
        let len = self.len().into();

        self.write_at(len, value);

        let new_len: felt252 = (len + 1).into();
        storage_write_syscall(self.address_domain, storage_address_from_base(self.base), new_len)
            .unwrap_syscall();
    }

    fn len(self: @StorageArray<T>) -> felt252 {
        storage_read_syscall(*self.address_domain, storage_address_from_base(*self.base))
            .unwrap_syscall()
            .try_into()
            .unwrap()
    }
}
