# Cosign: mutli-signatures for Ethereum

Unlike Bitcoin and other cryptocurrencies, Ethereum doesn't implement a
[multisignatures](http://bitcoin.stackexchange.com/questions/3718/what-are-multi-signature-transactions)
feature. Instead Ethereum provide a
[turing-complete](http://en.wikipedia.org/wiki/Turing_completeness) scripting
language with which we can build whatever we want (including multisigs).

[See the lisp-like version of the contract](/contract.lisp).

## Contract persistent storage

```lisp
[[0]]           ; Number of participants (n < 256)
[[1]]           ; Number of signatures required to accept a transaction
[[2]]           ; Number of transaction proposals
[[3]]           ; Amount of money frozen in pending transactions


[[10]]          ; Participant n°0 address
[[11]]          ; Participant n°1 address
[[12]]          ; Participant n°2 address
[[10+i]]        ; Participant n°i address (i < n)


[[1000]]        ; Transaction n°0: state
[[1001]]        ; Transaction n°0: receiver
[[1002]]        ; Transaction n°0: amount
[[1003]]        ; Transaction n°0: accept votes
[[1004]]        ; Transaction n°0: reject votes


[[t*10+1000]]   ; Transaction n°t: state
[[t*10+1001]]   ; Transaction n°t: receiver
[[t*10+1002]]   ; Transaction n°t: amount
[[t*10+1003]]   ; Transaction n°t: accept votes
[[t*10+1004]]   ; Transaction n°t: reject votes
```

Keys prior to 100 must be set in the initialization block. Keys `0`, `1`, and
in the `[10, 999]` range are immutable.

In the transaction storage (ie keys >= 1000) the following symbols represent:

* __state__:
  * `0x01` pending
  * `0x02` accepted
  * `0x03` rejected
* __receiver__: ethereum address
* __amount__: integer, number of wei (`0` => suicide)
* __accept votes__: a bitwise number. Imagine that voter 0 and 3 voted "accept",
  and other participants hasn't voted yet. We encode that state as
  `2^0 + 2^3 = 0000...0001001`. That's why we have a 255 voters limit.
* __reject votes__: same as "accept votes" but for "reject"

## Possible contract calls

### Propose

```
0x00: 0x01
0x20: address
0x40: amount (0 = suicide)
```

### Accept

```
0x00: 0x02
0x20: transactionId
```

### Reject

```
0x00: 0x03
0x20: transactionId
```

## Contributing

Contributions are welcome, whether it is for a
[bug report](https://github.com/mquandalle/ethereum-cosign/issues/new), a fix or
a new functionality proposition. Both the contract and the Ðapp are published
under the [MIT license](/LICENSE). Take a look at the [Todo list](/TODO.md).

### Modifying the Ðapp (XXX Not yet)

The Cosign Ðapp associate to the contract is built using the
[Meteor](https://www.meteor.com) framework. If you want to contribute,

1. Install Meteor
   ```
   $ curl https://install.meteor.com/ | sh
   ```
2. Download the application
   ```
   git clone https://github.com/mquandalle/ethereum-cosign
   ```
3. Start the app
   ```
   cd ethereum-cosign && meteor
   ```

### Tips

If you want to buy me a beer, I proudly accept bitcoin tips:
[1Jade7Fscsx2bF13iFVVFvcSUhe7eLJgSy](https://blockchain.info/address/1Jade7Fscsx2bF13iFVVFvcSUhe7eLJgSy)
