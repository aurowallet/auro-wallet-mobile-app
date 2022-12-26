
#[path = "./transaction.rs"]
mod transaction;

use num_bigint::BigUint;
use rand;
use transaction::Transaction;
use mina_signer::{BaseField, Keypair, NetworkId, PubKey, ScalarField, Signer};
use o1_utils::field_helpers::FieldHelpers;

pub fn getAddressFromSecretHex(secret_hex: String) -> String {
    let keypair =  Keypair::from_hex(&secret_hex).expect("failed to create keypair");
    return keypair.get_address();
}

pub fn signPayment(
    secret_hex: String, 
    to: String, 
    amount: u64, 
    fee: u64,
    nonce: u32,
    valid_until: u32,
    memo: String,
    network_id: u8
    ) -> SignatureData {
        let keypair = Keypair::from_hex(&secret_hex).expect("failed to create keypair");
        let mut tx = Transaction::new_payment(
            keypair.public,
            PubKey::from_address(&to).expect("invalid receiver address"),
            amount,
            fee,
            nonce,
        );
        tx = tx.set_valid_until(valid_until).set_memo_str(&memo);
        let net_id = match network_id {
            0 => NetworkId::TESTNET,
            1 => NetworkId::MAINNET,
            _ => NetworkId::TESTNET
        };
        let mut ctx = mina_signer::create_legacy::<Transaction>(net_id);
        let sig = ctx.sign(&keypair, &tx);
        return SignatureData {
            field: BigUint::from_bytes_le(&sig.rx.to_bytes()).to_str_radix(10),
            scalar: BigUint::from_bytes_le(&sig.s.to_bytes()).to_str_radix(10)
        };
}

pub fn signDelegation(
    secret_hex: String,
    to: String,
    fee: u64,
    nonce: u32,
    valid_until: u32,
    memo: String,
    network_id: u8
    ) -> SignatureData {
        let keypair = Keypair::from_hex(&secret_hex).expect("failed to create keypair");
        let mut tx = Transaction::new_delegation(
            keypair.public,
            PubKey::from_address(&to).expect("invalid receiver address"),
            fee,
            nonce,
        );
        tx = tx.set_valid_until(valid_until).set_memo_str(&memo);
        let net_id = match network_id {
            0 => NetworkId::TESTNET,
            1 => NetworkId::MAINNET,
            _ => NetworkId::TESTNET
        };
        let mut ctx = mina_signer::create_legacy::<Transaction>(net_id);
        let sig = ctx.sign(&keypair, &tx);
        return SignatureData {
            field: BigUint::from_bytes_le(&sig.rx.to_bytes()).to_str_radix(10),
            scalar: BigUint::from_bytes_le(&sig.s.to_bytes()).to_str_radix(10)
        };
}

#[derive(Debug, Clone)]
pub struct SignatureData {
    pub field: String,
    pub scalar: String,
}