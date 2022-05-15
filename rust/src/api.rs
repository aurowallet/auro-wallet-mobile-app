
#[path = "./transaction.rs"]
mod transaction;

use rand;
use transaction::Transaction;
use mina_signer::{BaseField, Keypair, NetworkId, PubKey, ScalarField, Signer};

pub fn hi(name: String) -> String {
    return "hi,".to_string() + &name;
}

pub fn sign() -> String {
    let keypair = Keypair::rand(&mut rand::rngs::OsRng);

    let tx = Transaction::new_payment(
                    keypair.public,
                    PubKey::from_address("B62qicipYxyEHu7QjUqS7QvBipTs5CzgkYZZZkPoKVYBu6tnDUcE9Zt").expect("invalid receiver address"),
                    1729000000000,
                    2000000000,
                    271828,
                );
    
    let mut ctx = mina_signer::create_legacy::<Transaction>(NetworkId::TESTNET);
    let sig = ctx.sign(&keypair, &tx);
    return sig.to_string();
}